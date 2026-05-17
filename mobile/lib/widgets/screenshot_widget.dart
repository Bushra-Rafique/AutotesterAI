import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';

class ScreenshotWidget extends StatelessWidget {
  final String? base64Image;
  const ScreenshotWidget({super.key, this.base64Image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: base64Image == null || base64Image!.isEmpty
          ? const Center(
              child: Text(
                'No screenshot',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      const Text(
                        'PAGE SCREENSHOT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: AppColors.muted,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'pinch to zoom',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5.0,
                      child: Image.memory(
                        base64Decode(base64Image!),
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
