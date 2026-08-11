# === ANÁLISE E LIMPEZA DO IDH BRASIL (1991–2021) ===
import pandas as pd
import numpy as np

# === ETAPA 1: IMPORTAÇÃO E LEITURA DE DADOS ===
df = pd.read_csv("idh.csv", sep=",", encoding="utf-8")

print("=== ETAPA 1: ANÁLISE INICIAL ===\n")
print(f"Total de linhas: {len(df)} | Colunas: {len(df.columns)}")
print("Período:", df['ano_referencia'].min(), "→", df['ano_referencia'].max(), "\n")

print("Amostra dos dados:")
print(df.head(3), "\n")

# === ETAPA 2: LIMPEZA E TRATAMENTO DE DADOS ===
print("=== ETAPA 2: LIMPEZA E TRATAMENTO ===")

cols_para_tratar = [
    'idh_feminino', 'idh_masculino',
    'expectativa_de_anos_escola_feminina',
    'expectativa_de_anos_escola_masculina'
]

for col in cols_para_tratar:
    if col in df.columns:
        zeros = (df[col] == 0).sum()
        if zeros > 0:
            media = df.loc[df[col] > 0, col].mean()
            df[col] = df[col].replace(0, media)
            print(f"→ {col}: {zeros} zeros substituídos pela média {media:.3f}")

print("Nenhum valor ausente:", df.isnull().sum().sum() == 0, "\n")

# === ETAPA 3: FILTRAGEM ===
df = df[(df['idh'] >= 0.4) & (df['idh'] <= 1.0)]
df_filtrado = df[df['ano_referencia'] >= 2000].copy()

print("=== ETAPA 3: DADOS FILTRADOS ===")
print(f"Anos considerados: {df_filtrado['ano_referencia'].min()}–{df_filtrado['ano_referencia'].max()}")
print(f"Total de registros após filtragem: {len(df_filtrado)}\n")

# === ETAPA 4: NOVAS INFORMAÇÕES ===
print("=== ETAPA 4: NOVAS INFORMAÇÕES ===")

df_filtrado['dif_vida_genero'] = (
    df_filtrado['expectativa_de_vida_feminina'] - df_filtrado['expectativa_de_vida_masculina']
)

idh_inicial = df_filtrado['idh'].iloc[0]
idh_final = df_filtrado['idh'].iloc[-1]
df_filtrado['idh_crescimento_%'] = ((df_filtrado['idh'] - idh_inicial) / idh_inicial) * 100
df_filtrado['idh_var_ano'] = df_filtrado['idh'].diff().fillna(0).round(4)

print(f"IDH inicial ({df_filtrado['ano_referencia'].iloc[0]}): {idh_inicial:.3f}")
print(f"IDH final   ({df_filtrado['ano_referencia'].iloc[-1]}): {idh_final:.3f}")
print(f"Crescimento total do IDH: {df_filtrado['idh_crescimento_%'].iloc[-1]:.2f}%\n")

# === ETAPA 5: RELAÇÕES ENTRE VARIÁVEIS ===
corr = df_filtrado[['idh', 'expectativa_de_vida', 'expectativa_de_anos_escola']].corr()
corr_vida = corr.loc['idh', 'expectativa_de_vida']
corr_escola = corr.loc['idh', 'expectativa_de_anos_escola']

print("=== ETAPA 5: RELAÇÕES ENTRE VARIÁVEIS ===")
print(f"→ Quanto maior o IDH, maior a expectativa de vida: {corr_vida:.2f}")
print(f"→ Quanto maior o IDH, maior a escolaridade média: {corr_escola:.2f}\n")

# === ETAPA 6: RESUMO FINAL ===
print("=== ETAPA 6: RESUMO FINAL ===")
print(f"O IDH do Brasil subiu de {idh_inicial:.3f} para {idh_final:.3f} entre "
      f"{df_filtrado['ano_referencia'].iloc[0]} e {df_filtrado['ano_referencia'].iloc[-1]}.")
print(f"Crescimento total de {df_filtrado['idh_crescimento_%'].iloc[-1]:.2f}% no período.")
print(f"Mulheres vivem em média {df_filtrado['dif_vida_genero'].mean():.1f} anos a mais que homens.")
print(f"Expectativa de vida média geral: {df_filtrado['expectativa_de_vida'].mean():.1f} anos.\n")