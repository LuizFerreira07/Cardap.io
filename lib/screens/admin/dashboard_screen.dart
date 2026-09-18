import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    if (orders.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SaborDigital Overview', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(title: 'Faturamento', value: CurrencyFormatter.format(orders.totalRevenue), icon: Icons.savings_outlined, trend: '+12%', trendUp: true),
              StatCard(title: 'Pedidos', value: '${orders.totalOrders}', icon: Icons.receipt_long_outlined, trend: '-3%', trendUp: false),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: AppTheme.primary.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text('Desempenho de Vendas', style: AppTheme.heading(17)),
                  ],
                ),
                Text('Resumo semanal de faturamento', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(height: 220, child: _RevenueAreaChart(data: orders.revenueLast7Days)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppTheme.primary, 'Esta Semana'),
                    const SizedBox(width: 20),
                    _legendDot(Colors.grey[300]!, 'Semana Passada'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categorias em Destaque', style: AppTheme.heading(17)),
                const SizedBox(height: 16),
                SizedBox(height: 220, child: _CategoryDonutChart(data: orders.revenueByCategory)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _RevenueAreaChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  const _RevenueAreaChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.value).fold<double>(0, (m, v) => v > m ? v : m);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 100 : maxY * 1.25,
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
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('E', 'pt_BR').format(data[index].key).substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value)],
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: AppTheme.primary, strokeWidth: 2, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.18)),
          ),
        ],
      ),
    );
  }
}

class _CategoryDonutChart extends StatelessWidget {
  final Map<MenuCategory, double> data;
  const _CategoryDonutChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return Center(child: Text('Sem dados de vendas ainda', style: TextStyle(color: Colors.grey[500])));
    }
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 44,
              sections: [
                for (final entry in data.entries)
                  if (entry.value > 0)
                    PieChartSectionData(
                      value: entry.value,
                      color: entry.key.color,
                      title: '${(entry.value / total * 100).round()}',
                      radius: 54,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final entry in data.entries)
              if (entry.value > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: entry.key.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('${entry.key.label} (${(entry.value / total * 100).round()}%)', style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
