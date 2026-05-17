import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';

class CodeViewerWidget extends StatelessWidget {
  final String code;
  const CodeViewerWidget({super.key, required this.code});

  Future<void> _export(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/playwright_test.py');
      await file.writeAsString(code);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Playwright Test Script',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: const Color(0xFF1A1A2E),
          ),
        );
      }
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080B14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(child: _buildCode()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text(
            'PLAYWRIGHT SCRIPT',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          _HeaderBtn(
            label: 'COPY',
            onTap: () => _copy(context),
          ),
          const SizedBox(width: 8),
          _HeaderBtn(
            label: 'EXPORT .PY',
            accent: true,
            onTap: () => _export(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        code.isEmpty ? '# No code generated yet' : code,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
          color: Color(0xFF98C379),
          height: 1.7,
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final String label;
  final bool accent;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent ? AppColors.accentDim : AppColors.faint,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: accent
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: accent ? const Color(0xFFA78BFA) : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
