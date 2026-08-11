r"""
Inteligência de Estoque - Rede de Varejo Esportivo

Objetivo
--------
Consolidar o saldo da rede, identificar produtos abaixo do estoque mínimo,
medir giro e cobertura recente, auditar a qualidade da base e gerar relatórios
e gráficos executivos para priorização de reposição.

Execução recomendada no VS Code / PowerShell
---------------------------------------------
    .\.venv\Scripts\python.exe .\asdf.py

Também é possível usar o Python Launcher do Windows:
    py .\asdf.py --janela-dias 90 --top 10 --saida saidas

Premissas importantes
---------------------
- Estoque Mínimo é um parâmetro por produto para o total da rede.
- Saldo_Atual é a soma líquida das movimentações, assumindo saldo inicial zero.
- Métricas chamadas de "potencial perdido" são mantidas por compatibilidade,
  mas representam proxies do gap de reposição, não perdas contábeis realizadas.
"""

from __future__ import annotations

import argparse
import sys
import textwrap
import time
from io import BytesIO
from pathlib import Path
from typing import Sequence

import matplotlib
import numpy as np
import pandas as pd

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import FuncFormatter


# -----------------------------------------------------------------------------
# Configuração e contratos de dados
# -----------------------------------------------------------------------------

PASTA_BASE = Path(__file__).resolve().parent
PASTA_SAIDA_PADRAO = PASTA_BASE / "saidas"

ARQUIVO_EXCEL = PASTA_BASE / "BaseDados.xlsx"
ARQUIVO_ESTOQUE_MIN = PASTA_BASE / "EstoqueMin.csv"
CSV_ESTOQUE = PASTA_BASE / "fEstoque.csv"
CSV_LOJA = PASTA_BASE / "dLoja.csv"
CSV_PRODUTO = PASTA_BASE / "dProduto.csv"

COL_MOVIMENTACAO = "Movimentação"
COL_ESTOQUE_MINIMO = "Estoque Mínimo"
COL_PRECO_UNIT = "Preço Unit"
COL_CUSTO_UNIT = "Custo Unit"

STATUS_ABAIXO = "Abaixo do Mínimo"
STATUS_SEGURO = "Estoque Seguro"

CRITICIDADE_ORDEM = {
    "CRÍTICO": 0,
    "ALTO": 1,
    "ATENÇÃO": 2,
    "SAUDÁVEL": 3,
    "SEM PARÂMETRO": 4,
}

CORES_CRITICIDADE = {
    "CRÍTICO": "#B42318",
    "ALTO": "#E56B1F",
    "ATENÇÃO": "#F2B134",
    "SAUDÁVEL": "#2E7D5B",
    "SEM PARÂMETRO": "#7A869A",
}

# 160 DPI mantém boa nitidez para apresentação e reduz sensivelmente o tempo
# e a memória de renderização do painel executivo 18 × 12.
DPI_GRAFICOS = 160


def configurar_terminal_utf8() -> None:
    """Evita caracteres quebrados no PowerShell/terminal integrado do VS Code."""
    for nome_stream in ("stdout", "stderr"):
        stream = getattr(sys, nome_stream, None)
        if stream is not None and hasattr(stream, "reconfigure"):
            try:
                stream.reconfigure(encoding="utf-8")
            except (AttributeError, OSError):
                pass


def inteiro_positivo(valor: str) -> int:
    numero = int(valor)
    if numero <= 0:
        raise argparse.ArgumentTypeError("o valor deve ser maior que zero")
    return numero


def criar_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Análise executiva de estoque da rede de varejo esportivo."
    )
    parser.add_argument(
        "--janela-dias",
        type=inteiro_positivo,
        default=90,
        help="janela de demanda em dias, encerrada na última data da base (padrão: 90)",
    )
    parser.add_argument(
        "--top",
        type=inteiro_positivo,
        default=10,
        help="quantidade de itens exibidos nos rankings do terminal e painel (padrão: 10)",
    )
    parser.add_argument(
        "--saida",
        type=Path,
        default=Path("saidas"),
        help="pasta de saída, relativa à pasta do script ou absoluta (padrão: saidas)",
    )
    return parser


# -----------------------------------------------------------------------------
# Leitura, padronização e validação
# -----------------------------------------------------------------------------

def limpar_colunas(df: pd.DataFrame) -> pd.DataFrame:
    """Remove espaços, BOM e caracteres invisíveis dos nomes das colunas."""
    df = df.copy()
    df.columns = (
        df.columns.astype(str)
        .str.replace("\ufeff", "", regex=False)
        .str.strip()
    )
    return df


def ler_csv_inteligente(caminho: Path) -> pd.DataFrame:
    """Lê CSV UTF-8 detectando vírgula, ponto e vírgula ou tabulação."""
    if not caminho.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {caminho}")
    try:
        df = pd.read_csv(
            caminho,
            sep=None,
            engine="python",
            encoding="utf-8-sig",
        )
    except (UnicodeDecodeError, pd.errors.ParserError) as erro:
        raise ValueError(f"Falha ao ler o CSV {caminho.name}: {erro}") from erro
    return limpar_colunas(df)


def identificar_fonte_dados() -> str:
    csvs = (CSV_ESTOQUE, CSV_LOJA, CSV_PRODUTO)
    existentes = [caminho.exists() for caminho in csvs]

    if not ARQUIVO_ESTOQUE_MIN.exists():
        raise FileNotFoundError(
            f"Arquivo obrigatório não encontrado: {ARQUIVO_ESTOQUE_MIN}"
        )

    if all(existentes):
        return "CSVs separados"

    if any(existentes):
        faltantes = [
            caminho.name
            for caminho, existe in zip(csvs, existentes)
            if not existe
        ]
        raise FileNotFoundError(
            "Conjunto parcial de CSVs encontrado. Inclua todos os arquivos "
            f"fEstoque.csv, dLoja.csv e dProduto.csv. Faltantes: {faltantes}"
        )

    if ARQUIVO_EXCEL.exists():
        return "BaseDados.xlsx"

    raise FileNotFoundError(
        "Não encontrei os três CSVs separados nem o arquivo BaseDados.xlsx."
    )


def carregar_dados() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Carrega fato, dimensões e parâmetros, priorizando os CSVs completos."""
    fonte = identificar_fonte_dados()

    if fonte == "CSVs separados":
        df_estoque = ler_csv_inteligente(CSV_ESTOQUE)
        df_loja = ler_csv_inteligente(CSV_LOJA)
        df_produto = ler_csv_inteligente(CSV_PRODUTO)
    else:
        try:
            excel = pd.ExcelFile(ARQUIVO_EXCEL)
        except (ValueError, OSError) as erro:
            raise ValueError(f"Falha ao abrir {ARQUIVO_EXCEL.name}: {erro}") from erro

        abas_obrigatorias = {"fEstoque", "dLoja", "dProduto"}
        abas_faltantes = sorted(abas_obrigatorias - set(excel.sheet_names))
        if abas_faltantes:
            excel.close()
            raise ValueError(
                f"Abas ausentes em {ARQUIVO_EXCEL.name}: {abas_faltantes}"
            )

        try:
            df_estoque = limpar_colunas(pd.read_excel(excel, sheet_name="fEstoque"))
            df_loja = limpar_colunas(pd.read_excel(excel, sheet_name="dLoja"))
            df_produto = limpar_colunas(pd.read_excel(excel, sheet_name="dProduto"))
        finally:
            excel.close()

    df_minimo = ler_csv_inteligente(ARQUIVO_ESTOQUE_MIN)
    return df_estoque, df_loja, df_produto, df_minimo


def validar_colunas(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> None:
    """Valida o contrato mínimo de cada tabela antes das conversões."""
    exigidas = {
        "fEstoque": {"ID Produto", "Data", "ID Loja", COL_MOVIMENTACAO, "Tipo"},
        "dLoja": {"ID Loja", "Loja", "Bairro"},
        "dProduto": {
            "ID Produto",
            "Produto",
            "Categoria",
            "Subcategoria",
            COL_CUSTO_UNIT,
            COL_PRECO_UNIT,
        },
        "EstoqueMin": {"ID Produto", COL_ESTOQUE_MINIMO},
    }
    tabelas = {
        "fEstoque": df_estoque,
        "dLoja": df_loja,
        "dProduto": df_produto,
        "EstoqueMin": df_minimo,
    }

    erros = []
    for nome, colunas_obrigatorias in exigidas.items():
        faltantes = sorted(colunas_obrigatorias - set(tabelas[nome].columns))
        if faltantes:
            erros.append(f"{nome}: colunas ausentes: {faltantes}")

    if erros:
        raise ValueError("Problemas de estrutura encontrados:\n- " + "\n- ".join(erros))


def _converter_numerico_estrito(
    df: pd.DataFrame,
    coluna: str,
    nome_tabela: str,
    inteiro: bool = False,
) -> None:
    convertido = pd.to_numeric(df[coluna], errors="coerce")
    invalidos = convertido.isna()
    if invalidos.any():
        exemplos = df.loc[invalidos, coluna].head(5).tolist()
        raise ValueError(
            f"{nome_tabela}.{coluna}: {int(invalidos.sum())} valor(es) "
            f"nulo(s) ou inválido(s). Exemplos: {exemplos}"
        )

    if inteiro and convertido.mod(1).ne(0).any():
        exemplos = convertido[convertido.mod(1).ne(0)].head(5).tolist()
        raise ValueError(
            f"{nome_tabela}.{coluna}: identificadores devem ser inteiros. "
            f"Exemplos: {exemplos}"
        )

    df[coluna] = convertido.astype("int64") if inteiro else convertido.astype("float64")


def tratar_tipos(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Converte tipos sem transformar valores inválidos silenciosamente em zero."""
    df_estoque = df_estoque.copy()
    df_loja = df_loja.copy()
    df_produto = df_produto.copy()
    df_minimo = df_minimo.copy()

    for df, coluna, tabela in (
        (df_estoque, "ID Produto", "fEstoque"),
        (df_estoque, "ID Loja", "fEstoque"),
        (df_loja, "ID Loja", "dLoja"),
        (df_produto, "ID Produto", "dProduto"),
        (df_minimo, "ID Produto", "EstoqueMin"),
    ):
        _converter_numerico_estrito(df, coluna, tabela, inteiro=True)

    _converter_numerico_estrito(df_estoque, COL_MOVIMENTACAO, "fEstoque")
    _converter_numerico_estrito(df_produto, COL_CUSTO_UNIT, "dProduto")
    _converter_numerico_estrito(df_produto, COL_PRECO_UNIT, "dProduto")
    _converter_numerico_estrito(df_minimo, COL_ESTOQUE_MINIMO, "EstoqueMin")

    datas = pd.to_datetime(df_estoque["Data"], errors="coerce")
    datas_invalidas = datas.isna()
    if datas_invalidas.any():
        exemplos = df_estoque.loc[datas_invalidas, "Data"].head(5).tolist()
        raise ValueError(
            f"fEstoque.Data: {int(datas_invalidas.sum())} data(s) inválida(s). "
            f"Exemplos: {exemplos}"
        )
    df_estoque["Data"] = datas
    df_estoque["Tipo"] = df_estoque["Tipo"].astype("string").str.upper().str.strip()

    for df, colunas in (
        (df_loja, ("Loja", "Bairro")),
        (df_produto, ("Produto", "Categoria", "Subcategoria")),
    ):
        for coluna in colunas:
            df[coluna] = df[coluna].astype("string").str.strip()

    return df_estoque, df_loja, df_produto, df_minimo


def validar_integridade(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> None:
    """Aplica regras de integridade que impedem resultados analíticos confiáveis."""
    erros: list[str] = []

    for nome, df in (
        ("fEstoque", df_estoque),
        ("dLoja", df_loja),
        ("dProduto", df_produto),
        ("EstoqueMin", df_minimo),
    ):
        if df.empty:
            erros.append(f"{nome} está vazia")

    for nome, df, chave in (
        ("dLoja", df_loja, "ID Loja"),
        ("dProduto", df_produto, "ID Produto"),
        ("EstoqueMin", df_minimo, "ID Produto"),
    ):
        duplicadas = int(df.duplicated(chave).sum())
        if duplicadas:
            erros.append(f"{nome}: {duplicadas} chave(s) duplicada(s) em {chave}")

    tipos_inesperados = sorted(
        str(valor) for valor in set(df_estoque["Tipo"].dropna()) - {"E", "S"}
    )
    if tipos_inesperados or df_estoque["Tipo"].isna().any():
        erros.append(f"fEstoque.Tipo contém valores inesperados: {tipos_inesperados}")

    entradas_negativas = int(
        ((df_estoque["Tipo"] == "E") & (df_estoque[COL_MOVIMENTACAO] < 0)).sum()
    )
    saidas_nao_negativas = int(
        ((df_estoque["Tipo"] == "S") & (df_estoque[COL_MOVIMENTACAO] >= 0)).sum()
    )
    if entradas_negativas:
        erros.append(f"fEstoque: {entradas_negativas} entrada(s) com valor negativo")
    if saidas_nao_negativas:
        erros.append(f"fEstoque: {saidas_nao_negativas} saída(s) com valor não negativo")

    for nome_coluna, serie in (
        (f"dProduto.{COL_CUSTO_UNIT}", df_produto[COL_CUSTO_UNIT]),
        (f"dProduto.{COL_PRECO_UNIT}", df_produto[COL_PRECO_UNIT]),
        (f"EstoqueMin.{COL_ESTOQUE_MINIMO}", df_minimo[COL_ESTOQUE_MINIMO]),
    ):
        negativos = int(serie.lt(0).sum())
        if negativos:
            erros.append(f"{nome_coluna}: {negativos} valor(es) negativo(s)")

    for nome, df, colunas in (
        ("dLoja", df_loja, ("Loja", "Bairro")),
        ("dProduto", df_produto, ("Produto", "Categoria", "Subcategoria")),
    ):
        for coluna in colunas:
            invalidos = df[coluna].isna() | df[coluna].eq("")
            if invalidos.any():
                erros.append(
                    f"{nome}.{coluna}: {int(invalidos.sum())} valor(es) vazio(s)"
                )

    produtos_orfaos = sorted(set(df_estoque["ID Produto"]) - set(df_produto["ID Produto"]))
    lojas_orfas = sorted(set(df_estoque["ID Loja"]) - set(df_loja["ID Loja"]))
    produtos_sem_minimo = sorted(set(df_produto["ID Produto"]) - set(df_minimo["ID Produto"]))
    minimos_sem_produto = sorted(set(df_minimo["ID Produto"]) - set(df_produto["ID Produto"]))

    if produtos_orfaos:
        erros.append(f"fEstoque contém produtos sem cadastro: {produtos_orfaos[:10]}")
    if lojas_orfas:
        erros.append(f"fEstoque contém lojas sem cadastro: {lojas_orfas[:10]}")
    if produtos_sem_minimo:
        erros.append(f"Produtos sem estoque mínimo: {produtos_sem_minimo[:10]}")
    if minimos_sem_produto:
        erros.append(f"Estoques mínimos sem produto cadastrado: {minimos_sem_produto[:10]}")

    if erros:
        raise ValueError("Falha de integridade dos dados:\n- " + "\n- ".join(erros))


def auditar_movimentacoes(df_estoque: pd.DataFrame) -> pd.DataFrame:
    """Resume volume, amplitude e saldo das movimentações por tipo."""
    return (
        df_estoque.groupby("Tipo", dropna=False)
        .agg(
            Qtde_Linhas=(COL_MOVIMENTACAO, "size"),
            Movimentos_Zero=(COL_MOVIMENTACAO, lambda serie: int(serie.eq(0).sum())),
            Menor_Movimentacao=(COL_MOVIMENTACAO, "min"),
            Maior_Movimentacao=(COL_MOVIMENTACAO, "max"),
            Soma_Movimentacao=(COL_MOVIMENTACAO, "sum"),
        )
        .reset_index()
    )


def auditar_qualidade(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> pd.DataFrame:
    """Cria uma trilha de auditoria sem excluir registros potencialmente legítimos."""
    linhas: list[dict[str, object]] = []

    def adicionar(
        categoria: str,
        indicador: str,
        valor: int | float,
        status: str,
        detalhe: str,
    ) -> None:
        linhas.append(
            {
                "Categoria": categoria,
                "Indicador": indicador,
                "Valor": valor,
                "Status": status,
                "Detalhe": detalhe,
            }
        )

    duplicatas_exatas = int(df_estoque.duplicated().sum())
    movimentos_zero = int(df_estoque[COL_MOVIMENTACAO].eq(0).sum())
    contagens_chave = df_estoque.groupby(["Data", "ID Loja", "ID Produto"]).size()
    excesso_chave = int((contagens_chave - 1).clip(lower=0).sum())
    precos_abaixo_custo = int(
        df_produto[COL_PRECO_UNIT].lt(df_produto[COL_CUSTO_UNIT]).sum()
    )
    combinacoes_observadas = len(
        df_estoque[["ID Loja", "ID Produto"]].drop_duplicates()
    )
    combinacoes_possiveis = df_loja["ID Loja"].nunique() * df_produto["ID Produto"].nunique()

    adicionar(
        "Volume",
        "Movimentacoes_Analisadas",
        len(df_estoque),
        "OK",
        "Quantidade total de linhas da tabela fato.",
    )
    adicionar(
        "Qualidade",
        "Duplicatas_Exatas",
        duplicatas_exatas,
        "AVISO" if duplicatas_exatas else "OK",
        "Preservadas: não existe ID de transação para confirmar duplicidade indevida.",
    )
    adicionar(
        "Qualidade",
        "Movimentos_Zerados",
        movimentos_zero,
        "AVISO" if movimentos_zero else "OK",
        "Preservados como dias/registros sem movimentação líquida.",
    )
    adicionar(
        "Qualidade",
        "Excesso_Chave_Dia_Loja_Produto",
        excesso_chave,
        "AVISO" if excesso_chave else "OK",
        "Mais de uma linha no mesmo dia, loja e produto pode representar transações distintas.",
    )
    adicionar(
        "Integridade",
        "Tipos_Movimento_Invalidos",
        int((~df_estoque["Tipo"].isin(["E", "S"])).sum()),
        "OK",
        "Tipos aceitos: E para entrada e S para saída.",
    )
    adicionar(
        "Integridade",
        "Precos_Abaixo_Custo",
        precos_abaixo_custo,
        "AVISO" if precos_abaixo_custo else "OK",
        "Pode indicar promoção, cadastro incorreto ou margem negativa.",
    )
    adicionar(
        "Cobertura",
        "Combinacoes_Loja_Produto_Observadas",
        combinacoes_observadas,
        "OK" if combinacoes_observadas == combinacoes_possiveis else "AVISO",
        f"{combinacoes_observadas} observadas de {combinacoes_possiveis} possíveis.",
    )
    adicionar(
        "Integridade",
        "Produtos_Sem_Estoque_Minimo",
        len(set(df_produto["ID Produto"]) - set(df_minimo["ID Produto"])),
        "OK",
        "Todo produto cadastrado deve possuir parâmetro de estoque mínimo.",
    )

    return pd.DataFrame(linhas)


# -----------------------------------------------------------------------------
# Métricas analíticas
# -----------------------------------------------------------------------------

def calcular_demanda_recente(
    df_estoque: pd.DataFrame,
    chaves: Sequence[str],
    janela_dias: int,
) -> pd.DataFrame:
    """Calcula unidades vendidas e média diária na janela encerrada na última data."""
    data_fim = df_estoque["Data"].max()
    data_inicio = data_fim - pd.Timedelta(days=janela_dias - 1)
    vendas = df_estoque.loc[
        df_estoque["Data"].between(data_inicio, data_fim)
        & df_estoque["Tipo"].eq("S")
    ].copy()

    colunas = list(chaves) + ["Unidades_Vendidas_Janela", "Venda_Media_Diaria"]
    if vendas.empty:
        dados_vazios = {
            chave: pd.Series(dtype=df_estoque[chave].dtype)
            for chave in chaves
        }
        dados_vazios["Unidades_Vendidas_Janela"] = pd.Series(dtype="float64")
        dados_vazios["Venda_Media_Diaria"] = pd.Series(dtype="float64")
        return pd.DataFrame(dados_vazios, columns=colunas)

    vendas["Unidades_Vendidas_Janela"] = -vendas[COL_MOVIMENTACAO]
    demanda = (
        vendas.groupby(list(chaves), as_index=False)["Unidades_Vendidas_Janela"]
        .sum()
    )
    demanda["Venda_Media_Diaria"] = (
        demanda["Unidades_Vendidas_Janela"] / janela_dias
    )
    return demanda


def _calcular_cobertura_dias(
    saldo: pd.Series,
    venda_media_diaria: pd.Series,
) -> pd.Series:
    cobertura = pd.Series(np.nan, index=saldo.index, dtype="float64")
    com_demanda = venda_media_diaria.gt(0)
    if not com_demanda.any():
        return cobertura
    cobertura.loc[com_demanda] = (
        saldo.loc[com_demanda].clip(lower=0)
        / venda_media_diaria.loc[com_demanda]
    )
    return cobertura


def calcular_relatorio_produto(
    df_estoque: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
    janela_dias: int = 90,
) -> pd.DataFrame:
    """Calcula o saldo e o gap de reposição por produto para o total da rede."""
    saldo = (
        df_estoque.groupby("ID Produto", as_index=False)[COL_MOVIMENTACAO]
        .sum()
        .rename(columns={COL_MOVIMENTACAO: "Saldo_Atual"})
    )
    demanda = calcular_demanda_recente(df_estoque, ["ID Produto"], janela_dias)

    df_final = (
        df_produto.merge(
            df_minimo,
            on="ID Produto",
            how="left",
            validate="one_to_one",
        )
        .merge(saldo, on="ID Produto", how="left", validate="one_to_one")
        .merge(demanda, on="ID Produto", how="left", validate="one_to_one")
    )
    df_final[["Saldo_Atual", "Unidades_Vendidas_Janela", "Venda_Media_Diaria"]] = (
        df_final[["Saldo_Atual", "Unidades_Vendidas_Janela", "Venda_Media_Diaria"]]
        .fillna(0)
    )
    df_final["Janela_Demanda_Dias"] = janela_dias

    df_final["Status_Estoque"] = np.where(
        df_final["Saldo_Atual"] < df_final[COL_ESTOQUE_MINIMO],
        STATUS_ABAIXO,
        STATUS_SEGURO,
    )
    df_final["Qtd_Em_Falta"] = (
        df_final[COL_ESTOQUE_MINIMO] - df_final["Saldo_Atual"]
    ).clip(lower=0)

    indice = pd.Series(np.nan, index=df_final.index, dtype="float64")
    minimo_positivo = df_final[COL_ESTOQUE_MINIMO].gt(0)
    indice.loc[minimo_positivo] = (
        df_final.loc[minimo_positivo, "Saldo_Atual"]
        / df_final.loc[minimo_positivo, COL_ESTOQUE_MINIMO]
    )
    df_final["Indice_Cobertura_Minimo"] = indice

    df_final["Nivel_Criticidade"] = np.select(
        [
            ~minimo_positivo,
            minimo_positivo & df_final["Saldo_Atual"].le(0),
            minimo_positivo & indice.lt(0.50),
            minimo_positivo & indice.lt(1.00),
        ],
        ["SEM PARÂMETRO", "CRÍTICO", "ALTO", "ATENÇÃO"],
        default="SAUDÁVEL",
    )

    df_final["Margem_Unitaria"] = (
        df_final[COL_PRECO_UNIT] - df_final[COL_CUSTO_UNIT]
    )
    df_final["Custo_Reposicao_Estimado"] = (
        df_final["Qtd_Em_Falta"] * df_final[COL_CUSTO_UNIT]
    )
    df_final["Valor_Venda_Gap_Reposicao"] = (
        df_final["Qtd_Em_Falta"] * df_final[COL_PRECO_UNIT]
    )
    df_final["Margem_Potencial_Gap"] = (
        df_final["Qtd_Em_Falta"] * df_final["Margem_Unitaria"]
    )
    df_final["Receita_Media_Diaria"] = (
        df_final["Venda_Media_Diaria"] * df_final[COL_PRECO_UNIT]
    )
    df_final["Cobertura_Dias"] = _calcular_cobertura_dias(
        df_final["Saldo_Atual"],
        df_final["Venda_Media_Diaria"],
    )

    # Aliases legados: mantidos para não quebrar consumidores atuais.
    df_final["Faturamento_Potencial_Perdido"] = df_final["Valor_Venda_Gap_Reposicao"]
    df_final["Lucro_Potencial_Perdido"] = df_final["Margem_Potencial_Gap"]

    df_final["_Ordem_Criticidade"] = df_final["Nivel_Criticidade"].map(CRITICIDADE_ORDEM)
    df_final = df_final.sort_values(
        ["_Ordem_Criticidade", "Valor_Venda_Gap_Reposicao", "Receita_Media_Diaria"],
        ascending=[True, False, False],
    ).drop(columns="_Ordem_Criticidade")
    return df_final.reset_index(drop=True)


def calcular_relatorio_loja_produto(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    relatorio_produto: pd.DataFrame,
    janela_dias: int = 90,
) -> pd.DataFrame:
    """Calcula saldo, giro e ruptura local sem repetir o mínimo como regra por loja."""
    grade = df_loja.merge(df_produto, how="cross", validate="many_to_many")
    saldo_local = (
        df_estoque.groupby(["ID Loja", "ID Produto"], as_index=False)[COL_MOVIMENTACAO]
        .sum()
        .rename(columns={COL_MOVIMENTACAO: "Saldo_Atual"})
    )
    demanda_local = calcular_demanda_recente(
        df_estoque,
        ["ID Loja", "ID Produto"],
        janela_dias,
    )

    rede = relatorio_produto[
        [
            "ID Produto",
            COL_ESTOQUE_MINIMO,
            "Status_Estoque",
            "Qtd_Em_Falta",
            "Indice_Cobertura_Minimo",
            "Nivel_Criticidade",
            "Custo_Reposicao_Estimado",
            "Valor_Venda_Gap_Reposicao",
            "Margem_Potencial_Gap",
            "Faturamento_Potencial_Perdido",
            "Lucro_Potencial_Perdido",
        ]
    ].rename(
        columns={
            COL_ESTOQUE_MINIMO: "Estoque_Minimo_Rede",
            "Status_Estoque": "Status_Estoque_Rede",
            "Qtd_Em_Falta": "Qtd_Em_Falta_Rede",
            "Indice_Cobertura_Minimo": "Indice_Cobertura_Minimo_Rede",
            "Nivel_Criticidade": "Nivel_Criticidade_Rede",
            "Custo_Reposicao_Estimado": "Custo_Reposicao_Estimado_Rede",
            "Valor_Venda_Gap_Reposicao": "Valor_Venda_Gap_Reposicao_Rede",
            "Margem_Potencial_Gap": "Margem_Potencial_Gap_Rede",
            "Faturamento_Potencial_Perdido": "Faturamento_Potencial_Perdido_Rede",
            "Lucro_Potencial_Perdido": "Lucro_Potencial_Perdido_Rede",
        }
    )

    df_final = (
        grade.merge(
            saldo_local,
            on=["ID Loja", "ID Produto"],
            how="left",
            validate="one_to_one",
        )
        .merge(
            demanda_local,
            on=["ID Loja", "ID Produto"],
            how="left",
            validate="one_to_one",
        )
        .merge(rede, on="ID Produto", how="left", validate="many_to_one")
    )
    df_final[["Saldo_Atual", "Unidades_Vendidas_Janela", "Venda_Media_Diaria"]] = (
        df_final[["Saldo_Atual", "Unidades_Vendidas_Janela", "Venda_Media_Diaria"]]
        .fillna(0)
    )
    df_final["Janela_Demanda_Dias"] = janela_dias
    df_final["Receita_Media_Diaria_Local"] = (
        df_final["Venda_Media_Diaria"] * df_final[COL_PRECO_UNIT]
    )
    df_final["Cobertura_Dias_Local"] = _calcular_cobertura_dias(
        df_final["Saldo_Atual"],
        df_final["Venda_Media_Diaria"],
    )
    df_final["Deficit_Local_Para_Zero"] = (-df_final["Saldo_Atual"]).clip(lower=0)
    df_final["Margem_Unitaria"] = (
        df_final[COL_PRECO_UNIT] - df_final[COL_CUSTO_UNIT]
    )
    df_final["Custo_Deficit_Local"] = (
        df_final["Deficit_Local_Para_Zero"] * df_final[COL_CUSTO_UNIT]
    )
    df_final["Valor_Venda_Deficit_Local"] = (
        df_final["Deficit_Local_Para_Zero"] * df_final[COL_PRECO_UNIT]
    )
    df_final["Margem_Deficit_Local"] = (
        df_final["Deficit_Local_Para_Zero"] * df_final["Margem_Unitaria"]
    )

    com_demanda = df_final["Venda_Media_Diaria"].gt(0)
    df_final["Status_Local"] = np.select(
        [
            com_demanda & df_final["Saldo_Atual"].le(0),
            ~com_demanda,
        ],
        ["RUPTURA LOCAL", "SEM DEMANDA RECENTE"],
        default="ESTOQUE POSITIVO",
    )

    # Colunas legadas preservadas. Aqui elas refletem a métrica da rede e não
    # devem ser somadas entre lojas; as métricas locais têm nomes explícitos.
    df_final[COL_ESTOQUE_MINIMO] = df_final["Estoque_Minimo_Rede"]
    df_final["Status_Estoque"] = df_final["Status_Estoque_Rede"]
    df_final["Qtd_Em_Falta"] = df_final["Qtd_Em_Falta_Rede"]
    df_final["Faturamento_Potencial_Perdido"] = df_final[
        "Faturamento_Potencial_Perdido_Rede"
    ]
    df_final["Lucro_Potencial_Perdido"] = df_final[
        "Lucro_Potencial_Perdido_Rede"
    ]
    df_final["Escopo_Metricas_Globais"] = "REDE_NAO_SOMAR"

    prioridade_local = {
        "RUPTURA LOCAL": 0,
        "ESTOQUE POSITIVO": 1,
        "SEM DEMANDA RECENTE": 2,
    }
    df_final["_Ordem_Local"] = df_final["Status_Local"].map(prioridade_local)
    df_final["_Ordem_Rede"] = df_final["Nivel_Criticidade_Rede"].map(CRITICIDADE_ORDEM)
    df_final = df_final.sort_values(
        [
            "_Ordem_Local",
            "_Ordem_Rede",
            "Cobertura_Dias_Local",
            "Receita_Media_Diaria_Local",
        ],
        ascending=[True, True, True, False],
        na_position="last",
    ).drop(columns=["_Ordem_Local", "_Ordem_Rede"])
    return df_final.reset_index(drop=True)


def gerar_agregacoes(
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Cria resumos sem somar métricas de rede repetidas no detalhe por loja."""
    criticos = relatorio_produto.loc[
        relatorio_produto["Status_Estoque"].eq(STATUS_ABAIXO)
    ]
    resumo_categoria = (
        criticos.groupby("Categoria", as_index=False)
        .agg(
            Produtos_Criticos=("ID Produto", "nunique"),
            Unidades_Em_Falta=("Qtd_Em_Falta", "sum"),
            Custo_Reposicao_Estimado=("Custo_Reposicao_Estimado", "sum"),
            Valor_Venda_Gap_Reposicao=("Valor_Venda_Gap_Reposicao", "sum"),
            Margem_Potencial_Gap=("Margem_Potencial_Gap", "sum"),
            Receita_Media_Diaria=("Receita_Media_Diaria", "sum"),
            Faturamento_Potencial_Perdido=("Faturamento_Potencial_Perdido", "sum"),
            Lucro_Potencial_Perdido=("Lucro_Potencial_Perdido", "sum"),
        )
        .sort_values("Valor_Venda_Gap_Reposicao", ascending=False)
        .reset_index(drop=True)
    )

    local = relatorio_loja_produto.copy()
    local["Indicador_Ruptura_Local"] = local["Status_Local"].eq("RUPTURA LOCAL")
    local["Receita_Diaria_Em_Ruptura"] = np.where(
        local["Indicador_Ruptura_Local"],
        local["Receita_Media_Diaria_Local"],
        0,
    )
    resumo_loja = (
        local.groupby(["Loja", "Bairro"], as_index=False)
        .agg(
            Produtos_Criticos=("Indicador_Ruptura_Local", "sum"),
            Produtos_Ruptura_Local=("Indicador_Ruptura_Local", "sum"),
            Unidades_Em_Falta=("Deficit_Local_Para_Zero", "sum"),
            Deficit_Local_Para_Zero=("Deficit_Local_Para_Zero", "sum"),
            Saldo_Total_Local=("Saldo_Atual", "sum"),
            Cobertura_Mediana_Dias=("Cobertura_Dias_Local", "median"),
            Receita_Media_Diaria_Em_Ruptura=("Receita_Diaria_Em_Ruptura", "sum"),
            Valor_Venda_Deficit_Local=("Valor_Venda_Deficit_Local", "sum"),
            Margem_Deficit_Local=("Margem_Deficit_Local", "sum"),
        )
    )
    # Aliases legados do resumo de loja passam a refletir somente déficit local.
    resumo_loja["Faturamento_Potencial_Perdido"] = resumo_loja[
        "Valor_Venda_Deficit_Local"
    ]
    resumo_loja["Lucro_Potencial_Perdido"] = resumo_loja["Margem_Deficit_Local"]
    resumo_loja = resumo_loja.sort_values(
        ["Receita_Media_Diaria_Em_Ruptura", "Produtos_Ruptura_Local"],
        ascending=False,
    ).reset_index(drop=True)
    return resumo_categoria, resumo_loja


def _valor_auditoria(auditoria_qualidade: pd.DataFrame, indicador: str) -> int:
    valores = auditoria_qualidade.loc[
        auditoria_qualidade["Indicador"].eq(indicador), "Valor"
    ]
    return int(valores.iloc[0]) if not valores.empty else 0


def gerar_resumo_executivo(
    df_estoque: pd.DataFrame,
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
    auditoria_qualidade: pd.DataFrame,
    janela_dias: int,
) -> pd.DataFrame:
    criticos = relatorio_produto["Status_Estoque"].eq(STATUS_ABAIXO)
    rupturas_locais = relatorio_loja_produto["Status_Local"].eq("RUPTURA LOCAL")
    qtd_produtos = relatorio_produto["ID Produto"].nunique()

    return pd.DataFrame(
        [
            {
                "Data_Inicio": df_estoque["Data"].min(),
                "Data_Fim": df_estoque["Data"].max(),
                "Janela_Demanda_Dias": janela_dias,
                "Movimentacoes": len(df_estoque),
                "Produtos": qtd_produtos,
                "Lojas": relatorio_loja_produto["ID Loja"].nunique(),
                "Combinacoes_Loja_Produto": len(relatorio_loja_produto),
                "Produtos_Abaixo_Minimo": int(criticos.sum()),
                "Percentual_Produtos_Abaixo_Minimo": (
                    float(criticos.sum() / qtd_produtos) if qtd_produtos else 0
                ),
                "Unidades_Gap_Reposicao": relatorio_produto["Qtd_Em_Falta"].sum(),
                "Custo_Reposicao_Estimado": relatorio_produto[
                    "Custo_Reposicao_Estimado"
                ].sum(),
                "Valor_Venda_Gap_Reposicao": relatorio_produto[
                    "Valor_Venda_Gap_Reposicao"
                ].sum(),
                "Margem_Potencial_Gap": relatorio_produto[
                    "Margem_Potencial_Gap"
                ].sum(),
                "Rupturas_Locais": int(rupturas_locais.sum()),
                "Saldos_Locais_Negativos": int(
                    relatorio_loja_produto["Saldo_Atual"].lt(0).sum()
                ),
                "Saldos_Locais_Zerados": int(
                    relatorio_loja_produto["Saldo_Atual"].eq(0).sum()
                ),
                "Duplicatas_Exatas": _valor_auditoria(
                    auditoria_qualidade, "Duplicatas_Exatas"
                ),
                "Movimentos_Zerados": _valor_auditoria(
                    auditoria_qualidade, "Movimentos_Zerados"
                ),
            }
        ]
    )


# -----------------------------------------------------------------------------
# Persistência
# -----------------------------------------------------------------------------

def salvar_relatorios(
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
    resumo_categoria: pd.DataFrame,
    resumo_loja: pd.DataFrame,
    auditoria_movimentacoes: pd.DataFrame,
    auditoria_qualidade: pd.DataFrame,
    resumo_executivo: pd.DataFrame,
    pasta_saida: Path,
) -> list[Path]:
    pasta_saida.mkdir(parents=True, exist_ok=True)
    arquivos = {
        "relatorio_produto.csv": relatorio_produto,
        "relatorio_loja_produto.csv": relatorio_loja_produto,
        "resumo_categoria.csv": resumo_categoria,
        "resumo_loja.csv": resumo_loja,
        "auditoria_movimentacoes.csv": auditoria_movimentacoes,
        "auditoria_qualidade.csv": auditoria_qualidade,
        "resumo_executivo.csv": resumo_executivo,
    }

    caminhos: list[Path] = []
    for nome, df in arquivos.items():
        caminho = pasta_saida / nome
        df.to_csv(
            caminho,
            index=False,
            encoding="utf-8-sig",
            float_format="%.4f",
            date_format="%Y-%m-%d",
        )
        caminhos.append(caminho)
    return caminhos


# -----------------------------------------------------------------------------
# Visualizações
# -----------------------------------------------------------------------------

def configurar_tema_graficos() -> None:
    sns.set_theme(style="whitegrid", context="notebook", font_scale=1.0)
    plt.rcParams.update(
        {
            "figure.facecolor": "white",
            "axes.facecolor": "white",
            "axes.titleweight": "bold",
            "axes.titlesize": 14,
            "axes.labelsize": 11,
            "grid.alpha": 0.22,
            "grid.linestyle": "--",
            "axes.spines.top": False,
            "axes.spines.right": False,
        }
    )


def _formatar_eixo_moeda(valor: float, _: int) -> str:
    absoluto = abs(valor)
    if absoluto >= 1_000_000:
        return f"R$ {valor / 1_000_000:.1f} mi".replace(".", ",")
    if absoluto >= 1_000:
        return f"R$ {valor / 1_000:.1f} mil".replace(".", ",")
    return f"R$ {valor:,.0f}".replace(",", ".")


def _mensagem_sem_dados(ax: plt.Axes, titulo: str, mensagem: str) -> None:
    ax.set_title(titulo, loc="left")
    ax.text(
        0.5,
        0.5,
        mensagem,
        ha="center",
        va="center",
        transform=ax.transAxes,
        fontsize=12,
        color="#5E6C84",
    )
    ax.set_axis_off()


def _salvar_figura(fig: plt.Figure, caminho: Path) -> Path:
    """Renderiza em memória e contorna bloqueios do Windows no PNG existente."""
    buffer = BytesIO()
    try:
        fig.savefig(
            buffer,
            format="png",
            dpi=DPI_GRAFICOS,
            facecolor="white",
        )
        conteudo = buffer.getvalue()
    finally:
        buffer.close()
        plt.close(fig)

    ultimo_erro: PermissionError | None = None
    for tentativa in range(4):
        try:
            caminho.write_bytes(conteudo)
            return caminho
        except PermissionError as erro:
            ultimo_erro = erro
            time.sleep(0.15 * (tentativa + 1))

    # Um visualizador pode manter o PNG oficial bloqueado no Windows. Nesse
    # caso, preservamos o arquivo anterior e entregamos a nova versão sem falhar.
    sufixo = f"{time.strftime('%Y%m%d_%H%M%S')}_{time.time_ns() % 1_000_000:06d}"
    alternativo = caminho.with_name(f"{caminho.stem}_{sufixo}{caminho.suffix}")
    try:
        alternativo.write_bytes(conteudo)
    except PermissionError:
        if ultimo_erro is not None:
            raise ultimo_erro
        raise

    print(
        f"      [AVISO] {caminho.name} estava aberto; nova versão salva como "
        f"{alternativo.name}.",
        flush=True,
    )
    return alternativo


def gerar_graficos(
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
    resumo_loja: pd.DataFrame,
    pasta_saida: Path,
    janela_dias: int,
    top_n: int,
    data_fim: pd.Timestamp,
) -> list[Path]:
    """Gera três gráficos compatíveis e um painel executivo consolidado."""
    pasta_saida.mkdir(parents=True, exist_ok=True)
    configurar_tema_graficos()
    caminhos: list[Path] = []
    criticos = relatorio_produto.loc[
        relatorio_produto["Status_Estoque"].eq(STATUS_ABAIXO)
    ].copy()

    # 1) Produtos críticos por categoria — contagem única no total da rede.
    caminho = pasta_saida / "grafico_criticos_por_categoria.png"
    contagem = (
        criticos.groupby("Categoria")["ID Produto"]
        .nunique()
        .sort_values(ascending=True)
    )
    fig, ax = plt.subplots(figsize=(11, 6.5))
    if contagem.empty:
        _mensagem_sem_dados(
            ax,
            "Produtos abaixo do estoque mínimo por categoria",
            "Nenhum produto abaixo do mínimo.",
        )
    else:
        barras = ax.barh(contagem.index.astype(str), contagem.values, color="#D95D39")
        ax.bar_label(barras, padding=5, fontsize=11, fontweight="bold")
        ax.set_title("Produtos abaixo do estoque mínimo por categoria", loc="left")
        ax.set_xlabel("Quantidade de produtos únicos")
        ax.set_ylabel("")
        ax.set_xlim(0, max(contagem.max() * 1.18, 1))
        ax.grid(axis="y", visible=False)
    fig.text(
        0.01,
        0.01,
        "Escopo: total da rede; cada produto é contado uma única vez.",
        fontsize=9,
        color="#5E6C84",
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    caminhos.append(_salvar_figura(fig, caminho))
    print("      [1/4] Categorias concluído.", flush=True)

    # 2) Distribuição do saldo local por categoria.
    caminho = pasta_saida / "boxplot_saldo_por_categoria.png"
    fig, ax = plt.subplots(figsize=(12, 7))
    if relatorio_loja_produto.empty:
        _mensagem_sem_dados(
            ax,
            "Distribuição do saldo local por categoria",
            "Não há combinações de loja e produto para exibir.",
        )
    else:
        ordem_categorias = sorted(relatorio_loja_produto["Categoria"].dropna().unique())
        sns.boxplot(
            data=relatorio_loja_produto,
            x="Categoria",
            y="Saldo_Atual",
            hue="Categoria",
            order=ordem_categorias,
            palette="Set2",
            legend=False,
            showmeans=True,
            meanprops={
                "marker": "D",
                "markerfacecolor": "#1F3A5F",
                "markeredgecolor": "white",
                "markersize": 6,
            },
            ax=ax,
        )
        sns.stripplot(
            data=relatorio_loja_produto,
            x="Categoria",
            y="Saldo_Atual",
            hue="Categoria",
            order=ordem_categorias,
            palette="Set2",
            legend=False,
            alpha=0.30,
            size=3,
            jitter=0.18,
            ax=ax,
        )
        ax.axhline(0, color=CORES_CRITICIDADE["CRÍTICO"], linestyle="--", linewidth=1.5)
        ax.set_title("Distribuição do saldo local por categoria", loc="left")
        ax.set_xlabel("")
        ax.set_ylabel("Saldo acumulado por Loja × Produto")
        ax.tick_params(axis="x", rotation=10)
    fig.text(
        0.01,
        0.01,
        "Linha vermelha: saldo zero. Losango: média da categoria.",
        fontsize=9,
        color="#5E6C84",
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    caminhos.append(_salvar_figura(fig, caminho))
    print("      [2/4] Distribuição dos saldos concluída.", flush=True)

    # 3) Maiores gaps de reposição — produto no total da rede.
    caminho = pasta_saida / "top_15_perda_potencial.png"
    top_15 = criticos.nlargest(15, "Valor_Venda_Gap_Reposicao").sort_values(
        "Valor_Venda_Gap_Reposicao"
    )
    fig, ax = plt.subplots(figsize=(13, 8))
    if top_15.empty:
        _mensagem_sem_dados(
            ax,
            "Maiores gaps de reposição por valor de venda",
            "Nenhum gap de reposição foi identificado.",
        )
    else:
        rotulos = [textwrap.fill(str(nome), width=38) for nome in top_15["Produto"]]
        cores = [CORES_CRITICIDADE[nivel] for nivel in top_15["Nivel_Criticidade"]]
        barras = ax.barh(rotulos, top_15["Valor_Venda_Gap_Reposicao"], color=cores)
        maior = float(top_15["Valor_Venda_Gap_Reposicao"].max())
        for barra, valor in zip(barras, top_15["Valor_Venda_Gap_Reposicao"]):
            ax.text(
                barra.get_width() + maior * 0.012,
                barra.get_y() + barra.get_height() / 2,
                formatar_moeda(valor),
                va="center",
                fontsize=9,
            )
        ax.set_xlim(0, maior * 1.25)
        ax.xaxis.set_major_formatter(FuncFormatter(_formatar_eixo_moeda))
        ax.set_title("Top gaps de reposição por valor de venda", loc="left")
        ax.set_xlabel("Valor de venda associado ao gap")
        ax.set_ylabel("")
        ax.grid(axis="y", visible=False)
    fig.text(
        0.01,
        0.01,
        "Proxy operacional: quantidade abaixo do mínimo × preço unitário; não representa perda realizada.",
        fontsize=9,
        color="#5E6C84",
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    caminhos.append(_salvar_figura(fig, caminho))
    print("      [3/4] Ranking dos gaps concluído.", flush=True)

    # 4) Painel executivo 2 × 2.
    caminho = pasta_saida / "painel_executivo_estoque.png"
    fig, axes = plt.subplots(2, 2, figsize=(18, 12))
    ax1, ax2, ax3, ax4 = axes.flatten()

    tabela_criticidade = pd.crosstab(
        relatorio_produto["Categoria"],
        relatorio_produto["Nivel_Criticidade"],
    ).reindex(columns=list(CRITICIDADE_ORDEM), fill_value=0)
    if tabela_criticidade.empty:
        _mensagem_sem_dados(ax1, "Criticidade por categoria", "Sem dados.")
    else:
        tabela_criticidade.plot(
            kind="barh",
            stacked=True,
            color=[CORES_CRITICIDADE[coluna] for coluna in tabela_criticidade.columns],
            ax=ax1,
        )
        ax1.set_title("Criticidade por categoria", loc="left")
        ax1.set_xlabel("Quantidade de produtos")
        ax1.set_ylabel("")
        ax1.legend(title="Nível", frameon=False, fontsize=8, loc="lower right")

    top_painel = criticos.nlargest(top_n, "Valor_Venda_Gap_Reposicao").sort_values(
        "Valor_Venda_Gap_Reposicao"
    )
    if top_painel.empty:
        _mensagem_sem_dados(ax2, "Maiores gaps de reposição", "Nenhum gap identificado.")
    else:
        rotulos = [
            f"{int(id_produto):02d} | "
            f"{textwrap.shorten(str(nome), width=29, placeholder='…')}"
            for id_produto, nome in zip(top_painel["ID Produto"], top_painel["Produto"])
        ]
        cores = [CORES_CRITICIDADE[nivel] for nivel in top_painel["Nivel_Criticidade"]]
        ax2.barh(rotulos, top_painel["Valor_Venda_Gap_Reposicao"], color=cores)
        ax2.xaxis.set_major_formatter(FuncFormatter(_formatar_eixo_moeda))
        ax2.set_title(f"Top {min(top_n, len(top_painel))} gaps por valor de venda", loc="left")
        ax2.set_xlabel("Valor do gap")
        ax2.set_ylabel("")

    cobertura = relatorio_produto["Cobertura_Dias"].replace([np.inf, -np.inf], np.nan).dropna()
    if cobertura.empty:
        _mensagem_sem_dados(ax3, "Distribuição da cobertura", "Sem demanda recente para estimar cobertura.")
    else:
        sns.histplot(cobertura, bins=min(10, max(4, len(cobertura) // 3)), color="#2F6B8A", ax=ax3)
        mediana = float(cobertura.median())
        ax3.axvline(mediana, color="#B42318", linestyle="--", linewidth=1.7)
        ax3.text(
            mediana,
            ax3.get_ylim()[1] * 0.88,
            f" Mediana: {mediana:.1f} dias".replace(".", ","),
            color="#B42318",
            fontsize=9,
        )
        ax3.set_title(f"Cobertura estimada — demanda de {janela_dias} dias", loc="left")
        ax3.set_xlabel("Dias de cobertura")
        ax3.set_ylabel("Produtos")

    lojas = resumo_loja.sort_values("Produtos_Ruptura_Local", ascending=True)
    if lojas.empty:
        _mensagem_sem_dados(ax4, "Rupturas locais por loja", "Sem dados por loja.")
    else:
        barras = ax4.barh(lojas["Loja"], lojas["Produtos_Ruptura_Local"], color="#B42318")
        ax4.bar_label(barras, padding=4, fontsize=9, fontweight="bold")
        ax4.set_title("Rupturas locais por loja", loc="left")
        ax4.set_xlabel("Produtos com saldo ≤ 0 e demanda recente")
        ax4.set_ylabel("")
        ax4.set_xlim(0, max(float(lojas["Produtos_Ruptura_Local"].max()) * 1.18, 1))

    fig.suptitle(
        "PAINEL EXECUTIVO — INTELIGÊNCIA DE ESTOQUE",
        fontsize=20,
        fontweight="bold",
        x=0.02,
        ha="left",
    )
    fig.text(
        0.02,
        0.945,
        f"Base encerrada em {data_fim:%d/%m/%Y}  |  Janela de demanda: {janela_dias} dias  |  Estoque mínimo: total da rede",
        fontsize=11,
        color="#5E6C84",
    )
    fig.text(
        0.02,
        0.01,
        "Saldo calculado pela soma líquida das movimentações, sob premissa de saldo inicial zero.",
        fontsize=9,
        color="#5E6C84",
    )
    fig.tight_layout(rect=(0, 0.035, 1, 0.92), h_pad=3.0, w_pad=2.5)
    print("      [4/4] Finalizando painel executivo...", flush=True)
    caminhos.append(_salvar_figura(fig, caminho))
    print("      [4/4] Painel executivo concluído.", flush=True)
    return caminhos


# -----------------------------------------------------------------------------
# Terminal executivo
# -----------------------------------------------------------------------------

def formatar_moeda(valor: float) -> str:
    return f"R$ {valor:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")


def formatar_inteiro(valor: float | int) -> str:
    return f"{int(round(float(valor))):,}".replace(",", ".")


def formatar_decimal(valor: float, casas: int = 1) -> str:
    if pd.isna(valor):
        return "—"
    return f"{valor:,.{casas}f}".replace(",", "X").replace(".", ",").replace("X", ".")


def _linha(tamanho: int = 100, caractere: str = "─") -> str:
    return caractere * tamanho


def imprimir_cabecalho() -> None:
    print("\n" + _linha(caractere="═"))
    print("  INTELIGÊNCIA DE ESTOQUE | PROCESSAMENTO EXECUTIVO")
    print(_linha(caractere="═"))


def imprimir_etapa(numero: int, total: int, descricao: str) -> None:
    print(f"  [{numero}/{total}] {descricao}")


def imprimir_resumo_executivo(
    fonte: str,
    resumo_executivo: pd.DataFrame,
    relatorio_produto: pd.DataFrame,
    resumo_loja: pd.DataFrame,
    auditoria_movimentacoes: pd.DataFrame,
    auditoria_qualidade: pd.DataFrame,
    arquivos_gerados: Sequence[Path],
    top_n: int,
    tempo_segundos: float,
) -> None:
    resumo = resumo_executivo.iloc[0]
    print("\n" + _linha())
    print("  RESUMO EXECUTIVO")
    print(_linha())
    print(f"  Fonte analisada           : {fonte}")
    print(
        "  Período da base           : "
        f"{resumo['Data_Inicio']:%d/%m/%Y} a {resumo['Data_Fim']:%d/%m/%Y}"
    )
    print(f"  Janela de demanda         : {int(resumo['Janela_Demanda_Dias'])} dias")
    print(f"  Movimentações             : {formatar_inteiro(resumo['Movimentacoes'])}")
    print(
        "  Produtos / Lojas          : "
        f"{formatar_inteiro(resumo['Produtos'])} / {formatar_inteiro(resumo['Lojas'])}"
    )
    print(
        "  Produtos abaixo do mínimo : "
        f"{formatar_inteiro(resumo['Produtos_Abaixo_Minimo'])} "
        f"({resumo['Percentual_Produtos_Abaixo_Minimo']:.1%})"
    )
    print(
        "  Gap total de reposição    : "
        f"{formatar_inteiro(resumo['Unidades_Gap_Reposicao'])} unidades"
    )
    print(
        "  Custo estimado reposição  : "
        f"{formatar_moeda(resumo['Custo_Reposicao_Estimado'])}"
    )
    print(
        "  Valor de venda do gap     : "
        f"{formatar_moeda(resumo['Valor_Venda_Gap_Reposicao'])}"
    )
    print(
        "  Margem potencial do gap   : "
        f"{formatar_moeda(resumo['Margem_Potencial_Gap'])}"
    )
    print(
        "  Rupturas locais           : "
        f"{formatar_inteiro(resumo['Rupturas_Locais'])} combinações Loja × Produto"
    )

    print("\n" + _linha())
    print("  QUALIDADE DOS DADOS")
    print(_linha())
    avisos = auditoria_qualidade.loc[auditoria_qualidade["Status"].eq("AVISO")]
    if avisos.empty:
        print("  [OK] Nenhum alerta de qualidade identificado.")
    else:
        for linha in avisos.itertuples(index=False):
            print(
                f"  [AVISO] {linha.Indicador}: {formatar_inteiro(linha.Valor)} — "
                f"{linha.Detalhe}"
            )

    print("\n  Auditoria de sinais:")
    auditoria_exibicao = auditoria_movimentacoes.copy()
    for coluna in auditoria_exibicao.columns[1:]:
        auditoria_exibicao[coluna] = auditoria_exibicao[coluna].map(formatar_inteiro)
    print(textwrap.indent(auditoria_exibicao.to_string(index=False), "    "))

    print("\n" + _linha())
    print(f"  TOP {top_n} PRIORIDADES DE REPOSIÇÃO — REDE")
    print(_linha())
    ranking = relatorio_produto.loc[
        relatorio_produto["Status_Estoque"].eq(STATUS_ABAIXO),
        [
            "Produto",
            "Categoria",
            "Saldo_Atual",
            COL_ESTOQUE_MINIMO,
            "Qtd_Em_Falta",
            "Nivel_Criticidade",
            "Cobertura_Dias",
            "Valor_Venda_Gap_Reposicao",
        ],
    ].head(top_n).copy()
    if ranking.empty:
        print("  Nenhum produto abaixo do estoque mínimo.")
    else:
        ranking["Produto"] = ranking["Produto"].map(
            lambda valor: textwrap.shorten(str(valor), width=42, placeholder="…")
        )
        ranking["Cobertura_Dias"] = ranking["Cobertura_Dias"].map(formatar_decimal)
        ranking["Valor_Venda_Gap_Reposicao"] = ranking[
            "Valor_Venda_Gap_Reposicao"
        ].map(formatar_moeda)
        for coluna in ("Saldo_Atual", COL_ESTOQUE_MINIMO, "Qtd_Em_Falta"):
            ranking[coluna] = ranking[coluna].map(formatar_inteiro)
        ranking = ranking.rename(
            columns={
                COL_ESTOQUE_MINIMO: "Mínimo",
                "Qtd_Em_Falta": "Gap",
                "Nivel_Criticidade": "Criticidade",
                "Cobertura_Dias": "Cobertura(d)",
                "Valor_Venda_Gap_Reposicao": "Valor gap",
            }
        )
        print(textwrap.indent(ranking.to_string(index=False), "  "))

    print("\n" + _linha())
    print("  RANKING OPERACIONAL POR LOJA")
    print(_linha())
    ranking_loja = resumo_loja[
        [
            "Loja",
            "Produtos_Ruptura_Local",
            "Deficit_Local_Para_Zero",
            "Cobertura_Mediana_Dias",
            "Receita_Media_Diaria_Em_Ruptura",
        ]
    ].head(top_n).copy()
    ranking_loja["Cobertura_Mediana_Dias"] = ranking_loja[
        "Cobertura_Mediana_Dias"
    ].map(formatar_decimal)
    ranking_loja["Receita_Media_Diaria_Em_Ruptura"] = ranking_loja[
        "Receita_Media_Diaria_Em_Ruptura"
    ].map(formatar_moeda)
    for coluna in ("Produtos_Ruptura_Local", "Deficit_Local_Para_Zero"):
        ranking_loja[coluna] = ranking_loja[coluna].map(formatar_inteiro)
    ranking_loja = ranking_loja.rename(
        columns={
            "Produtos_Ruptura_Local": "Rupturas",
            "Deficit_Local_Para_Zero": "Déficit",
            "Cobertura_Mediana_Dias": "Cobertura(d)",
            "Receita_Media_Diaria_Em_Ruptura": "Receita/dia risco",
        }
    )
    print(textwrap.indent(ranking_loja.to_string(index=False), "  "))

    print("\n" + _linha())
    print("  ARQUIVOS GERADOS")
    print(_linha())
    for caminho in arquivos_gerados:
        print(f"  [OK] {caminho.name}")
    print(
        "\n  Nota: 'Faturamento_Potencial_Perdido' permanece apenas como alias "
        "de compatibilidade."
    )
    print("  O indicador representa valor de venda do gap, não perda realizada.")
    print(f"  Processamento concluído em {tempo_segundos:.2f} segundos.")
    print(_linha(caractere="═") + "\n")


# -----------------------------------------------------------------------------
# Orquestração
# -----------------------------------------------------------------------------

def main(argv: Sequence[str] | None = None) -> int:
    configurar_terminal_utf8()
    parser = criar_parser()
    args = parser.parse_args(argv)
    pasta_saida = args.saida if args.saida.is_absolute() else PASTA_BASE / args.saida
    inicio_execucao = time.perf_counter()

    imprimir_cabecalho()
    try:
        imprimir_etapa(1, 7, "Localizando e carregando os dados...")
        fonte = identificar_fonte_dados()
        df_estoque, df_loja, df_produto, df_minimo = carregar_dados()

        imprimir_etapa(2, 7, "Validando estrutura, tipos, chaves e regras de negócio...")
        validar_colunas(df_estoque, df_loja, df_produto, df_minimo)
        df_estoque, df_loja, df_produto, df_minimo = tratar_tipos(
            df_estoque,
            df_loja,
            df_produto,
            df_minimo,
        )
        validar_integridade(df_estoque, df_loja, df_produto, df_minimo)

        imprimir_etapa(3, 7, "Auditando movimentações e qualidade da base...")
        auditoria_movimentacoes = auditar_movimentacoes(df_estoque)
        auditoria_qualidade = auditar_qualidade(
            df_estoque,
            df_loja,
            df_produto,
            df_minimo,
        )

        imprimir_etapa(4, 7, "Calculando saldo, giro, cobertura e criticidade da rede...")
        relatorio_produto = calcular_relatorio_produto(
            df_estoque,
            df_produto,
            df_minimo,
            janela_dias=args.janela_dias,
        )
        relatorio_loja_produto = calcular_relatorio_loja_produto(
            df_estoque,
            df_loja,
            df_produto,
            relatorio_produto,
            janela_dias=args.janela_dias,
        )
        resumo_categoria, resumo_loja = gerar_agregacoes(
            relatorio_produto,
            relatorio_loja_produto,
        )
        resumo_executivo = gerar_resumo_executivo(
            df_estoque,
            relatorio_produto,
            relatorio_loja_produto,
            auditoria_qualidade,
            args.janela_dias,
        )

        imprimir_etapa(5, 7, "Salvando relatórios analíticos...")
        arquivos_csv = salvar_relatorios(
            relatorio_produto,
            relatorio_loja_produto,
            resumo_categoria,
            resumo_loja,
            auditoria_movimentacoes,
            auditoria_qualidade,
            resumo_executivo,
            pasta_saida,
        )

        imprimir_etapa(6, 7, "Gerando gráficos e painel executivo...")
        arquivos_graficos = gerar_graficos(
            relatorio_produto,
            relatorio_loja_produto,
            resumo_loja,
            pasta_saida,
            args.janela_dias,
            args.top,
            df_estoque["Data"].max(),
        )

        imprimir_etapa(7, 7, "Consolidando resultados...")
        tempo_segundos = time.perf_counter() - inicio_execucao
        imprimir_resumo_executivo(
            fonte,
            resumo_executivo,
            relatorio_produto,
            resumo_loja,
            auditoria_movimentacoes,
            auditoria_qualidade,
            [*arquivos_csv, *arquivos_graficos],
            args.top,
            tempo_segundos,
        )
        return 0

    except KeyboardInterrupt:
        plt.close("all")
        print("\n" + _linha())
        print("  [CANCELADO] Execução interrompida pelo usuário (Ctrl+C / botão Parar).")
        print("  Execute novamente e aguarde a confirmação dos quatro gráficos.")
        print(_linha() + "\n")
        return 130
    except (FileNotFoundError, ValueError, KeyError, pd.errors.MergeError) as erro:
        print("\n" + _linha())
        print("  [ERRO] O processamento foi interrompido por uma inconsistência conhecida.")
        print(textwrap.indent(str(erro), "  "))
        print(_linha() + "\n")
        return 1
    except Exception as erro:  # Proteção do fluxo executivo: sem traceback poluído.
        print("\n" + _linha())
        print(f"  [ERRO INESPERADO] {type(erro).__name__}: {erro}")
        print("  Revise os arquivos de entrada ou execute novamente após corrigir a causa.")
        print(_linha() + "\n")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
