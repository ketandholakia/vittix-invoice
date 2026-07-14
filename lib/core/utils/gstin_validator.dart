class GstinValidator {
  // Format: 2-digit state + 10-char PAN + 1-digit entity + Z + checksum
  static bool isValid(String gstin) {
    if (gstin.length != 15) return false;
    final regex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!regex.hasMatch(gstin)) return false;
    return _verifyChecksum(gstin);
  }

  static int? extractStateCode(String gstin) {
    if (gstin.length < 2) return null;
    return int.tryParse(gstin.substring(0, 2));
  }

  static bool _verifyChecksum(String gstin) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    int sum = 0;
    for (int i = 0; i < 14; i++) {
      int val = chars.indexOf(gstin[i]);
      if (val == -1) return false;
      int factor = (i % 2 == 0) ? 1 : 2;
      int product = val * factor;
      sum += (product ~/ 36) + (product % 36);
    }
    int checkDigit = (36 - (sum % 36)) % 36;
    return chars[checkDigit] == gstin[14];
  }
}
