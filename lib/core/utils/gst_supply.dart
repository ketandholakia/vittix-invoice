import '../../database/app_database.dart';
import 'gstin_validator.dart';

/// The customer's GST state code: the explicit [Customer.stateCode] when set,
/// otherwise the state encoded in a valid GSTIN, otherwise null.
///
/// Used for both supply-type and place-of-supply derivation so the two never
/// disagree (e.g. a customer with a GSTIN but no explicit state code).
int? customerStateCode(Customer customer) {
  if (customer.stateCode != null) return customer.stateCode;
  final gstin = customer.gstin;
  if (gstin != null && GstinValidator.isValid(gstin)) {
    return GstinValidator.extractStateCode(gstin);
  }
  return null;
}

/// B2B when the customer has a valid GSTIN, otherwise B2C.
String deriveSupplyType(Customer customer) =>
    GstinValidator.isValid(customer.gstin ?? '') ? 'B2B' : 'B2C';

/// Place of supply: the customer's state, falling back to the supplier's state.
///
/// State 0 is not a valid GST state, so the business state is preferred over
/// recording an invoice with an impossible place of supply.
int derivePlaceOfSupply(Customer customer, Business business) =>
    customerStateCode(customer) ?? business.stateCode;
