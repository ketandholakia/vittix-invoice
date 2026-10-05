import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'database/app_database.dart';
import 'core/utils/app_diagnostics.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/business/business_list_screen.dart';
import 'features/business/business_form_screen.dart';
import 'features/customers/customer_list_screen.dart';
import 'features/customers/customer_form_screen.dart';
import 'features/customers/customer_detail_screen.dart';
import 'features/products/product_list_screen.dart';
import 'features/products/product_form_screen.dart';
import 'features/hsn_lookup/hsn_rate_history_screen.dart';
import 'features/invoices/list/invoice_list_screen.dart';
import 'features/invoices/create/invoice_form.dart';
import 'features/invoices/detail/invoice_preview_screen.dart';
import 'features/quotes/list/quote_list_screen.dart';
import 'features/quotes/create/quote_form.dart';
import 'features/quotes/detail/quote_preview_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/reminders/reminder_center_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/document_numbering_screen.dart';
import 'features/settings/uom_management_screen.dart';
import 'features/settings/template_manager_screen.dart';
import 'features/settings/template_editor_screen.dart';
import 'features/shared/not_found_screen.dart';
import 'providers/shared_preferences_provider.dart';
import 'providers/app_lock_provider.dart';
import 'providers/reminder_provider.dart';
import 'features/lock/lock_screen.dart';
import 'services/reminder_notification_service.dart';

T? _extraOrNull<T>(GoRouterState state) {
  final extra = state.extra;
  return extra is T ? extra : null;
}

int? _idFrom(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');

final goRouterProvider = Provider<GoRouter>((ref) {
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  return GoRouter(
    initialLocation: activeBusinessId == null ? AppRoutes.onboarding : AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.businesses,
        builder: (context, state) => const BusinessListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addBusiness,
        builder: (context, state) => const BusinessFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editBusiness,
        builder: (context, state) {
          final business = _extraOrNull<Business>(state);
          if (business == null) return const NotFoundScreen();
          return BusinessFormScreen(existingBusiness: business);
        },
      ),
      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCustomer,
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editCustomer,
        builder: (context, state) {
          final customer = _extraOrNull<Customer>(state);
          if (customer == null) return const NotFoundScreen();
          return CustomerFormScreen(existingCustomer: customer);
        },
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        builder: (context, state) {
          final id = _idFrom(state);
          if (id == null) return const NotFoundScreen();
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProduct,
        builder: (context, state) {
          final product = _extraOrNull<Product>(state);
          if (product == null) return const NotFoundScreen();
          return ProductFormScreen(existingProduct: product);
        },
      ),
      GoRoute(
        path: AppRoutes.invoices,
        builder: (context, state) => const InvoiceListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createInvoice,
        builder: (context, state) => const InvoiceFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editInvoice,
        builder: (context, state) {
          final invoice = _extraOrNull<Invoice>(state);
          if (invoice == null) return const NotFoundScreen();
          return InvoiceFormScreen(existingInvoice: invoice);
        },
      ),
      GoRoute(
        path: AppRoutes.invoicePreview,
        builder: (context, state) {
          final id = _idFrom(state);
          if (id == null) return const NotFoundScreen();
          return InvoicePreviewScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.quotes,
        builder: (context, state) => const QuoteListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createQuote,
        builder: (context, state) => const QuoteFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editQuote,
        builder: (context, state) {
          final quote = _extraOrNull<Quote>(state);
          if (quote == null) return const NotFoundScreen();
          return QuoteFormScreen(existingQuote: quote);
        },
      ),
      GoRoute(
        path: AppRoutes.quotePreview,
        builder: (context, state) {
          final id = _idFrom(state);
          if (id == null) return const NotFoundScreen();
          return QuotePreviewScreen(quoteId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentNumbering,
        builder: (context, state) => const DocumentNumberingScreen(),
      ),
      GoRoute(
        path: AppRoutes.templateManager,
        builder: (context, state) => const TemplateManagerScreen(),
      ),
      GoRoute(
        path: AppRoutes.templateEditor,
        builder: (context, state) {
          final args = _extraOrNull<TemplateEditorArgs>(state);
          if (args == null) return const NotFoundScreen();
          return TemplateEditorScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.hsnRates,
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return HsnRateHistoryScreen(initialCode: code);
        },
      ),
      GoRoute(
        path: AppRoutes.uoms,
        builder: (context, state) => const UomManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        builder: (context, state) => const ReminderCenterScreen(),
      ),
    ],
    redirect: (context, state) {
      if (activeBusinessId == null &&
          state.uri.path != AppRoutes.onboarding &&
          state.uri.path != AppRoutes.addBusiness) {
        return AppRoutes.onboarding;
      }
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

class VittixInvoiceApp extends ConsumerStatefulWidget {
  const VittixInvoiceApp({super.key});

  @override
  ConsumerState<VittixInvoiceApp> createState() => _VittixInvoiceAppState();
}

class _VittixInvoiceAppState extends ConsumerState<VittixInvoiceApp>
    with WidgetsBindingObserver {
  // Reminder re-syncs fire on every invoices/quotes stream emission; the
  // debounce coalesces bursts and the signature skip turns no-op emissions
  // (any watched row change) into zero platform-channel work.
  Timer? _reminderSyncDebounce;
  String? _lastReminderSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _reminderSyncDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleReminderSync({
    required ReminderCenterData data,
    required List<int> offsets,
    required bool enabled,
  }) {
    _reminderSyncDebounce?.cancel();
    _reminderSyncDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(
        _syncReminders(data: data, offsets: offsets, enabled: enabled),
      );
    });
  }

  String _reminderSignature(
    ReminderCenterData data,
    bool enabled,
    List<int> offsets,
  ) {
    final buffer = StringBuffer('e:$enabled;o:${offsets.join(',')}');
    for (final item in data.invoiceReminders) {
      buffer.write(
        '|i:${item.invoice.id}:${item.invoice.dueDate?.millisecondsSinceEpoch}:'
        '${item.daysUntilDue}:${item.balanceDue.toStringAsFixed(2)}:'
        '${item.invoice.currencyCode}',
      );
    }
    for (final item in data.quoteReminders) {
      buffer.write(
        '|q:${item.quote.id}:${item.quote.dueDate?.millisecondsSinceEpoch}:'
        '${item.daysUntilExpiry}:${item.quote.totalAmount.toStringAsFixed(2)}:'
        '${item.quote.currencyCode}',
      );
    }
    return buffer.toString();
  }

  Future<void> _syncReminders({
    required ReminderCenterData data,
    required List<int> offsets,
    required bool enabled,
  }) async {
    final signature = _reminderSignature(data, enabled, offsets);
    if (signature == _lastReminderSignature) return;
    _lastReminderSignature = signature;
    try {
      await ReminderNotificationService.instance.syncReminders(
        data: data,
        offsets: offsets,
        enabled: enabled,
      );
    } catch (error, stackTrace) {
      // Allow a later emission to retry after a failed sync.
      _lastReminderSignature = null;
      // Swallow platform-channel failures; reminders remain disabled safely, but
      // the failure stays visible to diagnostics.
      reportNonFatal(error, stackTrace, context: 'while syncing reminders');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when the app leaves the foreground so financial data is not left
    // open behind the app switcher.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockedProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderDataAsync = ref.watch(reminderCenterProvider);
    final remindersEnabled = ref.watch(reminderNotificationsEnabledProvider);
    final reminderOffsets = ref.watch(reminderNotificationOffsetsProvider);
    final router = ref.watch(goRouterProvider);

    ref.listen(reminderCenterProvider, (previous, next) {
      next.whenData((data) {
        _scheduleReminderSync(
          data: data,
          offsets: ref.read(reminderNotificationOffsetsProvider),
          enabled: ref.read(reminderNotificationsEnabledProvider),
        );
      });
    });
    ref.listen(reminderNotificationsEnabledProvider, (previous, next) {
      reminderDataAsync.whenData((data) {
        _scheduleReminderSync(
          data: data,
          offsets: reminderOffsets,
          enabled: next,
        );
      });
    });
    ref.listen(reminderNotificationOffsetsProvider, (previous, next) {
      reminderDataAsync.whenData((data) {
        _scheduleReminderSync(
          data: data,
          offsets: next,
          enabled: remindersEnabled,
        );
      });
    });

    return MaterialApp.router(
      title: 'VittixInvoice',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        final locked = ref.watch(appLockedProvider);
        if (!locked) return child ?? const SizedBox.shrink();
        return Stack(
          children: [
            ?child,
            const LockScreen(),
          ],
        );
      },
    );
  }
}

/// Notification plugin failures (e.g., missing platform support) must never
/// break the app UI, so reminder sync runs defensively off the build path.
