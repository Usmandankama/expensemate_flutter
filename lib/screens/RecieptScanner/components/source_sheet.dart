import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'scan_colors.dart';
import 'package:expense_mate_flutter/controllers/theme_controller.dart';

// ─── Image Source Bottom Sheet ────────────────────────────────────────────────
class SourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const SourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: ScanColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ScanColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "Import Receipt",
            style: TextStyle(
              color: ScanColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Choose your image source",
            style: TextStyle(color: ThemeController.to.isDarkMode ? 
              ThemeController.to.darkTheme.colorScheme.onSurfaceVariant : 
              ThemeController.to.lightTheme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SheetOption(
            icon: Icons.camera_alt_rounded,
            iconColor: ThemeController.to.isDarkMode ? 
              ThemeController.to.darkTheme.colorScheme.primary : 
              ThemeController.to.lightTheme.colorScheme.primary,
            iconBg: ThemeController.to.isDarkMode ? 
              ThemeController.to.darkTheme.colorScheme.primary.withOpacity(0.12) : 
              ThemeController.to.lightTheme.colorScheme.primary.withOpacity(0.12),
            title: "Take a Photo",
            subtitle: "Use your camera to capture a receipt",
            onTap: onCamera,
          ),
          const SizedBox(height: 12),
          SheetOption(
            icon: Icons.photo_library_rounded,
            iconColor: Theme.of(context).colorScheme.secondary,
            iconBg: Theme.of(context).colorScheme.secondaryContainer,
            title: "Choose from Gallery",
            subtitle: "Pick an existing photo from your library",
            onTap: onGallery,
          ),
        ],
      ),
    );
  }
}

class SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SheetOption({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ScanColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ScanColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ScanColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:  TextStyle(
                      color: ScanColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: ScanColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
