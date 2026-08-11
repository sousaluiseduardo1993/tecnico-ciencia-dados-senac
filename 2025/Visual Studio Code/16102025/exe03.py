# ==============================================
# 🧙‍♂️ Atividade Prática 4 - Extração e Manipulação para Análise
# Autor: Luis Eduardo (Grimoire adaptado)
# ==============================================

import requests
import pandas as pd
import matplotlib.pyplot as plt

# 1️⃣ Obter Dados da API
username = ""
url = f"https://api.github.com/users/{username}/repos"

response = requests.get(url)
if response.status_code == 200:
    repos_data = response.json()
else:
    raise SystemExit(f"❌ Erro ao acessar API ({response.status_code})")

# 2️⃣ Transformar em DataFrame
repos_list = []
for repo in repos_data:
    repos_list.append({
        "nome": repo["name"],
        "estrelas": repo["stargazers_count"],
        "forks": repo["forks_count"],
        "linguagem": repo["language"],
        "privado": repo["private"],
        "criado_em": repo["created_at"][:10],
        "atualizado_em": repo["updated_at"][:10],
        "url": repo["html_url"]
    })

df = pd.DataFrame(repos_list)

# 3️⃣ Limpar e Preparar os Dados
df["linguagem"] = df["linguagem"].fillna("Não especificada")
df = df.sort_values("estrelas", ascending=False)

print("\n=== 🧾 Dados Extraídos e Preparados ===\n")
print(df.head(10))

# 4️⃣ Visualização das Linguagens
linguagens_contagem = df["linguagem"].value_counts()

plt.figure(figsize=(10, 5))
plt.bar(linguagens_contagem.index, linguagens_contagem.values, color="mediumpurple")
plt.title(f"Linguagens mais usadas por @{username}")
plt.xlabel("Linguagem")
plt.ylabel("Quantidade de Repositórios")
plt.xticks(rotation=30)
plt.grid(axis="y", linestyle="--", alpha=0.6)
plt.tight_layout()
plt.show()

# 5️⃣ Estatísticas simples
print("\n📊 Estatísticas Gerais:")
print(f"Total de repositórios: {len(df)}")
print(f"Linguagens usadas: {', '.join(linguagens_contagem.index)}")
print(f"Média de estrelas: {df['estrelas'].mean():.2f}")
