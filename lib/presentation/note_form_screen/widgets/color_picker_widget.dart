import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CustomIconWidget(iconName: 'palette', color: Colors.black54, size: 16),
            const SizedBox(width: 8),
            Text(
              'Theme Color',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colorOptions.map((hex) {
            final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
            final isSelected = hex == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(hex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.black87, width: 2) : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withAlpha(102), blurRadius: 8, offset: const Offset(0, 4))]
                      : null,
                ),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}