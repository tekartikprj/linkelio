import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';

/// Firestore database service for Linkelio
class LinkelioFirestoreDatabaseService extends TkCmsFirestoreDatabaseService {
  /// Constructor
  LinkelioFirestoreDatabaseService(
      {required super.firebaseContext, required super.flavorContext});

  /// Get link by id
  Future<FsLink> getLink(String linkId) =>
      fsAppLinkCollection(app).doc(linkId).get(firestore);
}
