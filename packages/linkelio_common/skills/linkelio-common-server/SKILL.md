---
name: linkelio-common-server
description: >-
  Use when working on Linkelio, the tkcms based url shortener: the FsLink
  firestore document (url, active, created, userId, isActive, fsLinkModel),
  LinkelioFirestoreDatabaseService (fsAppRef, fsLinkCollectionRef, fsLinkRef,
  getLink), the LinkelioServerApp firebase function that 301-redirects a short
  link (linkV1, linkHttp, functionLinkV1Dev/functionLinkV1Prod), the not found
  page (linkNotFoundContent, notFoundContent), the builders
  (linkelioInitAllBuilders, linkelioInitFsBuilders, linkelioInitApiBuilders)
  and the local sembast bootstrap initLinkelioFirebaseLocal /
  initLinkelioLocal.
---

# Linkelio shared server code (linkelio_common)

`linkelio_common` is the shared Dart code of Linkelio, a url shortener built on
`tkcms_common`: one firestore document type (`FsLink`), the database service
that reads it, the firebase function that resolves `<host>/<linkId>` into a 301
redirect, and a local (sembast) firebase setup for dev and tests. It is the
only package of a private project repository, so there is no pub.dev release.

## Guidelines

* Dependency (git, private project repo):
  ```yaml
  dependencies:
    linkelio_common:
      git:
        url: https://github.com/tekartikprj/linkelio.git
        path: packages/linkelio_common
  ```
  It pulls `tkcms_common` (the whole cms/firestore/server layer),
  `tekartik_app_cv_firestore`, `tekartik_app_http` and `tekartik_mustache`.
* Libraries, all directly importable, none exported by a single barrel:
  * `package:linkelio_common/import_common.dart`: convenience re-export of
    `tekartik_app_cv_firestore/app_cv_firestore.dart` and
    `tkcms_common/tkcms_common.dart` only. It does **not** re-export the
    firestore/server/flavor tkcms libraries: import
    `package:tkcms_common/tkcms_firestore.dart` (also gives `FirebaseContext`,
    `Firestore`, `Timestamp`), `.../tkcms_flavor.dart` (`FlavorContext`,
    `AppFlavorContext`) and `.../tkcms_server.dart`
    (`TkCmsServerAppContext`) explicitly.
  * `model/fs_link.dart`: `FsLink`, `fsLinkModel`.
  * `model/all_models.dart`: `linkelioInitApiBuilders()`,
    `linkelioInitFsBuilders()`, `linkelioInitAllBuilders()`.
  * `firestore/firestore_database.dart`: `LinkelioFirestoreDatabaseService`,
    `FsLinkelioApp` (a typedef for tkcms' `TkCmsFsApp`).
  * `server/linkelio_server_app.dart`: `LinkelioServerApp`.
  * `html/html.dart`: `linkNotFoundContent(link)`, `notFoundContent`.
  * `firebase/firebase_local.dart`: `initLinkelioFirebaseLocal(...)` and the
    `LinkelioFirebaseServiceContext` extension (`initLinkelioLocal`).
  * `constants.dart`: `functionLinkV1Dev` (`'linkv1dev'`) and
    `functionLinkV1Prod` (`'linkv1prod'`). Their doc comments are swapped in
    the source; trust the names and the values.
* `FsLink` is a `CvFirestoreDocumentBase` with four fields: `url`
  (`CvField<String>`), `active` (`CvField<bool>`), `created`
  (`CvField<Timestamp>`) and `userId` (`CvField<String>`). Read and write them
  through `.v` (`link.url.v = 'https://...'`). `isActive` returns
  `active.value ?? true`: **a link with no `active` field is active**. Like any
  cv document it also has `id`, `path` and `exists`.
  `fsLinkModel` is a shared model instance, for field names in queries; never
  set values on it.
* Builders: `linkelioInitAllBuilders()` (idempotent, guarded by a private
  flag) registers the api and firestore constructors; `linkelioInitFsBuilders()`
  adds `cvAddConstructors([FsLink.new])` on top of tkcms' `initFsBuilders()`.
  `LinkelioServerApp`'s constructor calls `linkelioInitAllBuilders()` and
  `LinkelioFirestoreDatabaseService`'s calls `linkelioInitFsBuilders()`, so a
  standalone script that only deserializes json must call them itself, before
  any `cv<FsLink>()`.
* `LinkelioFirestoreDatabaseService({required firebaseContext, required
  flavorContext})` takes an `AppFlavorContext` (`app` is the tkcms app id, e.g.
  the value passed to `LinkelioServerApp.app`). Paths: `fsAppRef` is the app
  entity document, `fsLinkCollectionRef` its `link` sub collection,
  `fsLinkRef(linkId)` one document, and `getLink(linkId)` is
  `fsLinkRef(linkId).get(firestore)`. `get` never throws for a missing
  document: check `link.exists` (or a null/empty `url.v`) before redirecting,
  which is what the server does.
* `LinkelioServerApp extends TkCmsServerAppV2` with `apiVersion2`, and takes
  `context: TkCmsServerAppContext(...)` plus `app:`. `initFunctions()`
  registers `linkV1` under `functionLinkV1Prod` for `FlavorContext.prod` /
  `prodx` and under `functionLinkV1Dev` for everything else, then calls
  `super.initFunctions()` (the standard tkcms api functions). The function is
  `onRequest` with `HttpsOptions(cors: true, region: regionBelgium)`.
* `linkHttp` takes the **last path segment** as the link id, loads it, and
  `res.redirect(Uri.parse(url), status: 301)` when the stored `url` is not
  empty; otherwise it answers `linkNotFoundContent(id)` as `text/html`. Any
  error goes through tkcms' `sendCatchErrorResponse`. Keep new behaviour inside
  that try/catch so a failure never leaks a stack trace to the browser.
* `linkNotFoundContent(link)` renders the `notFoundContent` mustache template
  (`tekartik_mustache`'s synchronous `render`) with a single `{{link}}`
  variable. It is plain interpolation, not escaping: do not feed it anything
  but a link id.
* Local/dev/test setup: `initLinkelioFirebaseLocal(sembastDatabaseFactory:
  ..., projectId: ..., app: ..., isWeb: false)` builds the whole local firebase
  stack (sembast firestore + auth, memory functions), creates a
  `LinkelioServerApp` on `FlavorContext.dev`, calls `initFunctions()`, serves
  the functions and returns the `FirebaseContext`. Add `sembast` (or
  `tekartik_app_sembast`) to your own dependencies for the factory:
  `newDatabaseFactoryMemory()` for tests, a file based factory for a dev run.
  The served functions are reachable through the returned context
  (`ffServerOrNull`), and `initLinkelioLocal` on a `FirebaseServicesContext` is
  the same thing when you already built the services yourself.
* Everything here is server/VM oriented (`dart:io` through the local firebase
  stack); the package itself ships no test, no example and no `bin/`. Write
  tests in the consuming package (`@TestOn('vm')`) on top of
  `initLinkelioFirebaseLocal`.

## Examples

### Create and resolve a short link

```dart
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';
import 'package:tkcms_common/tkcms_flavor.dart';

Future<void> demo(FirebaseContext firebaseContext) async {
  var database = LinkelioFirestoreDatabaseService(
    firebaseContext: firebaseContext,
    flavorContext: AppFlavorContext(
      app: 'linkelio',
      flavorContext: FlavorContext.dev,
    ),
  );
  var firestore = database.firestore;

  var link = FsLink()
    ..url.v = 'https://example.com/a/very/long/url'
    ..active.v = true
    ..created.v = Timestamp.now()
    ..userId.v = 'user1';

  // Chosen id: <app doc>/link/my_id
  await database.fsLinkRef('my_id').set(firestore, link);
  // Or let firestore generate one.
  var added = await database.fsLinkCollectionRef.add(firestore, link);
  print('added ${added.id}');

  var read = await database.getLink('my_id');
  if (read.exists && read.isActive && (read.url.v?.isNotEmpty ?? false)) {
    print('redirect to ${read.url.v}');
  } else {
    print('not found');
  }
}
```

### Register the link functions in a firebase functions entry point

```dart
import 'package:linkelio_common/constants.dart';
import 'package:linkelio_common/server/linkelio_server_app.dart';
import 'package:tkcms_common/tkcms_firebase.dart';
import 'package:tkcms_common/tkcms_flavor.dart';
import 'package:tkcms_common/tkcms_server.dart';

/// Called from the `bin/main.dart` of the functions package, once the
/// firebase context is initialized (node or io).
void initLinkelioFunctions(FirebaseContext firebaseContext, String app) {
  for (var flavorContext in [FlavorContext.dev, FlavorContext.prod]) {
    LinkelioServerApp(
      app: app,
      context: TkCmsServerAppContext(
        firebaseContext: firebaseContext,
        flavorContext: flavorContext,
      ),
    ).initFunctions();
  }
  print('serving $functionLinkV1Dev and $functionLinkV1Prod');
}
```

### Test against the local sembast firebase stack

```dart
@TestOn('vm')
library;

import 'package:linkelio_common/firebase/firebase_local.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:test/test.dart';
import 'package:tkcms_common/tkcms_flavor.dart';

void main() {
  test('add and read a link', () async {
    var firebaseContext = await initLinkelioFirebaseLocal(
      sembastDatabaseFactory: newDatabaseFactoryMemory(),
      projectId: 'linkelio-test',
      app: 'linkelio',
    );
    var database = LinkelioFirestoreDatabaseService(
      firebaseContext: firebaseContext,
      flavorContext: AppFlavorContext(
        app: 'linkelio',
        flavorContext: FlavorContext.dev,
      ),
    );
    await database.fsLinkRef('id1').set(
      database.firestore,
      FsLink()..url.v = 'https://example.com',
    );

    var link = await database.getLink('id1');
    expect(link.exists, isTrue);
    expect(link.url.v, 'https://example.com');
    // No active field means active.
    expect(link.isActive, isTrue);
  });
}
```

### Render the not found page

```dart
import 'package:linkelio_common/html/html.dart';

void main() {
  // The same html the link function returns for an unknown id.
  var html = linkNotFoundContent('unknown_id');
  print(html.contains('Link unknown_id not found'));
}
```
