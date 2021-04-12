import 'dart:core';

import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<void> writeToFile(Uint8List data, String path) {
  return new File(path).writeAsBytes(data);
}

Future<String> createFolderInAppDocDir(String folderName) async {
//Get this App Document Directory
final Directory _appDocDir = await getApplicationDocumentsDirectory();
//App Document Directory + folder name
final Directory _appDocDirFolder = Directory(
    '${_appDocDir.path}/$folderName/');

if (await _appDocDirFolder
    .exists()) { //if folder already exists return path
return _appDocDirFolder.path;
} else { //if folder not exists create folder and then return its path
final Directory _appDocDirNewFolder = await _appDocDirFolder.create(
recursive: true);
return _appDocDirNewFolder.path;
}
}

bool safeCheckMapEntry(Map map, dynamic key, dynamic checkValue)
{
  if(map.containsKey(key))
    {
      if(checkValue == map[key])
        {
          return true;
        }
      else
        {
          return false;
        }
    }
  else{
    return false;
  }

}

dynamic getMapValueWithDef(Map map, dynamic key, dynamic defaultValue)
{
  if(map.containsKey(key))
  {
    return map[key];

  }
  else{
    return defaultValue;
  }
}

String convertDateTimeToRelative(DateTime theTime )
{
  DateTime now = DateTime.now();
  DateTime justNow = now.subtract(Duration(minutes: 1));
  DateTime localDateTime = theTime;
  if (!localDateTime.difference(justNow).isNegative) {
    return 'Gerade Eben';
  }

  String roughTimeString = DateFormat('jm').format(theTime);
  if (theTime.day == now.day && theTime.month == now.month && theTime.year == now.year) {
    return 'Heute ' + roughTimeString;
  }

  DateTime yesterday = now.subtract(Duration(days: 1));
  if (theTime.day == yesterday.day && theTime.month == yesterday.month && theTime.year == yesterday.year) {
    return 'Gestern ' + roughTimeString;
  }

  if (now.difference(theTime).inDays < 4) {
    String weekday = DateFormat('EEEE').format(theTime);
    return '$weekday, $roughTimeString';
  }

  return '${DateFormat('yMd').format(theTime)}, $roughTimeString';

}

String convertDateTimeToRelativeFuture(DateTime theTime )
{
  DateTime now = DateTime.now();
  DateTime justNow = now.add(Duration(minutes: 10));
  DateTime localDateTime = theTime;
  if (!justNow.difference(localDateTime).isNegative) {
    return 'Gleich';
  }

  String roughTimeString = DateFormat('jm').format(theTime);
  if (theTime.day == now.day && theTime.month == now.month && theTime.year == now.year) {
    return 'Heute ' + roughTimeString;
  }

  DateTime tomorrow = now.add(Duration(days: 1));
  if (theTime.day == tomorrow.day && theTime.month == tomorrow.month && theTime.year == tomorrow.year) {
    return 'Morgen ' + roughTimeString;
  }

  if (theTime.difference(now).inDays < 4) {
    String weekday = DateFormat('EEEE').format(theTime);
    return '$weekday, $roughTimeString';
  }

  return '${DateFormat('yMd').format(theTime)}, $roughTimeString';

}
