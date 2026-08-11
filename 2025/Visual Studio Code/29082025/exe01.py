import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Caminho do arquivo CSV
arquivo_csv = r"C:\Users\luis34288836\Desktop\Ciência de Dados\Excel\notas.csv"

# Carregar o CSV em um DataFrame
df = pd.read_csv(arquivo_csv, sep=";")  # Certifique-se de usar 'sep=";"' porque o separador no seu CSV é o ponto e vírgula

# Exibir as primeiras linhas do DataFrame
print(df.head())

# Calculando a média geral
media_geral = df["Nota"].mean() 
print(f"A média geral: {media_geral:.2f}")

# Média por matéria
media_materia = df.groupby("Materia")["Nota"].mean()
print(media_materia)

plt.figure(figsize=(8, 5))
media_materia.plot(kind="bar", color="#3498DB")
plt.title("Médias de Notas por Matéria")
plt.show()