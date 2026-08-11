# Importando as bibliotecas necessárias
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Criando um DataFrame simples
dados = {
    'cidade': ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Belo Horizonte', 'Salvador'],
    'populacao': [11.9, 6.7, 3.0, 2.4, 2.6],  # em milhões
    'area': [1521, 1200, 5802, 331, 693]      # em km²
}

df = pd.DataFrame(dados)

# Criando um gráfico de barras (corrigido para não gerar warnings)
plt.figure(figsize=(10, 6))
sns.barplot(
    x='cidade', 
    y='populacao', 
    data=df, 
    hue='cidade', 
    palette="Blues_d", 
    dodge=False, 
    legend=False
)
plt.title('População das Principais Cidades Brasileiras', fontsize=14, fontweight='bold')
plt.xlabel('Cidade', fontsize=12)
plt.ylabel('População (milhões)', fontsize=12)
plt.xticks(rotation=30, ha='right')
plt.tight_layout()
plt.savefig('grafico_barras.png', dpi=300)

# Criando um gráfico de dispersão
plt.figure(figsize=(10, 6))
sns.scatterplot(x='area', y='populacao', data=df, s=100, color="red")
plt.title('Relação entre Área e População', fontsize=14, fontweight='bold')
plt.xlabel('Área (km²)', fontsize=12)
plt.ylabel('População (milhões)', fontsize=12)

# Anotações nos pontos
for i, txt in enumerate(df['cidade']):
    plt.annotate(txt, (df['area'][i], df['populacao'][i]), xytext=(5, 5), textcoords='offset points')

plt.tight_layout()
plt.savefig('grafico_dispersao.png', dpi=300)
plt.show()
