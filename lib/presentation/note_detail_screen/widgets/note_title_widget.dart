
import '../../../core/app_export.dart';
import '../../../data/models/note_model.dart';

class NoteTitleWidget extends StatelessWidget {
  final NoteModel note;
  final Color accentColor;

  const NoteTitleWidget({
    super.key,
    required this.note,
    required this.accentColor,
  });

  String _formatFullDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject badge
          StatusBadgeWidget(
            label: note.subject,
            color: accentColor,
            fontSize: 12,
          ),
          const SizedBox(height: 16),
          // Large display title — anatomy locked from Image 1 Screen 1.2
          // Very large bold text spanning multiple lines, with avatar overlaid
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                note.title,
                style: GoogleFonts.manrope(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              // Author avatar overlaid at mid-text position
              Positioned(
                bottom: -8,
                right: 0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withAlpha(153),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(77),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl:
                          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=100',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      semanticLabel: 'Note author profile photo',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Date + word count row
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar',
                color: theme.colorScheme.outline,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _formatFullDate(note.updatedAt),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notes',
                color: theme.colorScheme.outline,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${note.content.split(' ').where((w) => w.isNotEmpty).length} words  •  ${note.content.split('\n').where((l) => l.isNotEmpty).length} lines',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withAlpha(102), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
