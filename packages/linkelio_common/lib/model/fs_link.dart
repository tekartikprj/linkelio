import 'package:tkcms_common/tkcms_firestore.dart';

/// Firestore document for a link
class FsLink extends CvFirestoreDocumentBase {
  /// url redirection
  final url = CvField<String>('url');

  @override
  CvFields get fields => [url];
}

/// Get the collection reference for links
CvCollectionReference<FsLink> fsAppLinkCollection(String app) =>
    fsAppRoot(app).collection<FsLink>('link');
