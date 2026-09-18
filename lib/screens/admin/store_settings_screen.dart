import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_settings_provider.dart';
import '../../theme/app_theme.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _phone;
  late TextEditingController _openTime;
  late TextEditingController _closeTime;
  late TextEditingController _deliveryFee;
  late TextEditingController _pixKey;
  String _closedDay = 'Terça-feira';
  bool _initialized = false;

  static const _weekDays = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo', 'Nenhum'
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StoreSettingsProvider>();

    if (settings.isLoading) return const Center(child: CircularProgressIndicator());

    if (!_initialized) {
      _name = TextEditingController(text: settings.name);
      _description = TextEditingController(text: settings.description);
      _phone = TextEditingController(text: settings.phone);
      _openTime = TextEditingController(text: settings.openTime);
      _closeTime = TextEditingController(text: settings.closeTime);
      _deliveryFee = TextEditingController(text: settings.deliveryFee.toStringAsFixed(2));
      _pixKey = TextEditingController(text: settings.pixKey);
      _closedDay = settings.closedDay;
      _initialized = true;
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              icon: Icons.storefront_outlined,
              title: 'Informações do Restaurante',
              children: [
                TextField(controller: _name, decoration: const InputDecoration(prefixIcon: Icon(Icons.restaurant_menu, size: 20), labelText: 'Nome')),
                const SizedBox(height: 12),
                TextField(controller: _description, maxLines: 2, decoration: const InputDecoration(prefixIcon: Icon(Icons.notes_outlined, size: 20), labelText: 'Descrição')),
                const SizedBox(height: 12),
                TextField(controller: _phone, decoration: const InputDecoration(prefixIcon: Icon(Icons.call_outlined, size: 20), labelText: 'Telefone')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionCard(
              icon: Icons.access_time,
              title: 'Horário de Funcionamento',
              children: [
                TextField(controller: _openTime, decoration: const InputDecoration(labelText: 'Abre às', hintText: 'Ex.: 11:00')),
                const SizedBox(height: 12),
                TextField(controller: _closeTime, decoration: const InputDecoration(labelText: 'Fecha às', hintText: 'Ex.: 23:30')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _closedDay,
                  decoration: const InputDecoration(labelText: 'Fechado às'),
                  items: [for (final d in _weekDays) DropdownMenuItem(value: d, child: Text(d))],
                  onChanged: (v) => setState(() => _closedDay = v!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionCard(
              icon: Icons.payments_outlined,
              title: 'Pagamentos e Taxas',
              children: [
                TextField(
                  controller: _deliveryFee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Taxa de Entrega (R\$)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pixKey,
                  decoration: const InputDecoration(labelText: 'Chave Pix', hintText: 'CPF, CNPJ, e-mail, telefone ou chave aleatória'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Salvar Alterações'),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: AppTheme.primary), const SizedBox(width: 8), Text(title, style: AppTheme.heading(16))]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Future<void> _save() async {
    final fee = double.tryParse(_deliveryFee.text.replaceAll(',', '.')) ?? 0;
    await context.read<StoreSettingsProvider>().save(
          name: _name.text.trim(),
          description: _description.text.trim(),
          phone: _phone.text.trim(),
          openTime: _openTime.text.trim(),
          closeTime: _closeTime.text.trim(),
          closedDay: _closedDay,
          deliveryFee: fee,
          pixKey: _pixKey.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas com sucesso!'), behavior: SnackBarBehavior.floating),
    );
  }
}
