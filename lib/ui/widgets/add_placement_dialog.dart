import 'package:flutter/material.dart';
import 'package:jama/data/models/visit_model.dart';

import '../app_styles.dart';
import '../translation.dart';

class AddPlacementDialog extends StatefulWidget {
  static Map<String, PlacementType> allPlacementTypeByString = Map.fromEntries(Translation.placementTypeToString.entries.map((x) => MapEntry(x.value, x.key)));

  final Function(int count, PlacementType type, String notes) onPlacementAdded;

  AddPlacementDialog({Key key, this.onPlacementAdded}) : super(key: key);

  @override
  _AddPlacementDialogState createState() => _AddPlacementDialogState();
}

class _AddPlacementDialogState extends State<AddPlacementDialog> {
  GlobalKey<FormState> _formData = GlobalKey();
  String _errorText = "";

  TextEditingController _count;

  PlacementType _type;

  TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _count = TextEditingController(text: "0");
    _type = PlacementType.values.first;
    _notes = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(child: Text("New Placement", style: AppStyles.heading2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 50,
                  child: TextFormField(
                      controller: _count,
                      onChanged: (s) {
                        if(_errorText.isNotEmpty) {
                          setState(() => _errorText = "");
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(5.0),
                      )),
                ),
                DropdownButton(
                  onChanged: (s) => setState(
                      () => _type = AddPlacementDialog.allPlacementTypeByString[s]),
                  value: Translation.placementTypeToString[_type],
                  items: AddPlacementDialog.allPlacementTypeByString.keys
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                )
              ],
            ),
            if(_errorText.isNotEmpty) Text(_errorText, style: AppStyles.smallTextStyle.copyWith(color: Colors.red)),
            TextFormField(
              controller: _notes,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: "Notes",
                  labelStyle: AppStyles.smallTextStyle),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    int count = int.parse(_count.text);
                    if(count == null || count <= 0) {
                      setState(() =>_errorText = "Count must be greater than 0.");
                      return;
                    } else {
                      setState(() =>_errorText = "");
                    }
                    
                    if (widget.onPlacementAdded != null) {
                      widget.onPlacementAdded(count, _type, _notes.text);
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  color: AppStyles.primaryColor,
                  child: Text(
                    "save",
                    style: AppStyles.heading4.copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
