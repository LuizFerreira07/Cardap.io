import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'kitchen_view_screen.dart';
import 'orders_screen.dart';
import 'sales_reports_screen.dart';
import 'store_settings_screen.dart';
import 'table_qr_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MenuProvider>().syncCurrentItems();
      await context.read<OrderProvider>().reload();
    });
  }

  static const _screens = [DashboardScreen(), InventoryScreen(), OrdersScreen(), KitchenViewScreen(), TableQrScreen(), SalesReportsScreen(), StoreSettingsScreen()];
  static const _titles = ['Dashboard', 'Estoque', 'Pedidos', 'Cozinha', 'QR das mesas', 'Relatórios', 'Configurações'];
  static const _icons = [Icons.bar_chart_rounded, Icons.inventory_2_outlined, Icons.receipt_long, Icons.soup_kitchen_outlined, Icons.qr_code_2, Icons.insights_outlined, Icons.settings_outlined];

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isDesktop(context) || Responsive.isTablet(context);
    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        leading: isWide ? null : Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        actions: [IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () async { await context.read<AuthProvider>().logout(); if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst); }), const SizedBox(width: 12)],
      ),
      drawer: isWide ? null : _drawer(),
      body: _screens[_index],
    );

    if (!isWide) return scaffold;
    return Scaffold(body: Row(children: [NavigationRail(selectedIndex: _index, onDestinationSelected: (i) => setState(() => _index = i), labelType: NavigationRailLabelType.all, leading: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)), alignment: Alignment.center, child: const Icon(Icons.restaurant, color: Colors.white))), destinations: [for (int i = 0; i < _titles.length; i++) NavigationRailDestination(icon: Icon(_icons[i]), label: Text(_titles[i]))]), const VerticalDivider(width: 1), Expanded(child: scaffold)]));
  }

  Widget _drawer() {
    return Drawer(
      backgroundColor: AppTheme.background,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: const Icon(Icons.restaurant, color: Colors.white, size: 20)), const SizedBox(width: 10), Text('SaborDigital', style: AppTheme.heading(18))])),
        const Divider(height: 1),
        for (int i = 0; i < _titles.length; i++) ListTile(leading: Icon(_icons[i], color: _index == i ? AppTheme.primary : Colors.grey[600]), title: Text(_titles[i], style: TextStyle(fontWeight: _index == i ? FontWeight.bold : FontWeight.normal)), selected: _index == i, selectedTileColor: AppTheme.primary.withOpacity(0.08), onTap: () { setState(() => _index = i); Navigator.pop(context); }),
      ])),
    );
  }
}
