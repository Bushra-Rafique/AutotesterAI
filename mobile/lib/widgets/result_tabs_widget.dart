import 'package:flutter/material.dart';
import '../main.dart';
import '../models/auto_test_model.dart';
import 'thought_stream_widget.dart';
import 'code_viewer_widget.dart';
import 'screenshot_widget.dart';

class ResultTabsWidget extends StatefulWidget {
  final AutoTestResponse response;
  final bool isLoading;

  const ResultTabsWidget({
    super.key,
    required this.response,
    this.isLoading = false,
  });

  @override
  State<ResultTabsWidget> createState() => _ResultTabsWidgetState();
}

class _ResultTabsWidgetState extends State<ResultTabsWidget>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  static const _labels = ['ANALYSIS', 'CODE', 'SCREENSHOT'];

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0, // start fully visible
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _switchTab(int index) async {
    if (index == _tab) return;

    // Fade out
    await _ctrl.reverse();

    // Swap content
    if (mounted) setState(() => _tab = index);

    // Fade in
    if (mounted) _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        const SizedBox(height: 10),
        Expanded(
          child: FadeTransition(
            opacity: _fade,
            child: _panelFor(_tab),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.faint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.accentDim : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: active
                      ? Border.all(color: AppColors.accent.withOpacity(0.25))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: active
                        ? const Color(0xFFA78BFA)
                        : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _panelFor(int tab) {
    switch (tab) {
      case 0:
        return ThoughtStreamWidget(
          thoughts: widget.response.thoughtStream,
          isLoading: widget.isLoading,
        );
      case 1:
        return CodeViewerWidget(code: widget.response.code);
      case 2:
        return ScreenshotWidget(base64Image: widget.response.screenshot);
      default:
        return const SizedBox();
    }
  }
}