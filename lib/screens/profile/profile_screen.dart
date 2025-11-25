import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon_finance/features/auth/services/auth_service.dart';
import 'package:horizon_finance/widgets/bottom_nav_menu.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Perfil',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 42,
              backgroundColor: primaryBlue,
              child: const Icon(Icons.person, size: 42, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Nome do Usuário',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 4),
            Text('usuario@email.com',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    )),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: Text('Editar Perfil',
                    style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  // TODO: Implementar edição de perfil
                },
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Configurações',
                    style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  // TODO: Navegar para configurações
                },
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text('Sair',
                    style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  try {
                    await ref.read(authServiceProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao sair: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavMenu(
        currentIndex: 4,
        primaryColor: primaryBlue,
      ),
    );
  }
}