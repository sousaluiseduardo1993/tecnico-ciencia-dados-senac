# Importando bibliotecas
import os
import sys
from datetime import datetime
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# Função de análise unificada
def analise_unificada(arquivo="vendas_de-e-commerce.csv", retornar_dfs=True, verbose=True):
    """
    Função que realiza uma análise unificada sobre os dados de vendas de e-commerce.
    Processa o arquivo CSV, gera insights e retorna DataFrames com os resultados.
    """
    # Verifica se o arquivo existe
    if not os.path.exists(arquivo):
        raise FileNotFoundError(f"Arquivo não encontrado: {arquivo}")

    if verbose:
        print("\n🧭 Iniciando Análise Estrutural Unificada...")
        print(f"📥 Arquivo: {arquivo}")

    # Leitura do CSV e conversão automática de tipos
    df = pd.read_csv(arquivo).convert_dtypes()

    if verbose:
        print(f"\n📦 Dimensão: {df.shape[0]} linhas | {df.shape[1]} colunas")
        print(f"📋 Colunas: {list(df.columns)}")

    # Limpeza e padronização de colunas categóricas
    for col in ["Categoria", "Cliente", "Produto", "Estado"]:
        if col in df.columns:
            df[col] = df[col].fillna("Desconhecido").astype(str).str.strip()

    if "Estado" in df.columns:
        df["Estado"] = df["Estado"].str.upper()

    # Tratamento de colunas numéricas
    if "Quantidade" in df.columns:
        df["Quantidade"] = pd.to_numeric(df["Quantidade"], errors="coerce").fillna(df["Quantidade"].median())
    else:
        df["Quantidade"] = 1

    if "Preço" in df.columns:
        df["Preço"] = pd.to_numeric(df["Preço"], errors="coerce").fillna(df["Preço"].median())
    else:
        df["Preço"] = 0.0

    if "Data" in df.columns:
        df["Data"] = pd.to_datetime(df["Data"], errors="coerce")
    else:
        df["Data"] = pd.NaT

    # Criação da coluna Receita
    df["Receita"] = df["Preço"] * df["Quantidade"]

    # Estatísticas descritivas das colunas numéricas
    numeric_cols = ["Quantidade", "Preço", "Receita"]
    desc = df[numeric_cols].describe().T
    desc["Mediana"] = df[numeric_cols].median()
    desc["CV_%"] = (desc["std"] / desc["mean"] * 100).round(2)
    desc.rename(columns={"mean": "Média", "max": "Máximo"}, inplace=True)
    desc_out = desc[["Média", "Mediana", "Máximo", "CV_%"]].round(2)

    if verbose:
        print("\n" + "=" * 60)
        print("📊 ESTATÍSTICAS NUMÉRICAS")
        print("=" * 60)
        print(desc_out.to_string())
        print("=" * 60)

    # Cálculo de KPIs principais
    total_receita = df["Receita"].sum()
    ticket_medio = df["Receita"].mean()
    produtos_unicos = df["Produto"].nunique() if "Produto" in df.columns else 0
    clientes_unicos = df["Cliente"].nunique() if "Cliente" in df.columns else 0
    categorias_ativas = df["Categoria"].nunique() if "Categoria" in df.columns else 0

    if verbose:
        print("\n💎 KPIs DO NEGÓCIO")
        print("-" * 60)
        print(f"• Receita Total: R$ {total_receita:,.2f}")
        print(f"• Ticket Médio: R$ {ticket_medio:,.2f}")
        print(f"• Produtos Únicos: {produtos_unicos}")
        print(f"• Clientes Únicos: {clientes_unicos}")
        print(f"• Categorias Ativas: {categorias_ativas}")
        print("-" * 60)

    # Matriz de correlação entre colunas numéricas
    corr = df[numeric_cols].corr().round(3)
    if verbose:
        print("\n🔗 MATRIZ DE CORRELAÇÃO")
        print("-" * 60)
        print(corr.to_string())
        print("-" * 60)

    # Agrupamentos para análise por categoria, estado e tempo
    receita_por_categoria = (
        df.groupby("Categoria")[["Quantidade", "Receita"]]
        .sum()
        .sort_values("Receita", ascending=False)
    )

    receita_por_estado = df.groupby("Estado")["Receita"].sum().sort_values(ascending=False)

    df["Ano"] = df["Data"].dt.year
    df["Mês"] = df["Data"].dt.month
    tempo = (
        df.groupby(["Ano", "Mês"])["Receita"]
        .sum()
        .reset_index()
        .sort_values(["Ano", "Mês"])
    )
    tempo["Crescimento_%"] = tempo["Receita"].pct_change() * 100

    if verbose:
        print("\n🏷️ RECEITA POR CATEGORIA")
        print("-" * 60)
        print(receita_por_categoria.to_string())
        print("-" * 60)
        print("\n🏷️ RECEITA POR ESTADO (TOP 10)")
        print("-" * 60)
        print(receita_por_estado.head(10).to_string())
        print("-" * 60)

    # Top 10 produtos mais rentáveis
    receita_produtos = df.groupby("Produto")["Receita"].sum().sort_values(ascending=False)
    top10_produtos = receita_produtos.head(10)

    if verbose:
        print("\n🏆 TOP 10 PRODUTOS MAIS RENTÁVEIS")
        print("-" * 60)
        print(top10_produtos.to_string())
        print("-" * 60)

    # Identificação de outliers (transações acima do 99º percentil)
    limite_99 = df["Receita"].quantile(0.99)
    outliers = df[df["Receita"] > limite_99].copy()

    if verbose:
        print(f"\n⚠️ TRANSAÇÕES ACIMA DO 99º PERCENTIL (> R$ {limite_99:,.2f}): {len(outliers)}")
        print("-" * 60)
        cols_show = [c for c in ["Cliente", "Produto", "Receita", "Estado"] if c in outliers.columns]
        print(
            outliers[cols_show].head(10).to_string(index=False)
            if not outliers.empty
            else "Nenhum outlier encontrado."
        )
        print("-" * 60)

    # Identificação do pico de vendas
    pico_info = None
    if not tempo["Receita"].empty:
        pico_row = tempo.loc[tempo["Receita"].idxmax()]
        pico_info = {
            "Ano": int(pico_row["Ano"]) if not pd.isna(pico_row["Ano"]) else None,
            "Mês": int(pico_row["Mês"]) if not pd.isna(pico_row["Mês"]) else None,
            "Receita": float(pico_row["Receita"]),
        }

        if verbose:
            print("\n📅 RITMO DE CRESCIMENTO (últimos registros)")
            print("-" * 60)
            print(tempo.tail(6).to_string(index=False))
            print("-" * 60)
            if pico_info["Ano"] is not None:
                print(f"🚀 Pico de vendas: {pico_info['Mês']}/{pico_info['Ano']} - R$ {pico_info['Receita']:,.2f}")
    else:
        if verbose:
            print("\n📅 RITMO DE CRESCIMENTO: não há dados de tempo válidos.")

    # Insights automáticos
    top_categoria = receita_por_categoria.index[0] if not receita_por_categoria.empty else None
    top_produto = top10_produtos.index[0] if not top10_produtos.empty else None
    crescimento_medio = tempo["Crescimento_%"].mean() if not tempo["Crescimento_%"].empty else np.nan

    if verbose:
        print("\n🧠 INSIGHTS AUTOMÁTICOS")
        print("-" * 60)
        print(f"• Categoria dominante....: {top_categoria}")
        print(f"• Produto campeão........: {top_produto}")
        if not np.isnan(crescimento_medio):
            print(f"• Crescimento médio mensal: {crescimento_medio:.2f}%")
            print(
                "📈 Tendência: Crescimento consistente no período."
                if crescimento_medio > 0
                else "📉 Tendência: Desaceleração ou sazonalidade presente."
            )
        else:
            print("• Crescimento médio mensal: N/A")
        print("-" * 60)

    # Dicionário com todos os DataFrames de saída
    dfs = {
        "raw": df,
        "estatisticas_num": desc_out,
        "kpis": pd.DataFrame({
            "Indicador": [
                "Receita Total",
                "Ticket Médio",
                "Produtos Únicos",
                "Clientes Únicos",
                "Categorias Ativas",
            ],
            "Valor": [
                f"R$ {total_receita:,.2f}",
                f"R$ {ticket_medio:,.2f}",
                produtos_unicos,
                clientes_unicos,
                categorias_ativas,
            ],
        }),
        "correlation": corr,
        "receita_por_categoria": receita_por_categoria,
        "receita_por_estado": receita_por_estado,
        "tempo": tempo,
        "top10_produtos": top10_produtos,
        "outliers": outliers,
        "pico": pd.DataFrame([pico_info]) if pico_info is not None else pd.DataFrame(),
    }

    return dfs if retornar_dfs else None


# Função para gerar os gráficos
def gerar_graficos(dfs):
    """
    Função para gerar gráficos a partir dos DataFrames de análise.
    Exibe os gráficos sem salvar como imagens.
    """
    # Extrai os dados necessários
    receita_cat = dfs["receita_por_categoria"]["Receita"]
    receita_est = dfs["receita_por_estado"].sort_values(ascending=False).head(10)
    top10_prod = dfs["top10_produtos"]

    # Função para plotar os gráficos de barra
    def plot_bar(x, y, title, xlabel, ylabel, rotate=45, figsize=(10,6)):
        fig, ax = plt.subplots(figsize=figsize)
        bars = ax.bar(x, y)
        ax.set_title(title, fontsize=14, fontweight='bold', pad=12)
        ax.set_xlabel(xlabel, fontsize=12)
        ax.set_ylabel(ylabel, fontsize=12)
        ax.grid(axis='y', linestyle='--', linewidth=0.6, alpha=0.7)
        plt.xticks(rotation=rotate, ha='right', fontsize=10)
        plt.tight_layout()

        # Adicionando valores nos gráficos
        for bar in bars:
            h = bar.get_height()
            ax.annotate(f'R$ {h:,.0f}', xy=(bar.get_x() + bar.get_width() / 2, h),
                        xytext=(0, 6), textcoords="offset points", ha='center', va='bottom', fontsize=9)
        
        plt.show()  # Exibe o gráfico

    # Gerando os gráficos
    plot_bar(receita_cat.index.astype(str), receita_cat.values,
             "Receita por Categoria", "Categoria", "Receita (R$)",
             rotate=25, figsize=(10,5))

    plot_bar(receita_est.index.astype(str), receita_est.values,
             "Receita por Estado (Top 10)", "Estado", "Receita (R$)",
             rotate=20, figsize=(10,5))

    plot_bar(top10_prod.index.astype(str), top10_prod.values,
             "Top 10 Produtos Mais Rentáveis", "Produto", "Receita (R$)",
             rotate=30, figsize=(12,5))


if __name__ == "__main__":
    # Permite passar o arquivo CSV como argumento na execução
    csv_entrada = sys.argv[1] if len(sys.argv) > 1 else "vendas_de-e-commerce.csv"
    try:
        # Executando a análise e gerando os DataFrames
        dfs = analise_unificada(csv_entrada, retornar_dfs=True, verbose=True)
        # Gerando os gráficos a partir dos DataFrames
        gerar_graficos(dfs)
    except Exception as e:
        print(f"Erro durante a execução: {e}")
        raise
