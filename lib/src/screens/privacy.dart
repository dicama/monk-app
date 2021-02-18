import 'package:flutter/material.dart';
import 'package:monk/src/bars/MonkScaffold.dart';
import 'package:monk/src/dto/addressAccess.dart';
import 'package:monk/src/models/DrawerModel.dart';
import 'package:monk/src/modules/basicmodule.dart';
import 'package:monk/src/service/accesslayer.dart';
import 'package:monk/src/dto/addressOwner.dart';
import 'package:monk/src/service/moduleloader.dart';
import 'package:provider/provider.dart';

//TODO Basti aufräumen, Code wiederverwenden, Reload nach Löschen des Zugriffs
class Privacy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<AddressOwner> addressOwnerList = AccessLayer().getAddressOwnerList();
    List<AddressAccess> addressAccessList = AccessLayer().getAddressAccessList();

    var drawerModel = Provider.of<DrawerModel>(context);
    String selectedModuleStr = drawerModel.selectedModule;
    var selectedModule = ModuleLoader().modules.firstWhere(
        (element) => element.name == selectedModuleStr,
        orElse: () => null);

    return DefaultTabController(
        length: 3,
        initialIndex: selectedModule == null ? 0 : 1,
        child: MonkScaffold(
            title: "Datenschutz",
            tabBar: TabBar(
              tabs: [
                Tab(text: 'Info'),
                Tab(text: 'Module'),
                Tab(text: 'Daten')
              ],
            ),
            body: TabBarView(children: [
            Padding( padding: EdgeInsets.all(10),
            child:ListView(padding: const EdgeInsets.all(10), children: <Widget>[
                Text('Warum ist MONK sicher?',
                    style: Theme.of(context).textTheme.headline5),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                        'Alle Deine persönlichen Daten werden ausschließlich auf Deinem Handy gespeichert und verschlüsselt. Der Verschlüsselungskey wird mit keinem externen Service oder Server geteilt. Es gibt darüber hinaus in der MONK Architektur keinen Server, der gehackt werden kann. Um an Deine Daten zu kommen muss wirklich jemand Zugriff auf Dein Smartphone bekommen. Selbst auf dem Smartphone lässt sich MONK darüber hinaus noch durch einen Fingerabdruck oder einen PIN absichern.',
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.justify,)),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                        'Das ganze kommt natürlich zu einem Preis: Ist Dein Handy weg, so sind auch Deine Daten für immer verloren, da diese nicht auf einem Server im Backup liegen. Als Lösung dazu wollen wir in der Zukunft wenigstens ein manuelles Backup erlauben, mit welchem Deine Daten in einem verschlüsselten ZIP-File gesichert werden. Du kannst es dann dort ablegen, wo Du es für am sichersten hältst. Und ohne dein selbstgewähltes Passwort kann keiner etwas mit der ZIP Datei anfangen.',
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.justify)),
              ])),
              buildModuleTab(context, addressOwnerList, addressAccessList,
                  selectedModule == null ? null : selectedModule.name),
              buildAddressTab(context, addressOwnerList, addressAccessList)
            ])));
  }

  Widget buildModuleTab(
      BuildContext context,
      List<AddressOwner> addressOwnerList,
      List<AddressAccess> addressAccessList,
      String selectedModule) {
    List<Widget> list = new List<Widget>();
    ModuleLoader().modules.forEach((module) {
      var themeData = Theme.of(context);
      list.add(Container(
          margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Color.fromRGBO(226, 224, 228, 1), width: 0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Wrap(children: [
                    Container(
                        child: Row(children: <Widget>[
                          Container(
                              child: module.getModuleIcon(size: 25),
                              padding: EdgeInsets.fromLTRB(12, 0, 8, 0)),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(),
                            height: 40,
                            padding: EdgeInsets.fromLTRB(8, 12, 0, 0),
                            child: Text(module.name ?? "Modulname",
                                // instered null checks here
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.87),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1)),
                          )),
                        ]),
                        color: selectedModule == module.name
                            ? themeData.secondaryHeaderColor
                            : themeData.accentColor),
                    Container(
                        child: buildAddressOwnerInfo(context, module,
                            addressOwnerList, addressAccessList),
                        color: Colors.white)
                  ])))));
    });

    return ListView(
      padding: EdgeInsets.all(10),
      children: list,
    );
  }

  Widget buildAddressTab(
      BuildContext context,
      List<AddressOwner> addressOwnerList,
      List<AddressAccess> addressAccessList) {
    List<Widget> list = new List<Widget>();

    addressOwnerList.forEach((addressOwner) {
      list.add(Container(
          margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Color.fromRGBO(226, 224, 228, 1), width: 0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Wrap(children: [
                    Container(
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(),
                            height: 40,
                            padding: EdgeInsets.fromLTRB(8, 12, 0, 0),
                            child: Text(addressOwner.label ?? "Label",
                                // instered null checks here
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.87),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1)),
                          )),
                        ]),
                        color: Theme.of(context).accentColor),
                    Container(
                        child: buildAddressInfo(context, addressOwner,
                            addressOwnerList, addressAccessList),
                        color: Colors.white)
                  ])))));
    });

    return ListView(
      padding: EdgeInsets.all(10),
      children: list,
    );
  }

  Widget buildAddressOwnerInfo(
      BuildContext context,
      BasicModule currentModule,
      List<AddressOwner> addressOwnerList,
      List<AddressAccess> addressAccessList) {
    List<Widget> list = new List<Widget>();
    addressOwnerList.forEach((element) {
      if (currentModule.id == element.owner) {
        list.add(
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(element.label ?? "Label", // instered null checks here
                  style: Theme.of(context).textTheme.bodyText1)),
          element.description != null
              ? IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'Modul: ' +
                                    currentModule.name +
                                    "\nDatenwert: " +
                                    element.address,
                                style: Theme.of(context).textTheme.bodyText1),
                            content: SingleChildScrollView(
                                child: Text(
                                    element.description ?? "keine Beschreibung",
                                    style:
                                        Theme.of(context).textTheme.bodyText2)),
                          );
                        });
                  },
                )
              : Container(),
        ]));
      }
    });

    addressAccessList.forEach((element) {
      if (currentModule.id == element.accessor) {
        AddressOwner addressOwner = AccessLayer().getOwner(element.address);
        BasicModule basicModule = ModuleLoader()
            .modules
            .firstWhere((element) => element.id == addressOwner.owner);

        list.add(
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(addressOwner.label + " (" + basicModule.name + ")",
                  style: Theme.of(context).textTheme.bodyText1)),
          element.description != null
              ? IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'Modul: ' +
                                    currentModule.name +
                                    "\nDatenwert: " +
                                    addressOwner.label,
                                style: Theme.of(context).textTheme.bodyText1),
                            content: SingleChildScrollView(
                                child: Text(
                                    element.description ?? "keine Beschreibung",
                                    style:
                                        Theme.of(context).textTheme.bodyText2)),
                          );
                        });
                  },
                )
              : Container(),
        ]));
      }
    });

    if (list.length == 0) {
      return Container();
    } else {
      return Column(children: list);
    }
  }

  Widget buildAddressAccessInfo(
      BuildContext context, List<AddressAccess> addressAccessList) {
    List<Widget> list = new List<Widget>();
    addressAccessList.forEach((element) {
      list.add(Text(
          element.address +
              " (" +
              AccessLayer().getOwner(element.address).owner +
              ") -> " +
              element.accessor +
              " (" +
              element.accessType.toString() +
              ")",
          style: Theme.of(context).textTheme.bodyText1));
    });
    return Column(children: list);
  }

  Widget buildAddressInfo(
      BuildContext context,
      AddressOwner addressOwner,
      List<AddressOwner> addressOwnerList,
      List<AddressAccess> addressAccessList) {
    List<Widget> list = new List<Widget>();
    addressOwnerList.forEach((element) {
      if (addressOwner.address == element.address) {
        BasicModule basicModule = ModuleLoader().modules.firstWhere(
            (module) => module.id == element.owner,
            orElse: () => null);
        if (basicModule == null) {
          print('no module for ' + element.owner);
          return;
        }
        list.add(
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(basicModule.name,
                  style: Theme.of(context).textTheme.bodyText1)),
          Row(children: [
            element.description != null
                ? IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'Datenwert: ' +
                                      addressOwner.label +
                                      "\nModul: " +
                                      basicModule.name,
                                  style: Theme.of(context).textTheme.bodyText1),
                              content: SingleChildScrollView(
                                  child: Text(element.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                            );
                          });
                    },
                  )
                : Container(),
            Container()
          ])
        ]));
      }
    });
    addressAccessList.forEach((element) {
      if (addressOwner.address == element.address) {
        BasicModule basicModule = ModuleLoader().modules.firstWhere(
            (module) => module.id == element.accessor,
            orElse: () => null);
        if (basicModule == null) {
          print('no module for ' + element.accessor);
          return;
        }
        list.add(
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(basicModule?.name,
                  style: Theme.of(context).textTheme.bodyText1)),
          Row(children: [
            element.description != null
                ? IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'Datenwert: ' +
                                      addressOwner.label +
                                      "\nModul: " +
                                      basicModule?.name,
                                  style: Theme.of(context).textTheme.bodyText1),
                              content: SingleChildScrollView(
                                  child: Text(element.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                            );
                          });
                    },
                  )
                : Container(),
            IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              'Datenzugriff auf ' +
                                  addressOwner.label +
                                  " durch das Modul " +
                                  basicModule.name +
                                  ' entziehen.',
                              style: Theme.of(context).textTheme.bodyText1),
                          content: Row(children: [
                            IconButton(
                                icon: Icon(
                                  Icons.check_outlined,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () {
                                  AccessLayer().revokeAccess(
                                      addressOwner.address, element.accessor);
                                  addressAccessList =
                                      AccessLayer().getAddressAccessList();
                                  Navigator.pop(context);
                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () {
                                  // close alert dialog, no deleteion
                                  Navigator.pop(context);
                                })
                          ]),
                        );
                      });
                })
          ])
        ]));
      }
    });
    if (list.length == 0) {
      return Container();
    } else {
      return Column(children: list);
    }
  }
}
