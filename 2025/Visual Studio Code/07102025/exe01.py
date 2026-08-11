import pandas as pd
import matplotlib.pyplot as plt

# --- Leitura do CSV ---
df = pd.read_csv("dados_vendas.csv")
print(df.head())

# Normaliza texto (opcional, evita problemas com maiúsc/minúsc e espaços)
df['Categoria'] = df['Categoria'].astype(str).str.strip().str.title()
df['Regiao'] = df['Regiao'].astype(str).str.strip().str.title()

# --- Filtrar e agrupar (Premium) ---
produtos_premium = df[df['Categoria'] == 'Premium']
vendas_premium_por_regiao = produtos_premium.groupby('Regiao')['Vendas'].sum()

# --- Agrupar e depois filtrar (totais por região) ---
vendas_por_regiao = df.groupby('Regiao')['Vendas'].sum()
regioes_alto_desempenho = vendas_por_regiao[vendas_por_regiao > 10000]

# --- Tabela comparativa (Totais x Premium) ---
tabela = pd.DataFrame({
    'Vendas_Totais': vendas_por_regiao,
    'Vendas_Premium': vendas_premium_por_regiao
}).fillna(0)

print('\n=== Tabela comparativa ===')
print(tabela)

# Plot: Vendas Totais vs Vendas Premium por Região
ax = tabela.plot(kind='bar', figsize=(8,5), title='Vendas Totais vs Vendas Premium por Região')
ax.set_xlabel('Região')
ax.set_ylabel('Vendas (R$)')
plt.tight_layout()
plt.show()

# === Trecho adicional: análise simples das 3 categorias ===
totais_categoria = df.groupby('Categoria')['Vendas'].sum()
total_geral = totais_categoria.sum()
percentual = (totais_categoria / total_geral * 100).round(1)

resumo_cat = pd.DataFrame({
    'Total (R$)': totais_categoria,
    'Percentual (%)': percentual
}).sort_values('Total (R$)', ascending=False)

print("\n=== Resumo simples por Categoria ===")
print(resumo_cat)

# Frase resumo curta
top = resumo_cat.index[0]
print(f"\nResumo: a categoria com maior participação é '{top}' — {resumo_cat.loc[top,'Percentual (%)']}% das vendas (R$ {resumo_cat.loc[top,'Total (R$)']:.2f}).")

# Gráfico compacto de Vendas por Categoria
resumo_cat['Total (R$)'].plot(kind='bar', title='Vendas por Categoria', figsize=(6,4))
plt.xlabel('Categoria')
plt.ylabel('Vendas (R$)')
plt.tight_layout()
plt.show()
