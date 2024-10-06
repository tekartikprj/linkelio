import 'package:tkcms_common/tkcms_firestore.dart';

/// Firestore document for a link
class FsLink extends CvFirestoreDocumentBase {
  /// url redirection
  final url = CvField<String>('url');

  /// active status, default to true!
  final active = CvField<bool>('active');

  /// Timestamp
  final created = CvField<Timestamp>('created');

  /// User id
  final userId = CvField<String>('userId');

  /// get active status
  bool get isActive => active.value ?? true;

  @override
  CvFields get fields => [url, active, created, userId];
}

/// FsLink model (for queries)
final fsLinkModel = FsLink();
