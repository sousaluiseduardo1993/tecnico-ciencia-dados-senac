"""
Análise Gráfica - Base Eleitoral
=================================
Gera 2 visualizações a partir de 'base_eleitoral_organizada.xlsx':

  1. Pizza      -> participação total de cada candidato (soma nacional)
  2. Barras agr.-> Top 3 candidatos nos 5 estados com maior volume de votos

Requisitos: pandas, openpyxl, matplotlib
    pip install pandas openpyxl matplotlib
"""

import pandas as pd
import matplotlib.pyplot as plt

# ----------------------------------------------------------------------
# 0. CONFIGURAÇÃO
# ----------------------------------------------------------------------
ARQUIVO = "base_eleitoral_organizada.xlsx"   # coloque o .xlsx na mesma pasta do script
ABA_DADOS = "Dados"

CANDIDATOS = [
    "Luiz Inácio Lula da Silva",
    "Flávio Bolsonaro",
    "Augusto Cury",
    "Renan Santos",
    "Ronaldo Caiado",
]

# Uma cor fixa por candidato -> mantém a mesma identidade visual nos 2 gráficos
CORES = {
    "Luiz Inácio Lula da Silva": "#C0392B",  # vermelho
    "Flávio Bolsonaro":          "#2E4053",  # azul petróleo
    "Augusto Cury":              "#7D3C98",  # roxo
    "Renan Santos":              "#1F618D",  # azul
    "Ronaldo Caiado":            "#B7950B",  # dourado
}

plt.rcParams["font.size"] = 10
plt.rcParams["axes.titleweight"] = "bold"


# ----------------------------------------------------------------------
# 1. LEITURA E PREPARO DOS DADOS
# ----------------------------------------------------------------------
def carregar_dados():
    df = pd.read_excel(ARQUIVO, sheet_name=ABA_DADOS)
    return df


# ----------------------------------------------------------------------
# 2. GRÁFICO 1 — PIZZA: participação total de cada candidato
# ----------------------------------------------------------------------
def grafico_pizza(df):
    totais = df[CANDIDATOS].sum()

    fig, ax = plt.subplots(figsize=(8, 8))

    # destaca o 1º colocado "puxando" a fatia para fora (explode)
    explode = [0.06 if c == totais.idxmax() else 0 for c in totais.index]

    wedges, texts, autotexts = ax.pie(
        totais,
        labels=totais.index,
        autopct="%1.1f%%",
        startangle=90,
        counterclock=False,
        explode=explode,
        colors=[CORES[c] for c in totais.index],
        pctdistance=0.78,
        wedgeprops={"edgecolor": "white", "linewidth": 1.5},
        textprops={"fontsize": 9},
    )
    for t in autotexts:
        t.set_color("white")
        t.set_fontweight("bold")

    ax.set_title(
        "Participação Total por Candidato\n(soma de todos os estados)",
        fontsize=13, pad=15,
    )
    ax.axis("equal")  # mantém o círculo perfeito

    fig.tight_layout()
    fig.savefig("grafico_1_pizza_participacao.png", dpi=200)
    plt.show()


# ----------------------------------------------------------------------
# 3. GRÁFICO 2 — BARRAS AGRUPADAS: Top 3 candidatos nos 5 maiores estados
# ----------------------------------------------------------------------
def grafico_barras_agrupadas(df, top_n_estados=5, top_n_candidatos=3):
    top3_candidatos = df[CANDIDATOS].sum().sort_values(ascending=False).head(top_n_candidatos).index.tolist()

    # "maiores estados" = maior soma entre os candidatos analisados
    df_top = df.copy()
    df_top["soma_top3"] = df_top[top3_candidatos].sum(axis=1)
    df_top = df_top.sort_values("soma_top3", ascending=False).head(top_n_estados)

    x = range(len(df_top))
    largura = 0.25

    fig, ax = plt.subplots(figsize=(10, 6))
    for i, candidato in enumerate(top3_candidatos):
        posicoes = [xi + i * largura for xi in x]
        barras = ax.bar(
            posicoes, df_top[candidato], width=largura,
            label=candidato, color=CORES[candidato],
        )
        ax.bar_label(barras, fmt="%d%%", fontsize=8, padding=2)

    ax.set_title(f"Top {top_n_candidatos} Candidatos nos {top_n_estados} Principais Estados", fontsize=13, pad=12)
    ax.set_ylabel("% de votos")
    ax.set_ylim(0, df_top[top3_candidatos].values.max() + 10)  # espaço extra p/ rótulos e legenda não colidirem
    ax.set_xticks([xi + largura for xi in x])
    ax.set_xticklabels(df_top["Region"], rotation=15, ha="right")
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.14), ncol=3, fontsize=8, frameon=False)
    ax.spines[["top", "right"]].set_visible(False)

    fig.tight_layout()
    fig.savefig("grafico_2_top_candidatos_estados.png", dpi=200)
    plt.show()


# ----------------------------------------------------------------------
# 4. EXECUÇÃO
# ----------------------------------------------------------------------
if __name__ == "__main__":
    df = carregar_dados()

    grafico_pizza(df)
    grafico_barras_agrupadas(df)

    print("\nOs 2 gráficos foram salvos como PNG na pasta do script:")
    print(" - grafico_1_pizza_participacao.png")
    print(" - grafico_2_top_candidatos_estados.png")