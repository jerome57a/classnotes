import 'dart:ui';


import '../../../core/app_export.dart';
import '../../../data/models/note_model.dart';

class DetailAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final NoteModel note;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final Color accentColor;

  const DetailAppBarWidget({
    super.key,
    required this.note,
    required this.onBack,
    required this.onShare,
    required this.accentColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 60 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withAlpha(184),
            border: Border(
              bottom: BorderSide(color: Colors.white.withAlpha(18), width: 1),
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: onBack,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: theme.colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),
              ),
              // Title
              Expanded(
                child: Center(
                  child: Text(
                    'Note Detail',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              // Overlapping avatars + share
              Row(
                children: [
                  // Two overlapping small avatars (decorative collaborators)
                  SizedBox(
                    width: 52,
                    height: 28,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.backgroundDark,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: CustomImageWidget(
                                imageUrl:
                                    'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=60',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    'Student collaborator profile photo',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.backgroundDark,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: CustomImageWidget(
                                imageUrl:
                                    'https://images.pixabay.com/photo/2016/11/21/12/42/beard-1845166_640.jpg',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    'Second student collaborator profile photo',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'share',
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
