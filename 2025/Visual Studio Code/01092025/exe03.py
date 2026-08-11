import pandas as pd

# ---------------------------
# 1. Criando DataFrame
# ---------------------------
df = pd.DataFrame({
    'Nome': ['Luis', 'Eduardo', None, 'Luis'],
    'Idade': ['18', '32', '25', '32'],
    'Cidade': ['Taguatinga', 'Brasilia', 'Brasília', 'Areal'],
    'Curso Favorito': ['Front-End', 'Adobe-Photoshop', 'Full-Stack', 'Photoshop']
})
print("🔥 DataFrame original:")
print(df)

# ---------------------------
# 2. Valores ausentes
# ---------------------------
print("\n📊 Valores ausentes por coluna:")
print(df.isna().sum())

# ---------------------------
# 3. Padronização de strings (usando map em cada coluna)
# ---------------------------
df = df.fillna({'Nome': 'Desconhecido'})

for col in df.columns:
    if df[col].dtype == 'object':  # aplica apenas em colunas com texto
        df[col] = df[col].map(lambda x: x.strip().lower().title() if isinstance(x, str) else x)

df['Cidade'] = df['Cidade'].replace({'Brasilia': 'Brasília'})  # corrigindo acentuação

print("\n✅ DataFrame padronizado:")
print(df)

# ---------------------------
# 4. Valores únicos por coluna
# ---------------------------
print("\n🔎 Valores únicos por coluna:")
for col in df.columns:
    print(f"{col}: {df[col].unique()}")

# ---------------------------
# 5. Removendo valores ausentes
# ---------------------------
df_sem_na = df.dropna()
print("\n🧹 DataFrame sem valores ausentes:")
print(df_sem_na)

# ---------------------------
# 6. Removendo apenas nomes nulos
# ---------------------------
df_sem_na_nome = df.dropna(subset=['Nome'])
print("\n🔎 DataFrame sem nomes nulos:")
print(df_sem_na_nome)

# ---------------------------
# 7. Duplicatas completas
# ---------------------------
df['Duplicata'] = df.duplicated(keep=False)
print("\n📋 Duplicatas completas detectadas:")
print(df)

# ---------------------------
# 8. Duplicatas por coluna
# ---------------------------
print("\n🔍 Duplicatas por coluna:")
for col in df.columns.drop('Duplicata'):
    dups = df[df.duplicated(subset=[col], keep=False)].sort_values(by=col)
    if not dups.empty:
        print(f"\n📌 Coluna '{col}' possui duplicatas:")
        print(dups[[col]])
    else:
        print(f"✅ Coluna '{col}' não possui duplicatas.")

# ---------------------------
# 9. Estatísticas rápidas
# ---------------------------
df['Idade'] = pd.to_numeric(df['Idade'], errors='coerce')
print("\n📈 Estatísticas descritivas por Nome:")
print(df.groupby('Nome')['Idade'].describe())
