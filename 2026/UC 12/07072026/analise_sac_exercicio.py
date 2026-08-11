"""
Análise de Dados SAC — Exercício de SLA e Chamados Técnicos

Versão ajustada para resolver problemas de cruzamento com dSuporte.

Objetivo:
- Carregar as bases fOcorrencias.csv, dUsuario.csv, dSuporte.csv e dProblema.csv
- Tratar datas de abertura e fechamento
- Padronizar chaves relacionais antes dos merges
- Cruzar as tabelas relacionais
- Calcular o tempo de resolução em dias
- Gerar métricas de SLA médio por problema e por suporte
- Criar gráficos para apoiar a análise gerencial

Bibliotecas necessárias:
    pip install pandas matplotlib seaborn openpyxl

Como executar:
    python analise_sac_exercicio_corrigido.py

Estrutura esperada:
    analise_sac_exercicio_corrigido.py
    fOcorrencias.csv
    dUsuario.csv
    dSuporte.csv
    dProblema.csv
    ou Base SAC.xlsx com abas dUsuario, dSuporte, dProblema e fOcorrencias

Saídas:
    ./saida_sac/
        base_sac_tratada.csv
        sla_medio_por_problema.csv
        sla_medio_por_suporte.csv
        chamados_por_mes.csv
        diagnostico_cruzamentos.txt
        grafico_sla_medio_por_problema.png
        grafico_chamados_por_mes.png
"""

from __future__ import annotations

from pathlib import Path
import csv

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


PASTA_PROJETO = Path(__file__).resolve().parent
PASTA_SAIDA = PASTA_PROJETO / "saida_sac"

ARQUIVOS_ENTRADA = {
    "ocorrencias": PASTA_PROJETO / "fOcorrencias.csv",
    "usuarios": PASTA_PROJETO / "dUsuario.csv",
    "suportes": PASTA_PROJETO / "dSuporte.csv",
    "problemas": PASTA_PROJETO / "dProblema.csv",
}

ARQUIVO_EXCEL_ENTRADA = PASTA_PROJETO / "Base SAC.xlsx"

ABAS_EXCEL = {
    "ocorrencias": "fOcorrencias",
    "usuarios": "dUsuario",
    "suportes": "dSuporte",
    "problemas": "dProblema",
}

APELIDOS_COLUNAS = {
    "Data Chamado": "Data Abertura",
    "Data Resposta": "Data Fechamento",
    "ID problema": "ID Problema",
    "Nome Cliente": "Nome Suporte",
}


def detectar_separador(caminho: Path) -> str:
    """
    Detecta automaticamente o separador do CSV.
    Isso evita erro quando os arquivos vêm separados por vírgula, ponto e vírgula ou tabulação.
    """
    amostra = caminho.read_text(encoding="utf-8-sig", errors="ignore")[:4096]

    try:
        dialecto = csv.Sniffer().sniff(amostra, delimiters=",;\t|")
        return dialecto.delimiter
    except csv.Error:
        return ","


def carregar_csv(caminho: Path) -> pd.DataFrame:
    """
    Carrega um CSV preservando as colunas de ID como texto.
    Preservar como texto ajuda a evitar incompatibilidades entre 1, 1.0 e '001'.
    """
    separador = detectar_separador(caminho)

    return pd.read_csv(
        caminho,
        sep=separador,
        dtype=str,
        encoding="utf-8-sig",
    )


def carregar_excel(caminho: Path) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Carrega as quatro bases a partir de uma planilha Excel com abas nomeadas.
    """
    try:
        with pd.ExcelFile(caminho) as arquivo_excel:
            abas_disponiveis = set(arquivo_excel.sheet_names)
            abas_faltantes = [
                aba for aba in ABAS_EXCEL.values()
                if aba not in abas_disponiveis
            ]

            if abas_faltantes:
                raise ValueError(
                    f"O arquivo {caminho.name} nao possui as abas obrigatorias: "
                    + ", ".join(abas_faltantes)
                )

            df_ocorrencias = pd.read_excel(
                arquivo_excel,
                sheet_name=ABAS_EXCEL["ocorrencias"],
                dtype=str,
            )
            df_usuarios = pd.read_excel(
                arquivo_excel,
                sheet_name=ABAS_EXCEL["usuarios"],
                dtype=str,
            )
            df_suportes = pd.read_excel(
                arquivo_excel,
                sheet_name=ABAS_EXCEL["suportes"],
                dtype=str,
            )
            df_problemas = pd.read_excel(
                arquivo_excel,
                sheet_name=ABAS_EXCEL["problemas"],
                dtype=str,
            )
    except ImportError as erro:
        raise ImportError(
            f"Para carregar {caminho.name}, instale a dependencia openpyxl: "
            "pip install openpyxl"
        ) from erro

    return df_ocorrencias, df_usuarios, df_suportes, df_problemas


def carregar_bases() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Carrega as bases do exercício.

    Prioriza os quatro CSVs separados. Se eles nao existirem todos, tenta usar
    a planilha Base SAC.xlsx com uma aba para cada base.
    """
    arquivos_faltantes = [
        caminho.name
        for caminho in ARQUIVOS_ENTRADA.values()
        if not caminho.exists()
    ]

    if not arquivos_faltantes:
        df_ocorrencias = carregar_csv(ARQUIVOS_ENTRADA["ocorrencias"])
        df_usuarios = carregar_csv(ARQUIVOS_ENTRADA["usuarios"])
        df_suportes = carregar_csv(ARQUIVOS_ENTRADA["suportes"])
        df_problemas = carregar_csv(ARQUIVOS_ENTRADA["problemas"])

        return df_ocorrencias, df_usuarios, df_suportes, df_problemas

    if ARQUIVO_EXCEL_ENTRADA.exists():
        return carregar_excel(ARQUIVO_EXCEL_ENTRADA)

    raise FileNotFoundError(
        "Os seguintes arquivos CSV obrigatorios nao foram encontrados na pasta do projeto: "
        + ", ".join(arquivos_faltantes)
        + f". Tambem nao foi encontrado o arquivo {ARQUIVO_EXCEL_ENTRADA.name}."
    )


def limpar_nomes_colunas(df: pd.DataFrame) -> pd.DataFrame:
    """
    Remove espaços extras e padroniza nomes alternativos das colunas.
    """
    df_limpo = df.copy()
    df_limpo.columns = [str(coluna).strip() for coluna in df_limpo.columns]
    df_limpo = df_limpo.rename(
        columns={
            coluna_origem: coluna_destino
            for coluna_origem, coluna_destino in APELIDOS_COLUNAS.items()
            if coluna_origem in df_limpo.columns
            and coluna_destino not in df_limpo.columns
        }
    )
    return df_limpo


def validar_colunas_obrigatorias(
    df_ocorrencias: pd.DataFrame,
    df_suportes: pd.DataFrame,
    df_problemas: pd.DataFrame,
) -> None:
    """
    Verifica se as colunas centrais do exercício estão disponíveis.
    """
    colunas_ocorrencias = {
        "Data Abertura",
        "Data Fechamento",
        "ID Problema",
        "ID Suporte",
    }
    colunas_suportes = {"ID Suporte", "Nome Suporte"}
    colunas_problemas = {"ID Problema", "Problema"}

    ausentes_ocorrencias = colunas_ocorrencias.difference(df_ocorrencias.columns)
    ausentes_suportes = colunas_suportes.difference(df_suportes.columns)
    ausentes_problemas = colunas_problemas.difference(df_problemas.columns)

    mensagens_erro = []

    if ausentes_ocorrencias:
        mensagens_erro.append(f"fOcorrencias.csv: {sorted(ausentes_ocorrencias)}")

    if ausentes_suportes:
        mensagens_erro.append(f"dSuporte.csv: {sorted(ausentes_suportes)}")

    if ausentes_problemas:
        mensagens_erro.append(f"dProblema.csv: {sorted(ausentes_problemas)}")

    if mensagens_erro:
        raise KeyError(
            "Colunas obrigatórias não encontradas:\n- " + "\n- ".join(mensagens_erro)
        )


def normalizar_chave(valor: object) -> str | pd.NA:
    """
    Padroniza chaves de relacionamento.

    Resolve casos comuns:
    - 1, '1', '1.0' passam a ser '1'
    - espaços antes/depois são removidos
    - texto vazio vira valor ausente
    - IDs com zeros à esquerda são comparados de forma numérica quando possível
    """
    if pd.isna(valor):
        return pd.NA

    texto = str(valor).strip()

    if texto == "":
        return pd.NA

    texto = texto.replace(",", ".")

    numero = pd.to_numeric(texto, errors="coerce")

    if pd.notna(numero) and float(numero).is_integer():
        return str(int(numero))

    return texto.upper()


def converter_coluna_data(serie: pd.Series) -> pd.Series:
    """
    Converte datas aceitando tanto formato ISO do Excel quanto formato brasileiro.
    """
    serie_texto = serie.astype("string").str.strip()
    datas = pd.Series(pd.NaT, index=serie.index, dtype="datetime64[ns]")

    mascara_iso = serie_texto.str.match(r"^\d{4}[-/]\d{1,2}[-/]\d{1,2}", na=False)
    if mascara_iso.any():
        datas.loc[mascara_iso] = pd.to_datetime(
            serie_texto.loc[mascara_iso],
            errors="coerce",
            yearfirst=True,
        )

    mascara_restante = ~mascara_iso
    if mascara_restante.any():
        datas.loc[mascara_restante] = pd.to_datetime(
            serie_texto.loc[mascara_restante],
            errors="coerce",
            dayfirst=True,
        )

    tem_valor = serie_texto.fillna("").ne("")
    mascara_fallback = datas.isna() & tem_valor
    if mascara_fallback.any():
        datas.loc[mascara_fallback] = pd.to_datetime(
            serie_texto.loc[mascara_fallback],
            errors="coerce",
            dayfirst=False,
        )

    return datas


def padronizar_chaves_relacionais(
    df_ocorrencias: pd.DataFrame,
    df_usuarios: pd.DataFrame,
    df_suportes: pd.DataFrame,
    df_problemas: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Cria colunas técnicas de chave para garantir que os merges funcionem corretamente.
    """
    df_ocorrencias = df_ocorrencias.copy()
    df_usuarios = df_usuarios.copy()
    df_suportes = df_suportes.copy()
    df_problemas = df_problemas.copy()

    df_ocorrencias["Chave_ID_Problema"] = df_ocorrencias["ID Problema"].map(normalizar_chave)
    df_problemas["Chave_ID_Problema"] = df_problemas["ID Problema"].map(normalizar_chave)

    df_ocorrencias["Chave_ID_Suporte"] = df_ocorrencias["ID Suporte"].map(normalizar_chave)
    df_suportes["Chave_ID_Suporte"] = df_suportes["ID Suporte"].map(normalizar_chave)

    if "ID Usuario" in df_ocorrencias.columns and "ID Usuario" in df_usuarios.columns:
        df_ocorrencias["Chave_ID_Usuario"] = df_ocorrencias["ID Usuario"].map(normalizar_chave)
        df_usuarios["Chave_ID_Usuario"] = df_usuarios["ID Usuario"].map(normalizar_chave)

    return df_ocorrencias, df_usuarios, df_suportes, df_problemas


def tratar_datas_e_calcular_sla(df_ocorrencias: pd.DataFrame) -> pd.DataFrame:
    """
    Converte as datas de texto para datetime e cria a coluna Dias_Resolucao.
    """
    df = df_ocorrencias.copy()

    df["Data Abertura"] = converter_coluna_data(df["Data Abertura"])
    df["Data Fechamento"] = converter_coluna_data(df["Data Fechamento"])

    df["Dias_Resolucao"] = (
        df["Data Fechamento"] - df["Data Abertura"]
    ).dt.days

    registros_com_data_invalida = df[
        df["Data Abertura"].isna() | df["Data Fechamento"].isna()
    ]

    if not registros_com_data_invalida.empty:
        print(
            f"Aviso: {len(registros_com_data_invalida)} ocorrência(s) possuem "
            "data de abertura ou fechamento inválida/ausente."
        )

    registros_com_sla_negativo = df[df["Dias_Resolucao"] < 0]

    if not registros_com_sla_negativo.empty:
        print(
            f"Aviso: {len(registros_com_sla_negativo)} ocorrência(s) possuem "
            "Data Fechamento anterior à Data Abertura."
        )

    return df


def diagnosticar_chaves(
    df_ocorrencias: pd.DataFrame,
    df_suportes: pd.DataFrame,
    df_problemas: pd.DataFrame,
) -> str:
    """
    Gera um diagnóstico simples das chaves usadas nos cruzamentos.
    """
    ids_suporte_ocorrencias = set(df_ocorrencias["Chave_ID_Suporte"].dropna())
    ids_suporte_cadastro = set(df_suportes["Chave_ID_Suporte"].dropna())
    ids_suporte_sem_cadastro = sorted(ids_suporte_ocorrencias - ids_suporte_cadastro)

    ids_problema_ocorrencias = set(df_ocorrencias["Chave_ID_Problema"].dropna())
    ids_problema_cadastro = set(df_problemas["Chave_ID_Problema"].dropna())
    ids_problema_sem_cadastro = sorted(ids_problema_ocorrencias - ids_problema_cadastro)

    linhas = [
        "DIAGNÓSTICO DOS CRUZAMENTOS",
        "=" * 35,
        "",
        f"IDs de suporte distintos em fOcorrencias: {len(ids_suporte_ocorrencias)}",
        f"IDs de suporte distintos em dSuporte: {len(ids_suporte_cadastro)}",
        f"IDs de suporte em ocorrências sem cadastro: {len(ids_suporte_sem_cadastro)}",
        f"Exemplos de IDs de suporte sem cadastro: {ids_suporte_sem_cadastro[:20]}",
        "Ocorrencias sem cadastro em dSuporte foram mantidas na analise "
        "como 'Suporte sem cadastro (ID X)'.",
        "",
        f"IDs de problema distintos em fOcorrencias: {len(ids_problema_ocorrencias)}",
        f"IDs de problema distintos em dProblema: {len(ids_problema_cadastro)}",
        f"IDs de problema em ocorrências sem cadastro: {len(ids_problema_sem_cadastro)}",
        f"Exemplos de IDs de problema sem cadastro: {ids_problema_sem_cadastro[:20]}",
    ]

    return "\n".join(linhas)


def preencher_suportes_sem_cadastro(df_base: pd.DataFrame) -> pd.DataFrame:
    """
    Mantem ocorrencias com ID Suporte sem cadastro na analise por suporte.
    """
    df = df_base.copy()

    if "Nome Suporte" not in df.columns or "Chave_ID_Suporte" not in df.columns:
        return df

    mascara_sem_cadastro = df["Nome Suporte"].isna() & df["Chave_ID_Suporte"].notna()

    if mascara_sem_cadastro.any():
        ids_suporte = df.loc[mascara_sem_cadastro, "Chave_ID_Suporte"].astype("string")
        df.loc[mascara_sem_cadastro, "Nome Suporte"] = (
            "Suporte sem cadastro (ID " + ids_suporte + ")"
        )

    return df


def cruzar_bases(
    df_ocorrencias: pd.DataFrame,
    df_usuarios: pd.DataFrame,
    df_suportes: pd.DataFrame,
    df_problemas: pd.DataFrame,
) -> pd.DataFrame:
    """
    Realiza os cruzamentos relacionais pedidos no exercício.

    Cruzamentos principais:
    1. fOcorrencias com dProblema usando ID Problema.
    2. Resultado com dSuporte usando ID Suporte.

    A base de usuários também é incorporada para preservar o contexto demográfico.
    """
    colunas_problemas = [
        coluna for coluna in df_problemas.columns
        if coluna not in {"ID Problema"}
    ]

    df_base = df_ocorrencias.merge(
        df_problemas[colunas_problemas],
        on="Chave_ID_Problema",
        how="left",
        validate="many_to_one",
    )

    colunas_suportes = [
        coluna for coluna in df_suportes.columns
        if coluna not in {"ID Suporte"}
    ]

    df_base = df_base.merge(
        df_suportes[colunas_suportes],
        on="Chave_ID_Suporte",
        how="left",
        validate="many_to_one",
        suffixes=("", "_Suporte"),
    )

    df_base = preencher_suportes_sem_cadastro(df_base)

    if "Chave_ID_Usuario" in df_base.columns and "Chave_ID_Usuario" in df_usuarios.columns:
        colunas_usuarios = [
            coluna for coluna in df_usuarios.columns
            if coluna not in {"ID Usuario"}
        ]

        df_base = df_base.merge(
            df_usuarios[colunas_usuarios],
            on="Chave_ID_Usuario",
            how="left",
            validate="many_to_one",
            suffixes=("", "_Usuario"),
        )

    problemas_sem_cadastro = df_base["Problema"].isna().sum()

    if problemas_sem_cadastro > 0:
        print(
            f"Aviso: {problemas_sem_cadastro} ocorrência(s) não encontraram "
            "correspondência na tabela dProblema."
        )

    return df_base


def calcular_indicadores(df_base: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Calcula as métricas principais solicitadas:
    - SLA médio por tipo de problema
    - SLA médio por analista de suporte
    - Quantidade de chamados abertos ao longo dos meses
    """
    df_fechados = df_base.dropna(subset=["Dias_Resolucao"]).copy()
    df_fechados = df_fechados[df_fechados["Dias_Resolucao"] >= 0]

    sla_medio_por_problema = (
        df_fechados
        .dropna(subset=["Problema"])
        .groupby("Problema", as_index=False)["Dias_Resolucao"]
        .mean()
        .sort_values("Dias_Resolucao", ascending=False)
    )

    sla_medio_por_problema["Dias_Resolucao"] = (
        sla_medio_por_problema["Dias_Resolucao"].round(2)
    )

    sla_medio_por_suporte = (
        df_fechados
        .dropna(subset=["Nome Suporte"])
        .groupby("Nome Suporte", as_index=False)["Dias_Resolucao"]
        .mean()
        .sort_values("Dias_Resolucao", ascending=False)
    )

    sla_medio_por_suporte["Dias_Resolucao"] = (
        sla_medio_por_suporte["Dias_Resolucao"].round(2)
    )

    chamados_por_mes = df_base.dropna(subset=["Data Abertura"]).copy()
    chamados_por_mes["Mes_Abertura"] = (
        chamados_por_mes["Data Abertura"]
        .dt.to_period("M")
        .dt.to_timestamp()
    )

    chamados_por_mes = (
        chamados_por_mes
        .groupby("Mes_Abertura", as_index=False)
        .size()
        .rename(columns={"size": "Quantidade_Chamados"})
        .sort_values("Mes_Abertura")
    )

    return sla_medio_por_problema, sla_medio_por_suporte, chamados_por_mes


def gerar_grafico_sla_por_problema(sla_medio_por_problema: pd.DataFrame) -> None:
    """
    Gera gráfico de barras horizontais com o SLA médio por tipo de problema.
    """
    plt.figure(figsize=(12, 7))

    sns.barplot(
        data=sla_medio_por_problema,
        x="Dias_Resolucao",
        y="Problema",
        order=sla_medio_por_problema["Problema"],
    )

    plt.title("SLA Médio por Tipo de Problema")
    plt.xlabel("Média de Dias para Resolução")
    plt.ylabel("Tipo de Problema")
    plt.tight_layout()

    caminho_saida = PASTA_SAIDA / "grafico_sla_medio_por_problema.png"
    plt.savefig(caminho_saida, dpi=160)
    plt.close()


def gerar_grafico_chamados_por_mes(chamados_por_mes: pd.DataFrame) -> None:
    """
    Gera gráfico de linhas com a quantidade de chamados abertos por mês.
    """
    plt.figure(figsize=(12, 6))

    sns.lineplot(
        data=chamados_por_mes,
        x="Mes_Abertura",
        y="Quantidade_Chamados",
        marker="o",
    )

    plt.title("Quantidade de Chamados Abertos ao Longo dos Meses")
    plt.xlabel("Mês de Abertura")
    plt.ylabel("Quantidade de Chamados")
    plt.xticks(rotation=45)
    plt.tight_layout()

    caminho_saida = PASTA_SAIDA / "grafico_chamados_por_mes.png"
    plt.savefig(caminho_saida, dpi=160)
    plt.close()


def salvar_resultados(
    df_base: pd.DataFrame,
    sla_medio_por_problema: pd.DataFrame,
    sla_medio_por_suporte: pd.DataFrame,
    chamados_por_mes: pd.DataFrame,
    diagnostico: str,
) -> None:
    """
    Salva as bases finais utilizadas na análise.
    """
    PASTA_SAIDA.mkdir(exist_ok=True)

    df_base.to_csv(
        PASTA_SAIDA / "base_sac_tratada.csv",
        index=False,
        encoding="utf-8-sig",
    )

    sla_medio_por_problema.to_csv(
        PASTA_SAIDA / "sla_medio_por_problema.csv",
        index=False,
        encoding="utf-8-sig",
    )

    sla_medio_por_suporte.to_csv(
        PASTA_SAIDA / "sla_medio_por_suporte.csv",
        index=False,
        encoding="utf-8-sig",
    )

    chamados_por_mes.to_csv(
        PASTA_SAIDA / "chamados_por_mes.csv",
        index=False,
        encoding="utf-8-sig",
    )

    (PASTA_SAIDA / "diagnostico_cruzamentos.txt").write_text(
        diagnostico,
        encoding="utf-8",
    )


def exibir_resumo(
    df_base: pd.DataFrame,
    sla_medio_por_problema: pd.DataFrame,
    sla_medio_por_suporte: pd.DataFrame,
    chamados_por_mes: pd.DataFrame,
) -> None:
    """
    Exibe no terminal um resumo objetivo dos principais resultados.
    """
    print("\nResumo da análise")
    print("-" * 60)
    print(f"Total de chamados analisados: {len(df_base)}")
    print(f"Chamados com data de fechamento válida: {df_base['Dias_Resolucao'].notna().sum()}")

    if not sla_medio_por_problema.empty:
        problema_critico = sla_medio_por_problema.iloc[0]
        print(
            "Problema com maior SLA médio: "
            f"{problema_critico['Problema']} "
            f"({problema_critico['Dias_Resolucao']} dias)"
        )

    if not sla_medio_por_suporte.empty:
        suporte_maior_sla = sla_medio_por_suporte.iloc[0]
        print(
            "Analista com maior SLA médio: "
            f"{suporte_maior_sla['Nome Suporte']} "
            f"({suporte_maior_sla['Dias_Resolucao']} dias)"
        )

    if not chamados_por_mes.empty:
        mes_pico = chamados_por_mes.sort_values(
            "Quantidade_Chamados",
            ascending=False,
        ).iloc[0]

        print(
            "Mês com maior volume de chamados: "
            f"{mes_pico['Mes_Abertura'].strftime('%Y-%m')} "
            f"({mes_pico['Quantidade_Chamados']} chamados)"
        )

    print("-" * 60)
    print(f"Arquivos salvos em: {PASTA_SAIDA}")


def main() -> None:
    """
    Executa o fluxo completo da análise.
    """
    print("Iniciando análise dos chamados do SAC...")

    df_ocorrencias, df_usuarios, df_suportes, df_problemas = carregar_bases()

    df_ocorrencias = limpar_nomes_colunas(df_ocorrencias)
    df_usuarios = limpar_nomes_colunas(df_usuarios)
    df_suportes = limpar_nomes_colunas(df_suportes)
    df_problemas = limpar_nomes_colunas(df_problemas)

    validar_colunas_obrigatorias(
        df_ocorrencias=df_ocorrencias,
        df_suportes=df_suportes,
        df_problemas=df_problemas,
    )

    (
        df_ocorrencias,
        df_usuarios,
        df_suportes,
        df_problemas,
    ) = padronizar_chaves_relacionais(
        df_ocorrencias=df_ocorrencias,
        df_usuarios=df_usuarios,
        df_suportes=df_suportes,
        df_problemas=df_problemas,
    )

    diagnostico = diagnosticar_chaves(
        df_ocorrencias=df_ocorrencias,
        df_suportes=df_suportes,
        df_problemas=df_problemas,
    )

    df_ocorrencias = tratar_datas_e_calcular_sla(df_ocorrencias)

    df_base = cruzar_bases(
        df_ocorrencias=df_ocorrencias,
        df_usuarios=df_usuarios,
        df_suportes=df_suportes,
        df_problemas=df_problemas,
    )

    (
        sla_medio_por_problema,
        sla_medio_por_suporte,
        chamados_por_mes,
    ) = calcular_indicadores(df_base)

    salvar_resultados(
        df_base=df_base,
        sla_medio_por_problema=sla_medio_por_problema,
        sla_medio_por_suporte=sla_medio_por_suporte,
        chamados_por_mes=chamados_por_mes,
        diagnostico=diagnostico,
    )

    gerar_grafico_sla_por_problema(sla_medio_por_problema)
    gerar_grafico_chamados_por_mes(chamados_por_mes)

    exibir_resumo(
        df_base=df_base,
        sla_medio_por_problema=sla_medio_por_problema,
        sla_medio_por_suporte=sla_medio_por_suporte,
        chamados_por_mes=chamados_por_mes,
    )


if __name__ == "__main__":
    main()
