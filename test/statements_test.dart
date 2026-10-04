
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/features/reports/customer_statement_report.dart';

void main() {
  group('CustomerStatementReport', () {
    test('builds signed statement rows with running balances', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final invoiceId = await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: 1,
              invoiceNumber: 'INV-2627-0001',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'TAX_INVOICE',
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
              amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 50,
              kind: const drift.Value('PAYMENT'),
              paidAt: DateTime(2026, 7, 1),
              createdAt: DateTime(2026, 7, 1),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 10,
              kind: const drift.Value('REFUND'),
              paidAt: DateTime(2026, 7, 2),
              createdAt: DateTime(2026, 7, 2),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 50,
              kind: const drift.Value('VOID'),
              paidAt: DateTime(2026, 7, 3),
              createdAt: DateTime(2026, 7, 3),
            ),
          );

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(4));
      expect(rows[0].entryType, 'INVOICE');
      expect(rows[0].amount, 118);
      expect(rows[0].runningBalance, 118);
      expect(rows[1].entryType, 'PAYMENT');
      expect(rows[1].amount, -50);
      expect(rows[1].runningBalance, 68);
      expect(rows[2].entryType, 'REFUND');
      expect(rows[2].amount, 10);
      expect(rows[2].runningBalance, 78);
      expect(rows[3].entryType, 'VOID');
      expect(rows[3].amount, 0);
      expect(rows[3].runningBalance, 78);
    });

    test('credit notes appear as negative statement entries', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: 1,
              invoiceNumber: 'INV-2627-0001',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'TAX_INVOICE',
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoices).insert(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'CN-2627-0001',
          invoiceDate: DateTime(2026, 7, 5),
          invoiceType: 'CREDIT_NOTE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          referenceInvoiceId: const drift.Value(1),
          status: const drift.Value('SENT'),
          createdAt: DateTime(2026, 7, 5),
          updatedAt: DateTime(2026, 7, 5),
        ),
      );

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(2));
      expect(rows[0].entryType, 'INVOICE');
      expect(rows[0].amount, 118);
      expect(rows[1].entryType, 'CREDIT_NOTE');
      expect(rows[1].amount, -118);
      expect(rows[1].runningBalance, 0);
    });

    test('excludes draft and cancelled invoices', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      Future<void> insertInvoice(String number, String status) =>
          database.into(database.invoices).insert(
                InvoicesCompanion.insert(
                  businessId: 1,
                  customerId: 1,
                  invoiceNumber: number,
                  invoiceDate: DateTime(2026, 6, 30),
                  invoiceType: 'TAX_INVOICE',
                  supplyType: 'B2B',
                  placeOfSupply: 27,
                  subtotal: 100,
                  taxableAmount: 100,
                  totalAmount: 118,
                  status: drift.Value(status),
                  createdAt: DateTime(2026, 6, 30),
                  updatedAt: DateTime(2026, 6, 30),
                ),
              );

      await insertInvoice('INV-2627-0001', 'SENT');
      await insertInvoice('INV-2627-0002', 'DRAFT');
      await insertInvoice('INV-2627-0003', 'CANCELLED');

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(1));
      expect(rows.single.documentNumber, 'INV-2627-0001');
    });
  });
}
