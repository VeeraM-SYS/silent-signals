import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/feedback_repository.dart';
import '../../../domain/models/signal_data.dart';
import '../../widgets/animated_background.dart';
import 'dart:math' as math;

class FacultyDashboard extends ConsumerWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalsAsync = ref.watch(signalsStreamProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dashboard_rounded, color: AppColors.accent, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Live Metrics',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                    ),
                    const Spacer(),
                    _PulseBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time classroom sentiment analysis',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: signalsAsync.when(
                    data: (signals) => _BentoGrid(signals: signals),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseBadge extends StatefulWidget {
  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(_opacity.value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.success, blurRadius: 8 * _opacity.value)
                  ]
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final SignalData signals;

  const _BentoGrid({required this.signals});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive Bento Grid
        // For simple mobile view, we stick to column mostly, but let's make it fancy.
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Top Row: Confusion (Critical)
              _SignalCard(
                label: 'Confused',
                count: signals.confusedCount,
                total: signals.totalCount,
                color: AppColors.danger,
                icon: Icons.help_outline_rounded,
                isLarge: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SignalCard(
                      label: 'Too Fast',
                      count: signals.tooFastCount,
                      total: signals.totalCount,
                      color: AppColors.warning,
                      icon: Icons.speed_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SignalCard(
                      label: 'Clear',
                      count: signals.clearCount,
                      total: signals.totalCount,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom: Heatline graph
              SizedBox(
                height: 250,
                child: _HeatlineGraph(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignalCard extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;
  final bool isLarge;

  const _SignalCard({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return GlassContainer(
      showGlow: isLarge && percentage > 0.3,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isLarge ? 28 : 24),
              ),
              if (percentage > 0.5)
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('DOMINANT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                 )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isLarge ? 48 : 32,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}% of class',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HeatlineGraph extends StatelessWidget {
  const _HeatlineGraph();

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final List<FlSpot> spots = [];
    final random = math.Random();
    double prev = 20;
    for (int i = 0; i < 20; i++) {
       prev = (prev + (random.nextDouble() - 0.5) * 10).clamp(0, 60);
       spots.add(FlSpot(i.toDouble(), prev));
    }

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confusion Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
           Text(
            'Last 10 minutes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 19,
                minY: 0,
                maxY: 70,
                lineTouchData: LineTouchData(
                   touchTooltipData: LineTouchTooltipData(
                   getTooltipColor: (touchedSpot) => AppColors.surface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                           return LineTooltipItem(
                              '${spot.y.toInt()}%',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                           );
                        }).toList();
                      }
                   )
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.danger,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.danger.withOpacity(0.3),
                          AppColors.danger.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
