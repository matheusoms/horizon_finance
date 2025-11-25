import 'package:flutter/material.dart';
import 'package:horizon_finance/widgets/bottom_nav_menu.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Theme.of(context).primaryColor;
    const Color secondaryGreen = Color(0xFF2E7D32); // Usando o verde secundário

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Minhas Metas',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Mantém o FAB e posiciona-o centralizado (mesma aparência do dashboard)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Adiciona o menu de navegação compartilhado
      bottomNavigationBar: BottomNavMenu(
<<<<<<< Updated upstream
        currentIndex: 2, // 2 = índice da tela de metas (ajuste se necessário)
=======
        currentIndex: 3,
>>>>>>> Stashed changes
        primaryColor: primaryBlue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGoalCard(
              name: 'Reserva de Emergência',
              currentAmount: 6500.00,
              targetAmount: 10000.00,
              primaryColor: primaryBlue,
              accentColor: secondaryGreen,
            ),
            _buildGoalCard(
              name: 'Viagem Europa 2026',
              currentAmount: 1200.00,
              targetAmount: 15000.00,
              primaryColor: primaryBlue,
              accentColor: primaryBlue.withOpacity(0.7),
            ),
            _buildGoalCard(
              name: 'Troca de Carro',
              currentAmount: 25000.00,
              targetAmount: 40000.00,
              primaryColor: primaryBlue,
              accentColor: primaryBlue.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String name,
    required double currentAmount,
    required double targetAmount,
    required Color primaryColor,
    required Color accentColor,
  }) {
    final double progress = currentAmount / targetAmount;
    final String progressPercent = (progress * 100).toStringAsFixed(1);

    return Card(
      elevation: 3, // Sombra suave para o clean look
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${currentAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242)),
                ),
                Text(
                  'Meta: R\$ ${targetAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: accentColor, // Usa a cor de destaque (verde ou azul)
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$progressPercent% concluído',
                  style: TextStyle(fontSize: 12, color: primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}