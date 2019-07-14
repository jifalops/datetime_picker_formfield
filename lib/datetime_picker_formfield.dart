import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart' show TextInputFormatter;

/// A [FormField<DateTime>] that integrates a text input with time-chooser UIs.
class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    @required this.format,
    @required this.onShowPicker,

    // From super
    Key key,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    DateTime initialValue,
    // bool autovalidate = false,
    // bool enabled = true,

    // Features
    TransitionBuilder builder,
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,

    // From [TextFormField]
    // this.key,
    TextEditingController controller,
    // this.initialValue,
    FocusNode focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscureText = false,
    this.autocorrect = true,
    this.autovalidate = false,
    this.maxLengthEnforced = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    // this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    // this.onSaved,
    // this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.buildCounter,
  })  : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode(),
        widgetBuilder = builder,
        super(
            key: key,
            autovalidate: autovalidate,
            initialValue: initialValue,
            enabled: enabled,
            validator: validator,
            onSaved: onSaved,
            builder: (state) => Container()) {
    this.controller.text = DateTimeField.tryFormat(initialValue, format);
  }

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// Called when the date chooser dialog should be shown.
  final Future<DateTime> Function(BuildContext context, DateTime currentValue)
      onShowPicker;

  /// The [builder] parameter can be used to wrap the dialog widget
  /// to add inherited widgets like a [Theme], [Localizations.override],
  /// [Directionality], or [MediaQuery].
  final TransitionBuilder widgetBuilder;

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

  // From [TextformField]
  // final Key key;
  final TextEditingController controller;
  // final String initialValue;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool autofocus;
  final bool readOnly;
  final bool showCursor;
  final bool obscureText;
  final bool autocorrect;
  final bool autovalidate;
  final bool maxLengthEnforced;
  final int maxLines;
  final int minLines;
  final bool expands;
  final int maxLength;
  // final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onFieldSubmitted;
  // final FormFieldSetter<String> onSaved;
  // final FormFieldValidator<String> validator;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final double cursorWidth;
  final Radius cursorRadius;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final InputCounterWidgetBuilder buildCounter;
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  bool showResetIcon = false;
  bool isShowingDialog = false;
  bool hadFocus;
  bool hadText;

  /// `true` when updating the text after programmatically changing the value
  bool changingText = false;

  /// `true` when updating the value after programmatically changing the text
  bool changingValue = false;

  /// The most recent non-null value;
  DateTime lastValidValue;

  @override
  DateTimeField get widget => super.widget;

  TextEditingController get controller => widget.controller;
  FocusNode get focusNode => widget.focusNode;

  bool get hasFocus => focusNode.hasFocus;
  bool get hasText => controller.text.isNotEmpty;

  String format(DateTime date) => DateTimeField.tryFormat(date, widget.format);
  DateTime parse(String text) => DateTimeField.tryParse(text, widget.format);

  @override
  void initState() {
    super.initState();
    if (value != null) {
      lastValidValue = value;
    }
    controller.text = format(widget.initialValue);
    hadFocus = focusNode.hasFocus;
    hadText = controller.text.isNotEmpty;
    focusNode.addListener(focusChanged);
    controller.addListener(textChanged);
  }

  @override
  void dispose() {
    if (controller != widget.controller) {
      controller.dispose();
    } else {
      controller.removeListener(textChanged);
    }
    if (focusNode != widget.focusNode) {
      focusNode.dispose();
    } else {
      focusNode.removeListener(focusChanged);
    }
    super.dispose();
  }

  @protected
  @override
  void setValue(DateTime value) {
    bool changed = value != super.value;
    super.setValue(value);
    if (value != null) {
      lastValidValue = value;
    }
    if (!changingValue) {
      changingText = true;
      controller.text = format(value);
      changingText = false;
    }
    if (changed && widget.onChanged != null) widget.onChanged(value);
  }

  @override
  void didChange(DateTime value) {
    setValue(value);
    super.didChange(value);
  }

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      /// Hide the keyboard.
      FocusScope.of(context).requestFocus(FocusNode());
      final newValue = await widget.onShowPicker(context, value);
      isShowingDialog = false;
      if (newValue != null) {
        didChange(newValue);
      }
    }
  }

  void focusChanged() {
    if (hasFocus && !hadFocus && (!hasText || widget.readOnly)) {
      requestUpdate();
    } else if (hadFocus && !hasFocus) {}

    hadFocus = hasFocus;
  }

  void textChanged() {
    if (showResetIcon != hasText &&
        widget.resetIcon != null &&
        widget.decoration.suffixIcon == null) {
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

  // void inputChanged() async {
  //   final bool requiresInput = widget.controller.text.isEmpty &&
  //       _previousValue.isEmpty &&
  //       widget.focusNode.hasFocus;

  //   if (requiresInput) {
  //     requestUpdate();
  //   } else if (widget.resetIcon != null &&
  //       widget.controller.text.isEmpty == showResetIcon) {
  //     setState(() => showResetIcon = !showResetIcon);
  //     // widget.focusNode.unfocus();
  //   }
  //   _previousValue = widget.controller.text;
  //   if (!widget.focusNode.hasFocus) {
  //     setValue(_toDate(_previousValue, widget.format));
  //   } else if (!requiresInput && !widget.editable) {
  //     requestUpdate();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Key key,
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration:
          widget.resetIcon == null || widget.decoration.suffixIcon != null
              ? widget.decoration
              : widget.decoration.copyWith(
                  suffixIcon: showResetIcon
                      ? IconButton(
                          icon: widget.resetIcon,
                          onPressed: () {
                            focusNode.unfocus();
                            controller.clear();
                          },
                        )
                      : Container(width: 0, height: 0),
                ),
      // initialValue: format(widget.initialValue),
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      // autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      // showCursor: widget.showCursor,
      // obscureText: widget.obscureText,
      // autocorrect: widget.autocorrect,
      autovalidate: widget.autovalidate,
      // maxLengthEnforced: widget.maxLengthEnforced,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      // expands: widget.expands,
      maxLength: widget.maxLength,
      onEditingComplete: widget.onEditingComplete,
      // onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: (string) => widget.onSaved(parse(string)),
      validator: (string) => widget.validator(parse(string)),
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled ?? true,
      cursorWidth: widget.cursorWidth,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      enableInteractiveSelection: widget.enableInteractiveSelection ?? true,
      buildCounter: widget.buildCounter,
    );
  }

  @override
  void didUpdateWidget(DateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(textChanged);
      widget.controller.text = oldWidget.controller.text;
      widget.controller.selection = oldWidget.controller.selection;
      widget.controller.addListener(textChanged);
      // oldWidget.controller.dispose();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(focusChanged);
      widget.focusNode.addListener(focusChanged);
      // oldWidget.focusNode.dispose();
    }

    // Update text value if format is changed
    if (widget.format != oldWidget.format) {
      widget.controller.removeListener(textChanged);
      widget.controller.text = format(value);
      widget.controller.addListener(textChanged);
    }
  }
}
