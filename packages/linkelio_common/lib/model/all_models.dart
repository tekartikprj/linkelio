import 'package:linkelio_common/model/fs_link.dart';
import 'package:tkcms_common/tkcms_api.dart';
import 'package:tkcms_common/tkcms_firestore.dart';

var _done = false;
void linkelioInitApiBuilders() {
  initApiBuilders();
  // common
  //cvAddConstructors([

  //]);
}

void linkelioInitFsBuilders() {
  initFsBuilders();
  // firestore
  cvAddConstructors([
    FsLink.new,
  ]);
  //cvAddConstructors([CvSubClass.new]);
}

void linkelioInitAllBuilders() {
  if (!_done) {
    _done = true;

    linkelioInitApiBuilders();

    linkelioInitFsBuilders();

    // initCsvExportBuilders();*/
  }
}
