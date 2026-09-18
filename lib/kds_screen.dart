import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'responsive.dart';

class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsOrder {
  final String table;
  final String station;
  final String time;
  final Color timeColor;
  final List<_KdsItem> items;
  const _KdsOrder(this.table, this.station, this.time, this.timeColor, this.items);
}

class _KdsItem {
  final int qty;
  final String name;
  final String? note;
  const _KdsItem(this.qty, this.name, [this.note]);
}

const _orders = [
  _KdsOrder('Mesa 04', 'GRILL', '14:22', AppColors.red, [
    _KdsItem(1, 'Picanha na Brasa', 'Ponto: Mal passada'),
    _KdsItem(2, 'Pão de Alho Especial', 'ponto_mal_passada'),
    _KdsItem(1, 'Arroz Carreteiro', 'ponto_mal_passada'),
  ]),
  _KdsOrder('Delivery #882', 'CHAPA', '08:45', AppColors.amber, [
    _KdsItem(2, 'X-Burguer Artesanal', 'Sem picles, Maionese extra'),
    _KdsItem(1, 'Batata Rústica G'),
  ]),
  _KdsOrder('Mesa 08', 'KITCHEN', '08:38', AppColors.brandCyan, [
    _KdsItem(1, 'Parmegiana da Casa', 'Sem cebola'),
    _KdsItem(1, 'Limonada Siciliana'),
  ]),
];

class _KdsScreenState extends State<KdsScreen> {
  int _station = 0;
  final Set<String> _readyOrders = <String>{};
  final stations = const ['Todas', 'Churrasqueira', 'Chapa', 'Cozinha'];

  List<_KdsOrder> get _visibleOrders {
    if (_station == 0) return _orders;
    final selected = const ['TODAS', 'GRILL', 'CHAPA', 'KITCHEN'][_station];
    return _orders.where((order) => order.station == selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveDashboardShell(
          maxWidth: 1000,
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                _Header(station: _station, stations: stations, onSelect: (i) => setState(() => _station = i)),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final columns = gridColumnsFor(constraints.maxWidth, mobile: 1, tablet: 2, desktop: 2);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _visibleOrders.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: columns == 1 ? 1.05 : 1.15,
                        ),
                        itemBuilder: (context, i) {
                          final order = _visibleOrders[i];
                          return _OrderTicket(
                            order: order,
                            ready: _readyOrders.contains(order.table),
                            onReady: () => setState(() => _readyOrders.add(order.table)),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const _MiniStat(label: 'PENDING', value: '08 Orders'),
              const SizedBox(width: 24),
              const _MiniStat(label: 'AVG TIME', value: '12.5 min'),
              const Spacer(),
              Text('View History',
                  style: TextStyle(color: AppColors.brownMedium, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 0.5)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.station, required this.stations, required this.onSelect});
  final int station;
  final List<String> stations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brownDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Cardap.io KDS',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: AppColors.green),
                  SizedBox(width: 6),
                  Text('Station Active', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = station == i;
                return ChoiceChip(
                  label: Text(i == 0 ? '✓ ${stations[i]}' : stations[i]),
                  selected: selected,
                  onSelected: (_) => onSelect(i),
                  selectedColor: AppColors.brownDark,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  side: BorderSide(color: selected ? AppColors.brownDark : AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTicket extends StatelessWidget {
  const _OrderTicket({required this.order, required this.ready, required this.onReady});
  final _KdsOrder order;
  final bool ready;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.table,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(order.station,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brownDark)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ready ? AppColors.green : order.timeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(order.time,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = order.items[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${item.qty}x',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          if (item.note != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text('↳ ${item.note}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ready ? null : onReady,
              icon: Icon(ready ? Icons.check_rounded : Icons.done_all_rounded),
              label: Text(ready ? 'Pronto' : 'Marcar como pronto'),
            ),
          ),
        ],
      ),
    );
  }
}
