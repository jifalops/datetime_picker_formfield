import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart' show TextInputFormatter;

/// A [FormField<DateTime>] that uses a [TextField] to manage input.
/// If it gains focus while empty, the date and/or time pickers will be shown
/// to the user.
class DateTimePickerFormField extends FormField<DateTime> {
  final bool dateOnly;
  final DateFormat format;
  final DateTime initialDate, firstDate, lastDate;
  final TimeOfDay initialTime;
  final IconData resetIcon;
  final FormFieldValidator<DateTime> validator;
  final FormFieldSetter<DateTime> onSaved;
  final ValueChanged<DateTime> onFieldSubmitted;
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;

  final TextInputType keyboardType;
  final TextStyle style;
  final TextAlign textAlign;
  final DateTime initialValue;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool maxLengthEnforced;
  final int maxLines;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  final enabled;
  final ValueChanged<DateTime> onChanged;
  DateTimePickerFormField({
    Key key,

    /// For representing the date as a string e.g.
    /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
    /// (Sunday, June 3, 2018 at 9:24pm)
    @required this.format,

    /// Which pickers this input should show. Either date, or date and time.
    /// For time only, use [TimePickerFormField].
    this.dateOnly: false,

    /// Called whenever the state's value changes, e.g. after picker value(s)
    /// have been selected or when the field loses focus. To listen for all text
    /// changes, use the [controller] and [focusNode].
    this.onChanged,

    /// By default the TextField [decoration]'s [suffixIcon] will be
    /// overridden to reset the input using the icon defined here.
    /// Set this to `null` to stop that behavior.
    this.resetIcon: Icons.close,

    /// Where the calendar will start when shown. Defaults to the current date.
    DateTime initialDate,

    /// The earliest choosable date. Defaults to 1900.
    DateTime firstDate,

    /// The latest choosable date. Defaults to 2100.
    DateTime lastDate,

    /// The initial time prefilled in the picker dialog when it is shown.
    this.initialTime: const TimeOfDay(hour: 12, minute: 0),

    /// For validating the [DateTime]. The value passed will be `null` if
    /// [format] fails to parse the text.
    this.validator,

    /// Called when an enclosing form is saved. The value passed will be `null`
    /// if [format] fails to parse the text.
    this.onSaved,

    /// Called when an enclosing form is submitted. The value passed will be
    /// `null` if [format] fails to parse the text.
    this.onFieldSubmitted,
    bool autovalidate: false,

    // TextField properties
    TextEditingController controller,
    FocusNode focusNode,
    this.initialValue,
    this.decoration: const InputDecoration(),
    this.keyboardType: TextInputType.text,
    this.style,
    this.textAlign: TextAlign.start,
    this.autofocus: false,
    this.obscureText: false,
    this.autocorrect: true,
    this.maxLengthEnforced: true,
    this.enabled,
    this.maxLines: 1,
    this.maxLength,
    this.inputFormatters,
  })  : controller = controller ??
            TextEditingController(text: _toString(initialValue, format)),
        focusNode = focusNode ?? FocusNode(),
        initialDate = initialDate ?? DateTime.now(),
        firstDate = firstDate ?? DateTime(1900),
        lastDate = lastDate ?? DateTime(2100),
        super(
            key: key,
            autovalidate: autovalidate,
            validator: validator,
            onSaved: onSaved,
            builder: (FormFieldState<DateTime> field) {
              // final _DateTimePickerTextFormFieldState state = field;
            });

  @override
  _DateTimePickerTextFormFieldState createState() =>
      _DateTimePickerTextFormFieldState(this);
}

class _DateTimePickerTextFormFieldState extends FormFieldState<DateTime> {
  final DateTimePickerFormField parent;
  bool showResetIcon = false;
  String _previousValue = '';

  _DateTimePickerTextFormFieldState(this.parent);

  @override
  void setValue(DateTime value) {
    super.setValue(value);
    if (parent.onChanged != null) parent.onChanged(value);
  }

  @override
  void initState() {
    super.initState();
    parent.focusNode.addListener(inputChanged);
    parent.controller.addListener(inputChanged);
  }

  @override
  void dispose() {
    parent.controller.removeListener(inputChanged);
    parent.focusNode.removeListener(inputChanged);
    super.dispose();
  }

  void inputChanged() {
    if (parent.controller.text.isEmpty &&
        _previousValue.isEmpty &&
        parent.focusNode.hasFocus) {
      getDateTimeInput(context).then((date) {
        parent.focusNode.unfocus();
        setState(() {
          parent.controller.text = _toString(date, parent.format);
          setValue(date);
        });
      });
    } else if (parent.resetIcon != null &&
        parent.controller.text.isEmpty == showResetIcon) {
      setState(() => showResetIcon = !showResetIcon);
      // parent.focusNode.unfocus();
    }
    _previousValue = parent.controller.text;
    if (!parent.focusNode.hasFocus) {
      setValue(_toDate(parent.controller.text, parent.format));
    }
  }

  Future<DateTime> getDateTimeInput(BuildContext context) async {
    var date = await showDatePicker(
        context: context,
        firstDate: parent.firstDate,
        lastDate: parent.lastDate,
        initialDate: parent.initialDate);
    if (date != null) {
      date = startOfDay(date);
      if (!parent.dateOnly) {
        final time = await showTimePicker(
          context: context,
          initialTime: parent.initialTime,
        );
        if (time != null) {
          date = date.add(Duration(hours: time.hour, minutes: time.minute));
        }
      }
    }

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: parent.controller,
      focusNode: parent.focusNode,
      decoration: parent.resetIcon == null
          ? parent.decoration
          : parent.decoration.copyWith(
              suffixIcon: showResetIcon
                  ? IconButton(
                      icon: Icon(parent.resetIcon),
                      onPressed: () {
                        parent.focusNode.unfocus();
                        _previousValue = '';
                        parent.controller.clear();
                      },
                    )
                  : Container(width: 0.0, height: 0.0),
            ),
      keyboardType: parent.keyboardType,
      style: parent.style,
      textAlign: parent.textAlign,
      autofocus: parent.autofocus,
      obscureText: parent.obscureText,
      autocorrect: parent.autocorrect,
      maxLengthEnforced: parent.maxLengthEnforced,
      maxLines: parent.maxLines,
      maxLength: parent.maxLength,
      inputFormatters: parent.inputFormatters,
      enabled: parent.enabled,
      onFieldSubmitted: (value) {
        if (parent.onFieldSubmitted != null) {
          return parent.onFieldSubmitted(_toDate(value, parent.format));
        }
      },
      validator: (value) {
        if (parent.validator != null) {
          return parent.validator(_toDate(value, parent.format));
        }
      },
      onSaved: (value) {
        if (parent.onSaved != null) {
          return parent.onSaved(_toDate(value, parent.format));
        }
      },
    );
  }
}

String _toString(DateTime date, DateFormat formatter) {
  if (date != null) {
    try {
      return formatter.format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
  }
  return '';
}

DateTime _toDate(String string, DateFormat formatter) {
  if (string != null && string.isNotEmpty) {
    try {
      return formatter.parse(string);
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }
  }
  return null;
}

DateTime startOfDay(DateTime date) => date.subtract(Duration(
    hours: date.hour,
    minutes: date.minute,
    seconds: date.second,
    milliseconds: date.millisecond,
    microseconds: date.microsecond));
