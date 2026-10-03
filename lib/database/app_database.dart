import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/businesses.dart';
import 'tables/customers.dart';
import 'tables/products.dart';
import 'tables/invoices.dart';
import 'tables/invoice_items.dart';
import 'tables/invoice_payments.dart';
import 'tables/customer_activity_events.dart';
import 'tables/hsn_codes.dart';
import 'tables/hsn_code_rates.dart';
import 'tables/quotes.dart';
import 'tables/quote_items.dart';
import 'tables/uoms.dart';
import 'tables/template_configs.dart';
import 'tables/document_sequences.dart';
import 'tables/stock_movements.dart';
import 'tables/recurring_invoices.dart';

import 'daos/business_dao.dart';
import 'daos/customer_dao.dart';
import 'daos/product_dao.dart';
import 'daos/invoice_dao.dart';
import 'daos/quote_dao.dart';
import 'daos/customer_activity_dao.dart';
import 'daos/hsn_dao.dart';
import 'daos/uom_dao.dart';
import 'daos/template_config_dao.dart';
import 'daos/recurring_invoice_dao.dart';
import 'document_sequence_allocator.dart';
import '../core/utils/gst_calculator.dart';
import '../core/utils/invoice_number.dart';
import '../core/utils/money.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Businesses,
    Customers,
    Products,
    Invoices,
    InvoiceItems,
    InvoicePayments,
    CustomerActivityEvents,
    Quotes,
    QuoteItems,
    HsnCodes,
    HsnCodeRates,
    Uoms,
    TemplateConfigs,
    DocumentSequences,
    StockMovements,
    RecurringInvoices,
  ],
  daos: [
    BusinessDao,
    CustomerDao,
    ProductDao,
    InvoiceDao,
    QuoteDao,
    CustomerActivityDao,
    HsnDao,
    UomDao,
    TemplateConfigDao,
    RecurringInvoiceDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 30;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 30) {
          await m.addColumn(products, products.reorderLevel);
        }
        if (from < 29) {
          await m.createTable(recurringInvoices);
        }
        if (from < 28) {
          await _repairItemTaxSplits();
        }
        if (from < 27) {
          await m.addColumn(invoices, invoices.tdsSection);
          await m.addColumn(invoices, invoices.tdsRate);
          await m.addColumn(invoices, invoices.tdsAmount);
          await m.addColumn(invoices, invoices.tcsSection);
          await m.addColumn(invoices, invoices.tcsRate);
          await m.addColumn(invoices, invoices.tcsAmount);
          await m.addColumn(quotes, quotes.tdsSection);
          await m.addColumn(quotes, quotes.tdsRate);
          await m.addColumn(quotes, quotes.tdsAmount);
          await m.addColumn(quotes, quotes.tcsSection);
          await m.addColumn(quotes, quotes.tcsRate);
          await m.addColumn(quotes, quotes.tcsAmount);
        }
        if (from < 26) {
          await m.addColumn(invoices, invoices.exportWithLut);
          await m.addColumn(quotes, quotes.exportWithLut);
        }
        if (from < 25) {
          await m.addColumn(invoices, invoices.reverseCharge);
          await m.addColumn(invoices, invoices.shipToName);
          await m.addColumn(invoices, invoices.shipToAddress);
          await m.addColumn(invoices, invoices.shipToCity);
          await m.addColumn(quotes, quotes.reverseCharge);
          await m.addColumn(quotes, quotes.shipToName);
          await m.addColumn(quotes, quotes.shipToAddress);
          await m.addColumn(quotes, quotes.shipToCity);
        }
        if (from < 24) {
          await m.addColumn(invoices, invoices.referenceInvoiceId);
          await m.addColumn(
            businesses,
            businesses.creditNoteSeriesFormat,
          );
          await m.addColumn(businesses, businesses.debitNoteSeriesFormat);
        }
        if (from < 23) {
          await m.addColumn(invoicePayments, invoicePayments.mode);
          await m.addColumn(invoicePayments, invoicePayments.reference);
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoices_invoice_date" '
            'ON "invoices" ("invoice_date")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoices_status" '
            'ON "invoices" ("status")',
          );
        }
        if (from < 22) {
          await m.createTable(stockMovements);
          // Backfill an opening movement for stock that predates the ledger so
          // the balance can always be rebuilt from movements.
          final existingProducts = await select(products).get();
          final backfillNow = DateTime.now();
          for (final product in existingProducts) {
            if (product.stockQuantity != 0) {
              await into(stockMovements).insert(
                StockMovementsCompanion.insert(
                  productId: product.id,
                  quantityDelta: product.stockQuantity,
                  reason: 'OPENING',
                  createdAt: backfillNow,
                ),
              );
            }
          }
        }
        if (from < 21) {
          await m.addColumn(invoices, invoices.roundOffAmount);
          await m.addColumn(quotes, quotes.roundOffAmount);
        }
        if (from < 20) {
          await m.addColumn(hsnCodeRates, hsnCodeRates.minUnitPrice);
          await m.addColumn(hsnCodeRates, hsnCodeRates.maxUnitPrice);
        }
        if (from < 3) {
          await m.addColumn(businesses, businesses.brandColor);
          await m.addColumn(invoices, invoices.amountPaid);
        }
        if (from < 4) {
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS invoices_business_id_invoice_number_unique '
            'ON invoices (business_id, invoice_number)',
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS quotes_business_id_invoice_number_unique '
            'ON quotes (business_id, invoice_number)',
          );
        }
        if (from < 5) {
          await m.createTable(invoicePayments);
        }
        if (from < 6) {
          await m.createTable(customerActivityEvents);
        }
        if (from < 7) {
          await m.addColumn(products, products.stockQuantity);
        }
        if (from < 8) {
          await m.addColumn(businesses, businesses.currencyCode);
          await m.addColumn(invoices, invoices.currencyCode);
          await m.addColumn(quotes, quotes.currencyCode);
        }
        if (from < 9) {
          await m.createTable(hsnCodeRates);
        }
        if (from < 10) {
          await m.createTable(uoms);
        }
        if (from < 11) {
          await m.addColumn(uoms, uoms.family);
          await m.addColumn(uoms, uoms.baseCode);
          await m.addColumn(uoms, uoms.conversionFactor);
        }
        if (from < 12) {
          await m.addColumn(invoicePayments, invoicePayments.kind);
        }
        if (from < 13) {
          await m.addColumn(businesses, businesses.invoiceTemplate);
          await m.addColumn(businesses, businesses.quoteTemplate);
        }
        if (from < 14) {
          await m.createTable(templateConfigs);
        }
        if (from < 15) {
          await m.addColumn(businesses, businesses.upiId);
        }
        if (from < 16) {
          await customStatement(
            'ALTER TABLE businesses ADD COLUMN default_invoice_template_id INTEGER',
          );
          await customStatement(
            'ALTER TABLE businesses ADD COLUMN default_quote_template_id INTEGER',
          );
        }
        if (from < 17) {
          await customStatement(
            "ALTER TABLE businesses ADD COLUMN invoice_series_format TEXT NOT NULL DEFAULT 'INV-{FY}-{SEQ4}'",
          );
          await customStatement(
            "ALTER TABLE businesses ADD COLUMN quote_series_format TEXT NOT NULL DEFAULT 'QT-{FY}-{SEQ4}'",
          );
        }
        if (from < 18) {
          await customStatement(
            'ALTER TABLE invoices ADD COLUMN template_id INTEGER',
          );
          await customStatement(
            'ALTER TABLE quotes ADD COLUMN template_id INTEGER',
          );
        }
        if (from < 19) {
          await m.createTable(documentSequences);
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoices_business_id" '
            'ON "invoices" ("business_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoices_customer_id" '
            'ON "invoices" ("customer_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoice_items_invoice_id" '
            'ON "invoice_items" ("invoice_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoice_items_product_id" '
            'ON "invoice_items" ("product_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_invoice_payments_invoice_id" '
            'ON "invoice_payments" ("invoice_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_quotes_business_id" '
            'ON "quotes" ("business_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_quotes_customer_id" '
            'ON "quotes" ("customer_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_quote_items_quote_id" '
            'ON "quote_items" ("quote_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_quote_items_product_id" '
            'ON "quote_items" ("product_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_customers_business_id" '
            'ON "customers" ("business_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_products_business_id" '
            'ON "products" ("business_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_customer_activity_business_id" '
            'ON "customer_activity_events" ("business_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_customer_activity_customer_id" '
            'ON "customer_activity_events" ("customer_id")',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS "idx_template_configs_business_id" '
            'ON "template_configs" ("business_id")',
          );
          await _backfillDocumentSequenceCounters();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Computes the legacy per-business / per-FY / per-format max sequences
  /// from stored documents and seeds the new counter rows, so numbering
  /// Recomputes every document line's tax split from its own taxable amount and
  /// GST rate for the parent document's supply type, then rewrites the parent's
  /// component totals from the repaired lines.
  ///
  /// Lines written before the split was recomputed at save time could disagree
  /// with `invoices.isIgst`, which corrupted the printed tax block. The parent
  /// totals are normalized to the exact sum (round off cleared) so the document
  /// and its lines agree again.
  Future<void> _repairItemTaxSplits() async {
    final invoiceRows = await select(invoices).get();
    final invoiceById = {for (final row in invoiceRows) row.id: row};
    final totalsByInvoice = <int, List<double>>{};

    for (final item in await select(invoiceItems).get()) {
      final invoice = invoiceById[item.invoiceId];
      if (invoice == null) continue;

      final split = GstCalculator.splitLine(
        taxableAmount: item.taxableAmount,
        gstRate: item.gstRate,
        isInterState: invoice.isIgst,
        cessRate: item.cessRate,
      );

      await (update(invoiceItems)..where((t) => t.id.equals(item.id))).write(
        InvoiceItemsCompanion(
          cgstRate: Value(split.cgstRate),
          sgstRate: Value(split.sgstRate),
          igstRate: Value(split.igstRate),
          cgstAmount: Value(split.cgstAmount),
          sgstAmount: Value(split.sgstAmount),
          igstAmount: Value(split.igstAmount),
          cessAmount: Value(split.cessAmount),
          totalAmount: Value(split.totalAmount),
        ),
      );

      final bucket = totalsByInvoice.putIfAbsent(
        item.invoiceId,
        () => [0, 0, 0, 0, 0],
      );
      bucket[0] += item.taxableAmount;
      bucket[1] += split.cgstAmount;
      bucket[2] += split.sgstAmount;
      bucket[3] += split.igstAmount;
      bucket[4] += split.cessAmount;
    }

    for (final entry in totalsByInvoice.entries) {
      final taxable = round2(entry.value[0]);
      final cgst = round2(entry.value[1]);
      final sgst = round2(entry.value[2]);
      final igst = round2(entry.value[3]);
      final cess = round2(entry.value[4]);

      await (update(invoices)..where((t) => t.id.equals(entry.key))).write(
        InvoicesCompanion(
          taxableAmount: Value(taxable),
          cgstAmount: Value(cgst),
          sgstAmount: Value(sgst),
          igstAmount: Value(igst),
          cessAmount: Value(cess),
          totalAmount: Value(round2(taxable + cgst + sgst + igst + cess)),
          roundOffAmount: const Value(0),
        ),
      );
    }
  }

  /// continues seamlessly for databases upgraded to schema v19.
  Future<void> _backfillDocumentSequenceCounters() async {
    final businessRows = await select(businesses).get();
    for (final business in businessRows) {
      final invoiceFormat = InvoiceNumberGenerator.normalizeFormat(
        business.invoiceSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
      );
      await _backfillDocType(
        businessId: business.id,
        docType: DocumentSequenceAllocator.invoiceDocType,
        format: invoiceFormat,
        documents: (await (select(invoices)
                  ..where((t) => t.businessId.equals(business.id)))
              .get())
            .map((row) => (
                  invoiceNumber: row.invoiceNumber,
                  invoiceDate: row.invoiceDate,
                ))
            .toList(),
      );
      final quoteFormat = InvoiceNumberGenerator.normalizeFormat(
        business.quoteSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultQuoteFormat,
      );
      await _backfillDocType(
        businessId: business.id,
        docType: DocumentSequenceAllocator.quoteDocType,
        format: quoteFormat,
        documents: (await (select(quotes)
                  ..where((t) => t.businessId.equals(business.id)))
              .get())
            .map((row) => (
                  invoiceNumber: row.invoiceNumber,
                  invoiceDate: row.invoiceDate,
                ))
            .toList(),
      );
    }
  }

  Future<void> _backfillDocType({
    required int businessId,
    required String docType,
    required String format,
    required List<({String invoiceNumber, DateTime invoiceDate})> documents,
  }) async {
    final maxByKey = DocumentSequenceBackfill.computeMaxSequences(
      format: format,
      documents: documents,
    );
    for (final entry in maxByKey.entries) {
      await customStatement(
        'INSERT OR IGNORE INTO document_sequences '
        '(business_id, doc_type, fiscal_year, format, sequence) '
        'VALUES (?, ?, ?, ?, ?)',
        [
          businessId,
          docType,
          DocumentSequenceBackfill.fiscalYearFromKey(entry.key),
          format,
          entry.value,
        ],
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vittix_invoice.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
