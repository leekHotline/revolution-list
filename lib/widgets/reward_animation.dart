import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class RewardAnimation extends StatefulWidget {
  final String type;
  final VoidCallback onComplete;

  const RewardAnimation({
    super.key,
    required this.type,
    required this.onComplete,
  });

  @override
  State<RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<RewardAnimation> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
    Future.delayed(const Duration(seconds: 3), widget.onComplete);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.type == 'complete';
    
    return Stack(
      children: [
        // Overlay
        Container(color: Colors.black54),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            colors: const [
              AppColors.primary,
              AppColors.secondary,
              AppColors.success,
              AppColors.warning,
              Color(0xFF06B6D4),
            ],
          ),
        ),
        
        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isComplete
                        ? [AppColors.success, const Color(0xFF059669)]
                        : [AppColors.primary, AppColors.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isComplete ? AppColors.success : AppColors.primary)
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(duration: 1.seconds),
              const SizedBox(height: 24),
              Text(
                isComplete ? '🎉 任务完成！' : '✨ 新任务创建！',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              Text(
                isComplete ? '继续保持，你做得很棒！' : '专注执行，完成它！',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ],
    );
  }
}