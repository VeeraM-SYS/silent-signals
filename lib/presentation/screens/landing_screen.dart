import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/feedback_repository.dart';
import '../widgets/animated_background.dart';
import 'dashboard/faculty_dashboard.dart';
import 'student/student_screen.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final _sessionController = TextEditingController();
  bool _isSessionValid = false;

  @override
  void initState() {
    super.initState();
    _sessionController.addListener(() {
      setState(() {
        _isSessionValid = _sessionController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  void _enterSession(Widget destination) {
    if (_sessionController.text.trim().isEmpty) {
       // Auto-generate if empty for Faculty? For now ensure non-empty.
       if (destination is FacultyDashboard) {
          _sessionController.text = 'class_${DateTime.now().millisecondsSinceEpoch % 1000}';
       } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a Session ID to join')),
          );
          return;
       }
    }

    // Update global session ID
    ref.read(currentSessionIdProvider.notifier).state = _sessionController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _RoleWrapper(child: destination)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.hub_rounded, size: 80, color: AppColors.accent),
                  const SizedBox(height: 20),
                  Text(
                    'Silent Signals',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect & Communicate Instantly',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Session Input
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _sessionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Session ID (e.g. math101)',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                        border: InputBorder.none,
                        icon: const Icon(Icons.tag_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Role Buttons
                  _HeroRoleButton(
                    label: 'Join as Student',
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    onTap: () => _enterSession(const StudentScreen()),
                  ),
                  const SizedBox(height: 16),
                  _HeroRoleButton(
                    label: 'Open Faculty Dashboard',
                    icon: Icons.dashboard_rounded,
                    color: AppColors.secondary,
                    onTap: () => _enterSession(const FacultyDashboard()),
                  ),
                  
                  const SizedBox(height: 24),
                   Text(
                    'Note: If Firebase is not configured, this will check for configuration but proceed in manual mode if needed.',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4), fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroRoleButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeroRoleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HeroRoleButton> createState() => _HeroRoleButtonState();
}

class _HeroRoleButtonState extends State<_HeroRoleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
         _controller.reverse();
         widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.8),
                widget.color.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wrapper to add a persistent "Switch Role" button overlay
class _RoleWrapper extends StatelessWidget {
  final Widget child;

  const _RoleWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 40,
          left: 16,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24)
                   ),
                   child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
