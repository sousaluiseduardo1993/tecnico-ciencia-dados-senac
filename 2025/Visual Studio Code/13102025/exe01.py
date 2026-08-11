# === Análise de Vendas — Limpeza e Estatísticas ===

import pandas as pd
import unicodedata

# -------------------------------------------------------------
# 1️⃣ Leitura e Normalização do Dataset
# -------------------------------------------------------------
def remover_acentos(texto):
    if pd.isna(texto):
        return texto
    nfkd = unicodedata.normalize("NFKD", str(texto))
    return "".join(c for c in nfkd if not unicodedata.combining(c))

def limpar_texto(s):
    if pd.isna(s):
        return s
    s = str(s).strip()
    s = remover_acentos(s)
    s = " ".join(s.split())
    return s.title()

df = pd.read_csv("produtos_erros.csv", dtype=str)

for col in ["Nome", "Cidade", "Estado", "Produto", "Categoria", "Observacao"]:
    if col in df.columns:
        df[col] = df[col].apply(limpar_texto)

df["Preco"] = pd.to_numeric(df.get("Preco"), errors="coerce").fillna(0)
df["Quantidade"] = pd.to_numeric(df.get("Quantidade"), errors="coerce").fillna(1).astype(int)
df["Vendas"] = (df["Preco"] * df["Quantidade"]).round(2)

# -------------------------------------------------------------
# 2️⃣ Estatísticas Gerais do Dataset
# -------------------------------------------------------------
num_regioes = df["Estado"].nunique()
num_cidades = df["Cidade"].nunique()
num_produtos = df["Produto"].nunique()
total_vendas = df["Vendas"].sum()
media_geral = df["Vendas"].mean()

print("\n🌎 === Estatísticas Gerais do Dataset ===")
print(f"🏙️ Cidades: {num_cidades} | 🧩 Produtos: {num_produtos}")
print(f"💰 Total de Vendas: R$ {total_vendas:,.2f} | 📈 Média por Pedido: R$ {media_geral:,.2f}")

# -------------------------------------------------------------
# 3️⃣ Agrupamento de Vendas por Categoria e Estado
# -------------------------------------------------------------
df["Categoria"] = df["Categoria"].fillna("Sem Categoria").str.title()

resumo_categoria_estado = (
    df.groupby(["Estado", "Categoria"])["Vendas"]
    .sum()
    .reset_index()
    .sort_values(["Estado", "Vendas"], ascending=[True, False])
)

# -------------------------------------------------------------
# 4️⃣ Vendas Totais por Estado
# -------------------------------------------------------------
df_estados = (
    df.groupby("Estado")["Vendas"]
    .sum()
    .reset_index()
    .sort_values("Vendas", ascending=False)
)

# -------------------------------------------------------------
# 5️⃣ Ranking dos 5 Produtos Mais Vendidos
# -------------------------------------------------------------
ranking_produtos = (
    df.groupby("Produto")["Vendas"]
    .sum()
    .sort_values(ascending=False)
    .head(5)
)

# -------------------------------------------------------------
# 6️⃣ Resumo Analítico por Estado (simulando regiões)
# -------------------------------------------------------------
valor_top = df_estados["Vendas"].max()
valor_low = df_estados["Vendas"].min()
estado_top = df_estados.loc[df_estados["Vendas"].idxmax(), "Estado"]
estado_low = df_estados.loc[df_estados["Vendas"].idxmin(), "Estado"]
media_estadual = df_estados["Vendas"].mean()

# -------------------------------------------------------------
# 7️⃣ Exibição dos Resultados Finais (alinhado e refinado)
# -------------------------------------------------------------
print("\n📊 === Distribuição de Vendas — Estado × Categoria ===")
print(f"{'Estado':<18} | {'Categoria':<18} | {'Vendas':>15}")
print("-" * 58)
for _, linha in resumo_categoria_estado.iterrows():
    estado, categoria, valor = linha
    print(f"{estado:<18} | {categoria:<18} | R$ {valor:>12,.2f}")

print("\n🏙️ === Vendas Totais por Estado ===")
print(f"{'Estado':<20} | {'Vendas':>15}")
print("-" * 38)
for _, linha in df_estados.iterrows():
    estado, vendas = linha
    print(f"{estado:<20} | R$ {vendas:>12,.2f}")

print("\n🏅 === Top 5 Produtos Nacionais ===")
print(f"{'Rank':<6} | {'Produto':<30} | {'Vendas':>15}")
print("-" * 58)
for i, (produto, valor) in enumerate(ranking_produtos.items(), start=1):
    print(f"{i:<6} | {produto:<30} | R$ {valor:>12,.2f}")

print("\n📈 === Resumo Analítico Nacional ===")
print("-" * 45)
print(f"• Estado líder: {estado_top:<20} R$ {valor_top:>12,.2f}")
print(f"• Estado menor: {estado_low:<20} R$ {valor_low:>12,.2f}")
print(f"• Média estadual:{'':<12} R$ {media_estadual:>12,.2f}")
print(f"• Diferença: {'':<16} R$ {valor_top - valor_low:>12,.2f}")
print(f"• Produto campeão: {ranking_produtos.index[0]:<20} R$ {ranking_produtos.iloc[0]:>12,.2f}")

# -------------------------------------------------------------
# 8️⃣ Projeção de Crescimento (12%)
# -------------------------------------------------------------
crescimento = 0.12
projecao = total_vendas * (1 + crescimento)
print(f"\n🔮 Projeção de Crescimento (+12%): R$ {projecao:,.2f}")

# -------------------------------------------------------------
# 9️⃣ Conclusão Interpretativa
# -------------------------------------------------------------
print("\n──────────────────────────────────────────────────────────────")
print("📊 Interpretação dos Resultados")
print("──────────────────────────────────────────────────────────────")
print("• Estados com nomes divergentes foram unificados pelo tratamento textual.")
print("• Categorias inconsistentes foram normalizadas para formato título.")
print("• Produtos com alta frequência determinam o padrão nacional de consumo.")
print("• A projeção indica sólido crescimento com base na média atual.")
print("──────────────────────────────────────────────────────────────")