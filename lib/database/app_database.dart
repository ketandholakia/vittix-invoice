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

import 'daos/business_dao.dart';
import 'daos/customer_dao.dart';
import 'daos/product_dao.dart';
import 'daos/invoice_dao.dart';
import 'daos/quote_dao.dart';
import 'daos/customer_activity_dao.dart';
import 'daos/hsn_dao.dart';
import 'daos/uom_dao.dart';
import 'daos/template_config_dao.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
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
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vittix_invoice.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
