import 'package:tkcms_common/tkcms_firestore.dart';

class FsLink extends CvFirestoreDocumentBase {
  final url = CvField<String>('url');

  @override
  CvFields get fields => [url];
}

CvCollectionReference<FsLink> fsAppLinkCollection(String app) =>
    fsAppRoot(app).collection<FsLink>('link');
