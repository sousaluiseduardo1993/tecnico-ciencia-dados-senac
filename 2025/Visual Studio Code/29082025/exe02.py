import numpy as np

# Criando um array de 1D
arr = np.array([1, 2, 3, 4, 5])
print("Array 1D:", arr)

# Criando um array de 2D
arr_2d = np.array([[1, 2], [3, 4], [5, 6]])
print("Array 2D:")
print(arr_2d)

# Operações matemáticas com arrays
arr_soma = arr + 10  # Soma de 10 a cada elemento
print("Soma com 10:", arr_soma)

# Média e soma de um array
media = np.mean(arr)
soma = np.sum(arr)
print("Média:", media)
print("Soma:", soma)

# Produto de arrays
produto = arr * 2
print("Produto por 2:", produto)
