import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ——— Dados baseados em Pirenópolis (inclui Vale da Lua) ———

# Itens típicos da viagem com relevância local
viagem = ["Transporte (gasolina)", "Alimentação", "Hospedagem", "Entradas em atrações", "Atividades extras"]

# Custos estimados com base em fontes atualizadas
# Transporte: viagem Brasília–Pirenópolis ida e volta ≈ R$ 150 (gasolina, sem pedágio) :contentReference[oaicite:0]{index=0}
# Alimentação: R$ 140 por pessoa por dia (almoço + jantar) :contentReference[oaicite:1]{index=1} assumindo 2 dias = R$ 280 por pessoa, ou R$ 560 para casal
# Hospedagem: pousada charme com café ≈ R$ 368 por noite :contentReference[oaicite:2]{index=2} assumindo 2 noites = R$ 736
# Entradas: cachoeiras entre R$ 30–60, média R$ 45, mais Vale da Lua R$ 40 por pessoa = R$ 170 para casal :contentReference[oaicite:3]{index=3}
# Atividades extras (ex: quadriciclo ou balão): média R$ 150 por pessoa = R$ 300 para casal :contentReference[oaicite:4]{index=4}

custos = np.array([
    150,    # Transporte
    560,    # Alimentação (casal, 2 dias)
    736,    # Hospedagem (2 noites)
    170,    # Entradas em atrações
    300     # Atividades extras
])

# 1. Imprimir a lista completa
print("Itens da viagem (Pirenópolis + Vale da Lua):", viagem)

# 2. Imprimir cada item em uma linha
print("\nItens listados um por um:")
for item in viagem:
    print("-", item)

# 3. Criar um array NumPy com custos — já feito acima

# 4. Mostrar custo total da viagem estimado
print(f"\nCusto total estimado da viagem (casal): R$ {custos.sum():.2f}")

# 5. Criar DataFrame com Pandas
df = pd.DataFrame({
    "Item": viagem,
    "Custo (R$)": custos
})
print("\nTabela da viagem estimada:")
print(df)

# 6. Gerar um gráfico de barras com Matplotlib
plt.figure(figsize=(9, 5))
plt.bar(df["Item"], df["Custo (R$)"], color="coral")
plt.title("Estimativa de Custos: Pirenópolis + Vale da Lua (Casal)")
plt.xlabel("Categoria")
plt.ylabel("Custo em R$")
plt.grid(axis='y', linestyle='--', alpha=0.6)
plt.xticks(rotation=15)
plt.tight_layout()
plt.show()
