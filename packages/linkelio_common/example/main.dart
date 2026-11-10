// ignore_for_file: avoid_print

// A short link stored and read back on the in memory firebase, with the link
// function served locally (memory http).
import 'package:linkelio_common/firebase/firebase_local.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/html/html.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';
import 'package:tkcms_common/tkcms_flavor.dart';

Future<void> main() async {
  const app = 'linkelio_example';
  // Memory firestore and auth, the link function served on memory http.
  var firebaseContext = await (await initFirebaseServicesMemory())
      .initLinkelioLocal(app: app);

  var database = LinkelioFirestoreDatabaseService(
    firebaseContext: firebaseContext,
    flavorContext: AppFlavorContext(app: app, flavorContext: FlavorContext.dev),
  );
  // <host>/<function>/promo redirects (302) to the url.
  await database
      .fsLinkRef('promo')
      .set(
        database.firestore,
        FsLink()
          ..url.v = 'https://example.com/a/very/long/url'
          ..created.v = Timestamp.now(),
      );

  var link = await database.getLink('promo');
  print('promo -> ${link.url.v} (active: ${link.isActive})');
  var missing = await database.getLink('missing');
  print('missing exists: ${missing.exists}');
  print(linkNotFoundContent('missing').contains('Link missing not found'));

  await firebaseContext.close();
}
