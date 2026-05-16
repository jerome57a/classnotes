import 'dart:ui';


import '../../../core/app_export.dart';

class SubjectDropdownWidget extends StatelessWidget {
  final List<String> subjects;
  final String selectedSubject;
  final ValueChanged<String?> onChanged;

  const SubjectDropdownWidget({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppTheme.subjectColor(selectedSubject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'label',
                color: theme.colorScheme.outline,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Subject',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark.withAlpha(153),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSubject,
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  icon: CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    color: theme.colorScheme.outline,
                    size: 24,
                  ),
                  selectedItemBuilder: (context) => subjects
                      .map(
                        (s) => Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.subjectColor(s),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  items: subjects
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppTheme.subjectColor(s),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                s,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
