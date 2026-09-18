import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController(text: 'admin@sabor.com');
  final _passController = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  String? _error;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
      });
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.restaurant, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 16),
                Text('SaborDigital', style: AppTheme.heading(28)),
                const SizedBox(height: 2),
                Text('Administrador', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Entrar no Painel', style: AppTheme.heading(20)),
                        const SizedBox(height: 20),
                        Text('E-mail', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _userController,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline)),
                          validator: (v) => (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
                        ),
                        const SizedBox(height: 16),
                        Text('Senha', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Switch(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v)),
                            const Text('Lembrar-me', style: TextStyle(fontSize: 13)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contate o suporte para redefinir sua senha.'), behavior: SnackBarBehavior.floating),
                              ),
                              child: const Text('Esqueceu a senha?', style: TextStyle(fontSize: 12.5)),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _submit,
                            icon: _loading
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.add, size: 18),
                            label: const Text('Acessar Painel'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OU', style: TextStyle(color: Colors.grey[500], fontSize: 12))),
                            Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('Demonstração: admin@sabor.com / admin123', style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final username = _userController.text.trim();
    final success = await context.read<AuthProvider>().login(username, _passController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
    } else {
      setState(() => _error = 'E-mail ou senha inválidos');
    }
  }
}
