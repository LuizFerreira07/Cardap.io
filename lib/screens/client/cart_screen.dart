import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/category.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/store_settings_provider.dart';
import '../../providers/table_session_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/pix_payload.dart';
import 'order_tracking_screen.dart';

class _CheckoutData {
  final String? name;
  final String? mesa;
  final String? address;
  final OrderType type;
  final PaymentMethod payment;

  const _CheckoutData({this.name, this.mesa, this.address, required this.type, required this.payment});
}

class CartScreen extends StatefulWidget {
  final int? tableNumber;
  final bool isDelivery;

  const CartScreen({super.key, this.tableNumber, this.isDelivery = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();
  String? _couponMessage;
  bool _couponValid = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.tableNumber != null ? 'Pedido • Mesa ${widget.tableNumber}' : 'Meu Carrinho')),
      body: cart.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('🛒', style: TextStyle(fontSize: 64)), const SizedBox(height: 12), Text('Seu carrinho está vazio', style: TextStyle(color: Colors.grey[600], fontSize: 16))]))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final line in cart.lines) _cartLineTile(context, line),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.06))),
                  child: Row(children: [
                    const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.sell_outlined, size: 18, color: AppTheme.primary)),
                    const SizedBox(width: 4),
                    Expanded(child: TextField(controller: _couponController, decoration: const InputDecoration(hintText: 'Cupom de desconto', border: InputBorder.none))),
                    TextButton.icon(onPressed: () { final valid = context.read<CartProvider>().applyCoupon(_couponController.text); setState(() { _couponValid = valid; _couponMessage = valid ? 'Cupom aplicado! 10% de desconto.' : 'Cupom inválido.'; }); }, icon: const Icon(Icons.add, size: 16), label: const Text('Aplicar')),
                  ]),
                ),
                if (_couponMessage != null) Padding(padding: const EdgeInsets.only(top: 8, left: 8), child: Text(_couponMessage!, style: TextStyle(color: _couponValid ? AppTheme.olive : AppTheme.danger, fontSize: 12.5))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Column(children: [
                    Text('Resumo do Pedido', style: AppTheme.heading(16)),
                    const SizedBox(height: 14),
                    _summaryRow('Subtotal', CurrencyFormatter.format(cart.subtotal)),
                    const SizedBox(height: 8),
                    _summaryRow(widget.tableNumber != null ? 'Consumo no salão' : 'Taxa de entrega', widget.tableNumber != null ? 'Sem taxa' : 'Calculada no checkout'),
                    if (cart.discount > 0) ...[const SizedBox(height: 8), _summaryRow('Desconto', '- ${CurrencyFormatter.format(cart.discount)}', color: AppTheme.olive)],
                  ]),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty ? null : SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total a pagar', style: TextStyle(color: Colors.white70, fontSize: 12)), Text(CurrencyFormatter.format(cart.total), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))])),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary), onPressed: () => _checkout(context), icon: const Icon(Icons.arrow_forward, size: 18), label: const Text('Finalizar Pedido')),
          ]),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[600])), Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color))]);

  Widget _cartLineTile(BuildContext context, CartLine line) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: line.category.color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), alignment: Alignment.center, child: const Text('🍽️', style: TextStyle(fontSize: 22))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(line.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 2), Text(CurrencyFormatter.format(line.unitPrice), style: TextStyle(color: Colors.grey[600], fontSize: 13))])),
      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => context.read<CartProvider>().decrement(line.key)),
      Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => context.read<CartProvider>().increment(line.key)),
    ]),
  );

  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final settings = context.read<StoreSettingsProvider>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    var payment = PaymentMethod.fisico;
    final type = widget.tableNumber != null ? OrderType.salao : OrderType.delivery;

    final data = await showDialog<_CheckoutData>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text(widget.tableNumber != null ? 'Enviar pedido para a Mesa ${widget.tableNumber}' : 'Finalizar delivery'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Seu nome (opcional)')),
          if (widget.tableNumber != null) ...[
            const SizedBox(height: 16),
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: const Text('Esta sessão está vinculada à mesa pelo QR Code. A mesa será liberada quando o pedido for fechado/pago.', style: TextStyle(fontSize: 13, height: 1.3))),
          ],
          if (widget.tableNumber == null) ...[
            const SizedBox(height: 12),
            TextField(controller: addressController, maxLines: 2, decoration: const InputDecoration(labelText: 'Endereço de entrega', hintText: 'Rua, número e complemento', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text('Taxa de entrega: ${CurrencyFormatter.format(settings.deliveryFee)}', style: TextStyle(color: Colors.grey[700], fontSize: 13))),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(value: payment, decoration: const InputDecoration(labelText: 'Forma de pagamento'), items: PaymentMethod.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(), onChanged: (v) { if (v != null) setDialogState(() => payment = v); }),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')), ElevatedButton(onPressed: () { if (type == OrderType.delivery && addressController.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o endereço de entrega.'))); return; } Navigator.pop(dialogContext, _CheckoutData(name: nameController.text.trim().isEmpty ? null : nameController.text.trim(), mesa: widget.tableNumber == null ? null : 'Mesa ${widget.tableNumber}', address: addressController.text.trim().isEmpty ? null : addressController.text.trim(), type: type, payment: payment)); }, child: const Text('Confirmar pedido'))],
      )),
    );
    nameController.dispose();
    addressController.dispose();
    if (data == null || !mounted) return;

    final fee = data.type == OrderType.delivery ? settings.deliveryFee : 0.0;
    if (data.payment == PaymentMethod.pix) {
      if (settings.pixKey.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A chave Pix ainda não foi configurada pelo restaurante.'))); return; }
      final pixCode = PixPayload.generate(key: settings.pixKey, amount: cart.total + fee, merchantName: settings.name);
      final paid = await _showPixPayment(context, pixCode, cart.total + fee);
      if (paid != true || !mounted) return;
    }
    final sessionId = widget.tableNumber == null ? null : await context.read<TableSessionProvider>().sessionId();
    final order = await orders.placeOrder(cart.lines.map((l) => l.toOrderItem()).toList(), customerName: data.name, mesa: data.mesa, tableSessionId: sessionId, type: data.type, paymentMethod: data.payment, address: data.address, deliveryFee: fee, discount: cart.discount);
    cart.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)));
  }

  Future<bool?> _showPixPayment(BuildContext context, String pixCode, double amount) {
    return showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Pague com Pix'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Escaneie este QR Code com o aplicativo do seu banco.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(12), color: Colors.white, child: QrImageView(data: pixCode, size: 220, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black))), const SizedBox(height: 12), Text('Total: ${CurrencyFormatter.format(amount)}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), OutlinedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: pixCode)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pix Copia e Cola copiado.'))); }, icon: const Icon(Icons.copy), label: const Text('Copiar Pix Copia e Cola'))])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continuar'))]));
  }
}
