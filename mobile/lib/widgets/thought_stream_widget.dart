import 'package:flutter/material.dart';
import '../main.dart';
import '../models/auto_test_model.dart';

class ThoughtStreamWidget extends StatelessWidget {
  final List<ThoughtStep> thoughts;
  final bool isLoading;

  const ThoughtStreamWidget({
    super.key,
    required this.thoughts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: thoughts.length,
              itemBuilder: (_, i) => _StepTile(
                step: thoughts[i],
                isLast: i == thoughts.length - 1,
                index: i,
                total: thoughts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          const Text(
            'THOUGHT STREAM',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          if (isLoading)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final ThoughtStep step;
  final bool isLast;
  final int index;
  final int total;

  const _StepTile({
    required this.step,
    required this.isLast,
    required this.index,
    required this.total,
  });

  bool get _isDone => index < total - 1 || !isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        const SizedBox(height: 3),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isDone ? AppColors.success : AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: (_isDone ? AppColors.success : AppColors.accent)
                    .withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 3),
              color: AppColors.faint,
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.thought,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              fontFamily: 'Courier',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.faint,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: _isDone ? AppColors.success : AppColors.accent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              step.action,
              style: TextStyle(
                fontSize: 11,
                color: _isDone
                    ? AppColors.success.withOpacity(0.9)
                    : AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
