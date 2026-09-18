import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../widgets/product_image.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class KitchenViewScreen extends StatefulWidget {
  const KitchenViewScreen({super.key});

  @override
  State<KitchenViewScreen> createState() => _KitchenViewScreenState();
}

class _KitchenViewScreenState extends State<KitchenViewScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    if (orders.isLoading) return const Center(child: CircularProgressIndicator());

    final active = orders.orders.where((o) => o.status != OrderStatus.entregue && o.status != OrderStatus.cancelado).toList();
    final visible = _filter == null ? active : active.where((o) => o.status == _filter).toList();
    final hourly = orders.ordersByHour();
    final maxHourly = hourly.map((e) => e.value).fold<int>(0, (m, v) => v > m ? v : m);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => showDialog(context: context, builder: (_) => const ManualOrderDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Pedido Manual'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SaborDigital • Pedidos ao vivo', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _statBox('Pendentes', '${orders.pendingCount}', AppTheme.danger)),
                const SizedBox(width: 12),
                Expanded(child: _statBox('Prontos', '${orders.readyCount}', AppTheme.olive)),
                const SizedBox(width: 12),
                Expanded(child: _statBox('Faturamento', CurrencyFormatter.format(orders.todayRevenue), AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedidos por Hora', style: AppTheme.heading(16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: BarChart(
                      BarChartData(
                        maxY: (maxHourly == 0 ? 5 : maxHourly * 1.3).toDouble(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= hourly.length) return const SizedBox.shrink();
                                final hour = hourly[index].key;
                                return Padding(padding: const EdgeInsets.only(top: 6), child: Text('${hour}h', style: const TextStyle(fontSize: 9)));
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (int i = 0; i < hourly.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: hourly[i].value.toDouble(), color: AppTheme.primary, width: 12, borderRadius: BorderRadius.circular(4)),
                            ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(null, 'Todos os Pedidos'),
                  _filterChip(OrderStatus.pendente, 'Novos'),
                  _filterChip(OrderStatus.preparando, 'Preparando'),
                  _filterChip(OrderStatus.pronto, 'Prontos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Comandas Ativas', style: AppTheme.heading(17)),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Nenhum pedido ativo', style: TextStyle(color: Colors.grey[500]))))
            else
              for (final order in visible) _ticket(context, order),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.heading(18, color: color)),
        ],
      ),
    );
  }

  Widget _filterChip(OrderStatus? status, String label) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = status),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textDark),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _ticket(BuildContext context, RestaurantOrder order) {
    final isNew = DateTime.now().difference(order.createdAt).inMinutes < 3;
    final summary = order.items.map((i) => '${i.quantity}x ${i.name}').join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pedido #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(20)),
                  child: const Text('novo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              Text(order.mesa ?? 'Entrega', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const Divider(height: 20),
          Text(summary, style: const TextStyle(fontSize: 13.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enviando comanda para impressão...'), behavior: SnackBarBehavior.floating),
                ),
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Imprimir'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.read<OrderProvider>().updateStatus(order.id, _nextStatus(order.status)),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(_nextStatusLabel(order.status)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  OrderStatus _nextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.pendente:
        return OrderStatus.preparando;
      case OrderStatus.preparando:
        return OrderStatus.pronto;
      case OrderStatus.pronto:
        return OrderStatus.entregue;
      case OrderStatus.entregue:
      case OrderStatus.cancelado:
        return current;
    }
  }

  String _nextStatusLabel(OrderStatus current) {
    switch (current) {
      case OrderStatus.pendente:
        return 'Iniciar Preparo';
      case OrderStatus.preparando:
        return 'Marcar Pronto';
      case OrderStatus.pronto:
        return 'Marcar Entregue';
      default:
        return 'Concluído';
    }
  }
}

/// Dialog para o atendente registrar um pedido manual (balcão/mesa),
/// escolhendo itens do cardápio e quantidade.
class ManualOrderDialog extends StatefulWidget {
  const ManualOrderDialog({super.key});

  @override
  State<ManualOrderDialog> createState() => _ManualOrderDialogState();
}

class _ManualOrderDialogState extends State<ManualOrderDialog> {
  final Map<String, int> _quantities = {};
  final _mesaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final available = menu.items.where((i) => i.available && !i.isOutOfStock).toList();
    final total = available.fold<double>(0, (sum, i) => sum + (i.price * (_quantities[i.id] ?? 0)));

    return AlertDialog(
      title: const Text('Novo Pedido Manual'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _mesaController,
              decoration: const InputDecoration(labelText: 'Mesa (opcional)', hintText: 'Ex.: Mesa 04'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ListView.builder(
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final item = available[index];
                  final qty = _quantities[item.id] ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ProductImage(
                      item: item,
                      width: 44,
                      height: 44,
                      emojiSize: 20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(item.name, style: const TextStyle(fontSize: 13.5)),
                    subtitle: Text(CurrencyFormatter.format(item.price), style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: qty == 0 ? null : () => setState(() => _quantities[item.id] = qty - 1)),
                        Text('$qty'),
                        IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() => _quantities[item.id] = qty + 1)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: total == 0
              ? null
              : () async {
                  final menuProvider = context.read<MenuProvider>();
                  final orderItems = <OrderItem>[];
                  for (final entry in _quantities.entries) {
                    if (entry.value <= 0) continue;
                    final item = menuProvider.byId(entry.key);
                    if (item == null) continue;
                    orderItems.add(OrderItem(
                      menuItemId: item.id,
                      name: item.name,
                      unitPrice: item.price,
                      quantity: entry.value,
                      category: item.category,
                    ));
                  }
                  await context.read<OrderProvider>().placeOrder(
                        orderItems,
                        mesa: _mesaController.text.trim().isEmpty ? null : _mesaController.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
          child: Text('Criar Pedido • ${CurrencyFormatter.format(total)}'),
        ),
      ],
    );
  }
}
