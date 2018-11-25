import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';

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
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  final timeFormat = DateFormat("h:mm a");
  final controller = TextEditingController();
  DateTime date;
  TimeOfDay time;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            DateTimePickerFormField(
              format: dateFormat,
              controller: controller,
              decoration: InputDecoration(labelText: 'Date'),
              onChanged: (dt) => setState(() => date = dt),
            ),
            Text('date.toString(): $date', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 16.0),
            TimePickerFormField(
              format: timeFormat,
              decoration: InputDecoration(labelText: 'Time'),
              onChanged: (t) => setState(() => time = t),
            ),
            Text('time.toString(): $time', style: TextStyle(fontSize: 18.0)),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Non-Editable")),
            DateTimePickerFormField(
              editable: false,
              format: dateFormat,
              decoration: InputDecoration(labelText: 'Date'),
              onChanged: (dt) => setState(() => date = dt),
            ),
            Text('date.toString(): $date', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 16.0),
            TimePickerFormField(
              editable: false,
              format: timeFormat,
              decoration: InputDecoration(labelText: 'Time'),
              onChanged: (t) => setState(() => time = t),
            ),
            Text('time.toString(): $time', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 16),
            RaisedButton(
                onPressed: () => controller.clear(),
                child: Text('Clear First TextField'))
          ],
        ),
      ));
}
