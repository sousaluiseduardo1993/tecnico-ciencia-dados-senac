import requests
import pandas as pd

# Lista de CEPs para consulta
ceps = [
    "01001-000",
    "30130-010",
    "70040-010",
    "71978-100",
    "99999-999"  # CEP inválido para teste
]


def consultar_cep(cep):
    """
    Consulta um CEP na API ViaCEP.
    Retorna um dicionário com os dados ou None caso ocorra erro.
    """

    # Remove traços e pontos
    cep = cep.replace("-", "").replace(".", "").strip()

    # Monta a URL da API
    url = f"https://viacep.com.br/ws/{cep}/json/"

    try:
        # Faz a requisição
        resposta = requests.get(url, timeout=5)

        # Verifica se a resposta foi bem sucedida
        if resposta.status_code == 200:

            dados = resposta.json()

            # Verifica se o CEP existe
            if "erro" in dados:
                print(f"❌ CEP {cep} inválido ou inexistente.")
                return None

            return {
                "CEP": dados.get("cep", ""),
                "Logradouro": dados.get("logradouro", ""),
                "Bairro": dados.get("bairro", ""),
                "Cidade": dados.get("localidade", ""),
                "UF": dados.get("uf", ""),
                "DDD": int(dados["ddd"]) if dados.get("ddd") else None
            }

        else:
            print(f"❌ Erro HTTP {resposta.status_code} ao consultar o CEP {cep}.")
            return None

    except requests.exceptions.Timeout:
        print(f"⏰ Tempo de conexão esgotado para o CEP {cep}.")

    except requests.exceptions.ConnectionError:
        print(f"🌐 Erro de conexão ao consultar o CEP {cep}.")

    except requests.exceptions.RequestException as erro:
        print(f"⚠️ Erro durante a consulta do CEP {cep}: {erro}")

    return None


# Lista onde serão armazenados os resultados
resultado = []

# Percorre todos os CEPs
for cep in ceps:

    endereco = consultar_cep(cep)

    if endereco is not None:
        resultado.append(endereco)

# Cria o DataFrame
df = pd.DataFrame(resultado)

print("\n===== TABELA FINAL DOS CEPs VÁLIDOS =====\n")

print(df)

# Opcional: salvar em arquivo CSV
df.to_csv("ceps_validados.csv", index=False, encoding="utf-8-sig")

print("\nArquivo 'ceps_validados.csv' salvo com sucesso!")