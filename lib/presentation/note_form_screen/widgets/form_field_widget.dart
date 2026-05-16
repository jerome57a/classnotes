import 'dart:ui';


import '../../../core/app_export.dart';

class FormFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconName;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;

  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconName,
    this.maxLines = 1,
    this.minLines,
    this.validator,
  });

  @override
  State<FormFieldWidget> createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late Animation<double> _focusAnim;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnim = CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOutCubic,
    );
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.manrope(
            fontSize: _isFocused ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: _isFocused
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            letterSpacing: 0.2,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: widget.iconName,
                  color: _isFocused
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(widget.label),
              ],
            ),
          ),
        ),
        // Glassmorphism field
        AnimatedBuilder(
          animation: _focusAnim,
          builder: (_, child) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariantDark.withOpacity(
                    _isFocused ? 0.85 : 0.6,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFocused
                        ? theme.colorScheme.primary.withAlpha(179)
                        : Colors.white.withAlpha(20),
                    width: _isFocused ? 1.5 : 1,
                  ),
                ),
                child: child,
              ),
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            validator: widget.validator,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.manrope(
                fontSize: 14,
                color: theme.colorScheme.outline.withAlpha(128),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorStyle: GoogleFonts.manrope(
                fontSize: 12,
                color: AppTheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
