# ===========================================
# 🧙‍♂️ Manipulação de Dados de APIs com Pandas
# Autor: Grimoire
# ===========================================

import requests
import pandas as pd
from tabulate import tabulate

# 🔹 Configuração do usuário
usuario = ""
url = f"https://api.github.com/users/{usuario}/repos"

# 🔹 Requisição à API do GitHub
response = requests.get(url)

if response.status_code == 200:
    repos = response.json()
    df = pd.DataFrame(repos)

    # 🔹 Selecionando colunas principais
    colunas = ['name', 'language', 'stargazers_count', 'forks_count']
    df_clean = df[colunas].fillna('N/D')

    print("\n" + "="*60)
    print(f"📦 Repositórios públicos de @{usuario}")
    print("="*60)

    # 🧾 Exibir tabela limpa e formatada
    print("\n📋 **Lista Completa de Repositórios:**\n")
    print(tabulate(df_clean, headers='keys', tablefmt='fancy_grid', showindex=False))

    # 🌟 Exibir Top 5 por estrelas
    df_sorted = df_clean.sort_values('stargazers_count', ascending=False)
    top5 = df_sorted.head(5)

    print("\n✨ **Top 5 Repositórios por Estrelas:**\n")
    print(tabulate(top5, headers='keys', tablefmt='fancy_grid', showindex=False))

    # 📈 Estatísticas simples
    total_repos = len(df_clean)
    linguagens = df_clean['language'].value_counts().to_dict()
    media_estrelas = df_clean['stargazers_count'].mean()

    print("\n📊 **Resumo:**")
    print(f"🔹 Total de repositórios: {total_repos}")
    print(f"🔹 Linguagens usadas: {', '.join(linguagens.keys())}")
    print(f"🔹 Média de estrelas por repositório: {media_estrelas:.2f}")

else:
    print(f"❌ Erro ao acessar API ({response.status_code}): {response.text}")
