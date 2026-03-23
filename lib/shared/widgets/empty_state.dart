import 'package:flutter/material.dart';
import 'package:notezen/core/constants/app_constants.dart';
import 'package:notezen/core/themes/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spaceXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon Container ───────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: isDark ? 0.1 : 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.primary.withValues(alpha: 0.4)),
            ),

            SizedBox(height: AppConstants.spaceXL),

            // ── Title ────────────────────────────
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppConstants.spaceSM),

            // ── Subtitle ─────────────────────────
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : AppTheme.textHint, height: 1.5),
              textAlign: TextAlign.center,
            ),

            // ── Optional Action Button ────────────
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppConstants.spaceXL),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spaceXL, vertical: AppConstants.spaceMD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusChip)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
