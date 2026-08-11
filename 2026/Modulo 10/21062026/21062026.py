import os
import sys
import time
import unicodedata
from dataclasses import dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text


ARQUIVO_EXCEL = "BaseFuncionarios.xlsx"
PASTA_SAIDA = "graficos_people_analytics"

COLUNA_CUSTO_TOTAL = "Custo_Total_Funcionario"
COLUNA_STATUS = "Status"

console = Console()


@dataclass(frozen=True)
class ColunasRH:
    nome: str
    salario: str
    impostos: str
    beneficios: str
    vt: str
    vr: str
    area: str
    nivel: str
    cargo: str
    contratacao: str
    demissao: str
    ferias: str
    horas_extras: str
    avaliacao: str
    trabalho_equipe: str
    lideranca: str
    comunicacao: str
    iniciativa: str
    organizacao: str
    sexo: str
    estado_civil: str


class PeopleAnalyticsReport:
    def __init__(self, arquivo_excel: str = ARQUIVO_EXCEL) -> None:
        self.arquivo_excel = Path(arquivo_excel)
        self.pasta_saida = Path(PASTA_SAIDA)
        self.df_bruto: pd.DataFrame | None = None
        self.df: pd.DataFrame | None = None
        self.colunas: ColunasRH | None = None
        self.inicio_execucao = time.perf_counter()

    @staticmethod
    def normalizar_texto(texto: object) -> str:
        texto = str(texto).strip().lower()
        texto = unicodedata.normalize("NFKD", texto)
        texto = "".join(c for c in texto if not unicodedata.combining(c))
        return " ".join(texto.split())

    @staticmethod
    def moeda(valor: float) -> str:
        return f"R$ {valor:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

    @staticmethod
    def numero(valor: float) -> str:
        return f"{valor:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

    def encontrar_coluna(self, nome_esperado: str) -> str:
        assert self.df_bruto is not None

        esperado = self.normalizar_texto(nome_esperado)
        mapa_colunas = {
            self.normalizar_texto(coluna): coluna
            for coluna in self.df_bruto.columns
        }

        if esperado in mapa_colunas:
            return mapa_colunas[esperado]

        raise KeyError(
            f"Coluna obrigatória não encontrada: {nome_esperado}\n"
            f"Colunas disponíveis: {list(self.df_bruto.columns)}"
        )

    def carregar_base(self) -> None:
        if not self.arquivo_excel.exists():
            console.print(
                Panel.fit(
                    f"[bold red]Arquivo não encontrado:[/bold red] {self.arquivo_excel}\n\n"
                    "Coloque o arquivo BaseFuncionarios.xlsx na mesma pasta deste script.",
                    title="Erro de Arquivo",
                    border_style="red",
                )
            )
            sys.exit(1)

        self.df_bruto = pd.read_excel(self.arquivo_excel, engine="openpyxl")

    def mapear_colunas(self) -> None:
        self.colunas = ColunasRH(
            nome=self.encontrar_coluna("Nome Completo"),
            salario=self.encontrar_coluna("Salario Base"),
            impostos=self.encontrar_coluna("Impostos"),
            beneficios=self.encontrar_coluna("Beneficios"),
            vt=self.encontrar_coluna("VT"),
            vr=self.encontrar_coluna("VR"),
            area=self.encontrar_coluna("Area"),
            nivel=self.encontrar_coluna("Nivel"),
            cargo=self.encontrar_coluna("Cargo"),
            contratacao=self.encontrar_coluna("Data de Contratacao"),
            demissao=self.encontrar_coluna("Data de Demissao"),
            ferias=self.encontrar_coluna("Ferias Acumuladas"),
            horas_extras=self.encontrar_coluna("Horas Extras"),
            avaliacao=self.encontrar_coluna("Avaliacao do Funcionario"),
            trabalho_equipe=self.encontrar_coluna("Trabalho em Equipe"),
            lideranca=self.encontrar_coluna("Lideranca"),
            comunicacao=self.encontrar_coluna("Comunicacao"),
            iniciativa=self.encontrar_coluna("Iniciativa"),
            organizacao=self.encontrar_coluna("Organizacao"),
            sexo=self.encontrar_coluna("Sexo"),
            estado_civil=self.encontrar_coluna("Estado Civil"),
        )

    def preparar_dados(self) -> None:
        assert self.df_bruto is not None
        assert self.colunas is not None

        c = self.colunas
        df = self.df_bruto.copy()

        colunas_financeiras = [c.salario, c.impostos, c.beneficios, c.vt, c.vr]
        colunas_numericas = [
            *colunas_financeiras,
            c.ferias,
            c.horas_extras,
            c.avaliacao,
            c.trabalho_equipe,
            c.lideranca,
            c.comunicacao,
            c.iniciativa,
            c.organizacao,
        ]

        for coluna in colunas_numericas:
            df[coluna] = pd.to_numeric(df[coluna], errors="coerce")

        df[c.contratacao] = pd.to_datetime(df[c.contratacao], errors="coerce")
        df[c.demissao] = pd.to_datetime(df[c.demissao], errors="coerce")

        df[COLUNA_CUSTO_TOTAL] = df[colunas_financeiras].sum(axis=1)
        df[COLUNA_STATUS] = df[c.demissao].apply(
            lambda valor: "Demitido" if pd.notna(valor) else "Ativo"
        )

        self.df = df

    def validar_qualidade(self) -> None:
        assert self.df is not None

        if self.df.empty:
            raise ValueError("A base está vazia.")

        if self.df[COLUNA_CUSTO_TOTAL].isna().all():
            raise ValueError("Não foi possível calcular o custo total dos funcionários.")

    def tabela_hipoteses(self) -> None:
        tabela = Table(title="1. Hipóteses de Negócio", show_header=True, header_style="bold cyan")
        tabela.add_column("Hipótese", style="bold")
        tabela.add_column("Descrição")

        tabela.add_row(
            "H1",
            "Cargos de nível júnior ou estagiário podem concentrar custos indiretos por horas extras e férias acumuladas.",
        )
        tabela.add_row(
            "H2",
            "Funcionários demitidos podem apresentar perfil de competências diferente dos funcionários ativos.",
        )
        tabela.add_row(
            "H3",
            "Áreas com maior custo total podem estar pressionando o orçamento além do salário-base.",
        )

        console.print(tabela)

    def resumo_executivo(self) -> None:
        assert self.df is not None
        assert self.colunas is not None

        total = len(self.df)
        ativos = int((self.df[COLUNA_STATUS] == "Ativo").sum())
        demitidos = int((self.df[COLUNA_STATUS] == "Demitido").sum())
        taxa_turnover = demitidos / total * 100

        c = self.colunas

        custo_area = self.df.groupby(c.area)[COLUNA_CUSTO_TOTAL].mean().sort_values(ascending=False)
        custo_total_area = self.df.groupby(c.area)[COLUNA_CUSTO_TOTAL].sum().sort_values(ascending=False)
        horas_cargo = (
            self.df.groupby(c.cargo)
            .agg(
                media_horas=(c.horas_extras, "mean"),
                funcionarios=(c.cargo, "count"),
            )
            .sort_values("media_horas", ascending=False)
        )

        area_maior_custo_medio = custo_area.index[0]
        valor_maior_custo_medio = custo_area.iloc[0]

        area_maior_custo_total = custo_total_area.index[0]
        valor_maior_custo_total = custo_total_area.iloc[0]

        cargo_maior_he = horas_cargo.index[0]
        valor_maior_he = horas_cargo.iloc[0]["media_horas"]
        qtd_cargo = int(horas_cargo.iloc[0]["funcionarios"])

        texto = Text()
        texto.append("PEOPLE ANALYTICS REPORT\n", style="bold cyan")
        texto.append("Auditoria de Custos, Sobrecarga e Perfil de Desligamentos\n\n", style="white")
        texto.append(f"Base analisada.................... {self.arquivo_excel.name}\n")
        texto.append(f"Registros processados............. {total}\n")
        texto.append(f"Funcionários ativos............... {ativos}\n")
        texto.append(f"Funcionários desligados........... {demitidos}\n")
        texto.append(f"Taxa de desligamento.............. {self.numero(taxa_turnover)}%\n\n")
        texto.append(f"Área com maior custo médio........ {area_maior_custo_medio} ({self.moeda(valor_maior_custo_medio)})\n")
        texto.append(f"Área com maior custo total........ {area_maior_custo_total} ({self.moeda(valor_maior_custo_total)})\n")
        texto.append(f"Cargo com maior média de HE....... {cargo_maior_he} ({self.numero(valor_maior_he)}h | n={qtd_cargo})")

        console.print(Panel(texto, title="Resumo Executivo", border_style="cyan"))

    def analise_estrutura(self) -> None:
        assert self.df is not None

        tabela = Table(title="2. Estrutura da Base", show_header=True, header_style="bold cyan")
        tabela.add_column("Indicador")
        tabela.add_column("Valor", justify="right")

        tabela.add_row("Linhas", str(len(self.df)))
        tabela.add_row("Colunas", str(len(self.df.columns)))
        tabela.add_row("Colunas com nulos", str(int((self.df.isna().sum() > 0).sum())))
        tabela.add_row("Memória aproximada", f"{self.df.memory_usage(deep=True).sum() / 1024:.2f} KB")

        console.print(tabela)

    def analise_nulos(self) -> None:
        assert self.df is not None

        nulos = self.df.isna().sum()
        nulos = nulos[nulos > 0].sort_values(ascending=False)

        tabela = Table(title="3. Qualidade dos Dados: Valores Nulos", show_header=True, header_style="bold cyan")
        tabela.add_column("Coluna")
        tabela.add_column("Nulos", justify="right")
        tabela.add_column("%", justify="right")

        if nulos.empty:
            tabela.add_row("Nenhuma coluna com nulos", "0", "0,00%")
        else:
            for coluna, qtd in nulos.items():
                percentual = qtd / len(self.df) * 100
                tabela.add_row(str(coluna), str(int(qtd)), f"{self.numero(percentual)}%")

        console.print(tabela)

    def analise_custo_area_nivel(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        resultado = (
            self.df.groupby([c.area, c.nivel])[COLUNA_CUSTO_TOTAL]
            .agg(Media="mean", Mediana="median", Quantidade="count")
            .sort_values("Media", ascending=False)
            .round(2)
        )

        tabela = Table(title="4. Média e Mediana do Custo Total por Área e Nível", show_header=True, header_style="bold cyan")
        tabela.add_column("Área")
        tabela.add_column("Nível")
        tabela.add_column("Média", justify="right")
        tabela.add_column("Mediana", justify="right")
        tabela.add_column("Qtd", justify="right")

        for (area, nivel), linha in resultado.iterrows():
            tabela.add_row(
                str(area),
                str(nivel),
                self.moeda(float(linha["Media"])),
                self.moeda(float(linha["Mediana"])),
                str(int(linha["Quantidade"])),
            )

        console.print(tabela)
        return resultado

    def analise_custo_area(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        resultado = (
            self.df.groupby(c.area)
            .agg(
                Custo_Medio=(COLUNA_CUSTO_TOTAL, "mean"),
                Custo_Total=(COLUNA_CUSTO_TOTAL, "sum"),
                Funcionarios=(c.area, "count"),
            )
            .sort_values("Custo_Medio", ascending=False)
            .round(2)
        )

        tabela = Table(title="5. Ranking de Custo por Área", show_header=True, header_style="bold cyan")
        tabela.add_column("Rank", justify="right")
        tabela.add_column("Área")
        tabela.add_column("Custo Médio", justify="right")
        tabela.add_column("Custo Total", justify="right")
        tabela.add_column("Qtd", justify="right")

        for posicao, (area, linha) in enumerate(resultado.iterrows(), start=1):
            medalha = "🥇" if posicao == 1 else "🥈" if posicao == 2 else "🥉" if posicao == 3 else f"{posicao}º"
            tabela.add_row(
                medalha,
                str(area),
                self.moeda(float(linha["Custo_Medio"])),
                self.moeda(float(linha["Custo_Total"])),
                str(int(linha["Funcionarios"])),
            )

        console.print(tabela)
        return resultado

    def analise_horas_extras_cargo(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        resultado = (
            self.df.groupby(c.cargo)
            .agg(
                Media_Horas_Extras=(c.horas_extras, "mean"),
                Mediana_Horas_Extras=(c.horas_extras, "median"),
                Quantidade=(c.cargo, "count"),
            )
            .sort_values("Media_Horas_Extras", ascending=False)
            .round(2)
        )

        tabela = Table(title="6. Sobrecarga: Top 10 Cargos por Média de Horas Extras", show_header=True, header_style="bold cyan")
        tabela.add_column("Rank", justify="right")
        tabela.add_column("Cargo")
        tabela.add_column("Média HE", justify="right")
        tabela.add_column("Mediana HE", justify="right")
        tabela.add_column("Qtd", justify="right")
        tabela.add_column("Alerta")

        for posicao, (cargo, linha) in enumerate(resultado.head(10).iterrows(), start=1):
            qtd = int(linha["Quantidade"])
            media = float(linha["Media_Horas_Extras"])
            alerta = "Amostra pequena" if qtd < 3 else "Sobrecarga alta" if media >= 120 else "Monitorar"

            tabela.add_row(
                str(posicao),
                str(cargo),
                f"{self.numero(media)}h",
                f"{self.numero(float(linha['Mediana_Horas_Extras']))}h",
                str(qtd),
                alerta,
            )

        console.print(tabela)
        return resultado

    def analise_demitidos(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas
        df_demitidos = self.df[self.df[COLUNA_STATUS] == "Demitido"].copy()

        competencias = [
            c.avaliacao,
            c.trabalho_equipe,
            c.lideranca,
            c.comunicacao,
            c.iniciativa,
            c.organizacao,
        ]

        resultado = df_demitidos[competencias].mean().sort_values(ascending=False).round(2)

        tabela = Table(title="7. Perfil Médio de Competências dos Demitidos", show_header=True, header_style="bold cyan")
        tabela.add_column("Competência")
        tabela.add_column("Média", justify="right")
        tabela.add_column("Leitura")

        for competencia, media in resultado.items():
            leitura = "Ponto forte" if media >= 9 else "Adequado" if media >= 8 else "Ponto de atenção"
            tabela.add_row(str(competencia), self.numero(float(media)), leitura)

        console.print(tabela)
        return resultado.to_frame("Media_Demitidos")

    def comparacao_ativos_demitidos(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        colunas_analise = [
            COLUNA_CUSTO_TOTAL,
            c.horas_extras,
            c.ferias,
            c.avaliacao,
            c.trabalho_equipe,
            c.lideranca,
            c.comunicacao,
            c.iniciativa,
            c.organizacao,
        ]

        resultado = self.df.groupby(COLUNA_STATUS)[colunas_analise].mean().round(2)

        tabela = Table(title="8. Comparação entre Ativos e Demitidos", show_header=True, header_style="bold cyan")
        tabela.add_column("Métrica")
        tabela.add_column("Ativos", justify="right")
        tabela.add_column("Demitidos", justify="right")
        tabela.add_column("Diferença", justify="right")

        if {"Ativo", "Demitido"}.issubset(resultado.index):
            for metrica in colunas_analise:
                ativo = float(resultado.loc["Ativo", metrica])
                demitido = float(resultado.loc["Demitido", metrica])
                diferenca = demitido - ativo

                if metrica == COLUNA_CUSTO_TOTAL:
                    tabela.add_row(
                        metrica,
                        self.moeda(ativo),
                        self.moeda(demitido),
                        self.moeda(diferenca),
                    )
                else:
                    tabela.add_row(
                        metrica,
                        self.numero(ativo),
                        self.numero(demitido),
                        self.numero(diferenca),
                    )

        console.print(tabela)
        return resultado

    def analise_juniores_estagiarios(self) -> pd.DataFrame:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        niveis = self.df[c.nivel].astype(str).map(self.normalizar_texto)
        mascara = niveis.str.contains("junior|estagi", regex=True, na=False)

        recorte = self.df[mascara].copy()

        resultado = (
            recorte.groupby([c.area, c.nivel])
            .agg(
                Quantidade=(c.nivel, "count"),
                Custo_Total_Medio=(COLUNA_CUSTO_TOTAL, "mean"),
                Horas_Extras_Media=(c.horas_extras, "mean"),
                Ferias_Media=(c.ferias, "mean"),
                Avaliacao_Media=(c.avaliacao, "mean"),
            )
            .sort_values(["Horas_Extras_Media", "Ferias_Media"], ascending=False)
            .round(2)
        )

        tabela = Table(title="9. Recorte: Juniores e Estagiários", show_header=True, header_style="bold cyan")
        tabela.add_column("Área")
        tabela.add_column("Nível")
        tabela.add_column("Qtd", justify="right")
        tabela.add_column("Custo Médio", justify="right")
        tabela.add_column("Média HE", justify="right")
        tabela.add_column("Férias Médias", justify="right")
        tabela.add_column("Avaliação", justify="right")

        for (area, nivel), linha in resultado.iterrows():
            tabela.add_row(
                str(area),
                str(nivel),
                str(int(linha["Quantidade"])),
                self.moeda(float(linha["Custo_Total_Medio"])),
                f"{self.numero(float(linha['Horas_Extras_Media']))}h",
                self.numero(float(linha["Ferias_Media"])),
                self.numero(float(linha["Avaliacao_Media"])),
            )

        console.print(tabela)
        return resultado

    def analise_equidade_avaliacao(self) -> None:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        por_sexo = self.df.groupby(c.sexo)[c.avaliacao].agg(["mean", "median", "count"]).round(2)
        por_estado_civil = self.df.groupby(c.estado_civil)[c.avaliacao].agg(["mean", "median", "count"]).round(2)

        tabela = Table(title="10. Equidade: Avaliação por Sexo", show_header=True, header_style="bold cyan")
        tabela.add_column("Sexo")
        tabela.add_column("Média", justify="right")
        tabela.add_column("Mediana", justify="right")
        tabela.add_column("Qtd", justify="right")

        for sexo, linha in por_sexo.iterrows():
            tabela.add_row(
                str(sexo),
                self.numero(float(linha["mean"])),
                self.numero(float(linha["median"])),
                str(int(linha["count"])),
            )

        console.print(tabela)

        tabela2 = Table(title="11. Equidade: Avaliação por Estado Civil", show_header=True, header_style="bold cyan")
        tabela2.add_column("Estado Civil")
        tabela2.add_column("Média", justify="right")
        tabela2.add_column("Mediana", justify="right")
        tabela2.add_column("Qtd", justify="right")

        for estado, linha in por_estado_civil.iterrows():
            tabela2.add_row(
                str(estado),
                self.numero(float(linha["mean"])),
                self.numero(float(linha["median"])),
                str(int(linha["count"])),
            )

        console.print(tabela2)

    def reflexoes_conceituais(self) -> None:
        texto = """
Dado bruto vs. Insight de RH:
Horas extras e férias acumuladas deixam de ser números isolados quando cruzadas por área, cargo e nível.
Se um grupo concentra muitas horas extras e muitas férias pendentes, isso pode indicar sobrecarga,
risco de burnout, falha de dimensionamento da equipe ou dependência operacional excessiva.

Viés em Avaliações:
Notas de soft skills como Liderança, Comunicação e Organização podem afetar promoções, salários
e permanência na empresa. Por isso, comparar avaliações por Sexo e Estado Civil ajuda a levantar
sinais de possíveis diferenças sistemáticas que precisam ser auditadas com cuidado.

Decisões com Evidências:
Analisar apenas o Salário Base é um erro porque o custo real do colaborador inclui impostos,
benefícios, VT e VR. Para planejamento orçamentário, a métrica correta é o Custo Total do Funcionário.
"""
        console.print(Panel(texto.strip(), title="12. Reflexão Conceitual", border_style="magenta"))

    def conclusao_final(self) -> None:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas

        custo_area = self.df.groupby(c.area)[COLUNA_CUSTO_TOTAL].mean().sort_values(ascending=False)
        horas_cargo = (
            self.df.groupby(c.cargo)
            .agg(media_he=(c.horas_extras, "mean"), qtd=(c.cargo, "count"))
            .sort_values("media_he", ascending=False)
        )

        demitidos = self.df[self.df[COLUNA_STATUS] == "Demitido"]
        competencias = [
            c.avaliacao,
            c.trabalho_equipe,
            c.lideranca,
            c.comunicacao,
            c.iniciativa,
            c.organizacao,
        ]
        menor_competencia = demitidos[competencias].mean().sort_values().index[0]
        menor_valor = demitidos[competencias].mean().sort_values().iloc[0]

        area_top = custo_area.index[0]
        valor_area_top = custo_area.iloc[0]

        cargo_top = horas_cargo.index[0]
        media_he_top = horas_cargo.iloc[0]["media_he"]
        qtd_top = int(horas_cargo.iloc[0]["qtd"])

        texto = Text()
        texto.append("Conclusão Executiva\n\n", style="bold cyan")
        texto.append(f"1. A área com maior custo médio por funcionário é ")
        texto.append(f"{area_top}", style="bold")
        texto.append(f", com média de {self.moeda(float(valor_area_top))}.\n\n")

        texto.append(f"2. O cargo com maior média de horas extras é ")
        texto.append(f"{cargo_top}", style="bold")
        texto.append(f", com {self.numero(float(media_he_top))}h em média. ")
        texto.append(f"A amostra possui {qtd_top} funcionário(s), então cargos com poucos registros devem ser interpretados com cautela.\n\n")

        texto.append(f"3. Entre os demitidos, a menor competência média é ")
        texto.append(f"{menor_competencia}", style="bold")
        texto.append(f", com média {self.numero(float(menor_valor))}.\n\n")

        texto.append("Recomendação de RH:\n", style="bold green")
        texto.append(
            "Priorizar investigação em áreas e cargos com alto custo, excesso de horas extras "
            "e férias acumuladas. Também é recomendado auditar avaliações comportamentais "
            "para verificar se há padrões relacionados à permanência ou desligamento."
        )

        console.print(Panel(texto, title="13. Insight Final para o Diretor de RH", border_style="green"))

    def criar_graficos(self) -> None:
        assert self.df is not None
        assert self.colunas is not None

        c = self.colunas
        self.pasta_saida.mkdir(exist_ok=True)

        sns.set_theme(style="whitegrid", palette="Set2")

        custo_area = (
            self.df.groupby(c.area)[COLUNA_CUSTO_TOTAL]
            .mean()
            .sort_values(ascending=False)
            .reset_index()
        )

        plt.figure(figsize=(12, 6))
        ax = sns.barplot(
            data=custo_area,
            x=COLUNA_CUSTO_TOTAL,
            y=c.area,
            orient="h",
        )
        ax.set_title("Custo Total Médio por Área", fontsize=15, weight="bold")
        ax.set_xlabel("Custo Total Médio por Funcionário")
        ax.set_ylabel("Área")

        for container in ax.containers:
            ax.bar_label(
                container,
                labels=[self.moeda(v) for v in custo_area[COLUNA_CUSTO_TOTAL]],
                padding=4,
                fontsize=9,
            )

        plt.tight_layout()
        plt.savefig(self.pasta_saida / "01_custo_total_medio_por_area.png", dpi=300)
        plt.show()

        plt.figure(figsize=(10, 6))
        ax = sns.boxplot(
            data=self.df,
            x=c.sexo,
            y=c.avaliacao,
        )
        sns.stripplot(
            data=self.df,
            x=c.sexo,
            y=c.avaliacao,
            color="black",
            alpha=0.35,
            size=3,
        )
        ax.set_title("Distribuição da Avaliação do Funcionário por Sexo", fontsize=15, weight="bold")
        ax.set_xlabel("Sexo")
        ax.set_ylabel("Avaliação do Funcionário")
        plt.tight_layout()
        plt.savefig(self.pasta_saida / "02_boxplot_avaliacao_por_sexo.png", dpi=300)
        plt.show()

        plt.figure(figsize=(10, 6))
        ax = sns.boxplot(
            data=self.df,
            x=c.estado_civil,
            y=c.avaliacao,
        )
        sns.stripplot(
            data=self.df,
            x=c.estado_civil,
            y=c.avaliacao,
            color="black",
            alpha=0.35,
            size=3,
        )
        ax.set_title("Distribuição da Avaliação do Funcionário por Estado Civil", fontsize=15, weight="bold")
        ax.set_xlabel("Estado Civil")
        ax.set_ylabel("Avaliação do Funcionário")
        plt.tight_layout()
        plt.savefig(self.pasta_saida / "03_boxplot_avaliacao_por_estado_civil.png", dpi=300)
        plt.show()

        horas_cargo = (
            self.df.groupby(c.cargo)
            .agg(
                Media_Horas_Extras=(c.horas_extras, "mean"),
                Quantidade=(c.cargo, "count"),
            )
            .sort_values("Media_Horas_Extras", ascending=False)
            .head(10)
            .reset_index()
        )

        plt.figure(figsize=(12, 6))
        ax = sns.barplot(
            data=horas_cargo,
            x="Media_Horas_Extras",
            y=c.cargo,
            orient="h",
        )
        ax.set_title("Top 10 Cargos por Média de Horas Extras", fontsize=15, weight="bold")
        ax.set_xlabel("Média de Horas Extras")
        ax.set_ylabel("Cargo")

        for container in ax.containers:
            ax.bar_label(
                container,
                labels=[f"{self.numero(v)}h" for v in horas_cargo["Media_Horas_Extras"]],
                padding=4,
                fontsize=9,
            )

        plt.tight_layout()
        plt.savefig(self.pasta_saida / "04_top10_horas_extras_por_cargo.png", dpi=300)
        plt.show()

        ferias_horas = (
            self.df.groupby([c.area, c.nivel])
            .agg(
                Horas_Extras_Media=(c.horas_extras, "mean"),
                Ferias_Media=(c.ferias, "mean"),
                Quantidade=(c.area, "count"),
            )
            .reset_index()
        )

        plt.figure(figsize=(11, 7))
        ax = sns.scatterplot(
            data=ferias_horas,
            x="Horas_Extras_Media",
            y="Ferias_Media",
            size="Quantidade",
            hue=c.area,
            sizes=(80, 450),
            alpha=0.8,
        )
        ax.set_title("Sobrecarga: Horas Extras x Férias Acumuladas por Área e Nível", fontsize=15, weight="bold")
        ax.set_xlabel("Média de Horas Extras")
        ax.set_ylabel("Média de Férias Acumuladas")
        plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left")
        plt.tight_layout()
        plt.savefig(self.pasta_saida / "05_sobrecarga_horas_extras_vs_ferias.png", dpi=300)
        plt.show()

        console.print(
            Panel.fit(
                f"Gráficos salvos na pasta: [bold cyan]{self.pasta_saida.resolve()}[/bold cyan]",
                title="Visualizações Geradas",
                border_style="cyan",
            )
        )

    def executar(self) -> None:
        self.carregar_base()
        self.mapear_colunas()
        self.preparar_dados()
        self.validar_qualidade()

        console.clear()

        self.resumo_executivo()
        self.tabela_hipoteses()
        self.analise_estrutura()
        self.analise_nulos()
        self.analise_custo_area_nivel()
        self.analise_custo_area()
        self.analise_horas_extras_cargo()
        self.analise_demitidos()
        self.comparacao_ativos_demitidos()
        self.analise_juniores_estagiarios()
        self.analise_equidade_avaliacao()
        self.reflexoes_conceituais()
        self.conclusao_final()
        self.criar_graficos()

        tempo_total = time.perf_counter() - self.inicio_execucao

        console.print(
            Panel.fit(
                f"[bold green]Análise finalizada com sucesso![/bold green]\n"
                f"Tempo de execução: {tempo_total:.2f} segundos",
                title="Processo Concluído",
                border_style="green",
            )
        )


def verificar_dependencias() -> None:
    pacotes = {
        "pandas": "pandas",
        "openpyxl": "openpyxl",
        "matplotlib": "matplotlib",
        "seaborn": "seaborn",
        "rich": "rich",
    }

    faltando = []

    for modulo, pacote in pacotes.items():
        try:
            __import__(modulo)
        except ModuleNotFoundError:
            faltando.append(pacote)

    if faltando:
        print("Bibliotecas faltando:")
        for pacote in faltando:
            print(f"- {pacote}")

        print("\nInstale com:")
        print(f"pip install {' '.join(faltando)}")
        sys.exit(1)


def main() -> None:
    verificar_dependencias()
    relatorio = PeopleAnalyticsReport(ARQUIVO_EXCEL)
    relatorio.executar()


if __name__ == "__main__":
    main()