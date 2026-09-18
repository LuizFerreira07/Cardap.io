import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'responsive.dart';

class DeliveryManagementScreen extends StatelessWidget {
  const DeliveryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveDashboardShell(
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth >= Breakpoints.mobile;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Expanded(child: StatPill(value: '12', label: 'Em Rota')),
                              SizedBox(width: 12),
                              Expanded(child: StatPill(value: '05', label: 'Pendentes')),
                              SizedBox(width: 12),
                              Expanded(child: StatPill(value: '28', label: 'Concluídos')),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _OrderCard(
                            id: '#4832',
                            time: 'Agora',
                            customer: 'Lucas Lima',
                            status: 'NA COZINHA',
                            statusColor: AppColors.green,
                            statusBg: AppColors.greenLight,
                            courier: 'Pendente',
                            value: 'R\$ 45,90',
                          ),
                          const SizedBox(height: 24),
                          const Text('Entregadores Online',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          wide
                              ? GridView.count(
                                  crossAxisCount: gridColumnsFor(constraints.maxWidth,
                                      mobile: 1, tablet: 2, desktop: 3),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 3.6,
                                  children: _couriers
                                      .map((c) => _CourierTile(courier: c))
                                      .toList(),
                                )
                              : Column(
                                  children: _couriers
                                      .map((c) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _CourierTile(courier: c),
                                          ))
                                      .toList(),
                                ),
                          const SizedBox(height: 90),
                        ],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrindo formulário de pedido manual...')),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Novo Pedido Manual', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerando relatório do dia...')),
                  ),
                  child: const Text('Relatório do Dia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Courier {
  final String initials;
  final String name;
  final String status;
  final bool available;
  const _Courier(this.initials, this.name, this.status, this.available);
}

const _couriers = [
  _Courier('Ricar', 'Ricardo Alves', 'Em entrega (Pedido #4829)', false),
  _Courier('Julian', 'Juliana Costa', 'Disponível', true),
  _Courier('Pedro', 'Pedro Santos', 'Disponível', true),
];

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.brownDark,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gestão de Delivery',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Cardap.io • Operação Ativa',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.id,
    required this.time,
    required this.customer,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.courier,
    required this.value,
  });

  final String id, time, customer, status, courier, value;
  final Color statusColor, statusBg;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$id • $time',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(customer, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entregador', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(courier, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourierTile extends StatelessWidget {
  const _CourierTile({required this.courier});
  final _Courier courier;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.cream,
            child: Text(
              courier.initials.isNotEmpty ? courier.initials[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.brownDark, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courier.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  courier.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: courier.available ? AppColors.green : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.visibility_outlined, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
