import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final orders = _filter == null ? provider.orders : provider.orders.where((o) => o.status == _filter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(null, 'Todos'),
                for (final s in OrderStatus.values) _filterChip(s, s.label),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(child: Text('Nenhum pedido encontrado', style: TextStyle(color: Colors.grey[600])))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(
                                'Pedido #${order.id}${order.customerName != null ? ' • ${order.customerName}' : ''}${order.mesa != null ? ' • ${order.mesa}' : ''}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)} • ${order.itemCount} itens'),
                              trailing: DropdownButton<OrderStatus>(
                                value: order.status,
                                underline: const SizedBox.shrink(),
                                items: [for (final s in OrderStatus.values) DropdownMenuItem(value: s, child: Text(s.label))],
                                onChanged: (s) {
                                  if (s != null) context.read<OrderProvider>().updateStatus(order.id, s);
                                },
                              ),
                              children: [
                                for (final item in order.items)
                                  ListTile(
                                    dense: true,
                                    title: Text('${item.quantity}x ${item.name}'),
                                    trailing: Text(CurrencyFormatter.format(item.subtotal)),
                                  ),
                                ListTile(
                                  dense: true,
                                  title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Text(CurrencyFormatter.format(order.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
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
}
