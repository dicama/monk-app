import 'package:flutter/material.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/fullpdfviewer.dart';
import 'package:monk/src/modules/lib/documentmanager/screens/imgviewer.dart';
import 'package:monk/src/service/encryptedfs.dart';

import 'screens/pdfviewer.dart';

class FileOpenHandler {

  static open(FileSysFile file, BuildContext context) async
  {
    if(file.fileType == FileSysFileType.image)
    {
      await Navigator.of(context).push(

        MaterialPageRoute(
            builder: (context) =>
                ImgViewer(file.name, EncryptedFS().loadEncryptedFile(file.uid))),
      );
    }
    else if(file.fileType == FileSysFileType.pdf)
    {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                FullPDFViewer(file.name, EncryptedFS().loadEncryptedFile(file.uid))),
      );
    }



  }




}