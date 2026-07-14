import 'package:drift/drift.dart';
import 'quotes.dart';
import 'products.dart';

@DataClassName('QuoteItem')
class QuoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quoteId =>
      integer().references(Quotes, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  TextColumn get name => text()();
  TextColumn get hsnSac => text()();
  TextColumn get unit => text()();
  RealColumn get quantity => real()();
  RealColumn get rate => real()();
  RealColumn get discountPct => real().withDefault(const Constant(0.0))();
  RealColumn get taxableAmount => real()();
  RealColumn get gstRate => real()();
  RealColumn get cgstRate => real().withDefault(const Constant(0.0))();
  RealColumn get sgstRate => real().withDefault(const Constant(0.0))();
  RealColumn get igstRate => real().withDefault(const Constant(0.0))();
  RealColumn get cessRate => real().withDefault(const Constant(0.0))();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get cessAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
