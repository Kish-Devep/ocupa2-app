import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

/// Selector de imagen (cámara o galería). NO sube nada: devuelve los bytes.
/// La subida a POST /uploads la hace el controlador del feature.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onPicked,
    this.label = 'Foto',
    this.required = false,
    this.errorText,
    this.helperText = 'Toca para tomar una foto o elegir de la galería.',
  });

  final PickedPhoto? photo;
  final ValueChanged<PickedPhoto?> onPicked;
  final String label;
  final bool required;
  final String? errorText;
  final String helperText;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    onPicked(PickedPhoto(bytes: bytes, filename: file.name));
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: AppTypography.labelLg,
              children: [
                if (required)
                  const TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          InkWell(
            key: const Key('photo_picker_tap'),
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.outlineVariant,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: photo == null
                  ? Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined,
                              color: AppColors.onSecondaryContainer),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(helperText,
                            style: AppTypography.bodyMd, textAlign: TextAlign.center),
                        Text('JPG, PNG, WEBP o GIF · máx. 8 MB',
                            style: AppTypography.labelMd),
                      ],
                    )
                  : Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          child: Image.memory(
                            photo!.bytes,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                photo!.filename,
                                style: AppTypography.labelMd,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => onPicked(null),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Quitar'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.base, left: AppSpacing.sm),
              child: Text(
                errorText!,
                style: AppTypography.labelMd.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}
