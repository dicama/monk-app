import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:monk/src/modules/module.dart';
import 'package:monk/src/templates/elements/basicelement.dart';

typedef SelectedTagsVoid = void Function(List<String>);

class _AddableTagsState extends State<AddableTagsWidget> {
  List<String> added = List();
  Map<String, bool> selectedOnes = Map();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.initialList.forEach((subs) {
      if (widget.selectedList.contains(subs)) {
        selectedOnes[subs] = true;
      } else {
        selectedOnes[subs] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8,
        runSpacing: 0,
        children: widget.initialList
                .map((subs) => InputChip(
                    key: Key(subs),
                    label: Text(subs),
                    selectedColor: Theme.of(context).accentColor,
                    selected: selectedOnes[subs],
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (widget.singleSelect) {
                            selectedOnes.forEach((key, value) {
                              selectedOnes[key] = false;
                            });
                            selectedOnes[subs] = true;
                          } else {
                            selectedOnes[subs] = true;
                          }
                        } else {
                          selectedOnes[subs] = false;
                        }
                      });
                      getSelected();
                      return true;
                    }))
                .toList() +
            added
                .map((subs) => InputChip(
                    key: Key(subs),
                    label: Text(subs),
                    selectedColor: Theme.of(context).accentColor,
                    selected: selectedOnes[subs],
                    onDeleted: () {
                      setState(() {
                        added.remove(subs);
                        selectedOnes.remove(subs);
                        getSelected();
                      });
                    },
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (widget.singleSelect) {
                            selectedOnes.forEach((key, value) {
                              selectedOnes[key] = false;
                            });
                            selectedOnes[subs] = true;
                          } else {
                            selectedOnes[subs] = true;
                          }
                        } else {
                          selectedOnes[subs] = false;
                        }
                      });
                      getSelected();
                      return true;
                    }))
                .toList() +
            [
              InputChip(
                  key: Key("Theaöömew"),
                  padding: EdgeInsets.zero,
                  selected: false,
                  onSelected: (noparam) {},
                  label: Container(
                      width: 100,
                      child: Row(children: [
                        Icon(Icons.add),
                        Expanded(
                            child: TextField(
                                decoration: InputDecoration(
                                    /*border: UnderlineInputBorder(borderSide: BorderSide.none),*/
                                    isDense: true,
                                    hintText: "neues Tag",
                                    contentPadding: EdgeInsets.zero),
                                controller: _controller,
                                onSubmitted: (final subs) {
                                  print("testing2");
                                  final finCase = widget.forceLowerCase
                                      ? subs.toLowerCase()
                                      : subs;
                                  if (subs.length > 0 &&
                                      !widget.initialList.contains(finCase) &&
                                      !added.contains(finCase)) {
                                    if (widget.singleSelect) {
                                      selectedOnes.forEach((key, value) {
                                        selectedOnes[key] = false;
                                      });
                                      selectedOnes[finCase] = true;
                                    } else {
                                      selectedOnes[finCase] = true;
                                    }
                                    getSelected();
                                    _controller.text = "";
                                    setState(() {
                                      added.add(finCase);
                                    });
                                  }
                                }))
                      ])))
            ]);
  }

  List<String> getSelected() {
    List<String> sel = List();
    selectedOnes.keys.forEach((element) {
      if (selectedOnes[element]) {
        sel.add(element);
      }
    });

    if (widget.onSelection != null) {
      widget.onSelection(sel);
      print("onselect");
    }
  }
}

class AddableTagsWidget extends StatefulWidget {
  final List<String> initialList;
  final List<String> selectedList;
  SelectedTagsVoid onSelection;
  final bool forceLowerCase;
  final bool singleSelect;

  AddableTagsWidget(this.initialList,
      {this.onSelection,
      this.selectedList = const [],
      this.singleSelect = false,
      this.forceLowerCase = true});

  @override
  _AddableTagsState createState() => _AddableTagsState();
}
