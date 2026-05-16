
import '../../../core/app_export.dart';

class ColorPickerWidget extends StatelessWidget {
  final List<String> colorOptions;
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.colorOptions,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'palette',
                color: theme.colorScheme.outline,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Accent Color',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.outline,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: colorOptions.map((hex) {
            Color color;
            try {
              color = Color(
                int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
              );
            } catch (_) {
              color = AppTheme.primary;
            }
            final isSelected = hex == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(hex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 12),
                width: isSelected ? 38 : 32,
                height: isSelected ? 38 : 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(128),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
