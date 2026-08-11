"""
EXE02 - Análise Lapidada de Vendas de E-commerce
Grimoire 🧙‍♂️ | 2025-10-23
"""

import pandas as pd
import plotly.express as px
import os

def analise_vendas(csv="vendas_de-e-commerce.csv"):
    if not os.path.exists(csv):
        raise FileNotFoundError(f"Arquivo '{csv}' não encontrado.")
    df = pd.read_csv(csv).convert_dtypes()

    df.fillna({
        "Categoria": "Não Categorizado",
        "Cliente": "Desconhecido",
        "Produto": "Sem Nome",
        "Estado": "Desconhecido"
    }, inplace=True)
    df["Preço"].fillna(df["Preço"].median(), inplace=True)
    df["Quantidade"].fillna(df["Quantidade"].median(), inplace=True)
    df["Data"] = pd.to_datetime(df["Data"], errors="coerce")
    df["Receita"] = df["Preço"] * df["Quantidade"]
    df["Ano"], df["Mês"] = df["Data"].dt.year, df["Data"].dt.month

    receita_cat = df.groupby("Categoria", as_index=False)["Receita"].sum().sort_values(by="Receita", ascending=False)
    receita_est = df.groupby("Estado", as_index=False)["Receita"].sum().sort_values(by="Receita", ascending=False)
    receita_temp = df.groupby(["Ano", "Mês"], as_index=False)["Receita"].sum()

    total_vendas = df["Receita"].sum()
    ticket_medio = df["Receita"].mean()
    top_cat, top_est = receita_cat.iloc[0], receita_est.iloc[0]

    print("\n📊 ESTATÍSTICAS GERAIS\n", df[["Quantidade", "Preço", "Receita"]].describe())
    print(f"\n💎 Total de Vendas: R$ {total_vendas:,.2f}")
    print(f"💰 Ticket Médio: R$ {ticket_medio:,.2f}")
    print(f"🏆 Categoria Top: {top_cat['Categoria']} (R$ {top_cat['Receita']:,.2f})")
    print(f"📦 Estado Top: {top_est['Estado']} (R$ {top_est['Receita']:,.2f})")

    px.bar(receita_cat, x="Categoria", y="Receita", color="Categoria", title="💰 Receita por Categoria").write_html("exe02_cat.html")
    px.bar(receita_est, x="Estado", y="Receita", color="Estado", title="🏙️ Receita por Estado").write_html("exe02_est.html")
    px.line(receita_temp, x="Mês", y="Receita", color="Ano", title="📈 Receita Mensal por Ano").write_html("exe02_tempo.html")

    df.to_csv("exe02_vendas_limpo.csv", index=False)
    print("\n✨ Relatórios salvos: exe02_cat.html | exe02_est.html | exe02_tempo.html | exe02_vendas_limpo.csv\n")

if __name__ == "__main__":
    analise_vendas("vendas_de_e-commerce.csv")