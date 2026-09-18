import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import 'menu_home_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  static const _deliveryStages = [
    (status: OrderStatus.pendente, title: 'Pedido Confirmado', desc: 'Recebemos seu pedido e ele já está na fila.'),
    (status: OrderStatus.preparando, title: 'Preparando seu pedido', desc: 'Nossos chefs estão fazendo a mágica acontecer.'),
    (status: OrderStatus.pronto, title: 'Saiu para entrega', desc: 'Seu entregador está a caminho do seu endereço.'),
    (status: OrderStatus.entregue, title: 'Entregue', desc: 'Aproveite sua refeição! Não esqueça de avaliar.'),
  ];

  static const _tableStages = [
    (status: OrderStatus.pendente, title: 'Pedido Confirmado', desc: 'Recebemos seu pedido e ele já está na fila.'),
    (status: OrderStatus.preparando, title: 'Preparando seu pedido', desc: 'Nossos chefs estão preparando seu pedido.'),
    (status: OrderStatus.pronto, title: 'Pedido pronto', desc: 'A equipe já pode levar seu pedido à mesa.'),
    (status: OrderStatus.entregue, title: 'Pedido entregue na mesa', desc: 'Bom apetite! Obrigado pela visita.'),
  ];

  int _stageIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendente:
        return 0;
      case OrderStatus.preparando:
        return 1;
      case OrderStatus.pronto:
        return 2;
      case OrderStatus.entregue:
        return 3;
      case OrderStatus.cancelado:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().byId(orderId);
    final tableNumber = order?.mesa == null ? null : int.tryParse(RegExp(r'\d+').firstMatch(order!.mesa!)?.group(0) ?? '');
    final isDelivery = order?.type == OrderType.delivery;
    final stages = isDelivery ? _deliveryStages : _tableStages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$orderId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MenuHomeScreen(tableNumber: tableNumber, isDelivery: order?.type == OrderType.delivery)), (_) => false),
        ),
      ),
      body: order == null
          ? const Center(child: Text('Pedido não encontrado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: const Color(0xFFEDE3D3), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Icon(Icons.soup_kitchen_outlined, size: 56, color: AppTheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          order.status == OrderStatus.entregue ? 'Pedido entregue!' : 'Preparando seu banquete!',
                          style: AppTheme.heading(18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.status == OrderStatus.entregue
                              ? (isDelivery ? 'Bom apetite!' : 'Bom apetite na mesa!')
                              : (isDelivery ? 'Entrega estimada: 25-30 min' : 'A equipe levará o pedido à sua mesa.'),
                          style: TextStyle(color: Colors.grey[600]),
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
                        Text('Status do Pedido', style: AppTheme.heading(16)),
                        const SizedBox(height: 16),
                        for (int i = 0; i < stages.length; i++) _timelineStep(i, order.status, stages),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _serviceCard(context, order, isDelivery),
                ],
              ),
            ),
    );
  }

  Widget _serviceCard(BuildContext context, RestaurantOrder order, bool isDelivery) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: AppTheme.background, child: Icon(isDelivery ? Icons.delivery_dining : Icons.table_restaurant_outlined, color: AppTheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isDelivery ? 'Entrega por delivery' : 'Atendimento da mesa', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(isDelivery ? 'Um entregador levará o pedido ao endereço informado.' : 'Seu pedido será levado à ${order.mesa ?? 'sua mesa'}.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        if (isDelivery)
          CircleAvatar(
            backgroundColor: AppTheme.primary,
            child: IconButton(
              icon: const Icon(Icons.call, color: Colors.white, size: 18),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ligando para o entregador...'), behavior: SnackBarBehavior.floating),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _timelineStep(int index, OrderStatus currentStatus, List<({OrderStatus status, String title, String desc})> stages) {
    final currentIndex = _stageIndex(currentStatus);
    final done = currentIndex >= index;
    final isLast = index == stages.length - 1;
    final stage = stages[index];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppTheme.olive : Colors.grey[300], size: 22),
              if (!isLast) Expanded(child: Container(width: 2, color: done ? AppTheme.olive : Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.title, style: TextStyle(fontWeight: FontWeight.w600, color: done ? AppTheme.textDark : Colors.grey)),
                  const SizedBox(height: 2),
                  Text(stage.desc, style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
