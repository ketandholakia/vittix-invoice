import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/utils/amount_in_words.dart';
import '../../../core/utils/gst_calculator.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../database/app_database.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/quote_provider.dart';
import '../../../services/quote_service.dart';
import '../../shared/document_form_screen.dart';
import '../../shared/item_entry_sheet.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Quote? existingQuote;

  const QuoteFormScreen({super.key, this.existingQuote});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState
    extends DocumentFormScreenState<
      QuoteFormScreen,
      Quote,
      QuotesCompanion,
      QuoteItemsCompanion
    > {
  @override
  Quote? get existingDocument => widget.existingQuote;

  @override
  String get documentNoun => 'Quote';

  @override
  String get dateLabel => 'Quote Date';

  @override
  String get endDateLabel => 'Valid Until';

  @override
  String get listRoute => '/quotes';

  @override
  String get saveErrorPrefix => 'quote';

  @override
  void seedFromExisting(Quote document) {
    documentDate = document.invoiceDate;
    endDate = document.dueDate;
    isInterState = document.isIgst;
  }

  @override
  ({String? notes, String? terms}) notesAndTermsOf(Quote document) =>
      (notes: document.notes, terms: document.terms);

  @override
  ({String? name, String? address, String? city}) shippingOf(Quote document) =>
      (
        name: document.shipToName,
        address: document.shipToAddress,
        city: document.shipToCity,
      );

  @override
  bool reverseChargeOf(Quote document) => document.reverseCharge;

  @override
  ({String supplyType, bool exportWithLut}) supplyDeclarationOf(
    Quote document,
  ) {
    const known = {'B2B', 'B2C', 'EXPORT', 'SEZ'};
    return (
      supplyType: known.contains(document.supplyType)
          ? document.supplyType
          : 'AUTO',
      exportWithLut: document.exportWithLut,
    );
  }

  @override
  ({String? tdsSection, double tdsRate, String? tcsSection, double tcsRate})
  taxesAtSourceOf(Quote document) => (
    tdsSection: document.tdsSection,
    tdsRate: document.tdsRate,
    tcsSection: document.tcsSection,
    tcsRate: document.tcsRate,
  );

  @override
  Future<Customer?> loadCustomer(Quote document) =>
      ref.read(customerDaoProvider).getCustomerById(document.customerId);

  @override
  Future<List<QuoteItemsCompanion>> loadItemCompanions(Quote document) async {
    final rows = await ref.read(quoteDaoProvider).getItemsForQuote(document.id);
    return rows
        .map((row) => ref.read(quoteServiceProvider).itemCompanionFrom(
              row,
              documentId: document.id,
            ))
        .toList();
  }

  @override
  Future<QuoteItemsCompanion?> showItemSheet({QuoteItemsCompanion? existing}) {
    return showModalBottomSheet<QuoteItemsCompanion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemEntrySheet<QuoteItemsCompanion>(
        isInterState: isInterState,
        existingItem: existing == null
            ? null
            : ItemEntryData.fromQuoteItemCompanion(existing),
        hsnLookupDate: documentDate,
        currencyCode: ref.watch(activeBusinessProvider).valueOrNull?.currencyCode ?? 'INR',
        buildCompanion: quoteItemCompanionFromData,
      ),
    );
  }

  @override
  ItemTotals totalsOf(QuoteItemsCompanion item) {
    final gross = round2(item.quantity.value * item.rate.value);
    final taxable = item.taxableAmount.value;
    return (
      gross: gross,
      discount: round2(gross - taxable),
      taxable: taxable,
      cgst: item.cgstAmount.value,
      sgst: item.sgstAmount.value,
      igst: item.igstAmount.value,
      cess: item.cessAmount.value,
    );
  }

  @override
  QuoteItemsCompanion recomputeItemTax(
    QuoteItemsCompanion item, {
    required bool isInterState,
    bool zeroRate = false,
  }) {
    final split = GstCalculator.splitLine(
      taxableAmount: item.taxableAmount.value,
      gstRate: zeroRate ? 0 : item.gstRate.value,
      isInterState: isInterState,
      cessRate: item.cessRate.value,
    );
    return item.copyWith(
      cgstRate: drift.Value(split.cgstRate),
      sgstRate: drift.Value(split.sgstRate),
      igstRate: drift.Value(split.igstRate),
      cgstAmount: drift.Value(split.cgstAmount),
      sgstAmount: drift.Value(split.sgstAmount),
      igstAmount: drift.Value(split.igstAmount),
      cessAmount: drift.Value(split.cessAmount),
      totalAmount: drift.Value(split.totalAmount),
    );
  }

  @override
  String itemListTitle(QuoteItemsCompanion item) => item.name.value;

  @override
  String itemListSubtitle(QuoteItemsCompanion item, String currencyCode) =>
      'Qty: ${item.quantity.value} | Total: ${formatMoney(item.totalAmount.value, currencyCode: currencyCode)}';

  @override
  String documentNumberLabel(Quote document) => 'Quote No: ${document.invoiceNumber}';

  @override
  QuotesCompanion buildCompanion({
    required int businessId,
    required Customer customer,
    required String currencyCode,
    required bool isGstEnabled,
    required String supplyType,
    required int placeOfSupply,
    required double subtotal,
    required double discount,
    required double taxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double cess,
    required double roundOff,
    required double grandTotal,
    required bool reverseCharge,
    required String? shipToName,
    required String? shipToAddress,
    required String? shipToCity,
    required bool exportWithLut,
    required String? tdsSection,
    required double tdsRate,
    required double tdsAmount,
    required String? tcsSection,
    required double tcsRate,
    required double tcsAmount,
  }) {
    return QuotesCompanion.insert(
      businessId: businessId,
      customerId: customer.id,
      invoiceNumber: 'PENDING',
      invoiceDate: documentDate,
      dueDate: drift.Value(endDate),
      invoiceType: 'QUOTE',
      supplyType: supplyType,
      placeOfSupply: placeOfSupply,
      subtotal: subtotal,
      discountAmount: drift.Value(discount),
      taxableAmount: taxable,
      totalAmount: grandTotal,
      roundOffAmount: drift.Value(roundOff),
      cgstAmount: drift.Value(cgst),
      sgstAmount: drift.Value(sgst),
      igstAmount: drift.Value(igst),
      cessAmount: drift.Value(cess),
      amountInWords: drift.Value(AmountInWords.convert(grandTotal)),
      notes: drift.Value(
        notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      ),
      terms: drift.Value(
        termsController.text.trim().isEmpty ? null : termsController.text.trim(),
      ),
      isIgst: drift.Value(isInterState),
      reverseCharge: drift.Value(reverseCharge),
      shipToName: drift.Value(shipToName),
      shipToAddress: drift.Value(shipToAddress),
      shipToCity: drift.Value(shipToCity),
      exportWithLut: drift.Value(exportWithLut),
      tdsSection: drift.Value(tdsSection),
      tdsRate: drift.Value(tdsRate),
      tdsAmount: drift.Value(tdsAmount),
      tcsSection: drift.Value(tcsSection),
      tcsRate: drift.Value(tcsRate),
      tcsAmount: drift.Value(tcsAmount),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).copyWith(currencyCode: drift.Value(currencyCode));
  }

  @override
  Future<void> saveDocument({
    required QuotesCompanion companion,
    required List<QuoteItemsCompanion> items,
    required Quote? existing,
  }) async {
    final service = ref.read(quoteProvider);
    if (existing == null) {
      await service.createQuoteWithItems(companion, items);
    } else {
      await service.updateQuoteWithItems(existing, companion, items);
    }
  }

  @override
  Widget buildCustomerSummaryCard(Customer customer, String currencyCode) {
    return Builder(
      builder: (context) {
        final quotes = ref.watch(quoteListProvider).valueOrNull;
        final invoices = ref.watch(invoiceListProvider).valueOrNull;
        if (quotes == null || invoices == null) {
          return const SizedBox.shrink();
        }

        final customerQuotes = quotes
            .where((quote) => quote.customerId == customer.id)
            .toList();
        final customerInvoices = invoices
            .where((invoice) => invoice.customerId == customer.id)
            .toList();
        final convertedCount = customerQuotes
            .where((quote) => quote.status == 'CONVERTED')
            .length;
        final lastQuote = customerQuotes.isEmpty
            ? null
            : (customerQuotes.toList()..sort(
                (a, b) => b.invoiceDate.compareTo(a.invoiceDate),
              ))
                  .first;

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(customer.name),
            subtitle: Text(
              'Quotes: ${customerQuotes.length} | Converted: $convertedCount'
              '${lastQuote != null ? ' | Last: ${lastQuote.invoiceNumber}' : ''}',
            ),
            trailing: Text('Invoices ${customerInvoices.length}'),
          ),
        );
      },
    );
  }
}
