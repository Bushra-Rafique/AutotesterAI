import 'package:flutter/material.dart';
import '../main.dart';
import '../models/auto_test_model.dart';
import '../models/test_history.dart';
import '../services/history_service.dart';
import '../widgets/result_tabs_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  List<TestHistory> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final h = await _service.loadHistory();
    if (mounted) setState(() { _history = h; _loading = false; });
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0E0E1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clear history',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will delete all saved test runs permanently.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.faint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.errorDim,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
    if (ok == true) {
      await _service.clearHistory();
      _load();
    }
  }

  Map<String, List<TestHistory>> _grouped() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<TestHistory>>{};
    for (final h in _history) {
      final d = DateTime(h.timestamp.year, h.timestamp.month, h.timestamp.day);
      final String key;
      if (d == today) {
        key = 'Today';
      } else if (d == yesterday) key = 'Yesterday';
      else key = '${d.day}/${d.month}/${d.year}';
      groups.putIfAbsent(key, () => []).add(h);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.6),
          radius: 1.0,
          colors: [Color(0xFF0F0828), AppColors.bg],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 1.5,
                      ),
                    )
                  : _history.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
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
          const Text(
            'HISTORY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          if (_history.isNotEmpty)
            GestureDetector(
              onTap: _clear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.errorDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No history yet',
        style: TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    );
  }

  Widget _buildList() {
    final groups = _grouped();
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      backgroundColor: const Color(0xFF0E0E1A),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8, top: 4),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.muted,
                ),
              ),
            ),
            for (final item in entry.value)
              _HistoryCard(
                item: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _DetailScreen(item: item),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TestHistory item;
  final VoidCallback onTap;

  const _HistoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ok = item.status == 'success';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 64,
              decoration: BoxDecoration(
                color: ok ? AppColors.success : AppColors.error,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (ok ? AppColors.success : AppColors.error)
                        .withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.url,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.userIntent,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _fmt(item.timestamp),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: ok ? AppColors.successDim : AppColors.errorDim,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (ok ? AppColors.success : AppColors.error)
                                  .withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            ok ? 'SUCCESS' : 'FAILED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: ok ? AppColors.success : AppColors.error,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.muted.withOpacity(0.4),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

class _DetailScreen extends StatelessWidget {
  final TestHistory item;
  const _DetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    final response = AutoTestResponse(
      status: item.status,
      thoughtStream: item.thoughtStream,
      logs: const [],
      code: item.code,
      screenshot: null,
    );
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'TEST DETAIL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ResultTabsWidget(response: response),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
