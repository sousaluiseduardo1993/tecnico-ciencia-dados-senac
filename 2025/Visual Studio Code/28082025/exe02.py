# Importando as bibliotecas
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Criando um array NumPy com notas
notas = np.array([85, 90, 78, 92, 88])

plt.figure(figsize=(8, 5))
plt.plot(notas)
plt.title("Notas de Prova")
plt.xlabel("Alunos")
plt.ylabel("Notas")
plt.show()

plt.figure(figsize=(8, 5))
alunos = ["Ana", "Pedro", "Maria", "João", "Lucas"]
plt.bar(alunos, notas)
plt.title("Notas por Aluno")
plt.show()

