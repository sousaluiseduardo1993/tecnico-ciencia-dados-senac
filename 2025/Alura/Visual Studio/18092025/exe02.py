import pandas as pd

df = pd.read_csv(r"C:\Users\xNigthKing\Desktop\GitHub\CDDSENAC\Alura\Visual Studio\18092025\ratings.csv")

df.columns = ["usuarioId", "filmeId", "nota", "momento"]

# Converte timestamp para data legível
df['momento'] = pd.to_datetime(df['momento'], unit='s')

# Mostra as 5 primeiras linhas já com a data convertida
print(df.head())

print("\n", df.shape)

print("\n", df['nota'].value_counts(), "\n")

media_notas = df['nota'].mean()

print(f"Média das notas: {media_notas}\n")
