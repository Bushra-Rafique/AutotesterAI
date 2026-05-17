import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../main.dart';
import '../models/auto_test_model.dart';
import '../models/test_history.dart';
import '../services/auto_tester_service.dart';
import '../services/history_service.dart';
import '../widgets/result_tabs_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlCtrl = TextEditingController(text: 'https://google.com');
  final _intentCtrl = TextEditingController(text: 'Search for AI Seekho 2026');

  late final _service = AutoTesterService(
    baseUrl: dotenv.get('APP_URL', fallback: 'http://10.0.2.2:8000'),
  );
  final _history = HistoryService();

  bool _loading = false;
  AutoTestResponse? _response;

  Future<void> _run() async {
    setState(() { _loading = true; _response = null; });
    try {
      final r = await _service.generateTest(
        url: _urlCtrl.text.trim(),
        userIntent: _intentCtrl.text.trim(),
      );
      await _history.saveEntry(TestHistory.fromResponse(
        url: _urlCtrl.text.trim(),
        userIntent: _intentCtrl.text.trim(),
        response: r,
      ));
      if (mounted) setState(() => _response = r);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.error, width: 0.5),
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _intentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.8, -0.8),
          radius: 1.0,
          colors: [Color(0xFF12082A), AppColors.bg],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _GlassField(
                      controller: _urlCtrl,
                      label: 'TARGET URL',
                      hint: 'https://example.com',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 10),
                    _GlassField(
                      controller: _intentCtrl,
                      label: 'USER INTENT',
                      hint: 'Describe what to test...',
                      icon: Icons.track_changes_rounded,
                    ),
                    const SizedBox(height: 16),
                    _RunButton(loading: _loading, onTap: _loading ? null : _run),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _response != null
                          ? ResultTabsWidget(
                        response: _response!,
                        isLoading: _loading,
                      )
                          : _IdleState(loading: _loading),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2),
              children: [
                TextSpan(text: 'AUTO', style: TextStyle(color: AppColors.white)),
                TextSpan(text: 'TESTER', style: TextStyle(color: AppColors.accent)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.25)),
            ),
            child: const Text(
              'AI v2',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.accent.withOpacity(0.5) : AppColors.glassBorder,
          width: _focused ? 1.2 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.accent.withOpacity(0.12), blurRadius: 16)]
            : [],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _focused ? AppColors.accentDim : AppColors.faint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _focused
                    ? AppColors.accent.withOpacity(0.3)
                    : AppColors.glassBorder,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: _focused ? const Color(0xFFA78BFA) : AppColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: _focused ? const Color(0xFFA78BFA) : AppColors.muted,
                  ),
                  child: Text(widget.label),
                ),
                const SizedBox(height: 3),
                Focus(
                  onFocusChange: (f) => setState(() => _focused = f),
                  child: TextField(
                    controller: widget.controller,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _RunButton({required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: loading
              ? null
              : const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: loading ? AppColors.faint : null,
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: loading
              ? []
              : [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.accent,
          ),
        )
            : const Text(
          'INITIATE ENGINE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  final bool loading;
  const _IdleState({required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: loading
            ? const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
            SizedBox(height: 16),
            Text(
              'Agent is working...',
              style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 0.5),
            ),
          ],
        )
            : const Text(
          'System idle',
          style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1),
        ),
      ),
    );
  }
}