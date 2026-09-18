/// Gera o payload Pix no padrão EMV, pronto para QR Code e Copia e Cola.
class PixPayload {
  static String generate({required String key, required double amount, String merchantName = 'RESTAURANTE', String city = 'SAO PAULO'}) {
    final normalizedKey = key.trim();
    final name = _normalize(merchantName, 25);
    final normalizedCity = _normalize(city, 15);
    final amountText = amount.toStringAsFixed(2);
    final merchantAccount = _field('00', 'BR.GOV.BCB.PIX') + _field('01', normalizedKey);
    final additional = _field('05', '***');
    final payload = [
      _field('00', '01'),
      _field('26', merchantAccount),
      _field('52', '0000'),
      _field('53', '986'),
      _field('54', amountText),
      _field('58', 'BR'),
      _field('59', name),
      _field('60', normalizedCity),
      _field('62', additional),
    ].join();
    final payloadWithCrcPlaceholder = '${payload}6304';
    return '$payloadWithCrcPlaceholder${_crc16(payloadWithCrcPlaceholder)}';
  }

  static String _field(String id, String value) => '$id${value.length.toString().padLeft(2, '0')}$value';

  static String _normalize(String value, int maxLength) {
    final clean = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 ]'), '').trim();
    return clean.substring(0, clean.length > maxLength ? maxLength : clean.length);
  }

  static String _crc16(String text) {
    var crc = 0xFFFF;
    for (final byte in text.codeUnits) {
      crc ^= byte << 8;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) & 0xFFFF : (crc << 1) & 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
