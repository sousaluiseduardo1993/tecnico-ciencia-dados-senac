import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ================== CONFIG ==================
sns.set(style="whitegrid")
plt.rcParams["figure.dpi"] = 120

# ================== DADOS ==================
df = pd.read_csv(r"C:\Users\luis34288836\Desktop\Ciência de Dados\Visual Studio Code\Aulas Exercicios\09092025\salarios_caged.csv")
cols = ["Salário Médio Real de Admissão", "Salário Médio Real de Desligamento"]

def limpar(x): return x.astype(str).str.replace("R$", "").str.replace(".", "").str.replace(",", ".").astype(float)
df[cols] = df[cols].apply(limpar)

# ================== ESTATÍSTICAS ==================
col = cols[0]
desc = df[col].describe()
print("="*50)
print("📊 MÉDIA: {:.2f} | MEDIANA: {:.2f} | MODA: {:.2f}".format(desc["mean"], df[col].median(), df[col].mode()[0]))
print("📉 STD: {:.2f} | MIN: {:.2f} | MAX: {:.2f}".format(desc["std"], desc["min"], desc["max"]))
print("\n📑 RESUMO\n", desc, "\n" + "="*50)

# ================== VISUALIZAÇÕES ==================
# Histogramas
df[cols].plot(kind="hist", bins=30, alpha=0.5, figsize=(10,5), density=True)
plt.title("Distribuições Salariais")
plt.legend(cols)
plt.show()

# Boxplot + média + mediana
ax = sns.boxplot(data=df[cols], palette="pastel")
sns.pointplot(data=df[cols], errorbar=None, color="red", markers="D", linestyle="none")
for i, c in enumerate(cols):
    plt.hlines(df[c].median(), i-0.3, i+0.3, colors="blue", linestyles="--", label=f"Mediana {c}" if i==0 else "")
plt.title("Boxplot Comparativo (♦ média, -- mediana)")
plt.legend(); plt.show()

# Pizza das médias
df[cols].mean().plot.pie(autopct="%.2f%%", colors=["skyblue","lightgreen"], startangle=90, wedgeprops={"edgecolor":"black"})
plt.title("Proporção das Médias Salariais"); plt.ylabel(""); plt.show()
