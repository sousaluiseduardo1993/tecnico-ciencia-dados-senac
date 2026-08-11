# ===============================
# TRABALHO: Pré-processamento com Pandas
# Dataset: Titanic (train.csv)
# ===============================
import pandas as pd

# --- Etapa 1: Importação dos Dados
file_path = "train.csv"
df = pd.read_csv(file_path, sep=",", encoding="utf-8")

def print_sep(t):
    print("\n" + "="*10 + f" {t} " + "="*10 + "\n")

# ===============================
# Etapa 2: Análise Exploratória Inicial (AED)
# ===============================
print_sep("RESUMO INICIAL")
print(f"Arquivo analisado: {file_path}")
print(f"Número de registros: {df.shape[0]} (linhas)")
print(f"Número de variáveis: {df.shape[1]} (colunas)")
print(f"Registros duplicados: {df.duplicated().sum()}")

print("\nPrimeiras 5 linhas do dataset:")
print(df.head(5))

print("\nValores ausentes (5 principais colunas):")
missing = df.isnull().sum().sort_values(ascending=False).head(5)
for col, val in missing.items():
    pct = val/df.shape[0]*100
    print(f"- {col}: {val} nulos ({pct:.1f}%)")

print_sep("DISTRIBUIÇÃO DE SOBREVIVÊNCIA")
print(f"Taxa geral de sobrevivência: {df['Survived'].mean()*100:.1f}%")

print("\nTaxa de sobrevivência por sexo:")
for sexo, val in df.groupby("Sex")["Survived"].mean().items():
    print(f"- {'Mulheres' if sexo=='female' else 'Homens'}: {val*100:.1f}%")

print("\nTaxa de sobrevivência por classe (Pclass):")
for classe, val in df.groupby("Pclass")["Survived"].mean().items():
    print(f"- Classe {classe}: {val*100:.1f}%")

# ===============================
# Etapa 2.1: Idade e Tarifa (Explicativo)
# ===============================
print_sep("IDADE E TARIFA")

# --- Idade
idade_quantis = df["Age"].quantile([0,0.25,0.5,0.75,1]).round(1)
print("Distribuição das Idades dos Passageiros:")
print(f"- Mais novo registrado: {idade_quantis.loc[0.0]} anos")
print(f"- 25% tinham até: {idade_quantis.loc[0.25]} anos (1º quartil)")
print(f"- 50% tinham até: {idade_quantis.loc[0.5]} anos (mediana)")
print(f"- 75% tinham até: {idade_quantis.loc[0.75]} anos (3º quartil)")
print(f"- Mais velho registrado: {idade_quantis.loc[1.0]} anos")
print(f"- Valores ausentes em idade: {df['Age'].isnull().sum()} passageiros\n")

# --- Tarifa
fare_quantis = df["Fare"].quantile([0,0.25,0.5,0.75,0.95,1]).round(2)
print("Distribuição das Tarifas (valor da passagem em libras):")
print(f"- Tarifa mínima: {fare_quantis.loc[0.0]}")
print(f"- 25% pagaram até: {fare_quantis.loc[0.25]} (1º quartil)")
print(f"- 50% pagaram até: {fare_quantis.loc[0.5]} (mediana)")
print(f"- 75% pagaram até: {fare_quantis.loc[0.75]} (3º quartil)")
print(f"- 5% mais caros pagaram acima de: {fare_quantis.loc[0.95]}")
print(f"- Tarifa máxima registrada: {fare_quantis.loc[1.0]}")

# ===============================
# Etapa 3: Limpeza & Transformação
# ===============================
print_sep("LIMPEZA DE DADOS")

# Preencher Idades (Age) com a mediana, agrupada por (Pclass, Sexo)
df["Age"] = df["Age"].fillna(df.groupby(["Pclass","Sex"])["Age"].transform("median"))

# Preencher Embarque (Embarked) com a moda
df["Embarked"] = df["Embarked"].fillna(df["Embarked"].mode()[0])

# Criar flag binária para presença de cabine
df["PossuiCabin"] = df["Cabin"].notna().astype(int)

# Codificar sexo em variável numérica
df["Sexo_Cod"] = df["Sex"].map({"male": 0, "female": 1})

# Criar faixas etárias
bins = [0,12,20,30,40,60,120]
labels = ["0-11","12-19","20-29","30-39","40-59","60+"]
df["FaixaEtaria"] = pd.cut(df["Age"], bins=bins, labels=labels)

print("✔ Idades preenchidas por mediana (grupo por Classe + Sexo)")
print("✔ Embarque preenchido com moda")
print("✔ Colunas criadas: PossuiCabin, Sexo_Cod, FaixaEtaria")

# ===============================
# Etapa 4: Observações para o Relatório
# ===============================
print_sep("OBSERVAÇÕES PRINCIPAIS")

obs = []
obs.append(f"As mulheres tiveram taxa de sobrevivência de {df.loc[df['Sex']=='female','Survived'].mean()*100:.1f}%, enquanto os homens apenas {df.loc[df['Sex']=='male','Survived'].mean()*100:.1f}%.")
obs.append(f"A classe social foi determinante: 1ª classe {df.loc[df['Pclass']==1,'Survived'].mean()*100:.1f}%, 2ª classe {df.loc[df['Pclass']==2,'Survived'].mean()*100:.1f}%, 3ª classe {df.loc[df['Pclass']==3,'Survived'].mean()*100:.1f}%.")
obs.append(f"Crianças (até 11 anos) apresentaram taxa de sobrevivência de {df.loc[df['Age']<=11,'Survived'].mean()*100:.1f}%.")
obs.append(f"A tarifa é bastante desigual: mediana de {df['Fare'].median():.2f}, mas valor máximo de {df['Fare'].max():.2f}.")
obs.append(f"Apenas {df['PossuiCabin'].mean()*100:.1f}% dos passageiros possuem informação de cabine, justificando o uso de uma variável binária (PossuiCabin).")

for i, o in enumerate(obs, start=1):
    print(f"- {i}) {o}")
