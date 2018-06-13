import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart' show TextInputFormatter;

DateFormat toDateFormat(TimeOfDayFormat format) {
  switch (format) {
    case TimeOfDayFormat.a_space_h_colon_mm:
      return DateFormat('a h:mm');
    case TimeOfDayFormat.frenchCanadian:
      return DateFormat("HH 'h' mm");
    case TimeOfDayFormat.H_colon_mm:
      return DateFormat('H:mm');
    case TimeOfDayFormat.h_colon_mm_space_a:
      return DateFormat('h:mm a');
    case TimeOfDayFormat.HH_colon_mm:
      return DateFormat('HH:mm');
    case TimeOfDayFormat.HH_dot_mm:
      return DateFormat('HH.mm');
  }
  return null;
}

/// A [FormField<TimeOfDay>] that uses a [TextField] to manage input.
/// If it gains focus while empty, the time picker will be shown to the user.
class TimePickerFormField extends FormField<TimeOfDay> {
  final DateFormat format;
  final IconData resetIcon;
  final FormFieldValidator<TimeOfDay> validator;
  final FormFieldSetter<TimeOfDay> onSaved;
  final ValueChanged<TimeOfDay> onFieldSubmitted;
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;

  final TextInputType keyboardType;
  final TextStyle style;
  final TextAlign textAlign;
  final TimeOfDay initialValue;
  final TimeOfDay initialTime;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool maxLengthEnforced;
  final int maxLines;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final ValueChanged<TimeOfDay> onChanged;
  TimePickerFormField({
    Key key,

    /// For representing the time as a string e.g.
    /// `DateFormat("h:mma")` (9:24pm). You can also use the helper function
    /// [toDateFormat(TimeOfDayFormat)].
    @required this.format,

    /// Called whenever the state's value changes, e.g. after the picker value
    /// has been selected or when the field loses focus. To listen for all text
    /// changes, use the [controller] and [focusNode].
    this.onChanged,

    /// By default the TextField [decoration]'s [suffixIcon] will be
    /// overridden to reset the input using the icon defined here.
    /// Set this to `null` to stop that behavior.
    this.resetIcon: Icons.close,

    /// The initial time prefilled in the picker dialog when it is shown.
    this.initialTime: const TimeOfDay(hour: 12, minute: 0),

    /// For validating the [TimeOfDay]. The value passed will be `null` if
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
        super(
            key: key,
            autovalidate: autovalidate,
            validator: validator,
            onSaved: onSaved,
            builder: (FormFieldState<TimeOfDay> field) {
              // final _TimePickerTextFormFieldState state = field;
            });

  @override
  _TimePickerTextFormFieldState createState() =>
      _TimePickerTextFormFieldState(this);
}

class _TimePickerTextFormFieldState extends FormFieldState<TimeOfDay> {
  final TimePickerFormField parent;
  bool showResetIcon = false;
  String _previousValue = '';

  _TimePickerTextFormFieldState(this.parent);

  @override
  void setValue(TimeOfDay value) {
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
      getTimeInput(context).then((time) {
        parent.focusNode.unfocus();
        setState(() {
          parent.controller.text = _toString(time, parent.format);
          setValue(time);
        });
      });
    } else if (parent.resetIcon != null &&
        parent.controller.text.isEmpty == showResetIcon) {
      setState(() => showResetIcon = !showResetIcon);
      // parent.focusNode.unfocus();
    }
    _previousValue = parent.controller.text;
    if (!parent.focusNode.hasFocus) {
      setValue(_toTime(parent.controller.text, parent.format));
    }
  }

  Future<TimeOfDay> getTimeInput(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: parent.initialTime,
    );
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
          return parent.onFieldSubmitted(_toTime(value, parent.format));
        }
      },
      validator: (value) {
        if (parent.validator != null) {
          return parent.validator(_toTime(value, parent.format));
        }
      },
      onSaved: (value) {
        if (parent.onSaved != null) {
          return parent.onSaved(_toTime(value, parent.format));
        }
      },
    );
  }
}

String _toString(TimeOfDay time, DateFormat formatter) {
  if (time != null) {
    try {
      return formatter.format(
          DateTime(0).add(Duration(hours: time.hour, minutes: time.minute)));
    } catch (e) {
      debugPrint('Error formatting time: $e');
    }
  }
  return '';
}

TimeOfDay _toTime(String string, DateFormat formatter) {
  if (string != null && string.isNotEmpty) {
    try {
      var date = formatter.parse(string);
      return TimeOfDay(hour: date.hour, minute: date.minute);
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
  }
  return null;
}
