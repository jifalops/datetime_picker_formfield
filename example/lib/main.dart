import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

const appName = 'DateTimePickerFormField Example';

void main() => runApp(MaterialApp(
      title: appName,
      home: MyHomePage(),
      theme: ThemeData.light().copyWith(
          inputDecorationTheme:
              InputDecorationTheme(border: OutlineInputBorder())),
    ));

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  Locale locale = Locale('es');
  DateTime date;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text('Format: "${formats[inputType].pattern}"'),

            //
            // The widget.
            //
            DateTimePickerFormField(
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              locale: locale,
              decoration: InputDecoration(
                  labelText: 'Date/Time', hasFloatingPlaceholder: false),
              onChanged: (dt) => setState(() => date = dt),
            ),

            Text('Date value: $date'),
            SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('Date picker'),
              value: inputType != InputType.time,
              onChanged: (value) => updateInputType(date: value),
            ),
            CheckboxListTile(
              title: Text('Time picker'),
              value: inputType != InputType.date,
              onChanged: (value) => updateInputType(time: value),
            ),
            CheckboxListTile(
              title: Text('Editable'),
              value: editable,
              onChanged: (value) => setState(() => editable = value),
            ),
          ],
        ),
      ));

  void updateInputType({bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
    setState(() => inputType =
        date ? time ? InputType.both : InputType.date : InputType.time);
  }
}
