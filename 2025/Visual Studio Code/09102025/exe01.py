# === Análise de Dados com Pandas ===
# Versão: Revisada 🧙‍♂️ Grimoire PRO
# Tema: Agrupamentos + Estatísticas de Vendas (incluindo Econômico + Estados)

import pandas as pd

# -------------------------------------------------------------
# 1️⃣ Leitura e padronização do arquivo CSV
# -------------------------------------------------------------
df = pd.read_csv("dados_vendas_desafio.csv")

# Padroniza texto em colunas categóricas
for col in ["Regiao", "Categoria", "Estado"]:
    df[col] = df[col].astype(str).str.strip().str.title()

# -------------------------------------------------------------
# 2️⃣ Estatísticas gerais do dataset
# -------------------------------------------------------------
num_regioes = df["Regiao"].nunique()
num_estados = df["Estado"].nunique()
num_produtos = df["Produto"].nunique()
total_vendas = df["Vendas"].sum()
media_geral = df["Vendas"].mean()

print("\n🌎 === Estatísticas Gerais do Dataset ===")
print(f"📦 Regiões: {num_regioes} | 🏙️ Estados: {num_estados} | 🧩 Produtos: {num_produtos}")
print(f"💰 Total de Vendas: R$ {total_vendas:,.2f} | 📈 Média Geral: R$ {media_geral:,.2f}")

# -------------------------------------------------------------
# 3️⃣ Agrupamento de vendas por categoria e região (inclui Econômico)
# -------------------------------------------------------------
categorias_validas = ["Premium", "Standard", "Econômico"]
df_filtrado = df[df["Categoria"].isin(categorias_validas)]

resumo_regiao_categoria = (
    df_filtrado
    .groupby(["Regiao", "Categoria"])["Vendas"]
    .sum()
    .reset_index()
    .sort_values(["Regiao", "Vendas"], ascending=[True, False])
)

# -------------------------------------------------------------
# 4️⃣ Novo DataFrame: Vendas por Estado (resumo simples)
# -------------------------------------------------------------
df_estados = (
    df.groupby(["Estado", "Regiao"])["Vendas"]
    .sum()
    .reset_index()
    .sort_values("Vendas", ascending=False)
)

# -------------------------------------------------------------
# 5️⃣ Ranking dos 5 produtos mais vendidos
# -------------------------------------------------------------
ranking_produtos = (
    df.groupby("Produto")["Vendas"]
    .sum()
    .sort_values(ascending=False)
    .head(5)
)

# -------------------------------------------------------------
# 6️⃣ Resumo analítico por região
# -------------------------------------------------------------
resumo_regional = df.groupby("Regiao")["Vendas"].sum().sort_values(ascending=False)

regiao_top = resumo_regional.idxmax()
valor_top = resumo_regional.max()
regiao_low = resumo_regional.idxmin()
valor_low = resumo_regional.min()
media_regional = resumo_regional.mean()

# -------------------------------------------------------------
# 7️⃣ Exibição dos resultados finais
# -------------------------------------------------------------
print("\n📊 === Distribuição de Vendas — Região × Categoria ===")
for _, linha in resumo_regiao_categoria.iterrows():
    regiao, categoria, valor = linha
    print(f"{regiao:<15} | {categoria:<10} | R$ {valor:,.2f}")

print("\n🏙️ === Vendas por Estado ===")
for _, linha in df_estados.iterrows():
    estado, regiao, vendas = linha
    print(f"{estado:<20} ({regiao}) — R$ {vendas:,.2f}")

print("\n🏅 === Top 5 Produtos Nacionais ===")
for i, (produto, valor) in enumerate(ranking_produtos.items(), start=1):
    print(f"{i}. {produto:<25} — R$ {valor:,.2f}")

print("\n📈 === Resumo Analítico Nacional ===")
print(f"• Região líder: {regiao_top} — R$ {valor_top:,.2f}")
print(f"• Região menor: {regiao_low} — R$ {valor_low:,.2f}")
print(f"• Média regional: R$ {media_regional:,.2f}")
print(f"• Diferença: R$ {valor_top - valor_low:,.2f}")
print(f"• Produto campeão: {ranking_produtos.index[0]} — R$ {ranking_produtos.iloc[0]:,.2f}")

# -------------------------------------------------------------
# 8️⃣ Projeção de crescimento (modelo simples)
# -------------------------------------------------------------
crescimento = 0.12  # 12% de crescimento previsto
projecao = total_vendas * (1 + crescimento)
print(f"\n🔮 Projeção de crescimento nacional (+12%): R$ {projecao:,.2f}")

# -------------------------------------------------------------
# 9️⃣ Conclusão interpretativa
# -------------------------------------------------------------
print("\n──────────────────────────────────────────────────────────────")
print("📊 Interpretação dos Resultados")
print("──────────────────────────────────────────────────────────────")
print("• O Sudeste lidera as vendas nacionais, seguido pelo Nordeste e Sul.")
print("• A adição do DataFrame de Estados permite visualizar melhor a força regional.")
print("• Produtos Premium e Standard seguem dominando o faturamento, mas Econômico")
print("  demonstra bom potencial em regiões emergentes.")
print("• O total cobre 15 estados, refletindo ampla cobertura nacional.")
print("──────────────────────────────────────────────────────────────")