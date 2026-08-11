# ==========================================
# ATIVIDADE - PREVISÃO DO TEMPO COM OPEN-METEO
# Autor: Luis Eduardo de Sousa
# Objetivo:
# Consultar a API Open-Meteo para obter a
# previsão do tempo de cidades brasileiras,
# calcular temperatura média, chuva total e
# gerar um relatório para uma empresa de logística.
# ==========================================

import requests
import pandas as pd

# ==========================================
# Lista de cidades
# Nome, Latitude e Longitude
# ==========================================

cidades = [
    {"cidade": "São Paulo", "latitude": -23.55, "longitude": -46.63},
    {"cidade": "Rio de Janeiro", "latitude": -22.90, "longitude": -43.20},
    {"cidade": "Curitiba", "latitude": -25.43, "longitude": -49.27},
    {"cidade": "Salvador", "latitude": -12.97, "longitude": -38.50},
]

# ==========================================
# Função para consultar a API
# ==========================================

def consultar_previsao(latitude, longitude):

    url = (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={latitude}"
        f"&longitude={longitude}"
        "&hourly=temperature_2m,precipitation"
    )

    try:
        resposta = requests.get(url, timeout=5)

        # Verifica se houve erro HTTP
        resposta.raise_for_status()

        return resposta.json()

    except requests.exceptions.RequestException as erro:
        print(f"Erro ao consultar API: {erro}")
        return None


# ==========================================
# Lista que armazenará o resultado final
# ==========================================

resultado = []

# ==========================================
# Processamento das cidades
# ==========================================

for cidade in cidades:

    dados = consultar_previsao(
        cidade["latitude"],
        cidade["longitude"]
    )

    if dados is None:
        continue

    temperaturas = dados["hourly"]["temperature_2m"]
    precipitacao = dados["hourly"]["precipitation"]

    temperatura_media = sum(temperaturas) / len(temperaturas)
    chuva_total = sum(precipitacao)

    if chuva_total > 10:
        alerta = "Alerta de Chuva"
    else:
        alerta = "Tempo Seguro"

    resultado.append({
        "Cidade": cidade["cidade"],
        "Temperatura Média (°C)": round(temperatura_media, 2),
        "Chuva Total (mm)": round(chuva_total, 2),
        "Classificação": alerta
    })

# ==========================================
# Criando DataFrame
# ==========================================

df = pd.DataFrame(resultado)

# Ordena da maior chuva para a menor
df = df.sort_values(
    by="Chuva Total (mm)",
    ascending=False
)

# Reinicia o índice
df.reset_index(drop=True, inplace=True)

# ==========================================
# Exibe o relatório
# ==========================================

print("\nRELATÓRIO METEOROLÓGICO\n")

print(df)