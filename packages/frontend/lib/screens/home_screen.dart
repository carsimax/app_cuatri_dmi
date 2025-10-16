import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_message.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Text(
              'Hola, ${authProvider.user?.nombre ?? 'Usuario'}',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensaje de error
                if (authProvider.error != null) ...[
                  ErrorMessage.simple(
                    message: authProvider.error!,
                  ),
                  const SizedBox(height: 24),
                ],

                // Tarjeta de bienvenida
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user.initials,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Bienvenido!',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user.fullName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Información del perfil
                Text(
                  'Información del Perfil',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Datos del usuario
                _buildInfoCard(
                  context,
                  'Información Personal',
                  [
                    _buildInfoRow(context, 'Nombre', user.nombre),
                    _buildInfoRow(context, 'Apellido', user.apellido),
                    _buildInfoRow(context, 'Email', user.email),
                  ],
                  Icons.person_outline,
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  'Estado de la Cuenta',
                  [
                    _buildStatusRow(
                      context,
                      'Estado',
                      user.activo ? 'Activo' : 'Inactivo',
                      user.activo ? Icons.check_circle : Icons.cancel,
                      user.activo ? Colors.green : Colors.red,
                    ),
                    _buildStatusRow(
                      context,
                      'Email Verificado',
                      user.emailVerified ? 'Verificado' : 'No verificado',
                      user.emailVerified ? Icons.verified : Icons.verified_user_outlined,
                      user.emailVerified ? Colors.green : Colors.orange,
                    ),
                  ],
                  Icons.security,
                ),

                const SizedBox(height: 24),

                // Botones de acción
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton.secondary(
                        text: 'Actualizar Perfil',
                        onPressed: () => _showUpdateProfileDialog(context),
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton.secondary(
                        text: 'Cambiar Contraseña',
                        onPressed: () => _showChangePasswordDialog(context),
                        icon: const Icon(Icons.lock),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón de logout
                SizedBox(
                  width: double.infinity,
                  child: CustomOutlinedButton(
                    text: 'Cerrar Sesión',
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),

                const SizedBox(height: 32),

                // Información adicional
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
                            'Información de la Cuenta',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Fecha de Registro',
                        _formatDate(user.createdAt),
                      ),
                      _buildInfoRow(
                        context,
                        'Última Actualización',
                        _formatDate(user.updatedAt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context) {
    // TODO: Implementar diálogo de actualización de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de actualización de perfil próximamente')),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // TODO: Implementar diálogo de cambio de contraseña
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de cambio de contraseña próximamente')),
    );
  }
}
