# Importando as bibliotecas necessárias
import requests
import json

# Fazendo uma requisição GET simples
url = "https://api.github.com/users/"
response = requests.get(url)

# Verificando o status da resposta
if response.status_code == 200:
    print("Requisição bem-sucedida!")
else:
    print(f"Erro: {response.status_code}")

# Convertendo a resposta para JSON
data = response.json()
print(f"Nome: {data['name']}")