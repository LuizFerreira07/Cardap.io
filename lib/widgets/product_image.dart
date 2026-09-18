import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';

/// Exibe a foto do produto com cantos/tamanho configuráveis.
/// Se o item não tiver foto (ou se ela falhar ao carregar), cai de volta
/// no gradiente colorido da categoria com o emoji — assim o app nunca
/// mostra um espaço quebrado.
class ProductImage extends StatelessWidget {
  final MenuItem item;
  final double? width;
  final double? height;
  final double emojiSize;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.emojiSize = 48,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final content = item.imageUrl.isEmpty
        ? _fallback()
        : Image.network(
            item.imageUrl,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _fallback(showEmoji: false, child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ));
            },
            errorBuilder: (context, error, stack) => _fallback(),
          );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }

  Widget _fallback({bool showEmoji = true, Widget? child}) {
    final color = item.category.color;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: child ?? (showEmoji ? Text(item.emoji, style: TextStyle(fontSize: emojiSize)) : null),
    );
  }
}
