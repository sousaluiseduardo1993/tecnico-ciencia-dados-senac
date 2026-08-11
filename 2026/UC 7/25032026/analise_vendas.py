from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


ARQUIVO_EXCEL = Path("vendas.xlsx")
ARQUIVO_BARRAS = Path("grafico_barras.png")
ARQUIVO_BOXPLOT = Path("boxplot_vendas.png")

VALORES_VENDA = [
    1200,
    1350,
    1500,
    1600,
    1700,
    1800,
    1900,
    2000,
    2100,
    2200,
    2300,
    2400,
    2500,
    2600,
    9000,
]


def formatar_brl(valor: float) -> str:
    texto = f"{valor:,.2f}"
    return f"R$ {texto.replace(',', 'X').replace('.', ',').replace('X', '.')}"


def criar_excel_vendas(caminho: Path) -> None:
    vendedores = [f"Vendedor {indice:02d}" for indice in range(1, 16)]
    df_vendas = pd.DataFrame(
        {
            "Vendedor": vendedores,
            "Valor_Venda": VALORES_VENDA,
        }
    )
    df_vendas.to_excel(caminho, index=False)


def normalizar_valor_venda(df: pd.DataFrame) -> pd.DataFrame:
    df["Valor_Venda"] = (
        df["Valor_Venda"]
        .astype(str)
        .str.replace("R$", "", regex=False)
        .str.replace(".", "", regex=False)
        .str.replace(",", ".", regex=False)
        .str.strip()
    )
    df["Valor_Venda"] = pd.to_numeric(df["Valor_Venda"], errors="coerce")
    return df


def validar_colunas(df: pd.DataFrame) -> None:
    colunas_obrigatorias = {"Vendedor", "Valor_Venda"}
    colunas_df = set(df.columns)
    faltando = colunas_obrigatorias - colunas_df
    if faltando:
        raise ValueError(
            "Colunas obrigatorias ausentes no Excel: "
            + ", ".join(sorted(faltando))
        )


def exibir_kpis(df: pd.DataFrame) -> None:
    media = df["Valor_Venda"].mean()
    mediana = df["Valor_Venda"].median()
    moda = df["Valor_Venda"].mode().tolist()
    quartis = df["Valor_Venda"].quantile([0.25, 0.75])

    print("KPIs de Vendas")
    print(f"- Media: {formatar_brl(media)}")
    print(f"- Mediana: {formatar_brl(mediana)}")
    if moda:
        moda_formatada = ", ".join(formatar_brl(valor) for valor in moda)
    else:
        moda_formatada = "Sem moda"
    print(f"- Moda: {moda_formatada}")
    print(f"- Quartil 25% (Q1): {formatar_brl(quartis.loc[0.25])}")
    print(f"- Quartil 75% (Q3): {formatar_brl(quartis.loc[0.75])}")

    if media > mediana:
        print(
            "\nObservacao: o outlier de R$ 9.000,00 puxa a media para cima, "
            "enquanto a mediana se mantem mais representativa do grupo."
        )


def gerar_graficos(df: pd.DataFrame) -> None:
    sns.set_theme(style="whitegrid")

    plt.figure(figsize=(12, 6))
    plt.bar(df["Vendedor"], df["Valor_Venda"], color="#1f77b4")
    plt.title("Desempenho Individual por Vendedor")
    plt.xlabel("Vendedor")
    plt.ylabel("Valor da Venda (R$)")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(ARQUIVO_BARRAS, dpi=300)
    plt.close()

    plt.figure(figsize=(10, 4))
    sns.boxplot(x=df["Valor_Venda"], color="#ff9f43")
    plt.title("Boxplot de Valor de Venda (detalhe de outliers)")
    plt.xlabel("Valor da Venda (R$)")
    plt.tight_layout()
    plt.savefig(ARQUIVO_BOXPLOT, dpi=300)
    plt.close()

    print(f"\nGraficos salvos: {ARQUIVO_BARRAS.name} e {ARQUIVO_BOXPLOT.name}")


def main() -> None:
    criar_excel_vendas(ARQUIVO_EXCEL)
    print(f"Arquivo Excel criado/recriado: {ARQUIVO_EXCEL.name}")

    df = pd.read_excel(ARQUIVO_EXCEL)
    df.columns = df.columns.str.strip()

    validar_colunas(df)
    df = normalizar_valor_venda(df)
    if df["Valor_Venda"].isna().any():
        raise ValueError(
            "Existem valores invalidos na coluna 'Valor_Venda' apos conversao."
        )

    exibir_kpis(df)
    gerar_graficos(df)


if __name__ == "__main__":
    main()
