import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'delivery_address_screen.dart';
import 'kds_screen.dart';
import 'responsive.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

enum _OperationPanel { service, kitchen }

enum _TicketStatus { waiting, preparing, ready }

class _Ticket {
  _Ticket({required this.code, required this.table, required this.items, required this.minutes, required this.status});

  final String code;
  final String table;
  final List<String> items;
  final int minutes;
  _TicketStatus status;
}

class _OperationsScreenState extends State<OperationsScreen> {
  _OperationPanel _panel = _OperationPanel.service;
  final List<_Ticket> _tickets = <_Ticket>[
    _Ticket(code: '#GF-214', table: 'Mesa 12', items: ['Picanha Prime BBQ', 'Limonada Siciliana'], minutes: 4, status: _TicketStatus.preparing),
    _Ticket(code: '#GF-215', table: 'Mesa 04', items: ['X-Burger Artesanal', 'Batata Rústica'], minutes: 7, status: _TicketStatus.waiting),
    _Ticket(code: '#GF-216', table: 'Delivery', items: ['Parmegiana da Casa', 'Mate da Casa'], minutes: 12, status: _TicketStatus.waiting),
    _Ticket(code: '#GF-217', table: 'Mesa 08', items: ['Costela BBQ 12h'], minutes: 15, status: _TicketStatus.ready),
  ];

  int get _waiting => _tickets.where((ticket) => ticket.status == _TicketStatus.waiting).length;
  int get _preparing => _tickets.where((ticket) => ticket.status == _TicketStatus.preparing).length;
  int get _ready => _tickets.where((ticket) => ticket.status == _TicketStatus.ready).length;

  void _advance(_Ticket ticket) {
    setState(() {
      if (ticket.status == _TicketStatus.waiting) {
        ticket.status = _TicketStatus.preparing;
      } else if (ticket.status == _TicketStatus.preparing) {
        ticket.status = _TicketStatus.ready;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${ticket.code} atualizado para ${_statusLabel(ticket.status)}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel da operação', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
        actions: [
          IconButton(
            tooltip: 'Gestão de delivery',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeliveryManagementScreen())),
            icon: const Icon(Icons.delivery_dining_outlined),
          ),
          IconButton(
            tooltip: 'Abrir KDS em tela cheia',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KdsScreen())),
            icon: const Icon(Icons.desktop_windows_outlined),
          ),
          IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados atualizados agora.'))), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: SafeArea(
        child: ResponsiveDashboardShell(
          maxWidth: 1160,
          child: Container(
            color: AppColors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OperationsHero(waiting: _waiting, preparing: _preparing, ready: _ready),
                  const SizedBox(height: 18),
                  SegmentedButton<_OperationPanel>(
                    segments: const [
                      ButtonSegment(value: _OperationPanel.service, icon: Icon(Icons.support_agent_rounded), label: Text('Atendimento')),
                      ButtonSegment(value: _OperationPanel.kitchen, icon: Icon(Icons.soup_kitchen_outlined), label: Text('Cozinha / KDS')),
                    ],
                    selected: {_panel},
                    onSelectionChanged: (value) => setState(() => _panel = value.first),
                  ),
                  const SizedBox(height: 20),
                  if (_panel == _OperationPanel.service) _ServicePanel(tickets: _tickets, onCallResolved: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chamado marcado como atendido.')))) else _KitchenPanel(tickets: _tickets, onAdvance: _advance),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationsHero extends StatelessWidget {
  const _OperationsHero({required this.waiting, required this.preparing, required this.ready});

  final int waiting;
  final int preparing;
  final int ready;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.brownDark, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.dashboard_rounded, color: Colors.white)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Operação em tempo real', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Acompanhe salão, delivery e cozinha em um só lugar.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)), child: const Text('Online', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Kpi(value: '$waiting', label: 'Aguardando', color: AppColors.amber)),
              const SizedBox(width: 8),
              Expanded(child: _Kpi(value: '$preparing', label: 'Preparando', color: AppColors.brownDark)),
              const SizedBox(width: 8),
              Expanded(child: _Kpi(value: '$ready', label: 'Prontos', color: AppColors.green)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [Text(value, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: color)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))]),
    );
  }
}

class _ServicePanel extends StatelessWidget {
  const _ServicePanel({required this.tickets, required this.onCallResolved});

  final List<_Ticket> tickets;
  final VoidCallback onCallResolved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Visão do salão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Mesas e alertas que precisam da atenção da equipe.', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = gridColumnsFor(constraints.maxWidth, mobile: 2, tablet: 3, desktop: 4);
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.28,
              children: const [
                _TableTile(number: '04', status: 'Ocupada', color: AppColors.red),
                _TableTile(number: '08', status: 'Pedido pronto', color: AppColors.green),
                _TableTile(number: '12', status: 'Chamar garçom', color: AppColors.amber, alert: true),
                _TableTile(number: '16', status: 'Livre', color: AppColors.textMuted),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Expanded(child: Text('Central de notificações', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))]),
              const SizedBox(height: 14),
              _AlertRow(icon: Icons.notifications_active_outlined, title: 'Mesa 12 chamou o garçom', subtitle: 'Há 1 minuto', color: AppColors.amber, action: onCallResolved),
              const Divider(height: 22),
              _AlertRow(icon: Icons.delivery_dining_outlined, title: 'Novo pedido de delivery', subtitle: 'Há 3 minutos • #GF-216', color: AppColors.brownDark, action: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.number, required this.status, required this.color, this.alert = false});

  final String number;
  final String status;
  final Color color;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: alert ? AppColors.amber : AppColors.border, width: alert ? 1.5 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text('Mesa $number', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Icon(alert ? Icons.notifications_active_rounded : Icons.circle, color: color, size: alert ? 17 : 10)]), const Spacer(), Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700))]),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.icon, required this.title, required this.subtitle, required this.color, required this.action});

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 19, backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color, size: 19)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))])),
        TextButton(onPressed: action, child: const Text('Resolver')),
      ],
    );
  }
}

class _KitchenPanel extends StatelessWidget {
  const _KitchenPanel({required this.tickets, required this.onAdvance});

  final List<_Ticket> tickets;
  final ValueChanged<_Ticket> onAdvance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(child: Text('Kitchen Display System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KdsScreen())),
            icon: const Icon(Icons.open_in_full_rounded, size: 16),
            label: const Text('Tela cheia'),
          ),
          const SizedBox(width: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)), child: const Text('Fila por prioridade', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brownMedium))),
        ]),
        const SizedBox(height: 5),
        const Text('Atualize o status para refletir instantaneamente no acompanhamento do cliente.', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        ...tickets.map((ticket) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _TicketCard(ticket: ticket, onAdvance: () => onAdvance(ticket)))),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onAdvance});

  final _Ticket ticket;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final isReady = ticket.status == _TicketStatus.ready;
    return SectionCard(
      borderColor: isReady ? AppColors.green : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ticket.code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isReady ? AppColors.greenLight : AppColors.cream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.table,
                  style: TextStyle(
                    color: isReady ? AppColors.green : AppColors.brownDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text('${ticket.minutes} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ...ticket.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.brownMedium),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(_statusLabel(ticket.status), style: TextStyle(color: _statusColor(ticket.status), fontWeight: FontWeight.w800, fontSize: 12)),
              const Spacer(),
              if (!isReady)
                OutlinedButton.icon(
                  onPressed: onAdvance,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(ticket.status == _TicketStatus.waiting ? 'Iniciar preparo' : 'Marcar pronto'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _statusLabel(_TicketStatus status) {
  switch (status) {
    case _TicketStatus.waiting:
      return 'Aguardando';
    case _TicketStatus.preparing:
      return 'Preparando';
    case _TicketStatus.ready:
      return 'Pronto para entregar';
  }
}

Color _statusColor(_TicketStatus status) {
  switch (status) {
    case _TicketStatus.waiting:
      return AppColors.amber;
    case _TicketStatus.preparing:
      return AppColors.brownDark;
    case _TicketStatus.ready:
      return AppColors.green;
  }
}
