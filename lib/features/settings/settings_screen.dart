import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/invoice_number.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/reminder_notification_service.dart';
import '../../services/database_backup_service.dart';
import '../../services/google_drive_service.dart';
import '../../providers/database_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/google_drive_provider.dart';
import '../../providers/nextcloud_provider.dart';
import '../../services/nextcloud_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGstEnabled = ref.watch(isGstEnabledProvider);
    final remindersEnabled = ref.watch(reminderNotificationsEnabledProvider);
    final reminderOffsets = ref.watch(reminderNotificationOffsetsProvider);
    final lowStockWarningsEnabled = ref.watch(lowStockWarningsEnabledProvider);
    final printBankDetailsOnInvoice = ref.watch(
      printBankDetailsOnInvoiceProvider,
    );
    final database = ref.watch(databaseProvider);
    final activeBusinessAsync = ref.watch(activeBusinessProvider);
    final googleDriveAccountAsync = ref.watch(googleDriveAccountProvider);
    final nextcloudConfig = ref.watch(nextcloudConfigProvider);
    const options = [-7, -3, -1, 0, 1, 3];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable GST Features'),
            subtitle: const Text(
              'Turn on to use GSTIN, HSN codes, and automatic tax calculations.',
            ),
            value: isGstEnabled,
            onChanged: (value) {
              ref.read(isGstEnabledProvider.notifier).setGstEnabled(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Device Notifications'),
            subtitle: const Text(
              'Schedule reminders on the device for due invoices and expiring quotes.',
            ),
            value: remindersEnabled,
            onChanged: (value) {
              ref
                  .read(reminderNotificationsEnabledProvider.notifier)
                  .setEnabled(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Low Stock Warnings'),
            subtitle: const Text(
              'Show a warning when a selected product has zero stock, but still allow saving.',
            ),
            value: lowStockWarningsEnabled,
            onChanged: (value) {
              ref
                  .read(lowStockWarningsEnabledProvider.notifier)
                  .setEnabled(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Print Bank Details on Invoice'),
            subtitle: const Text(
              'Include the business bank account block in invoice PDFs.',
            ),
            value: printBankDetailsOnInvoice,
            onChanged: (value) {
              ref
                  .read(printBankDetailsOnInvoiceProvider.notifier)
                  .setEnabled(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Reminder Cadence',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final offset in options)
                  FilterChip(
                    label: Text(_labelForOffset(offset)),
                    selected: reminderOffsets.contains(offset),
                    onSelected: remindersEnabled
                        ? (selected) {
                            final next = [...reminderOffsets];
                            if (selected) {
                              next.add(offset);
                            } else {
                              next.remove(offset);
                            }
                            ref
                                .read(
                                  reminderNotificationOffsetsProvider.notifier,
                                )
                                .setOffsets(next);
                          }
                        : null,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: OutlinedButton.icon(
              onPressed: remindersEnabled
                  ? () async {
                      await ReminderNotificationService.instance.initialize();
                    }
                  : null,
              icon: const Icon(Icons.sync),
              label: const Text('Initialize Notifications'),
            ),
          ),
          const Divider(height: 32),
          activeBusinessAsync.when(
            data: (business) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Documents',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Templates and numbering for invoices and quotes.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusChip(
                              label: 'Invoice Template',
                              value: _friendlyTemplateName(
                                business?.invoiceTemplate,
                              ),
                            ),
                            _StatusChip(
                              label: 'Quote Template',
                              value: _friendlyTemplateName(
                                business?.quoteTemplate,
                              ),
                            ),
                            _StatusChip(
                              label: 'Invoice Series',
                              value: _seriesExample(
                                business?.invoiceSeriesFormat,
                                fallback: InvoiceNumberGenerator
                                    .defaultInvoiceFormat,
                              ),
                            ),
                            _StatusChip(
                              label: 'Quote Series',
                              value: _seriesExample(
                                business?.quoteSeriesFormat,
                                fallback: InvoiceNumberGenerator
                                    .defaultQuoteFormat,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/template-manager'),
                                icon: const Icon(Icons.dashboard_customize_outlined),
                                label: const Text('Templates'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/document-numbering'),
                                icon: const Icon(Icons.pin_outlined),
                                label: const Text('Numbering'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Failed to load document status: $err'),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Google Drive',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          googleDriveAccountAsync.when(
            data: (account) {
              final signedInEmail = account?.email;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (signedInEmail != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Signed in as $signedInEmail'),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sign in to upload backups and share files from Drive.',
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              try {
                                if (signedInEmail == null) {
                                  await GoogleDriveService.instance.signIn();
                                } else {
                                  await GoogleDriveService.instance.signOut();
                                }
                                ref.invalidate(googleDriveAccountProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        signedInEmail == null
                                            ? 'Google Drive connected'
                                            : 'Google Drive disconnected',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Google Drive sign-in failed: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              signedInEmail == null
                                  ? Icons.login
                                  : Icons.logout,
                            ),
                            label: Text(
                              signedInEmail == null
                                  ? 'Connect Google'
                                  : 'Disconnect',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: signedInEmail == null
                                ? null
                                : () async {
                                    try {
                                      final result = await GoogleDriveService
                                          .instance
                                          .uploadBackup(database);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Backup uploaded to Drive: ${result.fileName}',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to upload backup: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Upload Backup'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: signedInEmail == null
                                ? null
                                : () async {
                                    try {
                                      final restoredActiveId =
                                          await GoogleDriveService.instance
                                              .restoreLatestBackup(database);
                                      ref.invalidate(businessListProvider);
                                      ref.invalidate(activeBusinessProvider);
                                      if (restoredActiveId != null) {
                                        ref
                                            .read(
                                              activeBusinessIdProvider.notifier,
                                            )
                                            .setActiveBusinessId(
                                              restoredActiveId,
                                            );
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Restored cloud backup',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to restore cloud backup: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.cloud_download_outlined),
                            label: const Text('Restore Backup'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Google Drive unavailable: $err'),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Nextcloud Sync',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Configure Nextcloud WebDAV credentials for backups.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: nextcloudConfig.serverUrl,
                  decoration: const InputDecoration(
                    labelText: 'Server URL (e.g., https://cloud.example.com)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(nextcloudConfigProvider.notifier).updateConfig(
                          nextcloudConfig.copyWith(serverUrl: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: nextcloudConfig.username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(nextcloudConfigProvider.notifier).updateConfig(
                          nextcloudConfig.copyWith(username: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: nextcloudConfig.password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'App Password',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(nextcloudConfigProvider.notifier).updateConfig(
                          nextcloudConfig.copyWith(password: value),
                        );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: !nextcloudConfig.isValid
                            ? null
                            : () async {
                                try {
                                  final result = await NextcloudService.instance
                                      .uploadBackup(database, nextcloudConfig);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Backup uploaded to Nextcloud: ${result.fileName}',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to upload to Nextcloud: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Upload Backup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: !nextcloudConfig.isValid
                            ? null
                            : () async {
                                try {
                                  final restoredActiveId =
                                      await NextcloudService.instance
                                          .restoreLatestBackup(database, nextcloudConfig);
                                  ref.invalidate(businessListProvider);
                                  ref.invalidate(activeBusinessProvider);
                                  if (restoredActiveId != null) {
                                    ref
                                        .read(activeBusinessIdProvider.notifier)
                                        .setActiveBusinessId(restoredActiveId);
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Restored Nextcloud backup'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to restore Nextcloud backup: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.cloud_download_outlined),
                        label: const Text('Restore Backup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          activeBusinessAsync.when(
            data: (business) {
              if (business == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Select a business to configure templates.'),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: business.invoiceTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Template',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CLASSIC',
                          child: Text('Classic'),
                        ),
                        DropdownMenuItem(
                          value: 'MODERN',
                          child: Text('Modern'),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;
                        await ref
                            .read(businessProvider)
                            .updateBusiness(
                              business.copyWith(invoiceTemplate: value),
                            );
                        ref.invalidate(activeBusinessProvider);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: business.quoteTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Quote Template',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CLASSIC',
                          child: Text('Classic'),
                        ),
                        DropdownMenuItem(
                          value: 'MODERN',
                          child: Text('Modern'),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;
                        await ref
                            .read(businessProvider)
                            .updateBusiness(
                              business.copyWith(quoteTemplate: value),
                            );
                        ref.invalidate(activeBusinessProvider);
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Failed to load active business: $err'),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Database Backup',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SwitchListTile(
            title: const Text('Auto Backup to Drive'),
            subtitle: const Text(
              'Automatically backup your database to Google Drive in the background.',
            ),
            value: ref.watch(autoBackupEnabledProvider),
            onChanged: (value) async {
              final account = await ref.read(googleDriveAccountProvider.future);
              if (value && account == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please connect Google Drive first.'),
                    ),
                  );
                }
                return;
              }
              ref.read(autoBackupEnabledProvider.notifier).setEnabled(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await DatabaseBackupService.shareBackup(database);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Backup exported')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to export backup: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.backup),
                    label: const Text('Export Backup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final file = await openFile(
                          acceptedTypeGroups: const [
                            XTypeGroup(label: 'JSON', extensions: ['json']),
                          ],
                        );
                        final path = file?.path;
                        if (path == null || path.isEmpty) return;

                        final restoredActiveId =
                            await DatabaseBackupService.restoreFromFile(
                              database,
                              path,
                            );
                        ref.invalidate(businessListProvider);
                        ref.invalidate(activeBusinessProvider);
                        if (restoredActiveId != null) {
                          ref
                              .read(activeBusinessIdProvider.notifier)
                              .setActiveBusinessId(restoredActiveId);
                        } else {
                          ref
                              .read(activeBusinessIdProvider.notifier)
                              .clearActiveBusiness();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Backup restored')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to restore backup: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore Backup'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Units of Measure',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => context.push('/uoms'),
              icon: const Icon(Icons.straighten),
              label: const Text('Manage Units'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _labelForOffset(int offset) {
    if (offset == 0) return 'Due date';
    final abs = offset.abs();
    return offset < 0 ? '$abs d before' : '$abs d after';
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
