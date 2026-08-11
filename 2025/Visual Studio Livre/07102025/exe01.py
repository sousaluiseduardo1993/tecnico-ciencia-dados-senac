import pandas as pd
import numpy as np

# Gerar dados aleatórios
np.random.seed(0)  # Para garantir que os resultados sejam reproduzíveis
n = 10  # número de linhas
dados = {
    'ID': np.arange(1, n+1),
    'Idade': np.random.randint(18, 60, size=n),
    'Salário': np.random.randint(2500, 8000, size=n),
    'Gênero': np.random.choice(['Masculino', 'Feminino'], size=n)
}

# Criar um DataFrame
df = pd.DataFrame(dados)

# Exibir o DataFrame
print("DataFrame Gerado:")
print(df)

# Calcular a média do salário
media_salario = df['Salário'].mean()
print(f"\nMédia do Salário: R${media_salario:.2f}")

# Salvar em um arquivo CSV
df.to_csv('dados_aleatorios.csv', index=False)
print("\nArquivo 'dados_aleatorios.csv' foi gerado!")