import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';

class LinkelioFirestoreDatabaseService extends TkCmsFirestoreDatabaseService {
  LinkelioFirestoreDatabaseService(
      {required super.firebaseContext, required super.flavorContext});

  Future<FsLink> getLink(String linkId) =>
      fsAppLinkCollection(app).doc(linkId).get(firestore);
}
