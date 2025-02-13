import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_api.dart';
import 'package:tkcms_common/tkcms_firestore.dart';

var _done = false;

/// Initialize all builders
void linkelioInitApiBuilders() {
  initApiBuilders();
  // common
  //cvAddConstructors([

  //]);
}

/// Initialize all builders
void linkelioInitFsBuilders() {
  initFsBuilders();
  // firestore
  cvAddConstructors([FsLink.new]);
  //cvAddConstructors([CvSubClass.new]);
}

/// Initialize all builders
void linkelioInitAllBuilders() {
  if (!_done) {
    _done = true;

    linkelioInitApiBuilders();

    linkelioInitFsBuilders();

    // initCsvExportBuilders();*/
  }
}
