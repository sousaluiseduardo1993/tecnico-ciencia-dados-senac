import pandas as pd

# === 1. Ler os dados ===
file_path = "Formulário Programação.csv"
df = pd.read_csv(file_path, sep=",", encoding="utf-8")

# === 2. Identificação de Erros ===
print("===== Valores Nulos por Coluna =====")
print(df.isnull().sum())

print("===== Duplicatas =====")
print(df.duplicated().sum())

# === 3. Limpeza dos Dados ===
# Remover espaços extras nos nomes das colunas
df.columns = df.columns.str.strip()

# Padronizar texto (remover espaços, converter para string)
for col in df.select_dtypes(include="object").columns:
    df[col] = df[col].astype(str).str.strip()

# Remover duplicatas
df = df.drop_duplicates()

# Preencher valores nulos na coluna "Como você se considera tecnicamente?"
if "Como você se considera tecnicamente?" in df.columns:
    df["Como você se considera tecnicamente?"] = df["Como você se considera tecnicamente?"].replace("nan", pd.NA)
    df["Como você se considera tecnicamente?"] = df["Como você se considera tecnicamente?"].fillna("Não informado")

# === 4. Análises Gerais ===
print("===== Informações Gerais do Dataset =====")
print(df.info())
print("\n===== Primeiras Linhas =====")
print(df.head())
print("\n===== Estatísticas Descritivas =====")
print(df.describe(include="all"))

# Distribuição por tempo de experiência
col_experiencia = [c for c in df.columns if "programar" in c.lower()]
if col_experiencia:
    print("\n===== Distribuição por Tempo de Experiência =====")
    print(df[col_experiencia[0]].value_counts())

# Distribuição por formas de aprendizado
col_aprendizado = [c for c in df.columns if "aprendeu programação" in c.lower()]
if col_aprendizado:
    print("\n===== Formas de Aprendizado =====")
    print(df[col_aprendizado[0]].value_counts())

# Frequência de linguagens
col_linguagens = [c for c in df.columns if "linguagens" in c.lower()]
if col_linguagens:
    langs = df[col_linguagens[0]].dropna().str.split(";")
    langs_exploded = langs.explode().str.strip()
    print("\n===== Linguagens Mais Usadas =====")
    print(langs_exploded.value_counts())

# Autoavaliação técnica
col_auto = [c for c in df.columns if "tecnicamente" in c.lower()]
if col_auto:
    print("\n===== Autoavaliação Técnica =====")
    print(df[col_auto[0]].value_counts())