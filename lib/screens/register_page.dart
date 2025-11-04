import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSuccess;
  const RegisterPage({super.key, required this.onSuccess});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late AnimationController _formController;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text;
    final confirmPass = _confirmPassController.text;

    if (pass != confirmPass) {
      setState(() {
        _error = 'Şifreler eşleşmiyor.';
        _confirmPassController.clear();
      });
      return;
    }

    if (pass.length < 8) {
      setState(() {
        _error = 'Şifre en az 8 karakter olmalı.';
      });
      return;
    }

    // Simulate successful registration
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1113), Color(0xFF1A1D21)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Icon Area
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        'Hesap Oluştur',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kombin dünyasına katıl',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Form
                      AnimatedBuilder(
                        animation: _formController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _formFadeAnimation,
                            child: SlideTransition(
                              position: _formSlideAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: 'Ad Soyad',
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                                        filled: true,
                                        fillColor: Color(0x1AFFFFFF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Color(0x33FFFFFF)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad soyad zorunlu' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: 'E-posta',
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                                        filled: true,
                                        fillColor: Color(0x1AFFFFFF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Color(0x33FFFFFF)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'E-posta zorunlu';
                                        if (!v.contains('@')) return 'Geçerli e-posta girin';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _userController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        labelText: 'Kullanıcı adı',
                                        labelStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                                        filled: true,
                                        fillColor: Color(0x1AFFFFFF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Color(0x33FFFFFF)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                          borderSide: BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı zorunlu' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passController,
                                      obscureText: _obscure,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Şifre',
                                        labelStyle: const TextStyle(color: Colors.white70),
                                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Şifre zorunlu' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmPassController,
                                      obscureText: _obscureConfirm,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Şifre Tekrar',
                                        labelStyle: const TextStyle(color: Colors.white70),
                                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Şifre tekrarı zorunlu' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Register Button
                      AnimatedBuilder(
                        animation: _formController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _formFadeAnimation,
                            child: SlideTransition(
                              position: _formSlideAnimation,
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Hesap Oluştur',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Back to Login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Zaten hesabın var mı? Giriş yap',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
