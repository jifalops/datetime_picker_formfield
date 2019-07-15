import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// A [FormField<DateTime>] that integrates a text input with time-chooser UIs.
class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    @required this.format,
    @required this.onShowPicker,
    this.child: const TextField(),

    // From super
    Key key,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    DateTime initialValue,
    bool autovalidate = false,
    // bool enabled = true,

    // Features
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,
  }) : super(
            key: key,
            autovalidate: autovalidate,
            initialValue: initialValue,
            enabled: child.enabled ?? true,
            validator: validator,
            onSaved: onSaved,
            builder: (field) {
              final _DateTimeFieldState state = field;
              return TextFormField(
                // Key key,
                controller: state.controller,
                focusNode: state.focusNode,
                decoration:
                    resetIcon == null || child.decoration.suffixIcon != null
                        ? child.decoration
                        : child.decoration.copyWith(
                            suffixIcon: state.showResetIcon
                                ? IconButton(
                                    icon: resetIcon,
                                    onPressed: () {
                                      state.focusNode.unfocus();
                                      state.didChange(null);
                                    },
                                  )
                                : Container(width: 0, height: 0),
                          ),
                // Cannot provide initialValue if controller is provided.
                // initialValue: format(initialValue),
                keyboardType: child.keyboardType,
                textCapitalization: child.textCapitalization,
                textInputAction: child.textInputAction,
                style: child.style,
                strutStyle: child.strutStyle,
                textDirection: child.textDirection,
                textAlign: child.textAlign,
                autofocus: child.autofocus,
                readOnly: child.readOnly,
                showCursor: child.showCursor,
                obscureText: child.obscureText,
                autocorrect: child.autocorrect,
                autovalidate: autovalidate ?? false,
                maxLengthEnforced: child.maxLengthEnforced,
                maxLines: child.maxLines,
                minLines: child.minLines,
                expands: child.expands,
                maxLength: child.maxLength,
                onEditingComplete: child.onEditingComplete,
                // Unused.
                // onFieldSubmitted: child.onFieldSubmitted,
                // Causes onSaved to be called twice.
                // onSaved: (string) =>
                //     onSaved == null ? null : onSaved(state.parse(string)),
                validator: (string) =>
                    validator == null ? null : validator(state.parse(string)),
                inputFormatters: child.inputFormatters,
                enabled: child.enabled ?? true,
                cursorWidth: child.cursorWidth,
                cursorRadius: child.cursorRadius,
                cursorColor: child.cursorColor,
                keyboardAppearance: child.keyboardAppearance,
                scrollPadding: child.scrollPadding,
                enableInteractiveSelection:
                    child.enableInteractiveSelection ?? true,
                buildCounter: child.buildCounter,
              );
            });

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// Called when the date chooser dialog should be shown.
  final Future<DateTime> Function(BuildContext context, DateTime currentValue)
      onShowPicker;

  /// The text field to draw properties from.
  final TextField child;

  /// The [InputDecoration.suffixIcon] to show when the field has text. Tapping
  /// the icon will clear the text field. Set this to `null` to disable that
  /// behavior.
  final Icon resetIcon;

  /// Called whenever the DateTime value changes.
  final ValueChanged<DateTime> onChanged;

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();

  /// Returns an empty string if [DateFormat.format()] throws or [date] is null.
  static String tryFormat(DateTime date, DateFormat format) {
    if (date != null) {
      try {
        return format.format(date);
      } catch (e) {
        print('Error formatting date: $e');
      }
    }
    return '';
  }

  /// Returns null if [format.parse()] throws.
  static DateTime tryParse(String string, DateFormat format) {
    if (string?.isNotEmpty ?? false) {
      try {
        return format.parse(string);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    return null;
  }

  /// Sets the hour and minute of a [DateTime] from a [TimeOfDay].
  static DateTime combine(DateTime date, TimeOfDay time) => DateTime(
      date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);

  static DateTime convert(TimeOfDay time) =>
      DateTime(1, 1, 1, time?.hour ?? 0, time?.minute ?? 0);
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  TextEditingController controller;
  FocusNode focusNode;

  bool showResetIcon = false;
  bool isShowingDialog = false;
  bool hadFocus;
  bool hadText;

  /// `true` when updating the text after programmatically changing the value
  bool changingText = false;

  /// `true` when updating the value after programmatically changing the text
  bool changingValue = false;

  DateTime previousValue;

  @override
  DateTimeField get widget => super.widget;

  bool get hasFocus => focusNode.hasFocus;
  bool get hasText => controller.text.isNotEmpty;

  String format(DateTime date) => DateTimeField.tryFormat(date, widget.format);
  DateTime parse(String text) => DateTimeField.tryParse(text, widget.format);

  @override
  void initState() {
    super.initState();
    controller =
        controller ?? widget.child.controller ?? TextEditingController();
    focusNode = focusNode ?? widget.child.focusNode ?? FocusNode();
    hadFocus = focusNode.hasFocus;
    hadText = controller.text.isNotEmpty;
    focusNode.addListener(focusChanged);
    controller.addListener(textChanged);
    // notifies listeners of the initalValue.
    setValue(widget.initialValue);
  }

  @override
  void reset() {
    super.reset();
    didChange(widget.initialValue);
  }

  @override
  void dispose() {
    if (controller != widget.child.controller) {
      controller.dispose();
    } else {
      controller.removeListener(textChanged);
    }
    if (focusNode != widget.child.focusNode) {
      focusNode.dispose();
    } else {
      focusNode.removeListener(focusChanged);
    }
    super.dispose();
  }

  @protected
  @override
  void setValue(DateTime value) {
    previousValue = value;
    super.setValue(value);
    if (!changingValue) {
      changingText = true;
      controller.text = format(value);
      changingText = false;
    }
  }

  @override
  void didChange(DateTime value) {
    setValue(value);
    super.didChange(value);
    if (value != previousValue && widget.onChanged != null)
      widget.onChanged(value);
    setState(() {});
  }

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      // Hide the keyboard.
      FocusScope.of(context).requestFocus(FocusNode());
      final newValue = await widget.onShowPicker(context, value);
      isShowingDialog = false;
      if (newValue != null) {
        didChange(newValue);
      }
    }
  }

  void focusChanged() {
    if (hasFocus && !hadFocus && (!hasText || widget.child.readOnly)) {
      requestUpdate();
    } else if (hadFocus && !hasFocus) {}

    hadFocus = hasFocus;
  }

  void textChanged() {
    if (showResetIcon != hasText &&
        widget.resetIcon != null &&
        widget.child.decoration.suffixIcon == null) {
      setState(() => showResetIcon = !showResetIcon);
    }
    if (!changingText) {
      final date = parse(controller.text);
      if (date != value) {
        changingValue = true;
        didChange(date);
        changingValue = false;
      }
    }
    hadText = hasText;
  }
}
