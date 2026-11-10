# linkelio_common

The shared Dart code of Linkelio, a url shortener built on `tkcms_common`:

- `FsLink` (`model/fs_link.dart`): a link document (`url`, `active`,
  `created`, `userId`); no `active` field means active.
- `LinkelioFirestoreDatabaseService` (`firestore/firestore_database.dart`):
  the links of an app (`<app document>/link/<id>`), `getLink(id)`.
- `LinkelioServerApp` (`server/linkelio_server_app.dart`): the tkcms server
  app plus the link function (`linkv1dev` / `linkv1prod`) answering
  `<host>/<id>` with a 302 to the stored url.
- `initLinkelioFirebaseLocal` / `initLinkelioLocal`
  (`firebase/firebase_local.dart`): the whole stack served locally, for
  development and tests.

Not on pub.dev: depend on it by git.

## Getting started

```yaml
dependencies:
  linkelio_common:
    git:
      url: https://github.com/tekartikprj/linkelio.git
      path: packages/linkelio_common
```

Dart SDK `^3.12.0`, Dart VM (server side code). A link stored and read on
the in memory firebase ([example/main.dart](example/main.dart),
`dart run example/main.dart`):

```dart
import 'package:linkelio_common/firebase/firebase_local.dart';
import 'package:linkelio_common/firestore/firestore_database.dart';
import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_firestore.dart';
import 'package:tkcms_common/tkcms_flavor.dart';

Future<void> main() async {
  const app = 'linkelio_example';
  var firebaseContext = await (await initFirebaseServicesMemory())
      .initLinkelioLocal(app: app);
  var database = LinkelioFirestoreDatabaseService(
    firebaseContext: firebaseContext,
    flavorContext: AppFlavorContext(app: app, flavorContext: FlavorContext.dev),
  );
  // <host>/<function>/promo redirects (302) to the url.
  await database
      .fsLinkRef('promo')
      .set(database.firestore, FsLink()..url.v = 'https://example.com/long');
  print((await database.getLink('promo')).url.v);
  await firebaseContext.close();
}
```

## The link function

- The id is the last non empty path segment, percent decoded (`/a%20b` is
  the link `a b`, `/caf%C3%A9` the link `café`). A segment that is not a
  document id (`.`, `..`, a decoded `/`) is not found.
- Found, active and with a url: 302 to it (not 301: browsers keep a 301 for
  ever).
- Otherwise: the html "Link <id> not found" page (`linkNotFoundContent`, the
  id html escaped), status 200, `text/html; charset=utf-8`.
- An error answers 500 with the error text and its stack trace (tkcms
  `sendCatchErrorResponse`).

## What to know

- `initLinkelioFirebaseLocal(sembastDatabaseFactory:, projectId:, app:)`
  persists in sembast databases (a file factory for a dev server,
  `newDatabaseFactoryMemory()` in tests); `initFirebaseServicesMemory()` +
  `initLinkelioLocal(app:)` is all in memory.
- The local memory http server does not implement redirects: test the link
  function by calling `LinkelioServerApp.linkHttp` with a request of your own
  (`test/linkelio_server_app_test.dart`).
- `constants.dart`: `functionLinkV1Dev` is `linkv1dev`, `functionLinkV1Prod`
  `linkv1prod` (their doc comments are swapped).

More in the [linkelio-common-server](skills/linkelio-common-server/SKILL.md)
skill.
