import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart' show TextInputFormatter;

/// A [FormField<DateTime>] that uses a [TextField] to manage input.
class DateTimePickerFormField extends FormField<DateTime> {
  /// Whether to show the time picker after a date has been chosen.
  /// To show the time picker only, use [TimePickerFormField].
  final bool dateOnly;

  /// Allow manual editing of the date/time. Defaults to true. If false, the
  /// picker(s) will be shown every time the field gains focus.
  final bool editable;

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// Where the calendar will start when shown. Defaults to the current date.
  final DateTime initialDate;

  /// The earliest choosable date. Defaults to 1900.
  final DateTime firstDate;

  /// The latest choosable date. Defaults to 2100.
  final DateTime lastDate;

  /// The initial time prefilled in the picker dialog when it is shown. Defaults
  /// to noon. Explicitly set this to `null` to use the current time.
  final TimeOfDay initialTime;

  /// If defined the TextField [decoration]'s [suffixIcon] will be
  /// overridden to reset the input using the icon defined here.
  /// Set this to `null` to stop that behavior. Defaults to [Icons.close].
  final IconData resetIcon;

  /// For validating the [DateTime]. The value passed will be `null` if
  /// [format] fails to parse the text.
  final FormFieldValidator<DateTime> validator;

  /// Called when an enclosing form is saved. The value passed will be `null`
  /// if [format] fails to parse the text.
  final FormFieldSetter<DateTime> onSaved;

  /// Corresponds to the [showDatePicker()] parameter. Defaults to
  /// [DatePickerMode.day].
  final DatePickerMode initialDatePickerMode;

  /// Corresponds to the [showDatePicker()] parameter.
  final Locale locale;

  /// Corresponds to the [showDatePicker()] parameter.
  final bool Function(DateTime) selectableDayPredicate;

  /// Corresponds to the [showDatePicker()] parameter.
  final TextDirection textDirection;

  /// Called when an enclosing form is submitted. The value passed will be
  /// `null` if [format] fails to parse the text.
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
  final bool enabled;

  /// Called whenever the state's value changes, e.g. after picker value(s)
  /// have been selected or when the field loses focus. To listen for all text
  /// changes, use the [controller] and [focusNode].
  final ValueChanged<DateTime> onChanged;

  DateTimePickerFormField({
    Key key,
    @required this.format,
    this.dateOnly: false,
    this.editable: true,
    this.onChanged,
    this.resetIcon: Icons.close,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    this.initialTime: const TimeOfDay(hour: 12, minute: 0),
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    bool autovalidate: false,
    DatePickerMode initialDatePickerMode,
    this.locale,
    this.selectableDayPredicate,
    this.textDirection,

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
        initialDatePickerMode = initialDatePickerMode ?? DatePickerMode.day,
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
      _DateTimePickerTextFormFieldState();
}

class _DateTimePickerTextFormFieldState extends FormFieldState<DateTime> {
  bool showResetIcon = false;
  String _previousValue = '';

  @override
  DateTimePickerFormField get widget => super.widget;

  _DateTimePickerTextFormFieldState();

  @override
  void setValue(DateTime value) {
    super.setValue(value);

    if (widget.onChanged != null) widget.onChanged(value);
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(inputChanged);
    widget.controller.addListener(inputChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(inputChanged);
    widget.focusNode.removeListener(inputChanged);
    super.dispose();
  }

  void inputChanged() {
    final bool requiresInput =
        widget.controller.text.isEmpty && _previousValue.isEmpty && widget.focusNode.hasFocus;

    if (requiresInput) {
      getDateTimeInput(context, widget.initialDate, widget.initialTime).then(_setValue);
    } else if (widget.resetIcon != null && widget.controller.text.isEmpty == showResetIcon) {
      setState(() => showResetIcon = !showResetIcon);
      // widget.focusNode.unfocus();
    }
    _previousValue = widget.controller.text;
    if (!widget.focusNode.hasFocus) {
      setValue(_toDate(_previousValue, widget.format));
    } else if (!requiresInput && !widget.editable) {
      var date = _toDate(_previousValue, widget.format);
      getDateTimeInput(context, date ?? widget.initialDate, _toTime(date) ?? widget.initialTime)
          .then(_setValue);
    }
  }

  void _setValue(DateTime date) {
    widget.focusNode.unfocus();
    // When Cancel is tapped, retain the previous value if present.
    if (date == null && _previousValue.isNotEmpty) {
      date = _toDate(_previousValue, widget.format);
    }
    setState(() {
      widget.controller.text = _toString(date, widget.format);
      setValue(date);
    });
  }

  Future<DateTime> getDateTimeInput(
      BuildContext context, DateTime initialDate, TimeOfDay initialTime) async {
    var date = await showDatePicker(
        context: context,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        initialDate: initialDate,
        initialDatePickerMode: widget.initialDatePickerMode,
        locale: widget.locale,
        selectableDayPredicate: widget.selectableDayPredicate,
        textDirection: widget.textDirection);
    if (date != null) {
      date = startOfDay(date);
      if (!widget.dateOnly) {
        final time = await showTimePicker(
          context: context,
          initialTime: initialTime ?? TimeOfDay.now(),
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
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: widget.resetIcon == null
          ? widget.decoration
          : widget.decoration.copyWith(
              suffixIcon: showResetIcon
                  ? IconButton(
                      icon: Icon(widget.resetIcon),
                      onPressed: () {
                        widget.focusNode.unfocus();
                        _previousValue = '';
                        widget.controller.clear();
                      },
                    )
                  : Container(width: 0.0, height: 0.0),
            ),
      keyboardType: widget.keyboardType,
      style: widget.style,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      maxLengthEnforced: widget.maxLengthEnforced,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      onFieldSubmitted: (value) {
        if (widget.onFieldSubmitted != null) {
          return widget.onFieldSubmitted(_toDate(value, widget.format));
        }
      },
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator(_toDate(value, widget.format));
        }
      },
      autovalidate: widget.autovalidate,
      onSaved: (value) {
        if (widget.onSaved != null) {
          return widget.onSaved(_toDate(value, widget.format));
        }
      },
    );
  }

  @override
  void didUpdateWidget(DateTimePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(inputChanged);
      widget.controller?.addListener(inputChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(inputChanged);
      widget.focusNode?.addListener(inputChanged);
    }

    // Update text value if format is changed
    if (widget.format != oldWidget.format) {
      widget.controller.text = _toString(value, widget.format);
    }
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

/// null-safe version of [TimeOfDay.fromDateTime(time)].
TimeOfDay _toTime(DateTime date) {
  if (date == null) return null;
  return TimeOfDay.fromDateTime(date);
}

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
