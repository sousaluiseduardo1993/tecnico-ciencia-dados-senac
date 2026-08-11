import pandas as pd  # Importa a biblioteca pandas para manipulação de dados

# Lê o arquivo CSV com as avaliações e armazena no DataFrame df
df = pd.read_csv(r"C:\Users\xNigthKing\Desktop\GitHub\CDDSENAC\Alura\Visual Studio\18092025\ratings.csv")

# Renomeia as colunas do DataFrame para nomes em português
df.columns = ["usuarioId", "filmeId", "nota", "momento"]

print(df.head()) # Exibe as 5 primeiras linhas do DataFrame
print("\n", df.shape) # Mostra o número de linhas e colunas do DataFrame

# Mostra a contagem de cada valor único presente na coluna 'nota', com quebra de linha antes e depois
print("\n", df['nota'].value_counts(), "\n")

# Calcula a média dos valores da coluna 'nota' e armazena na variável media_notas
media_notas = df['nota'].mean()

# Exibe a média calculada das notas com quebra de linha no final
print(f"Média das notas: {media_notas}\n")
