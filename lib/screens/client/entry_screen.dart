import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/table_session_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_login_screen.dart';
import 'menu_home_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  bool _checkingQr = true;
  bool _opening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openTableFromQr());
  }

  Future<void> _openTableFromQr() async {
    final table = int.tryParse(Uri.base.queryParameters['mesa'] ?? '');
    if (table == null || table < 1 || table > 6) {
      if (mounted) setState(() => _checkingQr = false);
      return;
    }
    await _openTable(table);
  }

  Future<void> _openTable(int tableNumber) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    final session = context.read<TableSessionProvider>();
    final claimed = await session.claim(tableNumber);
    if (!mounted) return;
    if (!claimed) {
      setState(() {
        _opening = false;
        _checkingQr = false;
        _error = 'A Mesa $tableNumber já está conectada. Ela será liberada quando o pedido for fechado/pago.';
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MenuHomeScreen(tableNumber: tableNumber)),
    );
  }

  void _openDelivery() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuHomeScreen(isDelivery: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingQr || _opening) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(24)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 18),
                  Text('Boteco da Vila', style: AppTheme.heading(30)),
                  const SizedBox(height: 6),
                  Text('Escolha como você quer fazer seu pedido', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 28),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.danger.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.lock_outline, color: AppTheme.danger),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.danger, height: 1.35))),
                      ]),
                    ),
                  _optionCard(
                    icon: Icons.table_restaurant_outlined,
                    title: 'Estou no restaurante',
                    subtitle: 'Aponte a câmera para o QR Code da sua mesa.',
                    onTap: () => _chooseTable(),
                  ),
                  const SizedBox(height: 12),
                  _optionCard(
                    icon: Icons.delivery_dining_outlined,
                    title: 'Quero pedir delivery',
                    subtitle: 'Faça seu pedido para receber em casa.',
                    onTap: _openDelivery,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                    label: const Text('Acesso administrativo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppTheme.primary)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13))])),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ]),
        ),
      ),
    );
  }

  Future<void> _chooseTable() async {
    final number = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Escolha a mesa'),
        children: [for (int table = 1; table <= 6; table++) SimpleDialogOption(onPressed: () => Navigator.pop(context, table), child: Text('Mesa $table'))],
      ),
    );
    if (number != null && mounted) await _openTable(number);
  }
}
