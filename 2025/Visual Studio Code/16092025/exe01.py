import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

data = [
    {"timestamp": "2023-05-10 08:00:00", "temperatura": 22.5, "umidade": 65, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:05:00", "temperatura": 22.7, "umidade": 64, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:10:00", "temperatura": 22.9, "umidade": 63, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:15:00", "temperatura": 23.1, "umidade": 63, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:20:00", "temperatura": 23.3, "umidade": 62, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:25:00", "temperatura": 23.5, "umidade": 61, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:30:00", "temperatura": 23.6, "umidade": 60, "id_sensor": "sensor_01"},
    {"timestamp": "2023-05-10 08:35:00", "temperatura": 23.8, "umidade": 60, "id_sensor": "sensor_01"},
]

df = pd.DataFrame(data)
df["timestamp"] = pd.to_datetime(df["timestamp"])

fig, ax1 = plt.subplots(figsize=(10, 6))

# Temperatura
ax1.plot(df["timestamp"], df["temperatura"], color="tab:blue", marker="o",
         label="Temperatura (°C)", linewidth=2, alpha=0.8)
ax1.set_xlabel("Data e Hora")
ax1.set_ylabel("Temperatura (°C)", color="tab:blue")
ax1.tick_params(axis="y", labelcolor="tab:blue")

# Umidade
ax2 = ax1.twinx()
ax2.plot(df["timestamp"], df["umidade"], color="tab:orange", marker="s",
         label="Umidade (%)", linewidth=2, alpha=0.8)
ax2.set_ylabel("Umidade (%)", color="tab:orange")
ax2.tick_params(axis="y", labelcolor="tab:orange")

# Legenda
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2,
           loc="center left", bbox_to_anchor=(1.05, 0.5),
           frameon=True, facecolor="white", framealpha=0.9)

# ✅ Mostrar data e hora no eixo X
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%d/%m/%Y %H:%M"))

# Ajustes visuais
plt.title("Variação de Temperatura e Umidade", fontsize=14, fontweight="bold")
ax1.grid(True, which="major", linestyle="--", alpha=0.4)
fig.autofmt_xdate()
fig.patch.set_facecolor("#f8f9fa")
ax1.set_facecolor("#f0f0f0")

plt.tight_layout()
plt.show()
