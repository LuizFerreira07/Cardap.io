import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

class TableSessionService {
  static const _localPrefix = 'active_table_session_';
  static const _sessionIdKey = 'table_session_id';
  final _uuid = const Uuid();
  String? _sessionId;

  Future<String> getSessionId() async {
    if (_sessionId != null) return _sessionId!;
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionIdKey) ?? _uuid.v4();
    await prefs.setString(_sessionIdKey, _sessionId!);
    return _sessionId!;
  }

  Future<bool> claimTable(int tableNumber) async {
    if (tableNumber < 1 || tableNumber > 6) return false;
    final sessionId = await getSessionId();

    if (SupabaseService.isConfigured) {
      try {
        final result = await SupabaseService.client!.rpc(
          'claim_table',
          params: {
            'p_table_number': tableNumber,
            'p_session_id': sessionId,
          },
        );
        return result == true;
      } catch (_) {
        // O usuário recebe uma mensagem de indisponibilidade na tela; não
        // liberamos a mesa localmente quando o servidor não respondeu.
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_localPrefix$tableNumber';
    final active = prefs.getString(key);
    if (active != null && active != sessionId) return false;
    await prefs.setString(key, sessionId);
    return true;
  }

  Future<bool> releaseTable(int tableNumber, {String? sessionId}) async {
    final ownerSessionId = sessionId ?? await getSessionId();

    if (SupabaseService.isConfigured) {
      try {
        final result = await SupabaseService.client!.rpc(
          'release_table',
          params: {
            'p_table_number': tableNumber,
            'p_session_id': ownerSessionId,
          },
        );
        return result == true;
      } catch (_) {
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_localPrefix$tableNumber';
    if (prefs.getString(key) != ownerSessionId) return false;
    await prefs.remove(key);
    return true;
  }
}
