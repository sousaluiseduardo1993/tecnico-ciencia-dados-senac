import requests
import json
from datetime import datetime
import matplotlib.pyplot as plt
from statistics import mean

API_KEY = ""

cidade = input("Digite o nome da cidade: ").strip()
BASE_URL = "https://api.openweathermap.org/data/2.5/forecast"

params = {
    "q": cidade,
    "appid": API_KEY,
    "units": "metric",
    "lang": "pt_br"
}

response = requests.get(BASE_URL, params=params)

if response.status_code == 200:
    data = response.json()
    cidade_info = data["city"]

    print("\n" + "="*60)
    print(f"🏙️  {cidade_info['name']} - {cidade_info['country']}")
    print("="*60)
    print(f"🌐 Coordenadas: Lat {cidade_info['coord']['lat']} | Lon {cidade_info['coord']['lon']}")
    print(f"👥 População: {cidade_info.get('population', 'N/D')}")
    print(f"🕒 Fuso horário: {cidade_info['timezone']} segundos em relação ao UTC\n")

    nascer_sol = datetime.fromtimestamp(cidade_info.get("sunrise", 0)).strftime("%H:%M:%S")
    por_sol = datetime.fromtimestamp(cidade_info.get("sunset", 0)).strftime("%H:%M:%S")
    print(f"🌅 Nascer do sol: {nascer_sol}")
    print(f"🌇 Pôr do sol: {por_sol}\n")

    print("=== 🌤️ Previsão diária (próximos 5 dias) ===\n")

    # Agrupamento por data
    previsoes_por_dia = {}
    for previsao in data["list"]:
        data_txt = previsao["dt_txt"].split(" ")[0]
        if data_txt not in previsoes_por_dia:
            previsoes_por_dia[data_txt] = []
        previsoes_por_dia[data_txt].append(previsao)

    dias = []
    temp_medias = []
    temp_maxs = []
    temp_mins = []

    for data_dia, lista_previsoes in previsoes_por_dia.items():
        temps = [p["main"]["temp"] for p in lista_previsoes]
        temps_min = [p["main"]["temp_min"] for p in lista_previsoes]
        temps_max = [p["main"]["temp_max"] for p in lista_previsoes]
        umidades = [p["main"]["humidity"] for p in lista_previsoes]
        pressoes = [p["main"]["pressure"] for p in lista_previsoes]
        ventos = [p["wind"]["speed"] for p in lista_previsoes]

        descricao = lista_previsoes[len(lista_previsoes)//2]["weather"][0]["description"].capitalize()

        media_temp = mean(temps)
        media_umid = mean(umidades)
        media_pressao = mean(pressoes)
        media_vento = mean(ventos)

        dias.append(datetime.strptime(data_dia, "%Y-%m-%d").strftime("%d/%m"))
        temp_medias.append(round(media_temp, 1))
        temp_mins.append(round(min(temps_min), 1))
        temp_maxs.append(round(max(temps_max), 1))

        print(f"📅 {data_dia}")
        print(f"   🌡️ Média: {media_temp:.1f}°C | Mín: {min(temps_min):.1f}°C | Máx: {max(temps_max):.1f}°C")
        print(f"   💧 Umidade média: {media_umid:.0f}% | 🔵 Pressão média: {media_pressao:.0f} hPa")
        print(f"   🌬️ Vento médio: {media_vento:.1f} m/s")
        print(f"   📖 Condição: {descricao}")
        print("-"*60)

    # 📈 Gráfico diário
    plt.figure(figsize=(10,5))
    plt.plot(dias, temp_medias, marker='o', color='orange', label='Média')
    plt.plot(dias, temp_maxs, linestyle='--', color='red', label='Máx')
    plt.plot(dias, temp_mins, linestyle='--', color='blue', label='Mín')
    plt.title(f"Temperatura diária - {cidade_info['name']}")
    plt.xlabel("Dia")
    plt.ylabel("Temperatura (°C)")
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    plt.show()

elif response.status_code == 404:
    print("❌ Cidade não encontrada. Verifique o nome e tente novamente.")
elif response.status_code == 401:
    print("❌ API Key inválida ou ausente. Verifique sua chave no site do OpenWeatherMap.")
else:
    print(f"⚠️ Erro inesperado ({response.status_code}): {response.text}")
