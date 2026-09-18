import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';

class TableQrScreen extends StatelessWidget {
  const TableQrScreen({super.key});

  String _linkFor(int tableNumber) {
    final base = Uri.base;
    if (base.scheme == 'http' || base.scheme == 'https') {
      return base.replace(queryParameters: {'mesa': '$tableNumber'}).toString();
    }
    return 'https://seu-dominio.com/?mesa=$tableNumber';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QR Codes das mesas', style: AppTheme.heading(20)),
        const SizedBox(height: 6),
        Text('Imprima um QR Code por mesa. Ao abrir o link, o cliente será direcionado diretamente para o cardápio daquela mesa.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 270, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .82),
          itemBuilder: (context, index) {
            final table = index + 1;
            final link = _linkFor(table);
            return Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text('Mesa $table', style: AppTheme.heading(17, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  Expanded(child: Container(color: Colors.white, child: QrImageView(data: link, padding: const EdgeInsets.all(4), eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black)))),
                  const SizedBox(height: 10),
                  Text(link, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: link)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copiado.'))); }, icon: const Icon(Icons.copy, size: 16), label: const Text('Copiar link')),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }
}
