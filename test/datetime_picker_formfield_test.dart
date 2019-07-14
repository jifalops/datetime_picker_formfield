import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

void main() {
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  final timeFormat = toDateFormat(TimeOfDayFormat.HH_colon_mm);
  test('Constructs minimal instances', () {
    final dateField = DateTimeTextField(
      format: dateFormat,
    );
    final timeField = DateTimeTextField(
      format: timeFormat,
    );
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
}
