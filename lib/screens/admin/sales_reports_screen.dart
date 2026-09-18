import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class SalesReportsScreen extends StatelessWidget {
  const SalesReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    if (orders.isLoading) return const Center(child: CircularProgressIndicator());

    final hourly = orders.ordersByHour();
    final maxHourly = hourly.map((e) => e.value).fold<int>(0, (m, v) => v > m ? v : m);
    final revenue7d = orders.revenueLast7Days;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance geral do SaborDigital', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statBox('Faturamento', CurrencyFormatter.format(orders.totalRevenue), Icons.savings_outlined, '+12%')),
              const SizedBox(width: 12),
              Expanded(child: _statBox('Pedidos', '${orders.totalOrders}', Icons.shopping_bag_outlined, '+5%')),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tendência de Faturamento', style: AppTheme.heading(16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check, size: 14, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text('Últimos 7 dias', style: TextStyle(fontSize: 12)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
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
                              if (index < 0 || index >= revenue7d.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(DateFormat('E', 'pt_BR').format(revenue7d[index].key).substring(0, 3),
                                    style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [for (int i = 0; i < revenue7d.length; i++) FlSpot(i.toDouble(), revenue7d[i].value)],
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.15)),
                        ),
                      ],
                    ),
                  ),
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
                Text('Horários de Pico', style: AppTheme.heading(16)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
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
                              return Padding(padding: const EdgeInsets.only(top: 6), child: Text('${hourly[index].key}h', style: const TextStyle(fontSize: 9)));
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < hourly.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(toY: hourly[i].value.toDouble(), color: AppTheme.terracotta, width: 12, borderRadius: BorderRadius.circular(4)),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String title, String value, IconData icon, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.heading(20)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.trending_up, size: 14, color: AppTheme.olive),
              const SizedBox(width: 2),
              Text(trend, style: const TextStyle(fontSize: 12, color: AppTheme.olive, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
