import 'package:flutter/material.dart';

class PresetsPage extends StatefulWidget {
  // TODO: Save Action List to Local Shared Preference or Online Database
  List<String> actionsLets;
  
  PresetsPage(this.actionsLets);
  
  @override
  _PresetsPageStates createState() => _PresetsPageStates();
}

class _PresetsPageStates extends State<PresetsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), 
      child: ListView.builder(itemBuilder: (context, index) {
        if (index >= widget.actionsLets.length * 2 - 1) {
          return null;
        } else {
          return index % 2 == 0
              ? ListTile(
                  title: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.actionsLets[index ~/ 2],
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  onTap: () => null,
                )
              : Divider();
        }
      }),
    );
  }
}
