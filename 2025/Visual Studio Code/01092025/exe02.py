# analisa_tweets_corrigido.py
# Requer: pandas, numpy, matplotlib
# Ex.: pip install pandas numpy matplotlib

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import re
from collections import Counter
from urllib.parse import urlparse

# ------------- CONFIGURE AQUI -------------
arquivo_csv = r"C:\Users\luis34288836\Desktop\Ciência de Dados\Excel\TweetsNeutralNews.csv"
# -------------------------------------------

def try_read_csv(path):
    encs = ("utf-8", "latin1", "cp1252", "iso-8859-1")
    seps = (",", ";", "\t")
    for enc in encs:
        for sep in seps:
            try:
                df_test = pd.read_csv(path, encoding=enc, sep=sep, engine='python', nrows=200)
                df = pd.read_csv(path, encoding=enc, sep=sep, engine='python')
                print(f"Lido com sucesso: encoding={enc}, separador={repr(sep)}")
                return df
            except Exception:
                continue
    raise RuntimeError("Não consegui ler o arquivo automaticamente. Verifique separador/encoding no Excel.")

def fix_mojibake(text):
    """Tenta corrigir casos comuns de mojibake (Ã, â etc)."""
    if not isinstance(text, str):
        return text
    # se detectar sequências típicas de mojibake, tenta decodificar/recodificar
    if re.search(r'Ã[[:ascii:]]|â|Â|Ã©|Ãª|Ã£|Ã§|Ã­|Ãº', text):
        try:
            return text.encode('latin1').decode('utf-8')
        except Exception:
            try:
                return text.encode('utf-8').decode('latin1')
            except Exception:
                return text
    return text

def extract_urls(text):
    if not isinstance(text, str):
        return []
    return re.findall(r'https?://\S+', text)

def domain_from_url(u):
    try:
        return urlparse(u).netloc
    except:
        return None

# lista curta de stopwords (expanda se quiser)
PT_STOPWORDS = {
 "que","de","a","o","e","do","da","dos","das","em","um","uma","para","é","com","não","no","na",
 "por","se","me","às","os","as","como","mais","foi","já","são","há","tem","quando","sobre","entre",
 "ser","ao","pela","este","esta","isso","esse","essa","eu","você","ele","ela","nos","mas"
}

def tokenize_simple(s):
    if not isinstance(s, str):
        return []
    tokens = re.findall(r'\w+', s.lower(), flags=re.UNICODE)
    tokens = [t for t in tokens if len(t) > 2 and t not in PT_STOPWORDS and not t.isnumeric()]
    return tokens

def clean_text_basic(s):
    if not isinstance(s, str):
        return ""
    s = s.lower()
    s = re.sub(r'https?://\S+', ' ', s)     # remove urls (já extraídas)
    s = re.sub(r'@\w+', ' ', s)             # remove mentions
    s = re.sub(r'#', '', s)                 # remove # (opcional)
    s = re.sub(r'[^a-z0-9\sçáéíóúãõâêôàèìòùü-]', ' ', s, flags=re.UNICODE)
    s = re.sub(r'\s+', ' ', s).strip()
    return s

def robust_col_mapping(df):
    """Mapeia colunas para nomes padronizados sem conflitar tweet_date/text."""
    col_map = {}
    taken = set()
    for c in df.columns:
        lc = c.lower().strip()
        # data
        if 'date' in lc or lc.endswith('_date'):
            col_map[c] = 'tweet_date'
            taken.add('tweet_date')
            continue
    for c in df.columns:
        if c in col_map: 
            continue
        lc = c.lower().strip()
        if 'text' in lc and 'tweet' in lc:
            # tweet_text preferencial
            if 'text' not in taken:
                col_map[c] = 'text'; taken.add('text'); continue
        if lc == 'tweet' or lc == 'tweet_text' or ('tweet' in lc and 'date' not in lc):
            if 'text' not in taken:
                col_map[c] = 'text'; taken.add('text'); continue
        if 'sentiment' in lc or lc in ('label','class','sentimento'):
            if 'sentiment' not in taken:
                col_map[c] = 'sentiment'; taken.add('sentiment'); continue
        if 'query' in lc or 'used' in lc or 'source' in lc:
            if 'query_used' not in taken:
                col_map[c] = 'query_used'; taken.add('query_used'); continue
        if lc in ('id','tweet_id'):
            if 'id' not in taken:
                col_map[c] = 'id'; taken.add('id'); continue
    return df.rename(columns=col_map), col_map

def main():
    path = Path(arquivo_csv)
    if not path.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {arquivo_csv}")

    df = try_read_csv(str(path))

    print("\nColunas originais:", df.columns.tolist())

    # aplica mapeamento robusto
    df, col_map = robust_col_mapping(df)
    print("Mapeamento aplicado:", col_map)
    print("Colunas após mapeamento:", df.columns.tolist())

    # Se não encontrou coluna text, tenta heurística: primeira coluna object com textos longos
    if 'text' not in df.columns:
        found = False
        for c in df.columns:
            if df[c].dtype == 'object' and df[c].dropna().map(lambda x: len(str(x))).median() > 10:
                df = df.rename(columns={c: 'text'})
                print(f"Usando coluna {c} como 'text' por heurística.")
                found = True
                break
        if not found:
            raise RuntimeError("Não foi possível identificar coluna de texto automaticamente. Informe-me qual coluna é o texto.")

    # Se tweet_date virou string por engano, mantém e converte depois
    if 'tweet_date' in df.columns:
        # se por acidente tweet_date foi renomeado como text, já prevenido pelo mapping robusto.
        pass

    # Corrige mojibake em text e query_used (se existir)
    df['text'] = df['text'].astype(str).map(fix_mojibake)
    if 'query_used' in df.columns:
        df['query_used'] = df['query_used'].astype(str).map(fix_mojibake)

    # Converter tweet_date para datetime (se existir)
    if 'tweet_date' in df.columns:
        df['tweet_date'] = pd.to_datetime(df['tweet_date'], errors='coerce')

    # Estatísticas básicas
    print("\n--- Estatísticas básicas ---")
    print("Linhas:", len(df))
    if 'sentiment' in df.columns:
        print("Sentiment counts:\n", df['sentiment'].value_counts(dropna=False))
    print("Colunas finais:", df.columns.tolist())

    # Colunas auxiliares
    df['text_len_chars'] = df['text'].str.len()
    df['urls'] = df['text'].apply(extract_urls)
    df['num_urls'] = df['urls'].apply(len)
    df['hashtags'] = df['text'].apply(lambda s: re.findall(r'#\w+', str(s)))
    df['tokens'] = df['text'].apply(tokenize_simple)
    df['text_clean'] = df['text'].apply(clean_text_basic)

    # Amostras e exemplos
    print("\nExemplos (texto original -> clean) — 5 amostras:")
    for orig, clean in df[['text','text_clean']].sample(5, random_state=1).values:
        print("----")
        print(orig[:200])
        print("->", clean[:200])

    # Top query_used
    if 'query_used' in df.columns:
        print("\nTop query_used (fontes):")
        print(df['query_used'].value_counts().head(15))

    # Top domínios
    all_urls = [u for lst in df['urls'] for u in lst]
    domains = [domain_from_url(u) for u in all_urls if u]
    dom_counts = Counter(d for d in domains if d)
    print("\nTop domínios encontrados nas URLs:")
    for d,c in dom_counts.most_common(15):
        print(f"{d}: {c}")

    # Top hashtags
    all_hashtags = [h.lower() for lst in df['hashtags'] for h in lst]
    print("\nTop hashtags:")
    for h,c in Counter(all_hashtags).most_common(20):
        print(h, c)

    # Top palavras
    all_tokens = [t for lst in df['tokens'] for t in lst]
    top_words = Counter(all_tokens).most_common(25)
    print("\nTop palavras (após limpeza):")
    for w,c in top_words:
        print(w, c)

    # ========== PLOTS ==========
    plt.rcParams.update({'figure.max_open_warning': 0})

    # Histograma de tamanho
    plt.figure(figsize=(8,4))
    plt.hist(df['text_len_chars'].dropna(), bins=40)
    plt.title("Distribuição do tamanho (caracteres) dos tweets")
    plt.xlabel("Caracteres")
    plt.ylabel("Quantidade")
    plt.tight_layout()
    plt.show()

    # Distribuição de sentimentos (se houver variação)
    if 'sentiment' in df.columns:
        vc = df['sentiment'].value_counts()
        plt.figure(figsize=(6,4))
        vc.plot(kind='bar')
        plt.title("Distribuição de Sentimentos")
        plt.ylabel("Contagem")
        plt.tight_layout()
        plt.show()

        if vc.nunique() == 1:
            print("\nObservação: a coluna 'sentiment' tem apenas uma classe (sem variação). Não é possível treinar um classificador útil com isso.")

    # Top domínios (barra)
    top_dom = dom_counts.most_common(15)
    if top_dom:
        names, counts = zip(*top_dom)
        plt.figure(figsize=(10,4))
        plt.bar(names, counts)
        plt.xticks(rotation=45, ha='right')
        plt.title("Top domínios extraídos das URLs")
        plt.tight_layout()
        plt.show()

    # Top palavras (barra)
    if top_words:
        words, counts = zip(*top_words)
        plt.figure(figsize=(10,4))
        plt.bar(words, counts)
        plt.xticks(rotation=60, ha='right')
        plt.title("Top palavras (limpas)")
        plt.tight_layout()
        plt.show()

    # Série temporal por dia (se houver datas válidas)
    if 'tweet_date' in df.columns and df['tweet_date'].notna().sum() > 0:
        df_d = df.set_index('tweet_date').resample('D').size()
        plt.figure(figsize=(10,4))
        df_d.plot()
        plt.title("Tweets por dia")
        plt.ylabel("Contagem")
        plt.tight_layout()
        plt.show()

    # ========== SALVAMENTO ==========
    saida = path.parent / f"{path.stem}_clean.csv"
    to_save_cols = ['id','text','text_clean','text_len_chars','num_urls','urls','hashtags','tokens']
    if 'sentiment' in df.columns:
        to_save_cols.insert(3, 'sentiment')
    # mantém colunas que existam
    to_save_cols = [c for c in to_save_cols if c in df.columns]
    df[to_save_cols].to_csv(saida, index=False, sep=';')
    print(f"\nCSV limpo salvo em: {saida}")

    sample_file = path.parent / f"{path.stem}_sample_small.csv"
    sample_cols = ['id','text','text_clean']
    if 'sentiment' in df.columns:
        sample_cols.append('sentiment')
    sample_cols = [c for c in sample_cols if c in df.columns]
    df.sample(frac=0.15, random_state=42)[sample_cols].to_csv(sample_file, index=False, sep=';')
    print(f"Amostra pequena salva em: {sample_file}")

    print("\nAnálise concluída.")

if __name__ == "__main__":
    main()
