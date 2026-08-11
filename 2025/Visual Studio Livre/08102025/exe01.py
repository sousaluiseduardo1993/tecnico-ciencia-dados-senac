import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from rich.console import Console
from rich.table import Table

# === Constantes ===
CSV_PATH = Path("dados_vendas.csv")
THRESHOLD_ALTO_DESEMPENHO = 10_000

# === Console ===
console = Console()

# === Funções ===
def read_data(path: Path) -> pd.DataFrame:
    """Lê o CSV e normaliza colunas de texto."""
    if not path.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {path}")
    df = pd.read_csv(path)
    expected_cols = {"Categoria", "Regiao", "Vendas"}
    if not expected_cols.issubset(df.columns):
        raise ValueError(f"O CSV deve conter colunas: {expected_cols}")
    df["Categoria"] = df["Categoria"].astype(str).str.strip().str.title()
    df["Regiao"] = df["Regiao"].astype(str).str.strip().str.title()
    return df

def calcular_vendas(df: pd.DataFrame) -> tuple[pd.Series, pd.Series]:
    """Retorna totais por região e por categoria premium."""
    total = df.groupby("Regiao")["Vendas"].sum()
    premium = df[df["Categoria"] == "Premium"].groupby("Regiao")["Vendas"].sum()
    return total, premium

def criar_tabela_comparativa(total: pd.Series, premium: pd.Series) -> pd.DataFrame:
    """Cria tabela com totais e premium por região."""
    tabela = pd.DataFrame({
        "Vendas_Totais": total,
        "Vendas_Premium": premium
    }).fillna(0)
    return tabela.sort_values("Vendas_Totais", ascending=False)

def exibir_tabela(df: pd.DataFrame, titulo: str) -> None:
    """Exibe DataFrame formatado no terminal com Rich."""
    table = Table(title=titulo, header_style="bold cyan", show_lines=True)
    for col in df.columns:
        table.add_column(str(col), justify="center", style="bold white")
    for _, row in df.iterrows():
        table.add_row(*[str(v) for v in row])
    console.print(table)

def plotar_barras(df: pd.DataFrame, titulo: str, xlabel: str, ylabel: str, cores=None) -> None:
    """Gera gráfico de barras com labels e estilo refinado."""
    sns.set_theme(style="whitegrid", palette="muted")
    ax = df.plot(kind="bar", figsize=(9, 5), title=titulo, color=cores)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.grid(axis="y", linestyle="--", alpha=0.6)
    for container in ax.containers:
        ax.bar_label(container, fmt="%.0f", label_type="edge", padding=3, fontsize=9)
    plt.tight_layout()
    plt.show()

def analisar_categorias(df: pd.DataFrame) -> pd.DataFrame:
    """Cria resumo por categoria."""
    totais = df.groupby("Categoria")["Vendas"].sum()
    total_geral = totais.sum()
    percentual = (totais / total_geral * 100).round(1)
    resumo = pd.DataFrame({
        "Total (R$)": totais,
        "Percentual (%)": percentual
    }).sort_values("Total (R$)", ascending=False)
    return resumo

def formatar_valor(v: float) -> str:
    """Formata número em R$ brasileiro."""
    return f"R$ {v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

def resumo_executivo(resumo_cat: pd.DataFrame, regioes_alto: pd.DataFrame) -> None:
    """Gera frase automática de resumo de resultados."""
    top_cat = resumo_cat.index[0]
    melhor_regiao = regioes_alto.iloc[0, 0]
    pct = resumo_cat.loc[top_cat, "Percentual (%)"]
    console.print(f"\n📊 [bold yellow]Categoria líder:[/bold yellow] {top_cat} ({pct}%)")
    console.print(f"🏆 [bold green]Região com maior desempenho:[/bold green] {melhor_regiao}\n")

# === Fluxo Principal ===
def main() -> None:
    df = read_data(CSV_PATH)
    vendas_total, vendas_premium = calcular_vendas(df)
    regioes_alto = vendas_total[vendas_total > THRESHOLD_ALTO_DESEMPENHO]

    # --- Tabela Comparativa ---
    tabela = criar_tabela_comparativa(vendas_total, vendas_premium)
    exibir_tabela(tabela.reset_index().rename(columns={"Regiao": "Região"}), "Vendas Totais vs Premium por Região")
    plotar_barras(tabela, "Vendas Totais vs Vendas Premium por Região", "Região", "Vendas (R$)", ["#4C72B0", "#55A868"])

    # --- Categorias ---
    resumo_cat = analisar_categorias(df)
    exibir_tabela(resumo_cat.reset_index().rename(columns={"Categoria": "Categoria"}), "Resumo por Categoria")
    plotar_barras(resumo_cat[["Total (R$)"]], "Vendas por Categoria", "Categoria", "Vendas (R$)", ["#C44E52"])

    # --- Regiões de alto desempenho ---
    df_regioes_alto = (
        regioes_alto.reset_index()
        .rename(columns={"Regiao": "Região", 0: "Vendas"})
        .sort_values("Vendas", ascending=False)
    )
    df_regioes_alto["Vendas (R$)"] = df_regioes_alto["Vendas"].apply(formatar_valor)
    df_regioes_alto = df_regioes_alto[["Região", "Vendas (R$)"]]
    exibir_tabela(df_regioes_alto, "Regiões de Alto Desempenho (vendas > R$ 10.000)")

    # --- Resumo Executivo ---
    resumo_executivo(resumo_cat, df_regioes_alto)

# === Execução ===
if __name__ == "__main__":
    main()
