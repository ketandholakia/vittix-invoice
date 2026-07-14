import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/google_drive_service.dart';

final googleDriveAccountProvider = FutureProvider<GoogleSignInAccount?>((ref) {
  return GoogleDriveService.instance.currentAccount();
});
