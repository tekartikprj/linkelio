// ignore_for_file: depend_on_referenced_packages

import 'package:linkelio_common/server/linkelio_server_app.dart';
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tkcms_common/tkcms_common.dart';
import 'package:tkcms_common/tkcms_firebase.dart';
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

/// app used as package name
Future<FirebaseContext> initLinkelioFirebaseLocal({
  required String projectId,
  required String app,
  bool isWeb = false,
}) async {
  return await initFirebaseServicesLocalSembast(
    projectId: projectId,
    isWeb: isWeb,
  ).initLinkelioLocal(app: app);
}

/// Linkelio local init extension
extension LinkelioFirebaseServiceContext on FirebaseServicesContext {
  /// Init server
  Future<FirebaseContext> initLinkelioLocal({
    FirebaseApp? firebaseApp,
    required String app,
    Uri? baseUri,
    bool debugFirestore = false,
  }) async {
    firebaseApp ??= await initApp();

    var functions = functionsService.functions(firebaseApp);
    var auth = authService.auth(firebaseApp);
    var firestore = firestoreService.firestore(firebaseApp);
    if (debugFirestore) {
      // ignore: avoid_print
      print('debug firestore');
      // ignore: deprecated_member_use
      firestore = firestore.debugQuickLoggerWrapper();
    }

    var serverApp = LinkelioServerApp(
      app: app,
      context: TkCmsServerAppContext(
        firebaseContext: FirebaseContext(
          auth: auth,
          functions: functions,
          firestore: firestore,
          firebase: firebase,
          firebaseApp: firebaseApp,
        ),
        flavorContext: FlavorContext.dev,
      ),
    );

    serverApp.initFunctions();
    var ffServer = await functions.serve();
    //var ffServer = await functions.serve();
    //baseUri ??= server.clientUri; // server.uri; //clientUri;
    var firebaseContext = init(
      firebaseApp: firebaseApp,
      ffServer: ffServer,
      serverApp: serverApp,
      debugFirestore: debugFirestore,
    );

    return firebaseContext;
  }
}
