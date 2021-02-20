import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' as ma;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monk/src/dto/addressAccess.dart';
import 'package:monk/src/dto/addressOwner.dart';
import 'package:monk/src/dto/settings.dart';
import 'package:monk/src/dto/timeSeriesType.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globalsettings.dart';

class AccessLayer {
  static final AccessLayer _instance = AccessLayer._internal();

  _DataLayer dataLayer;

  Map<String, AddressOwner> addressToOwnerMap;

  factory AccessLayer() => _instance;

  AccessLayer._internal() {
    // init things inside this
  }

  init() async {
    dataLayer = _DataLayer();
    await dataLayer.init();
  }

  register(String moduleIdentifier, String address, String label, String description) {
    if (getOwner(address) == null) {
      // register owner
      _registerOwner(moduleIdentifier, address, label, description);
    } else {
      // show error
      print('Address $address is already registered by $moduleIdentifier');
    }
  }

  registerReadAccess(String moduleIdentifier, String address, String description) {
    _registerAccess(moduleIdentifier, address, description, AccessType.READ);
  }

  getData(String moduleIdentifier, String address, { var defaultVal}) {
    _checkAccess(moduleIdentifier, address, AccessType.READ);
    var value = dataLayer.getData(address);
    if (value == null) {
      return defaultVal;
    }
    return value;
  }

  getSeriesData(String moduleIdentifier, String address, String dateAddress,
      String colorAddress) {
    _checkAccess(moduleIdentifier, address, AccessType.READ);
    return dataLayer.getSeriesData(address, dateAddress, colorAddress);
  }

  getString(String moduleIdentifier, String address, {String defaultValue}) {
    _checkAccess(moduleIdentifier, address, AccessType.READ);
    return dataLayer.getString(address, defaultValue: defaultValue);
  }

  getModuleDataString(String moduleIdentifier, String address, {String defaultValue}) {
    return dataLayer.getString(moduleIdentifier + "->" + address, defaultValue: defaultValue);
  }

  setData(String moduleIdentifier, String address, Object value) {
    _checkAccess(moduleIdentifier, address, AccessType.WRITE);
    dataLayer.setData(address, value);
  }

  setModuleData(String moduleIdentifier, String address, Object value) {
    dataLayer.setData(moduleIdentifier + "->" + address, value);
  }

  bool _checkAccess(String moduleIdentifier, String address, AccessType accessType) {
    if (moduleIdentifier == 'GENERAL') {
      return true;
    }
    if (getOwner(address) == null) {
      throw Exception('No access for $address for module $moduleIdentifier');
    }
    // check owner
    if (getOwner(address).owner == moduleIdentifier) {
      return true;
    }
    if (_getReadAccess(moduleIdentifier, address) && accessType == AccessType.READ) {
      return true;
    }
    throw Exception('No access for $address for module $moduleIdentifier');
  }

  AddressOwner getOwner(String address) {
    if (addressToOwnerMap == null) {
      addressToOwnerMap = {};
      dataLayer.getAddressOwnerList().forEach((addressOwner) =>
          addressToOwnerMap[addressOwner.address] = addressOwner);
    }
    return addressToOwnerMap[address];
  }

  _getReadAccess(String moduleIdentifier, String address) {
    dataLayer.getAddressAccessList().forEach((addressAccess) {
      if (addressAccess.accessor == moduleIdentifier && addressAccess.address == address) {
        return true;
      }
    });
    return false;
  }

  _registerOwner(String moduleIdentifier, String address, String label, String description) {
    AddressOwner addressOwner = AddressOwner(address, moduleIdentifier, label, description);
    var addressOwnerList = dataLayer.getAddressOwnerList();
    addressOwnerList.add(addressOwner);
    dataLayer.setAddressOwnerList(addressOwnerList);
    addressOwnerList.forEach((addressOwner) => addressToOwnerMap[addressOwner.address] = addressOwner);
  }

  _registerAccess(String moduleIdentifier, String address, String description,
      AccessType accessType) {
    AddressOwner addressOwner = getOwner(address);
    if (addressOwner == null) {
      throw Exception('Address $address has no current owner.');
    }
    if (addressOwner.owner == moduleIdentifier) {
      throw Exception('Address is already owned by accessor.');
    }

    var addressAccessList = dataLayer.getAddressAccessList();
    bool found = false;
    for (AddressAccess aa in addressAccessList) {
      //TODO AccessType ggf. aktualisieren
      if (aa.address == address && aa.accessor == moduleIdentifier) {
        found = true;
      }
    }

    if (!found) {
      addressAccessList.add(AddressAccess(address, moduleIdentifier,
          description, accessType));
      dataLayer.setAddressAccessList(addressAccessList);
    }
  }

  void revokeAccess(String address, String moduleIdentifier) {

    var addressAccessList = dataLayer.getAddressAccessList();
    AddressAccess addressAccess = addressAccessList.firstWhere((aa) => aa.address == address && aa.accessor == moduleIdentifier);
    addressAccessList.remove(addressAccess);

    dataLayer.setAddressAccessList(addressAccessList);
  }

  deleteModuleData(String moduleIdentifier) {
    var addressOwnerList = dataLayer.getAddressOwnerList();
    var list = new List();
    for (AddressOwner ao in addressOwnerList) {
      if (ao.owner == moduleIdentifier) {
        list.add(ao);
      }
    }
    for (AddressOwner ao in list) {
      dataLayer.deleteData(ao.address);
    }
  }

  deleteCompleteData() {
    dataLayer.deleteCompleteData();
  }

  Settings getSettings() {
    return dataLayer.getSettings();
  }

  setSettings(Settings settings) {
    dataLayer.setSettings(settings);
  }

  //TODO Basti (modul-id) mitnehmen, bzw modulid automatisch mitsenden?
  setModuleCacheData(String address, Object value) {
    dataLayer.modulecache[address] = value;
  }

  getModuleCacheData(String address) {
    return dataLayer.modulecache[address];
  }


  List<AddressOwner> getAddressOwnerList() {
    return dataLayer.getAddressOwnerList();
  }

  List<AddressAccess> getAddressAccessList() {
    return dataLayer.getAddressAccessList();
  }

  getWriteStream() {
    return dataLayer.writeStream;
  }
}

class _DataLayer {
  static final _settingsKey = "monk.settings";
  static final _addressOwnerKey = "monk.addressOwner";
  static final _addressAccessKey = "monk.addressAccess";
  static final _DataLayer _instance = _DataLayer._internal();
  var modulecache = new Map();


  var data = new Map();
  StreamController<String> writeStream = new StreamController<String>.broadcast();
  SharedPreferences storage;
  IV iv;
  Encrypter encrypter;
  final secureStorage = new FlutterSecureStorage();

  factory _DataLayer() => _instance;

  _DataLayer._internal() {
    // init things inside this
  }


  initDummyData() {

    final int brownCol = ma.Color.fromRGBO(78, 51, 22, 1.0).value;
    final int  greenCol = ma.Color.fromRGBO(86, 100, 20, 1.0).value;
    final int  lehmCol = ma.Color.fromRGBO(147, 143, 124, 1.0).value;
    final int  yelCol = ma.Color.fromRGBO(187, 172, 46, 1.0).value;
    final int  rotCol = ma.Color.fromRGBO(126, 6, 38, 1.0).value;
    final int  schwarzCol = ma.Color.fromRGBO(34, 30, 0, 1.0).value;
    // "Einzelne, feste Kügelchen#Wurstförmig, aber klumpig#Wurstförmig, mit rissiger Oberfläche#Wurstförmig mit glatter Oberfläche#Einzelne, weiche Klümpchen#Sehr weiche, breiige Klümpchen#Flüssig, ohne feste Bestandteile"
    var poopseries = [
      {
        "date": DateTime.now().subtract(Duration(days:0, hours:1)).toIso8601String(),
        "consistency": "Einzelne, feste Kügelchen",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:1, hours: 12)).toIso8601String(),
        "consistency": "Einzelne, feste Kügelchen",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:1, hours: 17)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:2, hours: 9)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": greenCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:2, hours: 12)).toIso8601String(),
        "consistency": "Einzelne, feste Kügelchen",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:2, hours: 17)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:1, hours: 12)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": lehmCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:3, hours: 12)).toIso8601String(),
        "consistency": "Einzelne, feste Kügelchen",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:4, hours: 12)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:4, hours: 17)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:5, hours: 17)).toIso8601String(),
        "consistency": "Flüssig, ohne feste Bestandteile",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:5, hours: 12)).toIso8601String(),
        "consistency": "Flüssig, ohne feste Bestandteile",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:5, hours: 11)).toIso8601String(),
        "consistency": "Flüssig, ohne feste Bestandteile",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },
      {
        "date": DateTime.now().subtract(Duration(days:5, hours: 10)).toIso8601String(),
        "consistency": "Flüssig, ohne feste Bestandteile",
        "color": rotCol,
        "value": 1,
        "pain": 0,
        "tags": []
      }
      ,{
        "date": DateTime.now().subtract(Duration(days:5, hours: 9)).toIso8601String(),
        "consistency": "Flüssig, ohne feste Bestandteile",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:6, hours: 12)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": brownCol,
        "value": 1,
        "pain": 0,
        "tags": []
      },{
        "date": DateTime.now().subtract(Duration(days:7, hours: 17)).toIso8601String(),
        "consistency": "Wurstförmig, mit rissiger Oberfläche",
        "color": greenCol,
        "value": 1,
        "pain": 0,
        "tags": []
      }




    ];

    setData("poopseries", poopseries);
    setData("Stuhltracker_old->last_entry", DateTime.now().toIso8601String());
    setData("document_manager->last_entry", DateTime.now().toIso8601String());
  }

  init() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    storage = await SharedPreferences.getInstance();
    if (!await secureStorage.containsKey(key: 'monk.credentials')) {
      //print('init password');
      var key = _generateRandomString(32);
      IV iv = IV.fromLength(16);
      var credentials = new Map();
      credentials['key'] = key;
      credentials['iv'] = iv.base64;
      await secureStorage.write(
          key: 'monk.credentials', value: jsonEncode(credentials));
    }
    var credentials =
    jsonDecode(await secureStorage.read(key: 'monk.credentials'));
    //print('loaded credentials: $credentials');
    //print('init datalayer');
    iv = IV.fromBase64(credentials['iv']);

    encrypter = Encrypter(AES(Key.fromUtf8(credentials['key'])));
    //print('init datalayer - encrypter ready');

    for (String key in storage.getKeys()) {
      try {
        if (key == _settingsKey) {
          final loadedVal = storage.getString(key);
          //print('init datalayer - cache loading: $key -> $loadedVal');
          data[key] = jsonDecode(loadedVal);
        } else {
          //final loadedVal = storage.getString(key);
          //print('init datalayer - cache loading: $key -> $loadedVal');
          data[key] =
              jsonDecode(encrypter.decrypt64(storage.getString(key), iv: iv));
          //print('init datalayer - cache loading: $key -> ' + data[key].toString());
        }
      } catch (e) {
        //print("error loading string");
      }
    }
    print('DataLayer inititated in ${stopwatch.elapsed}');

    if(GlobalSettings.generateDummyData) {
      if (getData("poopseries") == null) {
        initDummyData();
      }
    }

  }

  getData(String address) {
    //print('getData $address ' + data[address].toString());
    return json.decode(json.encode(data[address]));
  }

  getSeriesData(String address, String dateAddress, String colorAddress) {
    if (data[address + "_series"] != null) {
      return data[address + "_series"];
    }
    List<dynamic> val = data[address];
    List<TimeSeriesType> list = val.map((element) {
      return TimeSeriesType(element, dateAddress, colorAddress);
    }).toList();
    data[address + "_series"] = list;
    return list;
  }


  getString(String address, {String defaultValue}) {
    if (data[address] == null) {
      return defaultValue;
    }
    return data[address];
  }

  Settings getSettings() {
    if (storage.containsKey(_settingsKey)) {
      return Settings.fromJson(jsonDecode(storage.getString(_settingsKey)));
    }
    return Settings();
  }

  setData(String address, Object value) {
    //print('storing $value to $address');
    data[address] = value;

    writeStream.add(address);

    storage.setString(
        address, encrypter.encrypt(jsonEncode(value), iv: iv).base64);
    //print('getData $address ' + data[address].toString());
  }

  setSeriesData(String address, Object value) {
    data[address + "_series"] = value;
    setData(address, value);
  }

  setSettings(Settings settings) {
    storage.setString(_settingsKey, jsonEncode(settings));
  }


  setAddressOwnerList(List<AddressOwner> addressOwnerList) {
    storage.setString(_addressOwnerKey, jsonEncode(addressOwnerList));
  }

  List<AddressOwner> getAddressOwnerList() {
    if (storage.containsKey(_addressOwnerKey)) {
      return List<AddressOwner>.from((jsonDecode(storage.getString(_addressOwnerKey)) as List)
          .map((addressOwner) => AddressOwner.fromJson(addressOwner)));
    }
    return List();
  }

  List<AddressAccess> getAddressAccessList() {
    if (storage.containsKey(_addressAccessKey)) {
      return List<AddressAccess>.from((jsonDecode(storage.getString(_addressAccessKey)) as List)
          .map((addressAccess) => AddressAccess.fromJson(addressAccess)));
    }
    return List();
  }

  setAddressAccessList(List<AddressAccess> addressAccessList) {
    storage.setString(_addressAccessKey, jsonEncode(addressAccessList));
  }

  deleteCompleteData() {
    data.clear();
    storage.clear();
  }

  deleteData(String address) {
    data.remove(address);
    storage.remove(address);
  }

  String _generateRandomString(int len) {
    var r = Random.secure();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  getModuleCache() {
    return modulecache;
  }
}
