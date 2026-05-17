import '../../../core/app_export.dart';

class NoteInlineToolbarWidget extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final Color accentColor;

  const NoteInlineToolbarWidget({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section divider (Updated to dark color for visibility)
          Container(
            height: 1,
            color: Colors.black.withAlpha(15), 
            margin: const EdgeInsets.only(bottom: 20),
          ),
          Row(
            children: [
              // Large circle edit button (Changed to primary color)
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(51),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white, 
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Camera/attach icon button
              _ToolbarIconButton(
                iconName: 'attach_file',
                color: Colors.black54, 
                onTap: () {},
              ),
              const SizedBox(width: 10),
              // Delete icon button
              _ToolbarIconButton(
                iconName: 'delete_outline',
                color: AppTheme.error,
                backgroundColor: AppTheme.error.withAlpha(31),
                onTap: onDelete,
              ),
              const SizedBox(width: 10),
              // Share/list icon button
              _ToolbarIconButton(
                iconName: 'share',
                color: accentColor,
                backgroundColor: accentColor.withAlpha(31),
                onTap: onShare,
              ),
              const Spacer(),
              // Copy to clipboard
              _ToolbarIconButton(
                iconName: 'content_copy',
                color: Colors.black54, 
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87, 
            ),
          ),
          const SizedBox(height: 14),
          // Action chips row
          Row(
            children: [
              _ActionChip(
                label: 'Edit Note',
                iconName: 'edit',
                color: accentColor,
                onTap: onEdit,
              ),
              const SizedBox(width: 10),
              _ActionChip(
                label: 'Share',
                iconName: 'share',
                color: AppTheme.info,
                onTap: onShare,
              ),
              const SizedBox(width: 10),
              _ActionChip(
                label: 'Delete',
                iconName: 'delete_outline',
                color: AppTheme.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final String iconName;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.iconName,
    required this.color,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white, 
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withAlpha(15), width: 1), 
        ),
        child: Center(
          child: CustomIconWidget(iconName: iconName, color: color, size: 20),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final String iconName;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.iconName,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(77), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: iconName, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}