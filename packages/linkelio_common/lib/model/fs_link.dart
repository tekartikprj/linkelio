import 'package:tkcms_common/tkcms_firestore.dart';

/// Firestore document for a link
class FsLink extends CvFirestoreDocumentBase {
  /// url redirection
  final url = CvField<String>('url');

  @override
  CvFields get fields => [url];
}

/// FsLink model (for queries)
final fsLinkModel = FsLink();
