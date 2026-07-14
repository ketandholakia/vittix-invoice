import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/invoice_balance.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'invoice_provider.dart';
import 'quote_provider.dart';
import 'shared_preferences_provider.dart';

final reminderCenterProvider = FutureProvider<ReminderCenterData>((ref) async {
  final businessId = ref.watch(activeBusinessIdProvider);
  if (businessId == null) return const ReminderCenterData();

  final business = await ref
      .watch(businessDaoProvider)
      .getBusinessById(businessId);
  if (business == null) return const ReminderCenterData();

  final customers = await ref
      .watch(customerDaoProvider)
      .getCustomersForBusiness(businessId);
  final customerById = {
    for (final customer in customers) customer.id: customer,
  };
  final invoices = await ref
      .watch(invoiceDaoProvider)
      .getInvoicesForBusiness(businessId);
  final quotes = await ref
      .watch(quoteDaoProvider)
      .getQuotesForBusiness(businessId);
  final today = _dateOnly(DateTime.now());

  final invoiceReminders =
      invoices
          .where((invoice) {
            final balance = invoiceBalanceDue(invoice);
            if (balance <= 0 || invoice.status == 'CANCELLED') return false;
            final dueDate = invoice.dueDate;
            if (dueDate == null) return false;
            return _dateOnly(dueDate).difference(today).inDays <= 7;
          })
          .map((invoice) {
            final dueDate = _dateOnly(invoice.dueDate!);
            return InvoiceReminderItem(
              business: business,
              customer: customerById[invoice.customerId],
              invoice: invoice,
              daysUntilDue: dueDate.difference(today).inDays,
            );
          })
          .where((item) => item.customer != null)
          .toList()
        ..sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));

  final quoteReminders =
      quotes
          .where((quote) {
            if (quote.status == 'CONVERTED' || quote.status == 'REJECTED') {
              return false;
            }
            final validUntil = quote.dueDate;
            if (validUntil == null) return false;
            return _dateOnly(validUntil).difference(today).inDays <= 7;
          })
          .map((quote) {
            final validUntil = _dateOnly(quote.dueDate!);
            return QuoteReminderItem(
              business: business,
              customer: customerById[quote.customerId],
              quote: quote,
              daysUntilExpiry: validUntil.difference(today).inDays,
            );
          })
          .where((item) => item.customer != null)
          .toList()
        ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

  return ReminderCenterData(
    invoiceReminders: invoiceReminders,
    quoteReminders: quoteReminders,
  );
});

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class ReminderCenterData {
  final List<InvoiceReminderItem> invoiceReminders;
  final List<QuoteReminderItem> quoteReminders;

  int get totalCount => invoiceReminders.length + quoteReminders.length;

  const ReminderCenterData({
    this.invoiceReminders = const [],
    this.quoteReminders = const [],
  });
}

class InvoiceReminderItem {
  final Business business;
  final Customer? customer;
  final Invoice invoice;
  final int daysUntilDue;

  double get balanceDue => invoiceBalanceDue(invoice);
  bool get isOverdue => daysUntilDue < 0;

  const InvoiceReminderItem({
    required this.business,
    required this.customer,
    required this.invoice,
    required this.daysUntilDue,
  });
}

class QuoteReminderItem {
  final Business business;
  final Customer? customer;
  final Quote quote;
  final int daysUntilExpiry;

  bool get isExpired => daysUntilExpiry < 0;

  const QuoteReminderItem({
    required this.business,
    required this.customer,
    required this.quote,
    required this.daysUntilExpiry,
  });
}

final reminderActionsProvider = Provider<ReminderActions>((ref) {
  return ReminderActions(ref);
});

class ReminderActions {
  final Ref _ref;

  ReminderActions(this._ref);

  Future<void> markInvoiceContacted(int invoiceId) async {
    await _ref.read(invoiceProvider).markInvoiceReminderSent(invoiceId);
    _ref.invalidate(reminderCenterProvider);
  }

  Future<void> markQuoteContacted(int quoteId) async {
    await _ref.read(quoteProvider).markQuoteContacted(quoteId);
    _ref.invalidate(reminderCenterProvider);
  }
}
