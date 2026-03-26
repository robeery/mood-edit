import 'package:flutter/material.dart';
import '../../../model/export_settings.dart';
import '../../../theme/app_theme.dart';

Future<ExportSettings?> showExportSettingsDialog(
  BuildContext context,
  ExportSettings current,
) {
  return showDialog<ExportSettings>(
    context: context,
    builder: (ctx) => _ExportSettingsDialog(settings: current),
  );
}

class _ExportSettingsDialog extends StatefulWidget {
  final ExportSettings settings;
  const _ExportSettingsDialog({required this.settings});

  @override
  State<_ExportSettingsDialog> createState() => _ExportSettingsDialogState();
}

class _ExportSettingsDialogState extends State<_ExportSettingsDialog> {
  late ImageFormat _format;
  late int _quality;

  @override
  void initState() {
    super.initState();
    _format = widget.settings.format;
    _quality = widget.settings.quality;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: const Text('EXPORT SETTINGS', style: AppTextStyles.screenTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FORMAT',
            style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Row(
            children: ImageFormat.values.map((f) {
              final selected = f == _format;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _format = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.highlight : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: selected ? AppColors.highlight : AppColors.muted,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      f.label,
                      style: TextStyle(
                        color: selected ? AppColors.bg : AppColors.accent,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_format != ImageFormat.png) ...[
            const SizedBox(height: 20),
            Text(
              'QUALITY  $_quality%',
              style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.highlight,
                inactiveTrackColor: AppColors.muted,
                thumbColor: AppColors.highlight,
                overlayColor: AppColors.highlight.withValues(alpha: 0.1),
                trackHeight: 2,
              ),
              child: Slider(
                value: _quality.toDouble(),
                min: 10,
                max: 100,
                divisions: 9,
                onChanged: (v) => setState(() => _quality = v.round()),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 2),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            ExportSettings(format: _format, quality: _quality),
          ),
          child: const Text(
            'SAVE',
            style: TextStyle(color: AppColors.highlight, fontSize: 11, letterSpacing: 2),
          ),
        ),
      ],
    );
  }
}
