import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Date-Time Picker example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() {
    return new MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  final timeFormat = DateFormat("h:mm a");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          DateTimePickerFormField(
            format: dateFormat,
            onChanged: (date) {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('$date')));
            },
          ),
          TimePickerFormField(
            format: timeFormat,
            onChanged: (time) {
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('$time')));
            },
          ),
          DateTimePickerFormField(
            format: dateFormat,
            enabled: false,
          ),
          TimePickerFormField(
            format: toDateFormat(TimeOfDayFormat.HH_colon_mm),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
