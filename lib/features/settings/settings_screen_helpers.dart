part of 'settings_screen.dart';

// Dialogs and helpers shared by the settings screen sections.

/// user is warned and told a safety copy of the current data is taken first.
Future<bool> _confirmRestore(
  BuildContext context, {
  required String source,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Restore from backup?'),
      content: Text(
        'This replaces ALL current data with the contents of $source. '
        'A safety copy of your current data is saved first, but anything '
        'changed after that copy cannot be recovered.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Writes a pre-restore snapshot, swallowing failures so a failed safety copy
/// never blocks the restore the user asked for.
Future<String?> _safeSnapshot(AppDatabase database) async {
  try {
    return await DatabaseBackupService.createRestoreSafetySnapshot(database);
  } catch (error, stackTrace) {
    reportNonFatal(
      error,
      stackTrace,
      context: 'pre-restore safety snapshot',
    );
    return null;
  }
}

/// Prompts for a new app-lock PIN (4-8 digits). Returns null when cancelled.
Future<String?> _promptForNewPin(BuildContext context) async {
  final controller = TextEditingController();
  String? error;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Set an app lock PIN'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: InputDecoration(
            labelText: 'PIN (4-8 digits)',
            errorText: error,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final pin = controller.text.trim();
              if (pin.length < 4) {
                setState(() => error = 'Use at least 4 digits');
                return;
              }
              Navigator.pop(ctx, pin);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  controller.dispose();
  return result;
}

/// Prompts for a backup passphrase. Returns null when cancelled; an empty
/// string means "no encryption" for exports.
Future<String?> _promptForPassphrase(
  BuildContext context, {
  required String title,
  required String helpText,
  bool allowEmpty = false,
}) async {
  final controller = TextEditingController();
  String? error;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(helpText),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (!allowEmpty && value.isEmpty) {
                setState(() => error = 'Enter a passphrase');
                return;
              }
              Navigator.pop(ctx, value);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );

  controller.dispose();
  return result;
}

/// Runs a cloud restore, prompting for a passphrase when the backup turns out
/// to be encrypted.
Future<int?> _restoreCloudBackup(
  BuildContext context,
  Future<int?> Function(String? passphrase) restore,
) async {
  try {
    return await restore(null);
  } on BackupPassphraseRequired {
    if (!context.mounted) return null;
    final passphrase = await _promptForPassphrase(
      context,
      title: 'Backup passphrase',
      helpText: 'This backup is encrypted. Enter its passphrase to restore it.',
    );
    if (passphrase == null) {
      throw StateError('Restore cancelled');
    }
    return restore(passphrase);
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatusChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _friendlyTemplateName(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'MODERN':
      return 'Modern';
    case 'CLASSIC':
    default:
      return 'Classic';
  }
}

String _seriesExample(String? format, {required String fallback}) {
  final normalized = InvoiceNumberGenerator.normalizeFormat(
    format,
    fallback: fallback,
  );
  final example = InvoiceNumberGenerator.samplePreview(normalized, DateTime.now());
  return example.length > 18 ? '${example.substring(0, 18)}...' : example;
}
