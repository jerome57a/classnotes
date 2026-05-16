// lib/widgets/custom_image_widget.dart
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_export.dart';

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http://') || startsWith('https://')) {
      return ImageType.network;
    } else if (toLowerCase().endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://') || startsWith('/')) { // Fixed space issue and added direct absolute root check
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key, 
    this.imageUrl,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder = 'assets/images/no-image.jpg',
    this.errorWidget,
    this.semanticLabel,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String placeHolder;
  final Color? color;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Widget? errorWidget;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: _buildCircleImage(),
      ),
    );
  }

  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Image.asset(
        placeHolder,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        semanticLabel: semanticLabel,
      );
    }

    switch (imageUrl!.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imageUrl!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            semanticsLabel: semanticLabel,
          ),
        );
      case ImageType.file:
        final cleanPath = imageUrl!.replaceFirst('file://', '');
        return Image.file(
          File(cleanPath),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
        );
      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: imageUrl!,
          color: color,
          placeholder: (context, url) => SizedBox(
            height: height ?? 30,
            width: width ?? 30,
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildErrorFallback(),
        );
      case ImageType.png:
      default:
        return Image.asset(
          imageUrl!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
        );
    }
  }

  Widget _buildErrorFallback() {
    return errorWidget ?? Image.asset(
      placeHolder,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      semanticLabel: semanticLabel,
    );
  }
}