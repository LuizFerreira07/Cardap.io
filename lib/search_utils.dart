import 'dart:math' as math;

/// Utilitários de busca aproximada ("fuzzy search") usados no cardápio.
///
/// Resolvem dois problemas do buscador antigo (que usava apenas
/// `String.contains`):
///  1. Não reconhecia termos sem acento (ex.: "limao" não encontrava
///     "Limão", "cafe" não encontrava "Café").
///  2. Não tolerava nenhum erro de digitação (ex.: "pcanha" não
///     encontrava "Picanha").
library search_utils;

const _withDiacritics =
    'áàâãäåāăąèéêëēĕėęěìíîïĩīĭįòóôõöøōŏőùúûüũūŭůűųçćĉċčñńņňÿýỳỹÁÀÂÃÄÅĀĂĄÈÉÊËĒĔĖĘĚÌÍÎÏĨĪĬĮÒÓÔÕÖØŌŎŐÙÚÛÜŨŪŬŮŰŲÇĆĈĊČÑŃŅŇÝ';
const _withoutDiacritics =
    'aaaaaaaaaeeeeeeeeeiiiiiiiiooooooooouuuuuuuuucccccnnnnyyyyAAAAAAAAAEEEEEEEEEIIIIIIIIOOOOOOOOOUUUUUUUUUCCCCCNNNNY';

/// Remove acentuação e normaliza para minúsculas, para permitir
/// comparações que ignoram diacríticos (ex.: "limao" == "limão").
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = _withDiacritics.indexOf(char);
    buffer.write(index >= 0 ? _withoutDiacritics[index] : char);
  }
  return buffer.toString();
}

/// Quebra um texto normalizado em "palavras" (sequências alfanuméricas).
List<String> wordsOf(String normalizedText) {
  return normalizedText
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

/// Distância de Levenshtein clássica (número mínimo de inserções,
/// remoções ou substituições para transformar [a] em [b]).
int levenshteinDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final substitutionCost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + substitutionCost,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

/// Quantos erros de digitação toleramos, proporcional ao tamanho do termo.
/// Termos muito curtos (<=2 letras) não toleram erro, para não gerar
/// resultados irrelevantes.
int _maxDistanceFor(String query) {
  if (query.length <= 2) return 0;
  if (query.length <= 5) return 1;
  return 2;
}

/// Verifica se [word] "casa" aproximadamente com [query]: match exato,
/// prefixo, substring ou dentro da distância de edição tolerada.
bool isApproximateMatch(String word, String query) {
  if (query.isEmpty) return true;
  if (word.contains(query)) return true;

  final maxDistance = _maxDistanceFor(query);
  if (maxDistance == 0) return false;

  if (word.length <= query.length + maxDistance) {
    return levenshteinDistance(word, query) <= maxDistance;
  }
  // Para palavras mais longas que o termo buscado, desliza uma janela
  // do tamanho aproximado do termo para pegar erros de digitação no
  // meio de palavras compostas/longas.
  for (var start = 0; start <= word.length - query.length; start++) {
    final end = math.min(start + query.length + maxDistance, word.length);
    final window = word.substring(start, end);
    if (levenshteinDistance(window, query) <= maxDistance) return true;
  }
  return false;
}

/// Resultado de uma tentativa de correspondência: se casou e a
/// pontuação de relevância (quanto maior, melhor).
class SearchMatch {
  const SearchMatch({required this.matches, required this.score});

  final bool matches;
  final int score;

  static const none = SearchMatch(matches: false, score: 0);
}

/// Compara uma consulta (pode ter várias palavras) contra um texto já
/// normalizado. Todas as palavras da consulta precisam encontrar
/// correspondência (AND) em algum lugar do texto para haver match;
/// a pontuação prioriza matches exatos > prefixo > aproximado.
SearchMatch matchQuery(String normalizedHaystack, String normalizedQuery) {
  final queryTokens = normalizedQuery
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
  if (queryTokens.isEmpty) return const SearchMatch(matches: true, score: 0);

  final haystackWords = wordsOf(normalizedHaystack);
  var totalScore = 0;

  for (final token in queryTokens) {
    var tokenScore = 0;
    if (normalizedHaystack.contains(token)) {
      tokenScore = 100;
    }
    for (final word in haystackWords) {
      if (word == token) {
        tokenScore = math.max(tokenScore, 120);
      } else if (word.startsWith(token)) {
        tokenScore = math.max(tokenScore, 80);
      } else if (isApproximateMatch(word, token)) {
        tokenScore = math.max(tokenScore, 45);
      }
    }
    if (tokenScore == 0) {
      return SearchMatch.none; // termo não encontrado de nenhuma forma
    }
    totalScore += tokenScore;
  }

  return SearchMatch(matches: true, score: totalScore);
}
