# ==============================================
# 🌦️ Atividade Prática 3 - Consumo de API com Autenticação
# Autor: Luis Eduardo
# Objetivo: Consultar a previsão do tempo com a API do OpenWeatherMap
# ==============================================

import requests
import json
from datetime import datetime

# 🔑 Sua API Key (verifique se está ativa no site)
API_KEY = ""

# 🏙️ Entrada do usuário
cidade = input("Digite o nome da cidade: ").strip()

# 🌍 Endpoint da API de previsão (5 dias / 3h)
BASE_URL = "https://api.openweathermap.org/data/2.5/forecast"

# ⚙️ Parâmetros da requisição
params = {
    "q": cidade,
    "appid": API_KEY,
    "units": "metric",
    "lang": "pt_br"
}

# 🚀 Envio da requisição
response = requests.get(BASE_URL, params=params)

# 🧭 Verificação da resposta
if response.status_code == 200:
    data = response.json()
    cidade_info = data["city"]

    # 🗺️ Informações gerais da cidade
    print("\n" + "="*60)
    print(f"🏙️  {cidade_info['name']} - {cidade_info['country']}")
    print("="*60)
    print(f"🌐 Coordenadas: Lat {cidade_info['coord']['lat']} | Lon {cidade_info['coord']['lon']}")
    print(f"👥 População: {cidade_info.get('population', 'N/D')}")
    print(f"🕒 Fuso horário: {cidade_info['timezone']} segundos em relação ao UTC\n")

    # ☀️ Nascer e pôr do sol (timestamps UNIX → formato legível)
    nascer_sol = datetime.fromtimestamp(cidade_info.get("sunrise", 0)).strftime("%H:%M:%S")
    por_sol = datetime.fromtimestamp(cidade_info.get("sunset", 0)).strftime("%H:%M:%S")
    print(f"🌅 Nascer do sol: {nascer_sol}")
    print(f"🌇 Pôr do sol: {por_sol}\n")

    # 📅 Previsão das próximas 24 horas (8 blocos de 3h)
    print("=== 🌤️ Previsão das próximas 24 horas ===\n")
    for previsao in data["list"][:8]:
        hora = previsao["dt_txt"]
        temp = previsao["main"]["temp"]
        sensacao = previsao["main"]["feels_like"]
        temp_min = previsao["main"]["temp_min"]
        temp_max = previsao["main"]["temp_max"]
        pressao = previsao["main"]["pressure"]
        umidade = previsao["main"]["humidity"]
        vento = previsao["wind"]["speed"]
        direcao_vento = previsao["wind"]["deg"]
        descricao = previsao["weather"][0]["description"].capitalize()
        nuvens = previsao["clouds"]["all"]
        visibilidade = previsao.get("visibility", "N/D")

        print(f"🕒 {hora}")
        print(f"   🌡️ Temp: {temp}°C (Sensação {sensacao}°C) | Mín: {temp_min}°C | Máx: {temp_max}°C")
        print(f"   💧 Umidade: {umidade}% | 🔵 Pressão: {pressao} hPa")
        print(f"   🌬️ Vento: {vento} m/s ({direcao_vento}°) | ☁️ Nuvens: {nuvens}%")
        print(f"   👁️ Visibilidade: {visibilidade} m")
        print(f"   📖 Condição: {descricao}")
        print("-" * 60)

# ⚠️ Tratamento de erros
elif response.status_code == 404:
    print("❌ Cidade não encontrada. Verifique o nome e tente novamente.")
elif response.status_code == 401:
    print("❌ API Key inválida ou ausente. Verifique sua chave no site do OpenWeatherMap.")
else:
    print(f"⚠️ Erro inesperado ({response.status_code}): {response.text}")
    