import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart' show TextInputFormatter;

/// A [FormField<DateTime>] that integrates a text input with time-chooser UIs.
class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    @required this.format,
    @required this.onShowPicker,
    this.child = const TextField(),

    // From super
    Key key,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    DateTime initialValue,
    bool autovalidate = false,
    // bool enabled = true,

    // Features
    TransitionBuilder builder,
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,
  })  : widgetBuilder = builder,
        super(
            key: key,
            autovalidate: autovalidate,
            initialValue: initialValue,
            enabled: child.enabled,
            validator: validator,
            onSaved: onSaved,
            builder: (state) => Container());

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// The text field to manage. One will be created if not provided.
  final TextField child;

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
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  TextEditingController controller;
  FocusNode focusNode;
  bool showResetIcon = false;
  bool isShowingDialog = false;
  bool hadFocus;
  bool hadText;

  /// true when updating the text after a change in value
  bool changingText = false;

  /// true when changing the value internally and
  bool changingValue = false;

  /// The most recent non-null value;
  DateTime lastValidValue;

  @override
  DateTimeField get widget => super.widget;

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
    controller = widget.child.controller ?? TextEditingController();
    controller.text = format(widget.initialValue);
    focusNode = widget.child.focusNode ?? FocusNode();
    hadFocus = focusNode.hasFocus;
    hadText = controller.text.isNotEmpty;
    focusNode.addListener(focusChanged);
    controller.addListener(textChanged);
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
    return TextField(
      // Key key,
      controller: controller,
      focusNode: focusNode,
      decoration:
          widget.resetIcon == null || widget.child.decoration.suffixIcon != null
              ? widget.child.decoration
              : widget.child.decoration.copyWith(
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
      keyboardType: widget.child.keyboardType,
      textInputAction: widget.child.textInputAction,
      textCapitalization: widget.child.textCapitalization,
      style: widget.child.style,
      strutStyle: widget.child.strutStyle,
      textAlign: widget.child.textAlign,
      textAlignVertical: widget.child.textAlignVertical,
      textDirection: widget.child.textDirection,
      readOnly: widget.child.readOnly,
      showCursor: widget.child.showCursor,
      autofocus: widget.child.autofocus,
      obscureText: widget.child.obscureText,
      autocorrect: widget.child.autocorrect,
      maxLines: widget.child.maxLines,
      minLines: widget.child.minLines,
      expands: widget.child.expands,
      maxLength: widget.child.maxLength,
      maxLengthEnforced: widget.child.maxLengthEnforced,
      onChanged: widget.child.onChanged,
      onEditingComplete: widget.child.onEditingComplete,
      onSubmitted: widget.child.onSubmitted,
      inputFormatters: widget.child.inputFormatters,
      enabled: widget.child.enabled,
      cursorWidth: widget.child.cursorWidth,
      cursorRadius: widget.child.cursorRadius,
      cursorColor: widget.child.cursorColor,
      keyboardAppearance: widget.child.keyboardAppearance,
      scrollPadding: widget.child.scrollPadding,
      dragStartBehavior: widget.child.dragStartBehavior,
      enableInteractiveSelection: widget.child.enableInteractiveSelection,
      onTap: widget.child.onTap,
      buildCounter: widget.child.buildCounter,
      scrollController: widget.child.scrollController,
      scrollPhysics: widget.child.scrollPhysics,
    );
  }
}
