import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';

class MenuItemFormDialog extends StatefulWidget {
  final MenuItem? existing;
  const MenuItemFormDialog({super.key, this.existing});

  @override
  State<MenuItemFormDialog> createState() => _MenuItemFormDialogState();
}

class _MenuItemFormDialogState extends State<MenuItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _price;
  late TextEditingController _stock;
  late TextEditingController _imageUrl;
  late String _emoji;
  late MenuCategory _category;
  late bool _popular;

  static const _emojiOptions = [
    '🍔', '🥓', '🧀', '🥗', '🌭', '🍝', '🍲', '🍗', '🍤', '🍜',
    '🍹', '🍸', '🥂', '🥤', '🧃', '💧', '🍺', '🍕', '🌮', '🍰'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(text: e != null ? e.price.toStringAsFixed(2) : '');
    _stock = TextEditingController(text: '${e?.stockUnits ?? 20}');
    _imageUrl = TextEditingController(text: e?.imageUrl ?? '');
    _emoji = e?.emoji ?? _emojiOptions.first;
    _category = e?.category ?? MenuCategory.lanches;
    _popular = e?.popular ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar item' : 'Novo item'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 2,
                  validator: (v) => (v == null || v.isEmpty) ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o preço';
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return 'Preço inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stock,
                  decoration: const InputDecoration(labelText: 'Quantidade em estoque'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o estoque';
                    if (int.tryParse(v) == null) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(
                    labelText: 'Foto do produto (URL)',
                    hintText: 'https://... (deixe em branco para usar o ícone)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (_imageUrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl.text.trim(),
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        height: 110,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Não foi possível carregar a imagem'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<MenuCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: [for (final c in MenuCategory.values) DropdownMenuItem(value: c, child: Text(c.label))],
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Text('Ícone', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in _emojiOptions)
                      ChoiceChip(
                        label: Text(e, style: const TextStyle(fontSize: 18)),
                        selected: _emoji == e,
                        onSelected: (_) => setState(() => _emoji = e),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Marcar como popular'),
                  value: _popular,
                  onChanged: (v) => setState(() => _popular = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.parse(_price.text.replaceAll(',', '.'));
    final stock = int.parse(_stock.text);
    final menu = context.read<MenuProvider>();

    if (widget.existing != null) {
      await menu.updateItem(widget.existing!.copyWith(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: price,
        category: _category,
        emoji: _emoji,
        imageUrl: _imageUrl.text.trim(),
        popular: _popular,
        stockUnits: stock,
      ));
    } else {
      await menu.addItem(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: price,
        category: _category,
        emoji: _emoji,
        imageUrl: _imageUrl.text.trim(),
        popular: _popular,
        stockUnits: stock,
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
