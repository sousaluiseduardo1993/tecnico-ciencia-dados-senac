# ============================================================
# LOGISTICS ANALYTICS
# Auditoria de Rentabilidade e Eficiência de Frota
# ============================================================

# ============================================================
# 1. IMPORTAÇÃO DAS BIBLIOTECAS
# ============================================================

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

sns.set(style="whitegrid")

# ============================================================
# 2. CABEÇALHO DO RELATÓRIO
# ============================================================

print("=" * 56)
print("LOGISTICS ANALYTICS")
print("Auditoria de Rentabilidade da Frota")
print("=" * 56)

# ============================================================
# 3. IMPORTAÇÃO DO ARQUIVO
# ============================================================

arquivo = "Base Logistica.xlsx"

print("\n[1/8]")
print("Carregando arquivos...\n")

df_cliente = pd.read_excel(arquivo, sheet_name="dCliente")
print("✓ dCliente")

df_veiculo = pd.read_excel(arquivo, sheet_name="dVeiculo")
print("✓ dVeiculo")

df_frete = pd.read_excel(arquivo, sheet_name="fFrete")
print("✓ fFrete")

df_km = pd.read_excel(arquivo, sheet_name="fKmRodado")
print("✓ fKmRodado")

# ============================================================
# 4. VALIDAÇÃO DA ESTRUTURA
# ============================================================

print("\n[2/8]")
print("Validando Estrutura\n")

print(f"Fretes........{len(df_frete)} linhas")
print(f"KM Rodado.....{len(df_km)} linhas")
print(f"Veículos......{len(df_veiculo)} registros")
print(f"Clientes......{len(df_cliente)} registros")

# ============================================================
# 5. VALIDAÇÃO DE INTEGRIDADE
# ============================================================

print("\n[3/8]")
print("Validando Integridade\n")

total_nulos = (
    df_frete.isnull().sum().sum()
    + df_km.isnull().sum().sum()
    + df_veiculo.isnull().sum().sum()
    + df_cliente.isnull().sum().sum()
)

if total_nulos == 0:
    print("✓ Nenhum valor nulo encontrado")
else:
    print(f"⚠ {total_nulos} valores nulos encontrados")

print("✓ Estrutura consistente")
print("✓ Dados prontos para processamento")

# ============================================================
# 6. CRIAR CUSTO OPERACIONAL TOTAL
# ============================================================

print("\n[4/8]")
print("Calculando custo operacional...")

df_km["Custo_Operacional_Total"] = (
    df_km["Gasto com Combustível"]
    + df_km["Manut."]
    + df_km["Custos Fixos"]
)

print("✓ Custo Operacional Total calculado")

# ============================================================
# 7. AGRUPAR RECEITAS POR VEÍCULO
# ============================================================

df_receita = (
    df_frete
    .groupby("ID Veiculo", as_index=False)
    ["Valor do Frete Líquido"]
    .sum()
)

# ============================================================
# 8. AGRUPAR CUSTOS POR VEÍCULO
# ============================================================

df_custo = (
    df_km
    .groupby("ID Veiculo", as_index=False)
    [["Custo_Operacional_Total",
      "Km percorridos",
      "Gasto com Combustível"]]
    .sum()
)

print("\n[5/8]")
print("Agrupando receitas e custos por veículo...")
print("✓ Receita agrupada")
print("✓ Custos agrupados")

# ============================================================
# 9. MERGE RECEITA + CUSTOS
# ============================================================

df_performance = pd.merge(
    df_receita,
    df_custo,
    on="ID Veiculo",
    how="inner"
)

# ============================================================
# 10. MERGE COM CADASTRO DOS VEÍCULOS
# ============================================================

df_final = pd.merge(
    df_performance,
    df_veiculo,
    on="ID Veiculo",
    how="left"
)

print("\n[6/8]")
print("Consolidando base final...")
print("✓ Receita + Custos mesclados")
print("✓ Cadastro de veículos mesclado")

# ============================================================
# 11. CRIAR INDICADORES
# ============================================================

df_final["Margem_Liquida"] = (
    df_final["Valor do Frete Líquido"]
    - df_final["Custo_Operacional_Total"]
)

df_final["Custo_Por_KM"] = (
    df_final["Custo_Operacional_Total"]
    / df_final["Km percorridos"]
)

print("\nBase consolidada criada")
print(f"Veículos analisados: {df_final['ID Veiculo'].nunique()}")
print("\nIndicadores criados:")
print("✓ Margem Líquida")
print("✓ Custo por KM")
print("✓ Receita Total")
print("✓ Custo Operacional")

# ============================================================
# 12. INDICADORES ESTATÍSTICOS
# ============================================================

print("\n[7/8]")
print("Calculando indicadores estatísticos\n")

print(f"Receita Média..........R$ {df_final['Valor do Frete Líquido'].mean():,.2f}")
print(f"Receita Máxima..........R$ {df_final['Valor do Frete Líquido'].max():,.2f}")
print(f"Receita Mínima..........R$ {df_final['Valor do Frete Líquido'].min():,.2f}")
print(f"Margem Média............R$ {df_final['Margem_Liquida'].mean():,.2f}")
print(f"Custo Médio por KM......R$ {df_final['Custo_Por_KM'].mean():,.2f}")

# ============================================================
# 13. MAIORES MARGENS (TOP 10)
# ============================================================

top10 = df_final.sort_values(by="Margem_Liquida", ascending=False).head(10)

print("\nTop 10 veículos por margem líquida:")
print(
    top10[["ID Veiculo", "Placa", "Marca", "Margem_Liquida"]]
    .to_string(index=False)
)

# ============================================================
# 14. VEÍCULOS COM PREJUÍZO
# ============================================================

prejuizo = df_final[df_final["Margem_Liquida"] < 0]

print("\nVeículos com prejuízo:")
if prejuizo.empty:
    print("Nenhum veículo apresentou Margem Líquida negativa.")
    print("Todos os veículos operaram com lucro no período analisado.")
else:
    print(
        prejuizo[["ID Veiculo", "Placa", "Marca", "Margem_Liquida"]]
        .to_string(index=False)
    )

# ============================================================
# 15. MARGEM MÉDIA POR TIPO DE VEÍCULO
# ============================================================

margem_tipo = (
    df_final
    .groupby("Tipo Veículo")
    ["Margem_Liquida"]
    .mean()
    .reset_index()
    .sort_values(by="Margem_Liquida", ascending=False)
)

# ============================================================
# 16. GRÁFICO DE BARRAS
# ============================================================

plt.figure(figsize=(12, 6))

ax = sns.barplot(
    data=margem_tipo,
    x="Tipo Veículo",
    y="Margem_Liquida",
    order=margem_tipo["Tipo Veículo"],
    hue="Tipo Veículo",
    palette="Blues_d",
    legend=False
)

for container in ax.containers:
    ax.bar_label(container, fmt="R$ %.0f", padding=3)

plt.title(
    "Margem Líquida Média por Tipo de Veículo\n"
    "Período analisado: Base Logística",
    fontsize=13,
    fontweight="bold"
)

plt.xlabel("Tipo Veículo")
plt.ylabel("Margem Líquida Média (R$)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# ============================================================
# 17. GRÁFICO DE DISPERSÃO (KM x COMBUSTÍVEL)
# ============================================================

# Traz a Marca para a base de KM (1200 registros) via merge,
# em vez de usar df_final (50 registros agregados)
df_km_marca = pd.merge(
    df_km,
    df_veiculo[["ID Veiculo", "Marca"]],
    on="ID Veiculo",
    how="left"
)

plt.figure(figsize=(12, 6))

sns.scatterplot(
    data=df_km_marca,
    x="Km percorridos",
    y="Gasto com Combustível",
    hue="Marca",
    s=80,
    alpha=0.7
)

plt.title("Km Percorridos x Gasto com Combustível", fontsize=13, fontweight="bold")
plt.xlabel("Km Percorridos")
plt.ylabel("Gasto com Combustível (R$)")
plt.tight_layout()
plt.show()

print(
    "\nAnálise: foi observado comportamento proporcional entre Km e consumo "
    "de combustível. Os pontos mais afastados representam veículos que "
    "merecem investigação quanto à eficiência do consumo."
)

# ============================================================
# 18. RESUMO EXECUTIVO
# ============================================================

print("\n[8/8]")
print("Gerando resumo executivo...\n")

receita_total = df_final["Valor do Frete Líquido"].sum()
custo_total = df_final["Custo_Operacional_Total"].sum()
margem_total = df_final["Margem_Liquida"].sum()
custo_medio_km = df_final["Custo_Por_KM"].mean()

print("=" * 30)
print("RESUMO EXECUTIVO")
print("=" * 30)
print(f"Veículos analisados........{df_final['ID Veiculo'].nunique()}")
print(f"Clientes................{len(df_cliente)}")
print(f"Fretes..................{len(df_frete)}")
print(f"Receita Total........R$ {receita_total:,.0f}")
print(f"Custos Totais........R$ {custo_total:,.0f}")
print(f"Margem Líquida.......R$ {margem_total:,.0f}")
print(f"Custo Médio/KM.......R$ {custo_medio_km:,.2f}")
print("=" * 30)

# ============================================================
# 19. EXPORTAÇÃO DA BASE FINAL
# ============================================================

df_final.to_excel(
    "Performance_Frota.xlsx",
    index=False
)

print("\n" + "=" * 56)
print("ANÁLISE CONCLUÍDA")
print("✓ Receita consolidada")
print("✓ Custos consolidados")
print("✓ Indicadores calculados")
print("✓ Gráficos gerados")
print("✓ Arquivo Performance_Frota.xlsx exportado")
print("=" * 56)