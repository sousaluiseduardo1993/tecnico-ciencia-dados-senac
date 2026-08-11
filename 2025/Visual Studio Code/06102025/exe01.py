# atividade_agrupamento.py
# Atividade Prática – Agrupamento e Agregação

import pandas as pd
import matplotlib.pyplot as plt

# 1. Importação e leitura do CSV
df = pd.read_csv("dados_vendas.csv")

# 2. Agrupamento por categoria (média das vendas)
media_cat = df.groupby("Categoria")["Vendas"].mean()
print("\n=== MÉDIA DE VENDAS POR CATEGORIA ===")
print(media_cat)

# 3. Contagem de registros por categoria
contagem_cat = df.groupby("Categoria").size()
print("\n=== CONTAGEM POR CATEGORIA ===")
print(contagem_cat)

# 4. Agrupamento múltiplo (por Região e Produto)
agrup_multi = df.groupby(["Regiao", "Produto"])["Vendas"].sum()
print("\n=== AGRUPAMENTO MÚLTIPLO (Região x Produto) ===")
print(agrup_multi.head())

# 5. Tabela comparativa (Totais x Premium por Região)
vendas_totais = df.groupby("Regiao")["Vendas"].sum()
vendas_premium = df[df["Categoria"] == "Premium"].groupby("Regiao")["Vendas"].sum()
comparativo = pd.DataFrame({
    "Vendas_Totais": vendas_totais,
    "Vendas_Premium": vendas_premium
}).fillna(0)
print("\n=== TABELA COMPARATIVA ===")
print(comparativo)

# 6. Gráfico simples – Média de vendas por categoria
media_cat.plot(kind="bar", title="Média de Vendas por Categoria", figsize=(7,4))
plt.tight_layout()
plt.show()
