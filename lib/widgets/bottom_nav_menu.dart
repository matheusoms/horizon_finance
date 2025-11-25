import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavMenu extends StatelessWidget {
  final int currentIndex;
  final Color primaryColor;

  const BottomNavMenu({
    super.key,
    required this.currentIndex,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // 1. DASHBOARD
          IconButton(
            icon: Icon(
              Icons.dashboard,
              color: currentIndex == 0 ? primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (currentIndex != 0) {
                context.go('/dashboard');
              }
            },
          ),

          // 2. RELATÓRIOS
          IconButton(
            icon: Icon(
              Icons.list_alt,
              color: currentIndex == 1 ? primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (currentIndex != 1) {
                context.go('/reports');
              }
            },
          ),

<<<<<<< Updated upstream
          const SizedBox(width: 40), // Espaço para o FAB
=======
          // 3. BOTÃO DE AÇÃO (ADICIONAR TRANSAÇÃO)
          FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionFormScreen(
                    initialType: TransactionType.despesa,
                  ),
                ),
              );
              onTransactionAdded?.call();
            },
            backgroundColor: primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
>>>>>>> Stashed changes

          // 3. METAS
          IconButton(
            icon: Icon(
              Icons.track_changes,
              color: currentIndex == 3 ? primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (currentIndex != 3) {
                context.go('/goals');
              }
            },
          ),

          // 4. PERFIL
          IconButton(
            icon: Icon(
              Icons.person,
              color: currentIndex == 4 ? primaryColor : Colors.grey,
            ),
            onPressed: () {
              if (currentIndex != 4) {
                context.go('/profile');
              }
            },
          ),
        ],
      ),
    );
  }
}