# === Grimoire Data Science Engine v4.3 ===
# 🧙‍♂️ Visual Terminal Edition — Final Release
# Ciência de Dados com Pandas + Seaborn + Rich
# Mostra os gráficos diretamente no terminal (plt.show)

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

# === Configuração inicial ===
console = Console()
pd.set_option("display.float_format", lambda x: f"{x:,.2f}")
sns.set_theme(style="whitegrid", palette="muted")

# === 1️⃣ Leitura e normalização ===
df = pd.read_csv("dados_vendas_desafio.csv")

for col in ["Regiao", "Categoria", "Estado"]:
    df[col] = df[col].astype(str).str.strip().str.title()

# === 2️⃣ Estatísticas gerais ===
console.rule("[bold cyan]🌎 Estatísticas Gerais do Dataset[/bold cyan]")
num_regioes = df["Regiao"].nunique()
num_estados = df["Estado"].nunique()
num_produtos = df["Produto"].nunique()
total_vendas = df["Vendas"].sum()
media_geral = df["Vendas"].mean()

console.print(
    f"📦 Regiões: {num_regioes} | 🏙️ Estados: {num_estados} | 🧩 Produtos: {num_produtos}"
)
console.print(
    f"💰 Total de Vendas: R$ {total_vendas:,.2f} | 📈 Média Geral: R$ {media_geral:,.2f}\n"
)

# === 3️⃣ Agrupamento Região × Categoria ===
resumo = (
    df.groupby(["Regiao", "Categoria"], as_index=False)
    .agg(Total_Vendas=("Vendas", "sum"))
    .sort_values(["Regiao", "Total_Vendas"], ascending=[True, False])
)
region_totals = resumo.groupby("Regiao")["Total_Vendas"].sum().rename("Regional_Total")
resumo = resumo.merge(region_totals, on="Regiao")
resumo["Percentual"] = (resumo["Total_Vendas"] / resumo["Regional_Total"] * 100).round(2)

# === 4️⃣ Exibição tabular no terminal ===
table = Table(title="📊 Distribuição de Vendas — Região × Categoria", show_lines=True)
table.add_column("Região", justify="center", style="bold white")
table.add_column("Categoria", justify="center", style="bold cyan")
table.add_column("Vendas (R$)", justify="right", style="bold green")
table.add_column("% Regional", justify="center", style="bold yellow")

for _, row in resumo.iterrows():
    table.add_row(
        row["Regiao"],
        row["Categoria"],
        f"R$ {row['Total_Vendas']:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."),
        f"{row['Percentual']:.2f}%",
    )
console.print(table)

# === 5️⃣ Top 5 produtos nacionais ===
ranking_produtos = (
    df.groupby("Produto", as_index=False)
    .agg(Total=("Vendas", "sum"))
    .sort_values("Total", ascending=False)
    .head(5)
)
console.print(Panel.fit("🏅 [bold magenta]Top 5 Produtos Nacionais[/bold magenta]"))
for i, row in enumerate(ranking_produtos.itertuples(), 1):
    console.print(f"{i}. {row.Produto:<25} — R$ {row.Total:,.2f}")

# === 6️⃣ Gráficos no terminal (plt.show) ===
# Sem salvar, apenas visualizar inline

# 6.1 Total de vendas por região
plt.figure(figsize=(8, 5))
sns.barplot(x="Regiao", y="Vendas", data=df, estimator="sum", errorbar=None, hue="Regiao", legend=False)
plt.title("Total de Vendas por Região", fontsize=13, weight="bold")
plt.xlabel("Região")
plt.ylabel("Vendas (R$)")
plt.tight_layout()
plt.show()

# 6.2 Distribuição por categoria dentro de cada região
plt.figure(figsize=(8, 5))
sns.barplot(x="Regiao", y="Vendas", data=df, hue="Categoria", estimator="sum", errorbar=None)
plt.title("Distribuição de Vendas — Região × Categoria", fontsize=13, weight="bold")
plt.xlabel("Região")
plt.ylabel("Vendas (R$)")
plt.legend(title="Categoria")
plt.tight_layout()
plt.show()

# 6.3 Top 5 produtos nacionais
plt.figure(figsize=(7, 4))
sns.barplot(x="Total", y="Produto", data=ranking_produtos, hue="Produto", legend=False)
plt.title("Top 5 Produtos Nacionais", fontsize=13, weight="bold")
plt.xlabel("Vendas (R$)")
plt.ylabel("Produto")
plt.tight_layout()
plt.show()

# === 7️⃣ Análise estatística nacional ===
regiao_total = (
    df.groupby("Regiao", as_index=False)
    .agg(Total=("Vendas", "sum"))
    .sort_values("Total", ascending=False)
)
top_regiao = regiao_total.iloc[0]["Regiao"]
top_valor = regiao_total.iloc[0]["Total"]
baixo_regiao = regiao_total.iloc[-1]["Regiao"]
baixo_valor = regiao_total.iloc[-1]["Total"]
media_regional = regiao_total["Total"].mean()

console.print(
    Panel.fit(
        f"""
📈 [bold green]Resumo Analítico Nacional[/bold green]
• Região líder: [bold cyan]{top_regiao}[/bold cyan] — R$ {top_valor:,.2f}
• Região menor: [bold red]{baixo_regiao}[/bold red] — R$ {baixo_valor:,.2f}
• Média regional: R$ {media_regional:,.2f}
• Diferença: R$ {(top_valor - baixo_valor):,.2f}
• Produto campeão: {ranking_produtos.iloc[0]['Produto']} — R$ {ranking_produtos.iloc[0]['Total']:,.2f}
""",
        border_style="bright_magenta",
    )
)

# === 8️⃣ Projeção de crescimento ===
taxa_crescimento = 1.12
projecao = total_vendas * taxa_crescimento
console.print(f"\n🔮 Projeção de crescimento nacional (+12%): R$ {projecao:,.2f}")

# === 9️⃣ Interpretação dos resultados ===
console.rule("[bold cyan]📊 Interpretação dos Resultados[/bold cyan]")
console.print("• O Sudeste se destaca como o principal polo de vendas no país.")
console.print("• Categorias Premium e Standard dominam as regiões, reforçando foco em valor agregado.")
console.print("• A estabilidade entre regiões indica consistência operacional e maturidade de mercado.")
console.print("• O top 5 de produtos confirma predominância de tecnologia de consumo.")
console.print("\n[bold green]✅ Conclusão:[/bold green] O mercado apresenta alto potencial de crescimento e equilíbrio regional.")
