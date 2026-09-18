import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'responsive.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _foodRating = 5;
  int _serviceRating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Obrigado pelo feedback!'),
        content: const Text('Sua avaliação foi registrada e ajuda o Cardap.io a melhorar todos os dias.'),
        actions: [TextButton(onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); }, child: const Text('Concluir'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Avalie sua experiência', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ResponsivePhoneShell(
          child: Container(
            color: AppColors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 66, height: 66, decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.green, size: 34)),
                  const SizedBox(height: 16),
                  const Text('Pedido entregue!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Conte como foi sua experiência no Cardap.io.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 28),
                  _RatingCard(icon: Icons.restaurant_rounded, title: 'Qualidade da comida', subtitle: 'Sabor, frescor e apresentação', rating: _foodRating, onChanged: (value) => setState(() => _foodRating = value)),
                  const SizedBox(height: 12),
                  _RatingCard(icon: Icons.support_agent_rounded, title: 'Atendimento', subtitle: 'Agilidade e atenção da equipe', rating: _serviceRating, onChanged: (value) => setState(() => _serviceRating = value)),
                  const SizedBox(height: 18),
                  const Align(alignment: Alignment.centerLeft, child: Text('Quer deixar um comentário?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 10),
                  TextField(controller: _commentController, maxLines: 4, maxLength: 500, decoration: const InputDecoration(hintText: 'Conte o que você mais gostou ou sugira uma melhoria...')),
                  const SizedBox(height: 22),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.send_rounded), label: const Text('Enviar avaliação'))),
                  const SizedBox(height: 10),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Agora não')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.icon, required this.title, required this.subtitle, required this.rating, required this.onChanged});

  final IconData icon;
  final String title;
  final String subtitle;
  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.cream, child: Icon(icon, size: 19, color: AppColors.brownDark)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)), const SizedBox(height: 6), Row(children: List.generate(5, (index) => InkWell(onTap: () => onChanged(index + 1), child: Padding(padding: const EdgeInsets.only(right: 2), child: Icon(index < rating ? Icons.star_rounded : Icons.star_border_rounded, color: index < rating ? AppColors.amber : AppColors.border, size: 24)))))])),
        ],
      ),
    );
  }
}
