import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'database/app_database.dart';
import 'core/constants/app_routes.dart';
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
import 'providers/shared_preferences_provider.dart';
import 'providers/reminder_provider.dart';
import 'services/reminder_notification_service.dart';

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
          final business = state.extra! as Business;
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
          final customer = state.extra! as Customer;
          return CustomerFormScreen(existingCustomer: customer);
        },
      ),
      GoRoute(
        path: AppRoutes.customerDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
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
          final product = state.extra! as Product;
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
          final invoice = state.extra! as Invoice;
          return InvoiceFormScreen(existingInvoice: invoice);
        },
      ),
      GoRoute(
        path: AppRoutes.invoicePreview,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
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
          final quote = state.extra! as Quote;
          return QuoteFormScreen(existingQuote: quote);
        },
      ),
      GoRoute(
        path: AppRoutes.quotePreview,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
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
          final args = state.extra! as TemplateEditorArgs;
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
  );
});

class VittixInvoiceApp extends ConsumerWidget {
  const VittixInvoiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderDataAsync = ref.watch(reminderCenterProvider);
    final remindersEnabled = ref.watch(reminderNotificationsEnabledProvider);
    final reminderOffsets = ref.watch(reminderNotificationOffsetsProvider);
    final router = ref.watch(goRouterProvider);

    ref.listen(reminderCenterProvider, (previous, next) {
      next.whenData((data) {
        ReminderNotificationService.instance.syncReminders(
          data: data,
          offsets: ref.read(reminderNotificationOffsetsProvider),
          enabled: ref.read(reminderNotificationsEnabledProvider),
        );
      });
    });
    ref.listen(reminderNotificationsEnabledProvider, (previous, next) {
      reminderDataAsync.whenData((data) {
        ReminderNotificationService.instance.syncReminders(
          data: data,
          offsets: reminderOffsets,
          enabled: next,
        );
      });
    });
    ref.listen(reminderNotificationOffsetsProvider, (previous, next) {
      reminderDataAsync.whenData((data) {
        ReminderNotificationService.instance.syncReminders(
          data: data,
          offsets: next,
          enabled: remindersEnabled,
        );
      });
    });

    return MaterialApp.router(
      title: 'VittixInvoice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      routerConfig: router,
    );
  }
}
