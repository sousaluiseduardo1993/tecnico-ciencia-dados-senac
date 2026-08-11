import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import streamlit as st
import plotly.express as px
import numpy as np

# ================== PREPARAÇÃO ==================
caminho = r'C:\Users\luis34288836\Desktop\Ciência de Dados\Visual Studio Code\Aulas Exercicios\09092025\salarios_caged.csv'

# Carregar dataset
df = pd.read_csv(caminho)

# Função para limpar valores monetários
def limpar_salario(coluna):
    return (
        coluna.astype(str)
        .str.replace("R$", "", regex=False)
        .str.replace(".", "", regex=False)
        .str.replace(",", ".", regex=False)
        .astype(float)
    )

colunas_salario = ["Salário Médio Real de Admissão", "Salário Médio Real de Desligamento"]
for col in colunas_salario:
    df[col] = limpar_salario(df[col])

# ================== ESTATÍSTICAS ==================
estatisticas = df[colunas_salario].describe()
correlacao = df[colunas_salario].corr()

# Outliers
def detectar_outliers(col):
    z = (col - col.mean()) / col.std()
    return df.loc[abs(z) > 3, col.name]

outliers_adm = detectar_outliers(df["Salário Médio Real de Admissão"])
outliers_desl = detectar_outliers(df["Salário Médio Real de Desligamento"])

# ================== EXPORTAR EXCEL ==================
with pd.ExcelWriter("relatorio_salarios.xlsx", engine="xlsxwriter") as writer:
    df.to_excel(writer, sheet_name="Dados Limpos", index=False)
    estatisticas.to_excel(writer, sheet_name="Estatísticas")
    correlacao.to_excel(writer, sheet_name="Correlação")

# ================== DASHBOARD STREAMLIT ==================
def dashboard():
    st.title("📊 Análise de Salários - CAGED")

    st.subheader("🔍 Debug: Estatísticas calculadas")
    st.write(estatisticas)

    st.subheader("🔍 Debug: Correlação calculada")
    st.write(correlacao)

    try:
        fig1 = px.histogram(df, x="Salário Médio Real de Admissão", nbins=30, title="Distribuição - Salário de Admissão")
        st.plotly_chart(fig1)
    except Exception as e:
        st.error(f"Erro no gráfico de Admissão: {e}")

    try:
        fig2 = px.histogram(df, x="Salário Médio Real de Desligamento", nbins=30, title="Distribuição - Salário de Desligamento")
        st.plotly_chart(fig2)
    except Exception as e:
        st.error(f"Erro no gráfico de Desligamento: {e}")

    try:
        fig_box = px.box(df, y=colunas_salario, title="Boxplot Comparativo")
        st.plotly_chart(fig_box)
    except Exception as e:
        st.error(f"Erro no Boxplot: {e}")

    try:
        fig_kde = px.histogram(df, x=colunas_salario, marginal="box", barmode="overlay", opacity=0.6)
        fig_kde.update_layout(title="Distribuição Comparativa - Admissão vs Desligamento")
        st.plotly_chart(fig_kde)
    except Exception as e:
        st.error(f"Erro no gráfico KDE: {e}")

    st.subheader("Outliers Detectados")
    st.write("📌 Admissão:", outliers_adm.values)
    st.write("📌 Desligamento:", outliers_desl.values)

    with open("relatorio_salarios.xlsx", "rb") as f:
        st.download_button(
            label="⬇️ Baixar Relatório Excel",
            data=f.read(),
            file_name="relatorio_salarios.xlsx",
            mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )

# ================== EXECUÇÃO ==================
if __name__ == "__main__":
    dashboard()
