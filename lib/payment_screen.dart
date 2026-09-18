import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'responsive.dart';

enum PaymentMethod { pix, card, physical }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.total, required this.itemsCount, required this.orderType, this.address = ''});

  final double total;
  final int itemsCount;
  final String orderType;
  final String address;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.pix;
  bool _processing = false;

  Future<void> _confirmPayment() async {
    if (widget.orderType == 'Delivery' && widget.address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o endereço para continuar.')));
      return;
    }
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Finalizar pedido', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ResponsivePhoneShell(
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckoutSummary(widget: widget),
                        const SizedBox(height: 22),
                        const Text('Como você quer pagar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 12),
                        _PaymentOption(selected: _method == PaymentMethod.pix, icon: Icons.qr_code_2_rounded, title: 'Pix', subtitle: 'Aprovação imediata', onTap: () => setState(() => _method = PaymentMethod.pix)),
                        const SizedBox(height: 10),
                        _PaymentOption(selected: _method == PaymentMethod.card, icon: Icons.credit_card_rounded, title: 'Cartão', subtitle: 'Crédito ou débito', onTap: () => setState(() => _method = PaymentMethod.card)),
                        const SizedBox(height: 10),
                        _PaymentOption(selected: _method == PaymentMethod.physical, icon: Icons.payments_outlined, title: 'Pagar no local', subtitle: widget.orderType == 'Delivery' ? 'Dinheiro ou cartão na entrega' : 'Dinheiro ou cartão no caixa/mesa', onTap: () => setState(() => _method = PaymentMethod.physical)),
                        const SizedBox(height: 16),
                        if (_method == PaymentMethod.pix) const _PixPanel(),
                        if (_method == PaymentMethod.card) const _CardPanel(),
                        if (_method == PaymentMethod.physical) const _PhysicalPanel(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total do pedido', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)), Text(_money(widget.total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.brownDark))]),
                      const Spacer(),
                      ElevatedButton(onPressed: _processing ? null : _confirmPayment, child: _processing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirmar pedido')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.widget});

  final PaymentScreen widget;

  @override
  Widget build(BuildContext context) {
    final isDelivery = widget.orderType == 'Delivery';
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.receipt_long_outlined, color: AppColors.brownDark), const SizedBox(width: 10), const Expanded(child: Text('Resumo do pedido', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), Text('${widget.itemsCount} ${widget.itemsCount == 1 ? 'item' : 'itens'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
          const SizedBox(height: 14),
          Row(children: [Icon(isDelivery ? Icons.delivery_dining_outlined : Icons.table_bar_outlined, size: 18, color: AppColors.textSecondary), const SizedBox(width: 8), Text(isDelivery ? 'Entrega no endereço informado' : 'Pedido para consumo no local', style: const TextStyle(fontWeight: FontWeight.w700))]),
          if (isDelivery && widget.address.isNotEmpty) ...[const SizedBox(height: 6), Padding(padding: const EdgeInsets.only(left: 26), child: Text(widget.address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)))],
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({required this.selected, required this.icon, required this.title, required this.subtitle, required this.onTap});

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      selected: selected,
      onTap: onTap,
      borderColor: selected ? AppColors.green : null,
      child: Row(children: [CircleAvatar(radius: 20, backgroundColor: selected ? AppColors.greenLight : AppColors.cream, child: Icon(icon, color: selected ? AppColors.green : AppColors.brownDark)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))])), Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppColors.green : AppColors.border)]),
    );
  }
}

class _PixPanel extends StatelessWidget {
  const _PixPanel();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Escaneie o QR Code ou copie o código Pix', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(width: 142, height: 142, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)), child: const _FakeQr()),
          const SizedBox(height: 14),
          const Text('gastroflow@pagamentos.com', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código Pix copiado.'))), icon: const Icon(Icons.copy_rounded, size: 16), label: const Text('Copiar código Pix')),
        ],
      ),
    );
  }
}

class _FakeQr extends StatelessWidget {
  const _FakeQr();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _QrPainter(), child: const SizedBox.expand());
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.brownDark;
    const cells = 13;
    final cell = size.width / cells;
    for (var row = 0; row < cells; row++) {
      for (var col = 0; col < cells; col++) {
        final corner = (row < 4 && col < 4) || (row < 4 && col > 8) || (row > 8 && col < 4);
        final checker = ((row * 7 + col * 3 + row * col) % 5) < 2;
        if (corner || checker) canvas.drawRect(Rect.fromLTWH(col * cell, row * cell, cell - 1, cell - 1), paint);
      }
    }
    final clear = Paint()..color = Colors.white;
    for (final origin in [const Offset(0, 0), Offset(size.width - cell * 4, 0), Offset(0, size.height - cell * 4)]) {
      canvas.drawRect(Rect.fromLTWH(origin.dx + cell, origin.dy + cell, cell * 2, cell * 2), clear);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPanel extends StatelessWidget {
  const _CardPanel();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dados do cartão', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(19)],
            decoration: const InputDecoration(labelText: 'Número do cartão', prefixIcon: Icon(Icons.credit_card_rounded)),
          ),
          const SizedBox(height: 10),
          TextField(
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            decoration: const InputDecoration(labelText: 'Nome impresso no cartão'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.datetime,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')), LengthLimitingTextInputFormatter(5)],
                  decoration: const InputDecoration(labelText: 'Validade (MM/AA)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Seus dados são protegidos por criptografia.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PhysicalPanel extends StatelessWidget {
  const _PhysicalPanel();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(children: [CircleAvatar(radius: 21, backgroundColor: AppColors.cream, child: const Icon(Icons.info_outline_rounded, color: AppColors.brownDark)), const SizedBox(width: 12), const Expanded(child: Text('Seu pedido será enviado agora. Você poderá pagar no caixa ou diretamente no atendimento.', style: TextStyle(color: AppColors.textSecondary, height: 1.35)))]),
    );
  }
}

String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
