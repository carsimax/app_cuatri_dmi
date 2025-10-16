import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_message.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nombreFocusNode = FocusNode();
  final _apellidoFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _nombreFocusNode.dispose();
    _apellidoFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Título
              Center(
                child: Column(
                  children: [
                    Text(
                      'Crear Cuenta',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos para registrarte',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Formulario de registro
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de nombre
                    CustomTextField(
                      label: 'Nombre',
                      hint: 'Ingresa tu nombre',
                      controller: _nombreController,
                      focusNode: _nombreFocusNode,
                      textInputAction: TextInputAction.next,
                      validator: Validators.firstName,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSubmitted: (_) => _apellidoFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    // Campo de apellido
                    CustomTextField(
                      label: 'Apellido',
                      hint: 'Ingresa tu apellido',
                      controller: _apellidoController,
                      focusNode: _apellidoFocusNode,
                      textInputAction: TextInputAction.next,
                      validator: Validators.lastName,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    // Campo de email
                    CustomTextField(
                      label: 'Email',
                      hint: 'Ingresa tu email',
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    // Campo de contraseña
                    CustomTextField(
                      label: 'Contraseña',
                      hint: 'Crea una contraseña segura',
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                    ),

                    const SizedBox(height: 20),

                    // Campo de confirmar contraseña
                    CustomTextField(
                      label: 'Confirmar Contraseña',
                      hint: 'Confirma tu contraseña',
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSubmitted: (_) => _handleRegister(),
                    ),

                    const SizedBox(height: 32),

                    // Mensaje de error
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.error != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ErrorMessage.simple(
                              message: authProvider.error!,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Botón de registro
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: 'Crear Cuenta',
                          onPressed: _handleRegister,
                          isLoading: authProvider.isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Información sobre contraseñas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Requisitos de contraseña:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Al menos 6 caracteres\n• Debe contener al menos una letra\n• Debe contener al menos un número',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
