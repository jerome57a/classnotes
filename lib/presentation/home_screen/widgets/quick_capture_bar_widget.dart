import 'dart:ui';


import '../../../core/app_export.dart';

class QuickCaptureBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const QuickCaptureBarWidget({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariantDark.withAlpha(153),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(20), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withAlpha(179),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Quick note…',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 14,
                        color: theme.colorScheme.outline,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(89),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
