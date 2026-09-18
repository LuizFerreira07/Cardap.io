import 'package:supabase_flutter/supabase_flutter.dart';

/// Centraliza a inicialização e o acesso ao cliente do Supabase.
///
/// As credenciais NÃO ficam fixas no código: elas são lidas em tempo de
/// build via `--dart-define`, para facilitar trocar de projeto (dev/prod)
/// sem editar o app. Veja o arquivo SUPABASE_SETUP.md na raiz do projeto
/// para o passo a passo completo (criar o projeto, rodar o SQL e pegar
/// essas duas chaves).
///
/// Exemplo de execução:
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
class SupabaseService {
  static const String _url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True quando as duas variáveis de ambiente foram informadas no build.
  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  static bool _initialized = false;

  static Future<void> init() async {
    if (!isConfigured || _initialized) return;
    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
