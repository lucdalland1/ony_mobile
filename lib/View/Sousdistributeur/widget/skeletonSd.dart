import 'package:flutter/material.dart';

class SkeletonSdCard extends StatefulWidget {
  const SkeletonSdCard({super.key});

  @override
  State<SkeletonSdCard> createState() => _SkeletonSdCardState();
}

class _SkeletonSdCardState extends State<SkeletonSdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: List.generate(4, (index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0), // oscillation gauche-droite
                          child: child,
                        );
                      },
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth < 380 ? 16 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row principal
                                Row(
                                  children: [
                                    Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: screenWidth < 380 ? 48 : 56,
                                        height: screenWidth < 380 ? 48 : 56,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Material(
                                            elevation: 2,
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              height: 16,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Material(
                                            elevation: 2,
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              height: 12,
                                              width: screenWidth * 0.5,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 40,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Horaires et infos
                                Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    height: 12,
                                    width: screenWidth * 0.3,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    3,
                                    (i) => Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        width: screenWidth < 380 ? 60 : 80,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Boutons
                                Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: screenWidth < 380 ? 36 : 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: screenWidth < 380 ? 36 : 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
            },
          );
        }),
      ),
    );
  }
}
