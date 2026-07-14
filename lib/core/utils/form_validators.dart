class FormValidators {
  static String? requiredPositiveNumber(String? value, String label) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return '$label is required';
    if (parsed <= 0) return '$label must be greater than zero';
    return null;
  }

  static String? percentageValidator(String? value, String label) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return '$label is required';
    if (parsed < 0 || parsed > 100) return '$label must be between 0 and 100';
    return null;
  }

  static String? optionalPercentageValidator(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return percentageValidator(trimmed, label);
  }
  
  static String? requiredString(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }
}
