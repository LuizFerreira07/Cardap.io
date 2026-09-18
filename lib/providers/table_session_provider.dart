import 'package:flutter/foundation.dart';
import '../data/table_session_service.dart';

class TableSessionProvider extends ChangeNotifier {
  final TableSessionService _service = TableSessionService();
  int? _activeTable;
  bool _loading = false;

  int? get activeTable => _activeTable;
  bool get isLoading => _loading;

  Future<bool> claim(int tableNumber) async {
    _loading = true;
    notifyListeners();
    final success = await _service.claimTable(tableNumber);
    if (success) _activeTable = tableNumber;
    _loading = false;
    notifyListeners();
    return success;
  }

  Future<void> release() async {
    final table = _activeTable;
    if (table == null) return;
    await _service.releaseTable(table);
    _activeTable = null;
    notifyListeners();
  }

  Future<String> sessionId() => _service.getSessionId();
}
