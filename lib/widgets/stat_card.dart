import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? trend; // ex: "+12%" ou "-3%"
  final bool trendUp;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: iconColor ?? AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTheme.heading(24)),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendUp ? Icons.trending_up : Icons.trending_down,
                    size: 15, color: trendUp ? AppTheme.olive : AppTheme.danger),
                const SizedBox(width: 4),
                Text(trend!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: trendUp ? AppTheme.olive : AppTheme.danger)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
