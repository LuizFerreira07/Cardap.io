import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'data/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'providers/store_settings_provider.dart';
import 'providers/table_session_provider.dart';
import 'screens/client/entry_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await SupabaseService.initialize();
  runApp(const CardapioApp());
}

class CardapioApp extends StatelessWidget {
  const CardapioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => StoreSettingsProvider()),
        ChangeNotifierProvider(create: (_) => TableSessionProvider()),
      ],
      child: MaterialApp(
        title: 'Cardápio Digital',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const EntryScreen(),
      ),
    );
  }
}
