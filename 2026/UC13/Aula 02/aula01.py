import re


# ============================================================
# ANALISADOR DE FORÇA DE SENHA
# ============================================================
#
# Este programa analisa uma senha utilizando 5 critérios:
#
# 1. Possuir pelo menos 8 caracteres
# 2. Possuir pelo menos uma letra maiúscula
# 3. Possuir pelo menos uma letra minúscula
# 4. Possuir pelo menos um número
# 5. Possuir pelo menos um caractere especial
#
# Cada critério atendido vale 1 ponto.
#
# Pontuação:
#   0 a 2 pontos -> FRACA
#   3 a 4 pontos -> MÉDIA
#   5 pontos     -> FORTE
#
# ============================================================


def verificar_tamanho(senha):
    """
    Verifica se a senha possui pelo menos 8 caracteres.

    Retorna:
        True  -> se a senha tiver 8 ou mais caracteres
        False -> caso contrário
    """

    return len(senha) >= 8


def verificar_maiuscula(senha):
    """
    Verifica se a senha possui pelo menos uma letra maiúscula.

    Exemplo:
        Senha123 -> True
        senha123 -> False
    """

    return re.search(r"[A-Z]", senha) is not None


def verificar_minuscula(senha):
    """
    Verifica se a senha possui pelo menos uma letra minúscula.

    Exemplo:
        SENHA123 -> False
        Senha123 -> True
    """

    return re.search(r"[a-z]", senha) is not None


def verificar_numero(senha):
    """
    Verifica se a senha possui pelo menos um número.

    Exemplo:
        SenhaABC -> False
        Senha123 -> True
    """

    return re.search(r"[0-9]", senha) is not None


def verificar_caractere_especial(senha):
    """
    Verifica se a senha possui pelo menos um caractere especial.

    Caracteres especiais são símbolos que não sejam:
        - letras maiúsculas
        - letras minúsculas
        - números

    Exemplos:
        ! @ # $ % & * ?
    """

    return re.search(r"[^A-Za-z0-9]", senha) is not None


def analisar_senha(senha):
    """
    Analisa todos os critérios da senha.

    Retorna:
        pontuacao -> quantidade de critérios atendidos
        motivos   -> lista contendo os critérios que não foram atendidos
    """

    # Começamos com zero pontos.
    pontuacao = 0

    # Esta lista armazenará os motivos pelos quais
    # a senha precisa ser melhorada.
    motivos = []

    # --------------------------------------------------------
    # CRITÉRIO 1 - TAMANHO
    # --------------------------------------------------------

    if verificar_tamanho(senha):
        pontuacao += 1
    else:
        motivos.append("tem menos de 8 caracteres")

    # --------------------------------------------------------
    # CRITÉRIO 2 - LETRA MAIÚSCULA
    # --------------------------------------------------------

    if verificar_maiuscula(senha):
        pontuacao += 1
    else:
        motivos.append("não possui letra maiúscula")

    # --------------------------------------------------------
    # CRITÉRIO 3 - LETRA MINÚSCULA
    # --------------------------------------------------------

    if verificar_minuscula(senha):
        pontuacao += 1
    else:
        motivos.append("não possui letra minúscula")

    # --------------------------------------------------------
    # CRITÉRIO 4 - NÚMERO
    # --------------------------------------------------------

    if verificar_numero(senha):
        pontuacao += 1
    else:
        motivos.append("não possui número")

    # --------------------------------------------------------
    # CRITÉRIO 5 - CARACTERE ESPECIAL
    # --------------------------------------------------------

    if verificar_caractere_especial(senha):
        pontuacao += 1
    else:
        motivos.append("não possui caractere especial")

    # Retorna os resultados da análise.
    return pontuacao, motivos


def classificar_senha(pontuacao):
    """
    Classifica a senha de acordo com sua pontuação.

    Regras:
        0 a 2 -> FRACA
        3 a 4 -> MÉDIA
        5     -> FORTE
    """

    if pontuacao <= 2:
        return "FRACA"

    elif pontuacao <= 4:
        return "MÉDIA"

    else:
        return "FORTE"


def exibir_resultado(senha, pontuacao, motivos):
    """
    Exibe o resultado da análise no terminal.

    A senha original nunca é exibida.
    No lugar dela, usamos asteriscos.
    """

    # Descobre o nível da senha com base na pontuação.
    nivel = classificar_senha(pontuacao)

    # Cria uma representação visual da senha usando
    # apenas asteriscos.
    senha_oculta = "*" * len(senha)

    # --------------------------------------------------------
    # CABEÇALHO
    # --------------------------------------------------------

    print()
    print("=" * 40)
    print("       RESULTADO DA ANÁLISE")
    print("=" * 40)

    # --------------------------------------------------------
    # INFORMAÇÕES PRINCIPAIS
    # --------------------------------------------------------

    print(f"Senha:      {senha_oculta}")
    print(f"Nível:      {nivel}")
    print(f"Pontuação:  {pontuacao} / 5")

    # --------------------------------------------------------
    # MOTIVOS PARA MELHORAR
    # --------------------------------------------------------

    if motivos:
        print()
        print("Por que precisa melhorar?")

        # Percorre todos os motivos encontrados.
        for motivo in motivos:
            print(f"- {motivo}")

    else:
        print()
        print("Excelente!")
        print("A senha atende a todos os critérios.")

    # --------------------------------------------------------
    # RODAPÉ
    # --------------------------------------------------------

    print("=" * 40)
    print()


def main():
    """
    Função principal do programa.

    Responsável por organizar a execução:
        1. Solicitar a senha
        2. Validar a entrada
        3. Analisar a senha
        4. Exibir o resultado
    """

    print("=" * 40)
    print("       ANALISADOR DE SENHA")
    print("=" * 40)
    print()

    # --------------------------------------------------------
    # ENTRADA DO USUÁRIO
    # --------------------------------------------------------

    senha = input("Digite uma senha: ")

    # Remove espaços que eventualmente estejam no começo
    # ou no final da entrada.
    senha = senha.strip()

    # --------------------------------------------------------
    # VALIDAÇÃO DA ENTRADA
    # --------------------------------------------------------

    if not senha:
        print()
        print("Erro: nenhuma senha foi informada.")
        print("Execute o programa novamente e informe uma senha.")
        return

    # --------------------------------------------------------
    # ANÁLISE
    # --------------------------------------------------------

    pontuacao, motivos = analisar_senha(senha)

    # --------------------------------------------------------
    # RESULTADO
    # --------------------------------------------------------

    exibir_resultado(
        senha,
        pontuacao,
        motivos
    )


# ============================================================
# PONTO DE ENTRADA DO PROGRAMA
# ============================================================
#
# Esta condição faz com que a função main() seja executada
# somente quando este arquivo for executado diretamente.
#
# No VS Code, basta executar:
#
#     python nome_do_arquivo.py
#
# ============================================================

if __name__ == "__main__":
    main()