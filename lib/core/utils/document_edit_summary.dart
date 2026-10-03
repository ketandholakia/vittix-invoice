import 'formatting.dart';

/// Builds a human-readable summary of a document edit for the customer
/// activity feed. Shared by the invoice and quote services.
String buildDocumentEditSummary({
  required String docNoun,
  required String dateLabel,
  required int previousCustomerId,
  required int currentCustomerId,
  required double previousTotal,
  required double currentTotal,
  required DateTime? previousDate,
  required DateTime? currentDate,
  required int previousItemCount,
  required int currentItemCount,
}) {
  final parts = <String>[];
  if (previousCustomerId != currentCustomerId) {
    parts.add('customer changed');
  }
  if (previousTotal != currentTotal) {
    parts.add(
      'total ${previousTotal.toStringAsFixed(2)} -> ${currentTotal.toStringAsFixed(2)}',
    );
  }
  if (previousDate != currentDate) {
    final oldDate = previousDate == null ? 'none' : formatDate(previousDate);
    final newDate = currentDate == null ? 'none' : formatDate(currentDate);
    parts.add('$dateLabel $oldDate -> $newDate');
  }
  if (previousItemCount != currentItemCount) {
    parts.add('items $previousItemCount -> $currentItemCount');
  }
  if (parts.isEmpty) {
    return '$docNoun details refreshed';
  }
  return '$docNoun edited: ${parts.join(', ')}';
}
