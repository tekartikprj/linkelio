import 'package:linkelio_common/model/all_models.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';

/// Linkelio app
typedef FsLinkelioApp = TkCmsFsApp;

/// Firestore database service for Linkelio
class LinkelioFirestoreDatabaseService extends TkCmsFirestoreDatabaseService {
  /// App entity access
  late final appEntityAccess =
      TkCmsFirestoreDatabaseServiceEntityAccess<FsLinkelioApp>(
        firestore: this.firebaseContext.firestore,
        entityCollectionInfo: tkCmsFsAppCollectionInfo,
      );

  /// Constructor
  LinkelioFirestoreDatabaseService({
    required super.firebaseContext,
    required super.flavorContext,
  }) {
    linkelioInitFsBuilders();
  }

  /// Root document ref (which might not even exists)
  CvDocumentReference<FsLinkelioApp> get fsAppRef =>
      appEntityAccess.fsEntityRef(app);

  /// Link collection ref
  CvCollectionReference<FsLink> get fsLinkCollectionRef =>
      fsAppRef.collection<FsLink>('link');

  /// Link ref
  CvDocumentReference<FsLink> fsLinkRef(String linkId) =>
      fsLinkCollectionRef.doc(linkId);

  /// Get a link
  Future<FsLink> getLink(String linkId) => fsLinkRef(linkId).get(firestore);
}
