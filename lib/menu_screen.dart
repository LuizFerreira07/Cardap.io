import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'feedback_screen.dart';
import 'operations_screen.dart';
import 'payment_screen.dart';
import 'responsive.dart';
import 'search_utils.dart';

enum OrderMode { table, delivery }

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    required this.rating,
    required this.prepTime,
    required this.tags,
  });

  final String name;
  final String category;
  final String description;
  final double price;
  final String image;
  final double rating;
  final String prepTime;
  final List<String> tags;
}

class _ExtraOption {
  const _ExtraOption(this.name, this.price);

  final String name;
  final double price;
}

class _CartLine {
  _CartLine({
    required this.item,
    required this.quantity,
    this.extras = const [],
    this.extrasTotal = 0,
  });

  final _MenuItem item;
  int quantity;
  final List<String> extras;
  final double extrasTotal;

  double get unitPrice => item.price + extrasTotal;
  double get total => unitPrice * quantity;
}

const _items = <_MenuItem>[
  _MenuItem(
    name: 'Picanha Prime BBQ',
    category: 'Churrasco',
    description: 'Picanha na brasa, arroz de alho, farofa crocante e vinagrete da casa.',
    price: 42,
    image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=900&q=80',
    rating: 4.9,
    prepTime: '18–24 min',
    tags: ['Mais pedido', 'Sem glúten'],
  ),
  _MenuItem(
    name: 'Costela BBQ 12h',
    category: 'Churrasco',
    description: 'Costela bovina defumada lentamente, molho barbecue e batatas rústicas.',
    price: 48,
    image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=900&q=80',
    rating: 4.8,
    prepTime: '20–28 min',
    tags: ['Defumado'],
  ),
  _MenuItem(
    name: 'X-Burger Artesanal',
    category: 'Lanches',
    description: 'Pão brioche, blend 180 g, cheddar cremoso, cebola caramelizada e molho especial.',
    price: 29.5,
    image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900&q=80',
    rating: 4.8,
    prepTime: '12–18 min',
    tags: ['Favorito'],
  ),
  _MenuItem(
    name: 'Frango Crocante',
    category: 'Lanches',
    description: 'Pão de batata, frango crocante, queijo prato, alface e maionese de ervas.',
    price: 26,
    image: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=900&q=80',
    rating: 4.7,
    prepTime: '12–18 min',
    tags: ['Novo'],
  ),
  _MenuItem(
    name: 'Parmegiana da Casa',
    category: 'Pratos feitos',
    description: 'Filé empanado, molho de tomate, muçarela gratinada, arroz e fritas.',
    price: 36,
    image: 'https://images.unsplash.com/photo-1632778149955-e80f8ceca2e8?w=900&q=80',
    rating: 4.8,
    prepTime: '20–26 min',
    tags: ['Conforto'],
  ),
  _MenuItem(
    name: 'Risoto de Cogumelos',
    category: 'Pratos feitos',
    description: 'Arroz arbóreo cremoso, mix de cogumelos, parmesão e azeite trufado.',
    price: 34,
    image: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=900&q=80',
    rating: 4.6,
    prepTime: '18–24 min',
    tags: ['Vegetariano'],
  ),
  _MenuItem(
    name: 'Limonada Siciliana',
    category: 'Bebidas',
    description: 'Limão-siciliano, hortelã, água com gás e um toque de mel.',
    price: 12,
    image: 'https://images.unsplash.com/photo-1513558161293-ccef8c8f1c0b?w=900&q=80',
    rating: 4.7,
    prepTime: '5 min',
    tags: ['Refrescante'],
  ),
  _MenuItem(
    name: 'Mate da Casa',
    category: 'Bebidas',
    description: 'Chá-mate gelado, limão, laranja e especiarias da casa.',
    price: 10,
    image: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=900&q=80',
    rating: 4.6,
    prepTime: '5 min',
    tags: ['Sem álcool'],
  ),
  _MenuItem(
    name: 'Espetinho Mix da Brasa',
    category: 'Churrasco',
    description: 'Espetinhos de carne, frango e linguiça com farofa e vinagrete.',
    price: 32,
    image: 'https://images.unsplash.com/photo-1558030006-450675393462?w=900&q=80',
    rating: 4.7,
    prepTime: '16–22 min',
    tags: ['Na brasa'],
  ),
  _MenuItem(
    name: 'Linguiça Artesanal Acebolada',
    category: 'Churrasco',
    description: 'Linguiça artesanal grelhada, cebola na brasa, arroz e molho da casa.',
    price: 28,
    image: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=900&q=80',
    rating: 4.6,
    prepTime: '14–20 min',
    tags: ['Tradicional'],
  ),
  _MenuItem(
    name: 'Smash Bacon Crocante',
    category: 'Lanches',
    description: 'Pão brioche, dois smash burgers, cheddar, bacon crocante e molho especial.',
    price: 31,
    image: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=900&q=80',
    rating: 4.9,
    prepTime: '12–18 min',
    tags: ['Mais pedido'],
  ),
  _MenuItem(
    name: 'Crocante de Frango com Fritas',
    category: 'Lanches',
    description: 'Filé de frango empanado, queijo, alface, tomate e fritas sequinhas.',
    price: 27,
    image: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=900&q=80',
    rating: 4.7,
    prepTime: '14–20 min',
    tags: ['Crocante'],
  ),
  _MenuItem(
    name: 'Feijoada Executiva',
    category: 'Pratos feitos',
    description: 'Feijoada da casa com arroz, couve refogada, farofa e laranja.',
    price: 39,
    image: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=900&q=80',
    rating: 4.8,
    prepTime: '18–25 min',
    tags: ['Brasileiro'],
  ),
  _MenuItem(
    name: 'Strogonoff de Frango',
    category: 'Pratos feitos',
    description: 'Frango ao molho cremoso, arroz branco, batata palha e salada.',
    price: 33,
    image: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=900&q=80',
    rating: 4.7,
    prepTime: '16–22 min',
    tags: ['Caseiro'],
  ),
  _MenuItem(
    name: 'Suco Natural de Laranja',
    category: 'Bebidas',
    description: 'Suco natural de laranja feito na hora, sem conservantes.',
    price: 9,
    image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=900&q=80',
    rating: 4.8,
    prepTime: '5 min',
    tags: ['Natural'],
  ),
  _MenuItem(
    name: 'Água com Gás e Limão',
    category: 'Bebidas',
    description: 'Água mineral com gás, limão fresco e gelo.',
    price: 7,
    image: 'https://images.unsplash.com/photo-1559839914-17aae19cec71?w=900&q=80',
    rating: 4.5,
    prepTime: '2 min',
    tags: ['Leve'],
  ),
];

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Set<String> _favorites = <String>{};
  final List<_CartLine> _cart = <_CartLine>[];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Todos',
    'Churrasco',
    'Lanches',
    'Pratos feitos',
    'Bebidas',
  ];

  String _selectedCategory = 'Todos';
  String _search = '';
  bool _favoritesOnly = false;
  OrderMode _orderMode = OrderMode.table;
  int _orderStage = 0;
  bool _waiterCalled = false;
  String _deliveryValidation = 'Consulte o CEP para validar a área de entrega.';

  /// Busca por aproximação: ignora acentos ("limao" acha "Limão") e
  /// tolera pequenos erros de digitação ("pcanha" acha "Picanha").
  /// Os resultados são ordenados pela relevância do match (nome exato
  /// vem antes de um match parcial em tags/descrição, por exemplo).
  List<_MenuItem> get _filteredItems {
    final normalizedQuery = normalizeForSearch(_search.trim());

    final base = _items.where((item) {
      final categoryMatches = _selectedCategory == 'Todos' || item.category == _selectedCategory;
      final favoriteMatches = !_favoritesOnly || _favorites.contains(item.name);
      return categoryMatches && favoriteMatches;
    });

    if (normalizedQuery.isEmpty) return base.toList();

    final scored = <MapEntry<_MenuItem, int>>[];
    for (final item in base) {
      final haystack = normalizeForSearch(
        '${item.name} ${item.description} ${item.category} ${item.tags.join(' ')}',
      );
      final match = matchQuery(haystack, normalizedQuery);
      if (match.matches) scored.add(MapEntry(item, match.score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((entry) => entry.key).toList();
  }

  int get _cartCount => _cart.fold<int>(0, (sum, line) => sum + line.quantity);

  double get _subtotal => _cart.fold<double>(0, (sum, line) => sum + line.total);

  double get _deliveryFee => _orderMode == OrderMode.delivery ? 6.9 : 0;

  double get _total => _subtotal + _deliveryFee;

  @override
  void dispose() {
    _addressController.dispose();
    _cepController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(
    _MenuItem item, {
    int quantity = 1,
    List<String> extras = const [],
    double extrasTotal = 0,
  }) {
    setState(() {
      // Se já existe uma linha do mesmo item com exatamente os mesmos
      // extras, apenas soma a quantidade em vez de criar uma linha
      // duplicada no carrinho.
      final sortedExtras = List<String>.from(extras)..sort();
      final existingIndex = _cart.indexWhere((line) {
        if (!identical(line.item, item)) return false;
        final lineExtras = List<String>.from(line.extras)..sort();
        return listEquals(lineExtras, sortedExtras);
      });
      if (existingIndex != -1) {
        _cart[existingIndex].quantity += quantity;
      } else {
        _cart.add(_CartLine(
          item: item,
          quantity: quantity,
          extras: extras,
          extrasTotal: extrasTotal,
        ));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} adicionado ao pedido'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Ver pedido', onPressed: _openCart),
      ),
    );
  }

  void _showItemDetails(_MenuItem item) {
    const options = <_ExtraOption>[
      _ExtraOption('Queijo cheddar', 4),
      _ExtraOption('Bacon crocante', 5),
      _ExtraOption('Molho da casa', 2.5),
    ];
    int quantity = 1;
    final selected = <String>{};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, refresh) {
            final extrasTotal = options
                .where((option) => selected.contains(option.name))
                .fold<double>(0, (sum, option) => sum + option.price);
            return Container(
              height: MediaQuery.of(sheetContext).size.height * 0.82,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: 16 / 8,
                                child: Image.network(
                                  item.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const _ImageFallback(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 6),
                                      Text(item.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(_money(item.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.brownDark)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Personalize seu pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            ...options.map((option) {
                              final checked = selected.contains(option.name);
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: checked,
                                activeColor: AppColors.brownDark,
                                title: Text(option.name),
                                subtitle: Text('+ ${_money(option.price)}'),
                                onChanged: (_) => refresh(() {
                                  checked ? selected.remove(option.name) : selected.add(option.name);
                                }),
                              );
                            }),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('Quantidade', style: TextStyle(fontWeight: FontWeight.w700)),
                                const Spacer(),
                                _QuantityControl(
                                  quantity: quantity,
                                  onDecrease: quantity > 1 ? () => refresh(() => quantity--) : null,
                                  onIncrease: () => refresh(() => quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _addToCart(item, quantity: quantity, extras: selected.toList(), extrasTotal: extrasTotal);
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          label: Text('Adicionar • ${_money((item.price + extrasTotal) * quantity)}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _callWaiter() {
    setState(() => _waiterCalled = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chamado enviado. A equipe irá até sua mesa.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _lookupCep(StateSetter refresh) {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    refresh(() {
      if (cep.length != 8) {
        _deliveryValidation = 'Digite um CEP válido com 8 dígitos.';
        return;
      }
      _addressController.text = 'Rua das Flores, 120 — Centro';
      _deliveryValidation = 'Área atendida • taxa calculada: ${_money(_deliveryFee)}';
    });
  }

  void _openOperations() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OperationsScreen()));
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, refresh) => _buildCartSheet(sheetContext, refresh),
        );
      },
    );
  }

  Widget _buildCartSheet(BuildContext sheetContext, StateSetter refresh) {
    void update(VoidCallback action) {
      setState(action);
      refresh(() {});
    }

    return Container(
      height: MediaQuery.of(sheetContext).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  const Expanded(child: Text('Seu pedido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                  IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ModeChip(
                    icon: Icons.table_bar_outlined,
                    label: 'Sua mesa',
                    selected: _orderMode == OrderMode.table,
                    onTap: () => update(() => _orderMode = OrderMode.table),
                  ),
                  const SizedBox(width: 10),
                  _ModeChip(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Delivery',
                    selected: _orderMode == OrderMode.delivery,
                    onTap: () => update(() => _orderMode = OrderMode.delivery),
                  ),
                ],
              ),
            ),
            if (_orderMode == OrderMode.delivery)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cepController,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                            decoration: const InputDecoration(labelText: 'CEP', hintText: '00000000', prefixIcon: Icon(Icons.search_rounded)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: IconButton.filled(
                            tooltip: 'Buscar endereço',
                            onPressed: () => _lookupCep(refresh),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_deliveryValidation, style: TextStyle(fontSize: 12, color: _deliveryValidation.startsWith('Área') ? AppColors.green : AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      maxLength: 120,
                      inputFormatters: [LengthLimitingTextInputFormatter(120)],
                      decoration: const InputDecoration(labelText: 'Endereço de entrega', hintText: 'Rua, número e complemento', prefixIcon: Icon(Icons.location_on_outlined)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Seu pedido está vazio.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      itemCount: _cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final line = _cart[index];
                        return SectionCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Image.network(line.item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _ImageFallback()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(line.item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    if (line.extras.isNotEmpty)
                                      Text('Extras: ${line.extras.join(', ')}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(_money(line.total), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brownDark)),
                                  ],
                                ),
                              ),
                              _QuantityControl(
                                quantity: line.quantity,
                                onDecrease: () => update(() {
                                  if (line.quantity > 1) {
                                    line.quantity--;
                                  } else {
                                    _cart.removeAt(index);
                                  }
                                }),
                                onIncrease: () => update(() => line.quantity++),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _TotalRow(label: 'Subtotal', value: _money(_subtotal)),
                  if (_orderMode == OrderMode.delivery) ...[
                    const SizedBox(height: 6),
                    _TotalRow(label: 'Taxa de entrega', value: _money(_deliveryFee)),
                  ],
                  const SizedBox(height: 8),
                  _TotalRow(label: 'Total', value: _money(_total), strong: true),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cart.isEmpty ? null : () {
                        Navigator.pop(sheetContext);
                        _checkout();
                      },
                      child: const Text('Continuar para pagamento'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkout() async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          total: _total,
          itemsCount: _cartCount,
          orderType: _orderMode == OrderMode.table ? 'Mesa' : 'Delivery',
          address: _addressController.text.trim(),
        ),
      ),
    );
    if (!mounted || paid != true) return;
    setState(() {
      _cart.clear();
      _orderStage = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido confirmado e enviado para a cozinha.')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveDashboardShell(
          maxWidth: 1120,
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                _Header(
                  searchController: _searchController,
                  cartCount: _cartCount,
                  waiterCalled: _waiterCalled,
                  orderStage: _orderStage,
                  favoritesOnly: _favoritesOnly,
                  onSearch: (value) => setState(() => _search = value),
                  onCart: _openCart,
                  onOperations: _openOperations,
                  onCallWaiter: _callWaiter,
                  onToggleFavoritesOnly: () => setState(() => _favoritesOnly = !_favoritesOnly),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = gridColumnsFor(constraints.maxWidth, mobile: 1, tablet: 2, desktop: 3);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_orderStage > 0) ...[
                              _OrderProgress(stage: _orderStage),
                              const SizedBox(height: 18),
                            ],
                            SizedBox(
                              height: 42,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (_, index) {
                                  final category = _categories[index];
                                  final selected = _selectedCategory == category;
                                  return ChoiceChip(
                                    label: Text(category),
                                    selected: selected,
                                    onSelected: (_) => setState(() => _selectedCategory = category),
                                    selectedColor: AppColors.brownDark,
                                    backgroundColor: AppColors.surface,
                                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w700),
                                    side: BorderSide(color: selected ? AppColors.brownDark : AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(child: Text(_favoritesOnly ? 'Seus favoritos' : 'Mais pedidos hoje', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                                Text('${filteredItems.length} opções', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (filteredItems.isEmpty)
                              SectionCard(
                                child: Center(
                                  child: Text(
                                    _favoritesOnly
                                        ? 'Você ainda não favoritou nenhum item. Toque no coração de um prato para adicioná-lo aqui.'
                                        : 'Nenhum item encontrado. Tente outro termo.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredItems.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: columns == 1 ? 1.14 : 0.75,
                                ),
                                itemBuilder: (_, index) {
                                  final item = filteredItems[index];
                                  return _FoodCard(
                                    item: item,
                                    favorite: _favorites.contains(item.name),
                                    onTap: () => _showItemDetails(item),
                                    onFavToggle: () => setState(() {
                                      _favorites.contains(item.name) ? _favorites.remove(item.name) : _favorites.add(item.name);
                                    }),
                                    onQuickAdd: () => _addToCart(item),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _cartCount == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: _openCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text('Ver pedido • $_cartCount ${_cartCount == 1 ? 'item' : 'itens'} • ${_money(_total)}'),
                ),
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.cartCount,
    required this.waiterCalled,
    required this.orderStage,
    required this.favoritesOnly,
    required this.onSearch,
    required this.onCart,
    required this.onOperations,
    required this.onCallWaiter,
    required this.onToggleFavoritesOnly,
  });

  final TextEditingController searchController;
  final int cartCount;
  final bool waiterCalled;
  final int orderStage;
  final bool favoritesOnly;
  final ValueChanged<String> onSearch;
  final VoidCallback onCart;
  final VoidCallback onOperations;
  final VoidCallback onCallWaiter;
  final VoidCallback onToggleFavoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
              const Expanded(child: BrandLogo(height: 42)),
              IconButton(tooltip: 'Painel da operação', onPressed: onOperations, icon: const Icon(Icons.dashboard_customize_outlined)),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(tooltip: 'Seu pedido', onPressed: onCart, icon: const Icon(Icons.shopping_bag_outlined)),
                  if (cartCount > 0)
                    Positioned(
                      right: 4,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                        child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.brandCyan),
              const SizedBox(width: 5),
              const Text('Sessão QR • Sua mesa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Salão aberto', style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: onCallWaiter,
                icon: Icon(waiterCalled ? Icons.check_circle_outline : Icons.notifications_none_rounded, size: 17),
                label: Text(waiterCalled ? 'Garçom avisado' : 'Chamar garçom'),
              ),
            ],
          ),
          TextField(
            onChanged: onSearch,
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar pratos, bebidas ou ingredientes...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, maxWidth: 92),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Limpar busca',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded, size: 19, color: AppColors.textMuted),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    ),
                  IconButton(
                    tooltip: favoritesOnly ? 'Mostrar todos os itens' : 'Mostrar apenas favoritos',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      favoritesOnly ? Icons.favorite_rounded : Icons.tune_rounded,
                      size: 19,
                      color: favoritesOnly ? AppColors.red : AppColors.textMuted,
                    ),
                    onPressed: onToggleFavoritesOnly,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.item,
    required this.favorite,
    required this.onTap,
    required this.onFavToggle,
    required this.onQuickAdd,
  });

  final _MenuItem item;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavToggle;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _ImageFallback()),
                ),
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                        const SizedBox(width: 2),
                        Text('${item.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: IconButton(
                    onPressed: onFavToggle,
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 19, color: favorite ? AppColors.red : AppColors.textMuted),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 5,
                      children: item.tags.take(1).map((tag) => Text(tag.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.brownMedium, fontWeight: FontWeight.w800, letterSpacing: .4))).toList(),
                    ),
                    const SizedBox(height: 5),
                    Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 5),
                    Expanded(child: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(_money(item.price), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brownDark, fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(item.prepTime, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        const Spacer(),
                        IconButton.filled(
                          onPressed: onQuickAdd,
                          icon: const Icon(Icons.add_rounded),
                          tooltip: 'Adicionar rapidamente',
                          style: IconButton.styleFrom(backgroundColor: AppColors.brownDark, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.cream, child: const Center(child: Icon(Icons.restaurant_rounded, color: AppColors.brownLight, size: 36)));
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onDecrease, required this.onIncrease});

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove_rounded, size: 17), visualDensity: VisualDensity.compact),
          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
          IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_rounded, size: 17), visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenLight : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.green : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.green : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? AppColors.green : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: strong ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: strong ? FontWeight.w800 : FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: strong ? 19 : 14, fontWeight: strong ? FontWeight.w900 : FontWeight.w700, color: strong ? AppColors.brownDark : AppColors.textPrimary)),
      ],
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.stage});

  final int stage;

  @override
  Widget build(BuildContext context) {
    const labels = ['Recebido', 'Preparando', 'A caminho'];
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Pedido #GF-214 está em andamento', style: TextStyle(fontWeight: FontWeight.w800))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)), child: const Text('Ao vivo', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: List.generate(labels.length, (index) {
              final active = index <= stage;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: active ? AppColors.green : AppColors.cream, child: Icon(active ? Icons.check_rounded : Icons.circle_outlined, size: 15, color: active ? Colors.white : AppColors.textMuted)),
                        const SizedBox(height: 5),
                        Text(labels[index], style: TextStyle(fontSize: 10, color: active ? AppColors.green : AppColors.textSecondary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (index < labels.length - 1) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18, left: 5, right: 5), color: index < stage ? AppColors.green : AppColors.border)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
