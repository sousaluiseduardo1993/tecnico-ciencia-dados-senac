import os
from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings("ignore")
sns.set_theme(style="whitegrid")

# --- Configuração ---
WORKDIR = Path(r"C:\Users\luis34288836\Desktop\Ciência de Dados\Visual Studio Code\Aulas Exercicios\04092025")
OUTPUT_DIR = WORKDIR / "output"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ----------------------------
# Funções auxiliares
# ----------------------------
def try_read_csv(path: Path) -> pd.DataFrame:
    """Tenta abrir CSV com encoding e separador variados"""
    for enc in ("utf-8", "latin1"):
        for sep in (";", ","):
            try:
                df = pd.read_csv(path, sep=sep, encoding=enc, engine="python", low_memory=False)
                if df.shape[1] > 1:
                    print(f"✅ Leitura bem-sucedida (encoding={enc}, sep='{sep}')")
                    return df
            except Exception:
                pass
    # fallback manual
    text = Path(path).read_text(encoding="latin1", errors="ignore")
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    header = lines[0].split(";")
    data = [l.split(";") for l in lines[1:]]
    print("⚠️ Fallback: leitura manual com ';'")
    return pd.DataFrame(data, columns=header)

def clean_num(series: pd.Series) -> pd.Series:
    """Limpa valores monetários"""
    s = series.astype(str).str.strip()
    s = s.str.replace(r"[^0-9,\.-]", "", regex=True)
    s = s.apply(lambda x: x.replace(".", "").replace(",", ".") if ("," in x and "." in x) else x)
    return pd.to_numeric(s, errors="coerce")

# ----------------------------
# Carregar dataset
# ----------------------------
csv_files = list(WORKDIR.glob("*.csv"))
xlsx_files = list(WORKDIR.glob("*.xlsx"))

file_path = csv_files[0] if csv_files else (xlsx_files[0] if xlsx_files else None)
if file_path is None:
    raise FileNotFoundError(f"Nenhum .csv ou .xlsx encontrado em {WORKDIR}")

print(f"📂 Arquivo carregado: {file_path}")

df = try_read_csv(file_path) if file_path.suffix.lower() == ".csv" else pd.read_excel(file_path, sheet_name=0)

# Padronizar colunas
df.columns = df.columns.astype(str).str.strip().str.lower().str.replace(" ", "_")
df.columns = [c.replace("é", "e").replace("ç", "c") for c in df.columns]

# ----------------------------
# Detectar colunas principais
# ----------------------------
price_col   = next((c for c in df.columns if "valor" in c or "preco" in c), None)
date_col    = next((c for c in df.columns if "data" in c and "venda" in c), None)
marca_col   = next((c for c in df.columns if "marca" in c or "brand" in c), None)
cidade_col  = next((c for c in df.columns if "cidade" in c or "city" in c), None)

print(f"🔍 Detectado -> preço: {price_col} | data: {date_col} | marca: {marca_col} | cidade: {cidade_col}")

# ----------------------------
# Limpeza de dados
# ----------------------------
df["valor_venda_num"] = clean_num(df[price_col]) if price_col else np.nan
if date_col:
    df["data_venda_dt"] = pd.to_datetime(df[date_col], errors="coerce", dayfirst=True)
    df["ano_venda"] = df["data_venda_dt"].dt.year
else:
    df["ano_venda"] = np.nan

print(f"✅ Valores válidos em preço: {df['valor_venda_num'].notna().sum()}")
print(f"✅ Datas válidas: {df['ano_venda'].notna().sum()}")

# ----------------------------
# GRÁFICOS
# ----------------------------
# Top marcas
if marca_col:
    top_marcas = df[marca_col].value_counts().nlargest(10).reset_index()
    top_marcas.columns = [marca_col, "contagem"]
    plt.figure(figsize=(10,6))
    sns.barplot(x="contagem", y=marca_col, data=top_marcas)
    plt.title("Top 10 Marcas Mais Vendidas")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "top10_marcas.png", dpi=150)
    plt.close()
    top_marcas.to_csv(OUTPUT_DIR / "top10_marcas.csv", index=False)

# Histograma valores
if df["valor_venda_num"].notna().sum() > 0:
    plt.figure(figsize=(10,6))
    sns.histplot(df["valor_venda_num"].dropna(), bins=50)
    plt.title("Distribuição dos Valores de Venda")
    plt.xlabel("Valor (R$)")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "histograma_valor_venda.png", dpi=150)
    plt.close()

# Top cidades
if cidade_col:
    top_cidades = df[cidade_col].value_counts().nlargest(15).reset_index()
    top_cidades.columns = [cidade_col, "contagem"]
    plt.figure(figsize=(10,8))
    sns.barplot(x="contagem", y=cidade_col, data=top_cidades)
    plt.title("Top 15 Cidades com Mais Vendas")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "top15_cidades.png", dpi=150)
    plt.close()
    top_cidades.to_csv(OUTPUT_DIR / "top15_cidades.csv", index=False)

# Vendas por ano
if "ano_venda" in df and df["ano_venda"].notna().sum() > 0:
    vendas_ano = df.groupby("ano_venda").size().reset_index(name="contagem")
    plt.figure(figsize=(10,5))
    sns.lineplot(x="ano_venda", y="contagem", data=vendas_ano, marker="o")
    plt.title("Número de Vendas por Ano")
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / "vendas_por_ano.png", dpi=150)
    plt.close()
    vendas_ano.to_csv(OUTPUT_DIR / "vendas_por_ano.csv", index=False)

# ----------------------------
# Resumo em TXT
# ----------------------------
resumo_path = OUTPUT_DIR / "resumo_insights.txt"
with open(resumo_path, "w", encoding="utf-8") as f:
    f.write("📊 Resumo da Análise de Vendas\n")
    f.write("="*40 + "\n\n")
    f.write(f"Arquivo analisado: {file_path.name}\n")
    f.write(f"Shape final: {df.shape}\n\n")
    f.write("Colunas finais:\n")
    for c in df.columns:
        f.write(f" - {c}\n")
    f.write("\nResumo Estatístico (valor_venda_num):\n")
    f.write(df["valor_venda_num"].describe().to_string() + "\n")
    f.write("\nDatas válidas: " + str(df["ano_venda"].notna().sum()) + "\n")

print(f"📑 Resumo salvo em: {resumo_path}")
print("✅ Execução concluída com sucesso!")
