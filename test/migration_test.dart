import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sq3;
import 'package:vittix_invoice/database/app_database.dart';

/// Regression tests for the schema migration ladder, built as hand-crafted
/// legacy database files. The migration previously ran its version blocks in
/// descending order, so steps read columns that only later (numerically
/// lower) steps added — a v6 database crashed in the v22 stock backfill
/// (stock_quantity is a v7 column) and a v20 database crashed in the v28
/// tax-split repair (round_off_amount is a v21 column). These fixtures pin
/// both upgrade paths.
void main() {
  // 2026-06-15: Indian FY 2627 (June falls in April 2026 - March 2027).
  final june2026 = DateTime.utc(2026, 6, 15).millisecondsSinceEpoch ~/ 1000;

  File buildLegacyDatabase(String name, List<String> statements, int version) {
    final file = File(
      '${Directory.systemTemp.createTempSync('vittix-migration-').path}'
      '/$name.sqlite',
    );
    final db = sq3.sqlite3.open(file.path);
    try {
      db.execute('BEGIN');
      for (final statement in statements) {
        db.execute(statement);
      }
      db.execute('PRAGMA user_version = $version');
      db.execute('COMMIT');
    } finally {
      db.close();
    }
    return file;
  }

  const createCustomers = '''
    CREATE TABLE customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      business_id INTEGER NOT NULL REFERENCES businesses (id),
      name TEXT NOT NULL,
      gstin TEXT NULL,
      pan TEXT NULL,
      address TEXT NULL,
      city TEXT NULL,
      state_code INTEGER NULL,
      pincode TEXT NULL,
      phone TEXT NULL,
      email TEXT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL
    )''';

  const createInvoiceItems = '''
    CREATE TABLE invoice_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices (id) ON DELETE CASCADE,
      product_id INTEGER NULL REFERENCES products (id),
      name TEXT NOT NULL,
      hsn_sac TEXT NOT NULL,
      unit TEXT NOT NULL,
      quantity REAL NOT NULL,
      rate REAL NOT NULL,
      discount_pct REAL NOT NULL DEFAULT 0.0,
      taxable_amount REAL NOT NULL,
      gst_rate REAL NOT NULL,
      cgst_rate REAL NOT NULL DEFAULT 0.0,
      sgst_rate REAL NOT NULL DEFAULT 0.0,
      igst_rate REAL NOT NULL DEFAULT 0.0,
      cess_rate REAL NOT NULL DEFAULT 0.0,
      cgst_amount REAL NOT NULL DEFAULT 0.0,
      sgst_amount REAL NOT NULL DEFAULT 0.0,
      igst_amount REAL NOT NULL DEFAULT 0.0,
      cess_amount REAL NOT NULL DEFAULT 0.0,
      total_amount REAL NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0
    )''';

  test('migrates a v20 database to v30 (round-off + repair + stock ledger)',
      () async {
    final file = buildLegacyDatabase(
      'v20',
      [
        // v20 businesses: no credit/debit note series formats (v24).
        '''
        CREATE TABLE businesses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          gstin TEXT NOT NULL,
          pan TEXT NULL,
          business_type INTEGER NOT NULL DEFAULT 0,
          address TEXT NOT NULL,
          city TEXT NOT NULL,
          state_code INTEGER NOT NULL,
          pincode TEXT NULL,
          phone TEXT NULL,
          email TEXT NULL,
          logo_path TEXT NULL,
          bank_name TEXT NULL,
          bank_account TEXT NULL,
          bank_ifsc TEXT NULL,
          upi_id TEXT NULL,
          currency_code TEXT NOT NULL DEFAULT 'INR',
          invoice_template TEXT NOT NULL DEFAULT 'CLASSIC',
          quote_template TEXT NOT NULL DEFAULT 'CLASSIC',
          invoice_series_format TEXT NOT NULL DEFAULT 'INV-{FY}-{SEQ4}',
          quote_series_format TEXT NOT NULL DEFAULT 'QT-{FY}-{SEQ4}',
          default_invoice_template_id INTEGER NULL,
          default_quote_template_id INTEGER NULL,
          brand_color INTEGER NULL,
          is_active INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL
        )''',
        createCustomers,
        // v20 products: no reorder_level (v30).
        '''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          name TEXT NOT NULL,
          description TEXT NULL,
          hsn_sac TEXT NOT NULL,
          unit TEXT NOT NULL,
          sale_price REAL NOT NULL,
          purchase_price REAL NULL,
          gst_rate REAL NOT NULL,
          cess_rate REAL NOT NULL DEFAULT 0.0,
          stock_quantity REAL NOT NULL DEFAULT 0.0,
          is_service INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL
        )''',
        // v20 invoices: no round_off_amount (v21), reference_invoice_id (v24),
        // reverse_charge/ship_to (v25), export_with_lut (v26), tds/tcs (v27).
        '''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          customer_id INTEGER NOT NULL REFERENCES customers (id),
          invoice_number TEXT NOT NULL,
          currency_code TEXT NOT NULL DEFAULT 'INR',
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NULL,
          invoice_type TEXT NOT NULL,
          supply_type TEXT NOT NULL,
          place_of_supply INTEGER NOT NULL,
          subtotal REAL NOT NULL,
          discount_amount REAL NOT NULL DEFAULT 0.0,
          taxable_amount REAL NOT NULL,
          cgst_amount REAL NOT NULL DEFAULT 0.0,
          sgst_amount REAL NOT NULL DEFAULT 0.0,
          igst_amount REAL NOT NULL DEFAULT 0.0,
          cess_amount REAL NOT NULL DEFAULT 0.0,
          total_amount REAL NOT NULL,
          amount_paid REAL NOT NULL DEFAULT 0.0,
          amount_in_words TEXT NULL,
          notes TEXT NULL,
          terms TEXT NULL,
          status TEXT NOT NULL DEFAULT 'DRAFT',
          is_igst INTEGER NOT NULL DEFAULT 0,
          template_id INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )''',
        createInvoiceItems,
        // v20 payments: kind exists (v12) but not mode/reference (v23).
        '''
        CREATE TABLE invoice_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_id INTEGER NOT NULL REFERENCES invoices (id),
          amount REAL NOT NULL,
          kind TEXT NOT NULL DEFAULT 'PAYMENT',
          paid_at INTEGER NOT NULL,
          note TEXT NULL,
          created_at INTEGER NOT NULL
        )''',
        // v20 quotes: same v21/v25/v26/v27 columns missing as invoices.
        '''
        CREATE TABLE quotes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          customer_id INTEGER NOT NULL REFERENCES customers (id),
          invoice_number TEXT NOT NULL,
          currency_code TEXT NOT NULL DEFAULT 'INR',
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NULL,
          invoice_type TEXT NOT NULL,
          supply_type TEXT NOT NULL,
          place_of_supply INTEGER NOT NULL,
          subtotal REAL NOT NULL,
          discount_amount REAL NOT NULL DEFAULT 0.0,
          taxable_amount REAL NOT NULL,
          cgst_amount REAL NOT NULL DEFAULT 0.0,
          sgst_amount REAL NOT NULL DEFAULT 0.0,
          igst_amount REAL NOT NULL DEFAULT 0.0,
          cess_amount REAL NOT NULL DEFAULT 0.0,
          total_amount REAL NOT NULL,
          amount_in_words TEXT NULL,
          notes TEXT NULL,
          terms TEXT NULL,
          status TEXT NOT NULL DEFAULT 'DRAFT',
          is_igst INTEGER NOT NULL DEFAULT 0,
          template_id INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )''',
        "INSERT INTO businesses (name, gstin, address, city, state_code, "
            "created_at) VALUES ('B', '27AAPFU0939F1ZV', 'a', 'b', 27, "
            '$june2026)',
        "INSERT INTO customers (business_id, name, created_at) "
            "VALUES (1, 'C', $june2026)",
        "INSERT INTO products (business_id, name, hsn_sac, unit, sale_price, "
            'gst_rate, stock_quantity, created_at) VALUES (1, '
            "'Widget', '8479', 'PCS', 100.0, 18.0, 5.0, $june2026)",
        "INSERT INTO invoices (business_id, customer_id, invoice_number, "
            'invoice_date, invoice_type, supply_type, place_of_supply, '
            'subtotal, taxable_amount, cgst_amount, sgst_amount, '
            'total_amount, status, is_igst, created_at, updated_at) '
            "VALUES (1, 1, 'INV-2627-0007', $june2026, 'TAX_INVOICE', 'B2B', "
            '27, 100.0, 100.0, 0.0, 0.0, 100.0, 1, 0, $june2026, $june2026)',
        "INSERT INTO invoice_items (invoice_id, name, hsn_sac, unit, "
            'quantity, rate, taxable_amount, gst_rate, total_amount) '
            "VALUES (1, 'Widget', '8479', 'PCS', 1.0, 100.0, 100.0, 18.0, "
            '100.0)',
      ],
      20,
    );

    final database = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(database.close);

    final business = await database.select(database.businesses).getSingle();
    // v24 column lands with its default.
    expect(business.creditNoteSeriesFormat, 'CN-{FY}-{SEQ4}');
    // v31 adds the Bill of Supply series with its default.
    expect(business.billOfSupplySeriesFormat, 'BOS-{FY}-{SEQ4}');

    final product = await database.select(database.products).getSingle();
    // v30 column lands with its default; the v7-era stock value survives.
    expect(product.reorderLevel, 0);
    expect(product.stockQuantity, 5);

    // v22 backfilled an opening movement for the pre-ledger stock.
    final movements = await database.select(database.stockMovements).get();
    expect(movements, hasLength(1));
    expect(movements.single.quantityDelta, 5);
    expect(movements.single.reason, 'OPENING');

    // v28 repaired the stored split that disagreed with the document: the
    // line's own taxable amount and rate drive CGST/SGST, and round-off (v21)
    // is cleared.
    final invoice = await database.select(database.invoices).getSingle();
    expect(invoice.cgstAmount, 9);
    expect(invoice.sgstAmount, 9);
    expect(invoice.totalAmount, 118);
    expect(invoice.roundOffAmount, 0);
  });

  test('migrates a v6 database to v30 (stock column + sequence backfill)',
      () async {
    final file = buildLegacyDatabase(
      'v6',
      [
        // v6 businesses: no currency code (v8), templates (v13), UPI (v15),
        // default template ids (v16), series formats (v17), note formats (v24).
        '''
        CREATE TABLE businesses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          gstin TEXT NOT NULL,
          pan TEXT NULL,
          business_type INTEGER NOT NULL DEFAULT 0,
          address TEXT NOT NULL,
          city TEXT NOT NULL,
          state_code INTEGER NOT NULL,
          pincode TEXT NULL,
          phone TEXT NULL,
          email TEXT NULL,
          logo_path TEXT NULL,
          bank_name TEXT NULL,
          bank_account TEXT NULL,
          bank_ifsc TEXT NULL,
          brand_color INTEGER NULL,
          is_active INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL
        )''',
        createCustomers,
        // v6 products: no stock_quantity (v7) or reorder_level (v30).
        '''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          name TEXT NOT NULL,
          description TEXT NULL,
          hsn_sac TEXT NOT NULL,
          unit TEXT NOT NULL,
          sale_price REAL NOT NULL,
          purchase_price REAL NULL,
          gst_rate REAL NOT NULL,
          cess_rate REAL NOT NULL DEFAULT 0.0,
          is_service INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL
        )''',
        // v6 invoices: additionally no currency code (v8), template id (v18),
        // round-off (v21), and the v24-27 compliance columns.
        '''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          customer_id INTEGER NOT NULL REFERENCES customers (id),
          invoice_number TEXT NOT NULL,
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NULL,
          invoice_type TEXT NOT NULL,
          supply_type TEXT NOT NULL,
          place_of_supply INTEGER NOT NULL,
          subtotal REAL NOT NULL,
          discount_amount REAL NOT NULL DEFAULT 0.0,
          taxable_amount REAL NOT NULL,
          cgst_amount REAL NOT NULL DEFAULT 0.0,
          sgst_amount REAL NOT NULL DEFAULT 0.0,
          igst_amount REAL NOT NULL DEFAULT 0.0,
          cess_amount REAL NOT NULL DEFAULT 0.0,
          total_amount REAL NOT NULL,
          amount_paid REAL NOT NULL DEFAULT 0.0,
          amount_in_words TEXT NULL,
          notes TEXT NULL,
          terms TEXT NULL,
          status TEXT NOT NULL DEFAULT 'DRAFT',
          is_igst INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )''',
        createInvoiceItems,
        // v6 quotes, quote items, payments, and activity events existed by v6.
        '''
        CREATE TABLE quotes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          customer_id INTEGER NOT NULL REFERENCES customers (id),
          invoice_number TEXT NOT NULL,
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NULL,
          invoice_type TEXT NOT NULL,
          supply_type TEXT NOT NULL,
          place_of_supply INTEGER NOT NULL,
          subtotal REAL NOT NULL,
          discount_amount REAL NOT NULL DEFAULT 0.0,
          taxable_amount REAL NOT NULL,
          cgst_amount REAL NOT NULL DEFAULT 0.0,
          sgst_amount REAL NOT NULL DEFAULT 0.0,
          igst_amount REAL NOT NULL DEFAULT 0.0,
          cess_amount REAL NOT NULL DEFAULT 0.0,
          total_amount REAL NOT NULL,
          amount_in_words TEXT NULL,
          notes TEXT NULL,
          terms TEXT NULL,
          status TEXT NOT NULL DEFAULT 'DRAFT',
          is_igst INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )''',
        '''
        CREATE TABLE quote_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quote_id INTEGER NOT NULL REFERENCES quotes (id) ON DELETE CASCADE,
          product_id INTEGER NULL REFERENCES products (id),
          name TEXT NOT NULL,
          hsn_sac TEXT NOT NULL,
          unit TEXT NOT NULL,
          quantity REAL NOT NULL,
          rate REAL NOT NULL,
          discount_pct REAL NOT NULL DEFAULT 0.0,
          taxable_amount REAL NOT NULL,
          gst_rate REAL NOT NULL,
          cgst_rate REAL NOT NULL DEFAULT 0.0,
          sgst_rate REAL NOT NULL DEFAULT 0.0,
          igst_rate REAL NOT NULL DEFAULT 0.0,
          cess_rate REAL NOT NULL DEFAULT 0.0,
          cgst_amount REAL NOT NULL DEFAULT 0.0,
          sgst_amount REAL NOT NULL DEFAULT 0.0,
          igst_amount REAL NOT NULL DEFAULT 0.0,
          cess_amount REAL NOT NULL DEFAULT 0.0,
          total_amount REAL NOT NULL,
          sort_order INTEGER NOT NULL DEFAULT 0
        )''',
        // v6 payments: no kind (v12) or mode/reference (v23).
        '''
        CREATE TABLE invoice_payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_id INTEGER NOT NULL REFERENCES invoices (id),
          amount REAL NOT NULL,
          paid_at INTEGER NOT NULL,
          note TEXT NULL,
          created_at INTEGER NOT NULL
        )''',
        '''
        CREATE TABLE customer_activity_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_id INTEGER NOT NULL REFERENCES businesses (id),
          customer_id INTEGER NOT NULL REFERENCES customers (id),
          event_type TEXT NOT NULL,
          entity_type TEXT NULL,
          entity_id INTEGER NULL,
          title TEXT NOT NULL,
          note TEXT NULL,
          created_at INTEGER NOT NULL
        )''',
        "INSERT INTO businesses (name, gstin, address, city, state_code, "
            "created_at) VALUES ('B', '27AAPFU0939F1ZV', 'a', 'b', 27, "
            '$june2026)',
        "INSERT INTO customers (business_id, name, created_at) "
            "VALUES (1, 'C', $june2026)",
        "INSERT INTO products (business_id, name, hsn_sac, unit, sale_price, "
            'gst_rate, created_at) VALUES (1, '
            "'Service', '9983', 'NOS', 100.0, 18.0, $june2026)",
        "INSERT INTO invoices (business_id, customer_id, invoice_number, "
            'invoice_date, invoice_type, supply_type, place_of_supply, '
            'subtotal, taxable_amount, cgst_amount, sgst_amount, '
            'total_amount, status, is_igst, created_at, updated_at) '
            "VALUES (1, 1, 'INV-2627-0003', $june2026, 'TAX_INVOICE', 'B2B', "
            '27, 100.0, 100.0, 0.0, 0.0, 100.0, 1, 0, $june2026, $june2026)',
        "INSERT INTO invoice_items (invoice_id, name, hsn_sac, unit, "
            'quantity, rate, taxable_amount, gst_rate, total_amount) '
            "VALUES (1, 'Service', '9983', 'NOS', 1.0, 100.0, 100.0, 18.0, "
            '100.0)',
        "INSERT INTO quotes (business_id, customer_id, invoice_number, "
            'invoice_date, invoice_type, supply_type, place_of_supply, '
            'subtotal, taxable_amount, total_amount, status, is_igst, '
            'created_at, updated_at) VALUES (1, 1, '
            "'QT-2627-0001', $june2026, 'QUOTE', 'B2B', 27, 100.0, 100.0, "
            "100.0, 'SENT', 0, $june2026, $june2026)",
      ],
      6,
    );

    final database = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(database.close);

    // v7 gave products a stock column (default 0) and v30 a reorder level.
    final product = await database.select(database.products).getSingle();
    expect(product.stockQuantity, 0);
    expect(product.reorderLevel, 0);

    // v19 backfilled sequence counters from the stored numbers using the
    // default series format that v17 introduced.
    final sequences = await database.select(database.documentSequences).get();
    final invoiceSequence = sequences.firstWhere(
      (row) =>
          row.docType == 'INV' &&
          row.fiscalYear == '2627' &&
          row.format == 'INV-{FY}-{SEQ4}',
    );
    expect(invoiceSequence.sequence, 3);
    final quoteSequence = sequences.firstWhere(
      (row) =>
          row.docType == 'QT' &&
          row.fiscalYear == '2627' &&
          row.format == 'QT-{FY}-{SEQ4}',
    );
    expect(quoteSequence.sequence, 1);

    // The v28 repair normalized the corrupted split after v21/v22/v27 lands.
    final invoice = await database.select(database.invoices).getSingle();
    expect(invoice.cgstAmount, 9);
    expect(invoice.sgstAmount, 9);
    expect(invoice.totalAmount, 118);

    // No stock existed at v6, so the v22 backfill wrote no opening movement.
    final movements = await database.select(database.stockMovements).get();
    expect(movements, isEmpty);
  });
}
