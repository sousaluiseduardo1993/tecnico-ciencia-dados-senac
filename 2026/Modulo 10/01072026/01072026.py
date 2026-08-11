"""
Inteligência de Estoque - Rede de Varejo Esportivo
Autor: Analista Sênior de Dados
Objetivo:
    Ler fEstoque, dLoja, dProduto e EstoqueMin; calcular saldo atual;
    identificar produtos abaixo do mínimo; estimar faturamento potencial perdido;
    gerar relatórios analíticos e gráficos para decisão de reabastecimento.

Como executar no VS Code:
    1. Coloque este arquivo na mesma pasta de BaseDados.xlsx e EstoqueMin.csv
       OU coloque fEstoque.csv, dLoja.csv, dProduto.csv e EstoqueMin.csv.
    2. Instale dependências:
       pip install pandas numpy matplotlib seaborn openpyxl
    3. Execute:
       python inteligencia_estoque.py

Saídas geradas:
    - saidas/relatorio_produto.csv
    - saidas/relatorio_loja_produto.csv
    - saidas/resumo_categoria.csv
    - saidas/resumo_loja.csv
    - saidas/grafico_criticos_por_categoria.png
    - saidas/boxplot_saldo_por_categoria.png
    - saidas/top_15_perda_potencial.png
"""

from __future__ import annotations

from pathlib import Path
from typing import Tuple

import numpy as np
import pandas as pd
import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import seaborn as sns


PASTA_BASE = Path(__file__).resolve().parent
PASTA_SAIDA = PASTA_BASE / "saidas"

ARQUIVO_EXCEL = PASTA_BASE / "BaseDados.xlsx"
ARQUIVO_ESTOQUE_MIN = PASTA_BASE / "EstoqueMin.csv"

CSV_ESTOQUE = PASTA_BASE / "fEstoque.csv"
CSV_LOJA = PASTA_BASE / "dLoja.csv"
CSV_PRODUTO = PASTA_BASE / "dProduto.csv"


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
    """Lê CSV tentando detectar separador automaticamente."""
    if not caminho.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {caminho}")
    df = pd.read_csv(caminho, sep=None, engine="python", encoding="utf-8-sig")
    return limpar_colunas(df)


def carregar_dados() -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Carrega as quatro tabelas necessárias.

    Prioridade:
    1. CSVs separados: fEstoque.csv, dLoja.csv, dProduto.csv, EstoqueMin.csv.
    2. Caso os CSVs de fato/dimensões não existam, usa BaseDados.xlsx com abas:
       fEstoque, dLoja, dProduto, além de EstoqueMin.csv.
    """
    if CSV_ESTOQUE.exists() and CSV_LOJA.exists() and CSV_PRODUTO.exists():
        df_estoque = ler_csv_inteligente(CSV_ESTOQUE)
        df_loja = ler_csv_inteligente(CSV_LOJA)
        df_produto = ler_csv_inteligente(CSV_PRODUTO)
    elif ARQUIVO_EXCEL.exists():
        df_estoque = limpar_colunas(pd.read_excel(ARQUIVO_EXCEL, sheet_name="fEstoque"))
        df_loja = limpar_colunas(pd.read_excel(ARQUIVO_EXCEL, sheet_name="dLoja"))
        df_produto = limpar_colunas(pd.read_excel(ARQUIVO_EXCEL, sheet_name="dProduto"))
    else:
        raise FileNotFoundError(
            "Não encontrei os CSVs separados nem o arquivo BaseDados.xlsx."
        )

    df_minimo = ler_csv_inteligente(ARQUIVO_ESTOQUE_MIN)

    return df_estoque, df_loja, df_produto, df_minimo


def validar_colunas(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> None:
    """Valida se todas as colunas exigidas pela atividade estão presentes."""
    exigidas = {
        "fEstoque": {"ID Produto", "Data", "ID Loja", "Movimentação", "Tipo"},
        "dLoja": {"ID Loja", "Loja", "Bairro"},
        "dProduto": {
            "ID Produto",
            "Produto",
            "Categoria",
            "Subcategoria",
            "Custo Unit",
            "Preço Unit",
        },
        "EstoqueMin": {"ID Produto", "Estoque Mínimo"},
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
        raise ValueError("Problemas de estrutura encontrados:\n" + "\n".join(erros))


def tratar_tipos(df_estoque: pd.DataFrame, df_produto: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """Padroniza tipos numéricos e datas para evitar erros silenciosos."""
    df_estoque = df_estoque.copy()
    df_produto = df_produto.copy()

    df_estoque["Data"] = pd.to_datetime(df_estoque["Data"], errors="coerce")
    df_estoque["Movimentação"] = pd.to_numeric(df_estoque["Movimentação"], errors="coerce").fillna(0)
    df_estoque["Tipo"] = df_estoque["Tipo"].astype(str).str.upper().str.strip()

    df_produto["Custo Unit"] = pd.to_numeric(df_produto["Custo Unit"], errors="coerce")
    df_produto["Preço Unit"] = pd.to_numeric(df_produto["Preço Unit"], errors="coerce")

    return df_estoque, df_produto


def auditar_movimentacoes(df_estoque: pd.DataFrame) -> pd.DataFrame:
    """
    Gera uma auditoria simples para confirmar se:
    - Entradas estão positivas.
    - Saídas estão negativas.
    - Há tipos diferentes de E/S.
    """
    auditoria = (
        df_estoque.groupby("Tipo", dropna=False)
        .agg(
            Qtde_Linhas=("Movimentação", "size"),
            Menor_Movimentacao=("Movimentação", "min"),
            Maior_Movimentacao=("Movimentação", "max"),
            Soma_Movimentacao=("Movimentação", "sum"),
        )
        .reset_index()
    )
    return auditoria


def calcular_relatorio_produto(
    df_estoque: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> pd.DataFrame:
    """
    Atende exatamente à regra central da atividade:
    Agrupar fEstoque por ID Produto e somar Movimentação para obter Saldo_Atual.
    """
    df_saldo = (
        df_estoque.groupby("ID Produto", as_index=False)["Movimentação"]
        .sum()
        .rename(columns={"Movimentação": "Saldo_Atual"})
    )

    df_final = (
        df_saldo
        .merge(df_produto, on="ID Produto", how="left")
        .merge(df_minimo, on="ID Produto", how="left")
    )

    df_final["Status_Estoque"] = np.where(
        df_final["Saldo_Atual"] < df_final["Estoque Mínimo"],
        "Abaixo do Mínimo",
        "Estoque Seguro",
    )

    df_final["Qtd_Em_Falta"] = (
        df_final["Estoque Mínimo"] - df_final["Saldo_Atual"]
    ).clip(lower=0)

    df_final["Faturamento_Potencial_Perdido"] = (
        df_final["Qtd_Em_Falta"] * df_final["Preço Unit"]
    )

    df_final["Margem_Unitaria"] = df_final["Preço Unit"] - df_final["Custo Unit"]
    df_final["Lucro_Potencial_Perdido"] = (
        df_final["Qtd_Em_Falta"] * df_final["Margem_Unitaria"]
    )

    return df_final.sort_values("Faturamento_Potencial_Perdido", ascending=False)


def calcular_relatorio_loja_produto(
    df_estoque: pd.DataFrame,
    df_loja: pd.DataFrame,
    df_produto: pd.DataFrame,
    df_minimo: pd.DataFrame,
) -> pd.DataFrame:
    """
    Versão operacional mais forte para diretoria:
    calcula ruptura por loja e produto, pois uma rede varejista precisa saber
    onde enviar mercadoria primeiro.
    """
    df_saldo = (
        df_estoque.groupby(["ID Loja", "ID Produto"], as_index=False)["Movimentação"]
        .sum()
        .rename(columns={"Movimentação": "Saldo_Atual"})
    )

    df_final = (
        df_saldo
        .merge(df_loja, on="ID Loja", how="left")
        .merge(df_produto, on="ID Produto", how="left")
        .merge(df_minimo, on="ID Produto", how="left")
    )

    df_final["Status_Estoque"] = np.where(
        df_final["Saldo_Atual"] < df_final["Estoque Mínimo"],
        "Abaixo do Mínimo",
        "Estoque Seguro",
    )

    df_final["Qtd_Em_Falta"] = (
        df_final["Estoque Mínimo"] - df_final["Saldo_Atual"]
    ).clip(lower=0)

    df_final["Faturamento_Potencial_Perdido"] = (
        df_final["Qtd_Em_Falta"] * df_final["Preço Unit"]
    )

    df_final["Margem_Unitaria"] = df_final["Preço Unit"] - df_final["Custo Unit"]
    df_final["Lucro_Potencial_Perdido"] = (
        df_final["Qtd_Em_Falta"] * df_final["Margem_Unitaria"]
    )

    return df_final.sort_values("Faturamento_Potencial_Perdido", ascending=False)


def gerar_agregacoes(df_loja_produto: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """Cria resumos para priorização logística por categoria e por loja/bairro."""
    criticos = df_loja_produto[df_loja_produto["Status_Estoque"] == "Abaixo do Mínimo"]

    resumo_categoria = (
        criticos.groupby("Categoria", as_index=False)
        .agg(
            Produtos_Criticos=("ID Produto", "count"),
            Unidades_Em_Falta=("Qtd_Em_Falta", "sum"),
            Faturamento_Potencial_Perdido=("Faturamento_Potencial_Perdido", "sum"),
            Lucro_Potencial_Perdido=("Lucro_Potencial_Perdido", "sum"),
        )
        .sort_values("Faturamento_Potencial_Perdido", ascending=False)
    )

    resumo_loja = (
        criticos.groupby(["Loja", "Bairro"], as_index=False)
        .agg(
            Produtos_Criticos=("ID Produto", "count"),
            Unidades_Em_Falta=("Qtd_Em_Falta", "sum"),
            Faturamento_Potencial_Perdido=("Faturamento_Potencial_Perdido", "sum"),
            Lucro_Potencial_Perdido=("Lucro_Potencial_Perdido", "sum"),
        )
        .sort_values("Faturamento_Potencial_Perdido", ascending=False)
    )

    return resumo_categoria, resumo_loja


def formatar_moeda(valor: float) -> str:
    return f"R$ {valor:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")


def gerar_graficos(df_loja_produto: pd.DataFrame) -> None:
    """Gera os gráficos exigidos na atividade usando Matplotlib puro."""
    PASTA_SAIDA.mkdir(exist_ok=True)

    criticos = df_loja_produto[df_loja_produto["Status_Estoque"] == "Abaixo do Mínimo"].copy()

    contagem_categoria = criticos["Categoria"].value_counts().sort_values(ascending=False)

    plt.figure(figsize=(12, 7))
    plt.bar(contagem_categoria.index.astype(str), contagem_categoria.values)
    plt.title("Quantidade de produtos abaixo do mínimo por categoria")
    plt.xlabel("Categoria")
    plt.ylabel("Quantidade de ocorrências críticas")
    plt.xticks(rotation=20, ha="right")
    plt.tight_layout()
    plt.savefig(PASTA_SAIDA / "grafico_criticos_por_categoria.png", dpi=160)
    plt.close()

    categorias = [
        categoria
        for categoria in df_loja_produto["Categoria"].dropna().unique()
    ]
    dados_boxplot = [
        df_loja_produto.loc[df_loja_produto["Categoria"] == categoria, "Saldo_Atual"].dropna().values
        for categoria in categorias
    ]

    plt.figure(figsize=(12, 7))
    plt.boxplot(dados_boxplot, tick_labels=categorias, showmeans=True)
    plt.axhline(0, linestyle="--", linewidth=1.5)
    plt.title("Distribuição do saldo atual por categoria")
    plt.xlabel("Categoria")
    plt.ylabel("Saldo atual")
    plt.xticks(rotation=20, ha="right")
    plt.tight_layout()
    plt.savefig(PASTA_SAIDA / "boxplot_saldo_por_categoria.png", dpi=160)
    plt.close()

    top_15 = criticos.nlargest(15, "Faturamento_Potencial_Perdido").copy()
    top_15["Produto_Loja"] = top_15["Produto"] + " | " + top_15["Loja"]
    top_15 = top_15.sort_values("Faturamento_Potencial_Perdido", ascending=True)

    plt.figure(figsize=(14, 9))
    plt.barh(top_15["Produto_Loja"], top_15["Faturamento_Potencial_Perdido"])
    plt.title("Top 15 rupturas por faturamento potencial perdido")
    plt.xlabel("Faturamento potencial perdido")
    plt.ylabel("Produto | Loja")
    plt.tight_layout()
    plt.savefig(PASTA_SAIDA / "top_15_perda_potencial.png", dpi=160)
    plt.close()

def salvar_relatorios(
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
    resumo_categoria: pd.DataFrame,
    resumo_loja: pd.DataFrame,
    auditoria: pd.DataFrame,
) -> None:
    PASTA_SAIDA.mkdir(exist_ok=True)

    relatorio_produto.to_csv(PASTA_SAIDA / "relatorio_produto.csv", index=False, encoding="utf-8-sig")
    relatorio_loja_produto.to_csv(PASTA_SAIDA / "relatorio_loja_produto.csv", index=False, encoding="utf-8-sig")
    resumo_categoria.to_csv(PASTA_SAIDA / "resumo_categoria.csv", index=False, encoding="utf-8-sig")
    resumo_loja.to_csv(PASTA_SAIDA / "resumo_loja.csv", index=False, encoding="utf-8-sig")
    auditoria.to_csv(PASTA_SAIDA / "auditoria_movimentacoes.csv", index=False, encoding="utf-8-sig")


def imprimir_resumo_executivo(
    df_estoque: pd.DataFrame,
    relatorio_produto: pd.DataFrame,
    relatorio_loja_produto: pd.DataFrame,
    resumo_categoria: pd.DataFrame,
    resumo_loja: pd.DataFrame,
    auditoria: pd.DataFrame,
) -> None:
    """Mostra no terminal os principais achados."""
    qtd_mov = len(df_estoque)
    periodo_ini = df_estoque["Data"].min()
    periodo_fim = df_estoque["Data"].max()

    qtd_produtos = relatorio_produto["ID Produto"].nunique()
    qtd_lojas = relatorio_loja_produto["ID Loja"].nunique()
    total_combinacoes = len(relatorio_loja_produto)
    total_criticos = int((relatorio_loja_produto["Status_Estoque"] == "Abaixo do Mínimo").sum())
    perc_criticos = total_criticos / total_combinacoes if total_combinacoes else 0
    perda_total = relatorio_loja_produto["Faturamento_Potencial_Perdido"].sum()
    saldos_negativos = int((relatorio_loja_produto["Saldo_Atual"] < 0).sum())
    saldos_zerados = int((relatorio_loja_produto["Saldo_Atual"] == 0).sum())

    print("\n" + "=" * 80)
    print("RESUMO EXECUTIVO - INTELIGÊNCIA DE ESTOQUE")
    print("=" * 80)
    print(f"Movimentações analisadas: {qtd_mov:,}".replace(",", "."))
    print(f"Período analisado: {periodo_ini:%d/%m/%Y} até {periodo_fim:%d/%m/%Y}")
    print(f"Produtos cadastrados: {qtd_produtos}")
    print(f"Lojas analisadas: {qtd_lojas}")
    print(f"Combinações Loja x Produto: {total_combinacoes}")
    print(f"Combinações abaixo do mínimo: {total_criticos} ({perc_criticos:.1%})")
    print(f"Faturamento potencial perdido estimado: {formatar_moeda(perda_total)}")
    print(f"Saldos negativos encontrados: {saldos_negativos}")
    print(f"Saldos zerados encontrados: {saldos_zerados}")

    print("\nAUDITORIA DE MOVIMENTAÇÕES")
    print(auditoria.to_string(index=False))

    print("\nRANKING POR CATEGORIA")
    print(resumo_categoria.to_string(index=False))

    print("\nRANKING POR LOJA / BAIRRO")
    print(resumo_loja.to_string(index=False))

    print("\nTOP 10 PRODUTOS/LOJAS COM MAIOR FATURAMENTO POTENCIAL PERDIDO")
    colunas_top = [
        "Loja",
        "Bairro",
        "Produto",
        "Categoria",
        "Saldo_Atual",
        "Estoque Mínimo",
        "Qtd_Em_Falta",
        "Preço Unit",
        "Faturamento_Potencial_Perdido",
    ]
    print(relatorio_loja_produto[colunas_top].head(10).to_string(index=False))

    print("\nArquivos gerados na pasta:", PASTA_SAIDA)
    print("=" * 80 + "\n")


def main() -> None:
    df_estoque, df_loja, df_produto, df_minimo = carregar_dados()

    validar_colunas(df_estoque, df_loja, df_produto, df_minimo)

    df_estoque, df_produto = tratar_tipos(df_estoque, df_produto)

    auditoria = auditar_movimentacoes(df_estoque)

    relatorio_produto = calcular_relatorio_produto(
        df_estoque=df_estoque,
        df_produto=df_produto,
        df_minimo=df_minimo,
    )

    relatorio_loja_produto = calcular_relatorio_loja_produto(
        df_estoque=df_estoque,
        df_loja=df_loja,
        df_produto=df_produto,
        df_minimo=df_minimo,
    )

    resumo_categoria, resumo_loja = gerar_agregacoes(relatorio_loja_produto)

    salvar_relatorios(
        relatorio_produto=relatorio_produto,
        relatorio_loja_produto=relatorio_loja_produto,
        resumo_categoria=resumo_categoria,
        resumo_loja=resumo_loja,
        auditoria=auditoria,
    )

    gerar_graficos(relatorio_loja_produto)

    imprimir_resumo_executivo(
        df_estoque=df_estoque,
        relatorio_produto=relatorio_produto,
        relatorio_loja_produto=relatorio_loja_produto,
        resumo_categoria=resumo_categoria,
        resumo_loja=resumo_loja,
        auditoria=auditoria,
    )


if __name__ == "__main__":
    main()
