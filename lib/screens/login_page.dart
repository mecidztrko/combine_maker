import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSuccess;
  const LoginPage({super.key, required this.onSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscure = true;
  String? _error;

  static const String _demoUser = 'user';
  static const String _demoPass = '1234';

  void _submit() {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final u = _userController.text.trim();
    final p = _passController.text;
    if (u == _demoUser && p == _demoPass) {
      widget.onSuccess();
    } else {
      setState(() {
        _error = 'Kullanıcı adı veya şifre hatalı. Tekrar deneyin.';
        _passController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kombin Oluşturucu',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı adı',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı zorunlu' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Şifre zorunlu' : null,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Giriş Yap'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demo: kullanıcı=user, şifre=1234',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

