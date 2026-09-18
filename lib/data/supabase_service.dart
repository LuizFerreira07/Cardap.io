import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicialização única do Supabase.
///
/// As credenciais entram no build/run via:
/// --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
/// Sem credenciais, o app continua funcionando em modo local para demonstração.
class SupabaseService {
  static bool _initialized = false;

  static bool get isConfigured => _initialized;
  static SupabaseClient? get client => _initialized ? Supabase.instance.client : null;

  static Future<void> initialize() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    if (url.isEmpty || publishableKey.isEmpty) return;

    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
    _initialized = true;
  }
}

class SupabaseDataException implements Exception {
  final String message;
  const SupabaseDataException(this.message);

  @override
  String toString() => message;
}

Map<String, dynamic> asMap(dynamic value) => Map<String, dynamic>.from(value as Map);

List<dynamic> asList(dynamic value) => value is List ? value : const [];
