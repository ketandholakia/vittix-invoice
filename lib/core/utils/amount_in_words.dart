class AmountInWords {
  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String convert(double amount) {
    if (amount <= 0) return 'Zero Rupees Only';

    final totalPaise = (amount * 100).round();
    final rupees = totalPaise ~/ 100;
    final paise = totalPaise % 100;

    final rupeeWord = rupees == 0
        ? 'Zero Rupees'
        : '${_convertNumber(rupees)} ${rupees == 1 ? 'Rupee' : 'Rupees'}';

    if (paise == 0) return '$rupeeWord Only';
    return '$rupeeWord and ${_convertNumber(paise)} Paise Only';
  }

  static String _convertNumber(int number) {
    if (number == 0) return '';

    if (number < 20) {
      return _units[number];
    }

    if (number < 100) {
      return '${_tens[number ~/ 10]} ${_units[number % 10]}'.trim();
    }

    if (number < 1000) {
      return '${_units[number ~/ 100]} Hundred ${_convertNumber(number % 100)}'
          .trim();
    }

    if (number < 100000) {
      // Lakh
      return '${_convertNumber(number ~/ 1000)} Thousand ${_convertNumber(number % 1000)}'
          .trim();
    }

    if (number < 10000000) {
      // Crore
      return '${_convertNumber(number ~/ 100000)} Lakh ${_convertNumber(number % 100000)}'
          .trim();
    }

    return '${_convertNumber(number ~/ 10000000)} Crore ${_convertNumber(number % 10000000)}'
        .trim();
  }
}
