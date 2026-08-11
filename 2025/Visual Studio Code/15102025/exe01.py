# ====== Consumo Simples de API - GitHub ======
# Autor: xnigthking
# Objetivo: Consumir a API pública do GitHub e exibir informações do usuário

import requests
import json

# 1️⃣ Definir o nome do usuário do GitHub
username = ''
url = f'https://api.github.com/users/{username}'

# 2️⃣ Enviar a requisição GET
response = requests.get(url)
print(f'Status code: {response.status_code}\n')

# 3️⃣ Converter a resposta para JSON e exibir os dados
if response.status_code == 200:
    data = response.json()

    print("=== Dados do Usuário ===")
    print(f"Nome: {data.get('name')}")
    print(f"Login: {data.get('login')}")
    print(f"Bio: {data.get('bio')}")
    print(f"Localização: {data.get('location')}")
    print(f"Repositórios Públicos: {data.get('public_repos')}")
    print(f"Seguidores: {data.get('followers')}")
    print(f"Seguindo: {data.get('following')}")
    print(f"URL do Perfil: {data.get('html_url')}\n")

    # 4️⃣ Buscar os repositórios do usuário
    repos_url = data.get('repos_url')
    repos_response = requests.get(repos_url)

    if repos_response.status_code == 200:
        repos = repos_response.json()
        print("=== Repositórios Públicos ===")
        for repo in repos[:10]:  # Mostra os 10 primeiros repositórios
            print(f"- {repo['name']}: {repo['html_url']}")
    else:
        print("❌ Não foi possível buscar os repositórios.")
else:
    print("❌ Erro ao buscar dados do usuário.")
