import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

/// A [FormField<DateTime>] that integrates a text input with time-chooser UIs.
///
/// It borrows many of it's parameters from [TextFormField].
///
/// When a [controller] is specified, [initialValue] must be null (the
/// default).
class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    required this.format,
    required this.onShowPicker,

    // From super
    Key? key,
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    DateTime? initialValue,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,

    // Features
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,

    // From TextFormField
    // Key key,
    this.controller,
    // String initialValue,
    this.focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    this.readOnly = true,
    bool? showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    // bool autovalidate = false,
    MaxLengthEnforcement maxLengthEnforcement = MaxLengthEnforcement.enforced,
    int maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<DateTime?>? onFieldSubmitted,
    // FormFieldSetter<String> onSaved,
    // FormFieldValidator<String> validator,
    List<TextInputFormatter>? inputFormatters,
    // bool enabled = true,
    double cursorWidth = 2.0,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder? buildCounter,
  }) : super(
            key: key,
            autovalidateMode: autovalidateMode,
            initialValue: initialValue,
            enabled: enabled,
            validator: validator,
            onSaved: onSaved,
            builder: (field) {
              final _DateTimeFieldState state = field as _DateTimeFieldState;
              final InputDecoration effectiveDecoration =
                  (decoration ?? const InputDecoration()).applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return TextField(
                controller: state._effectiveController,
                focusNode: state._effectiveFocusNode,
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                  suffixIcon: state.shouldShowClearIcon(effectiveDecoration)
                      ? IconButton(
                          icon: resetIcon!,
                          onPressed: state.clear,
                        )
                      : null,
                ),
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                style: style,
                strutStyle: strutStyle,
                textAlign: textAlign,
                textDirection: textDirection,
                textCapitalization: textCapitalization,
                autofocus: autofocus,
                readOnly: readOnly,
                showCursor: showCursor,
                obscureText: obscureText,
                autocorrect: autocorrect,
                maxLengthEnforcement: maxLengthEnforcement,
                maxLines: maxLines,
                minLines: minLines,
                expands: expands,
                maxLength: maxLength,
                onChanged: (string) => field.didChange(tryParse(string, format)),
                onEditingComplete: onEditingComplete,
                onSubmitted: (string) => onFieldSubmitted == null ? null : onFieldSubmitted(tryParse(string, format)),
                inputFormatters: inputFormatters,
                enabled: enabled,
                cursorWidth: cursorWidth,
                cursorRadius: cursorRadius,
                cursorColor: cursorColor,
                scrollPadding: scrollPadding,
                keyboardAppearance: keyboardAppearance,
                enableInteractiveSelection: enableInteractiveSelection,
                buildCounter: buildCounter,
              );
            });

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// Called when the date chooser dialog should be shown.
  final Future<DateTime?> Function(BuildContext context, DateTime? currentValue) onShowPicker;

  /// The [InputDecoration.suffixIcon] to show when the field has text. Tapping
  /// the icon will clear the text field. Set this to `null` to disable that
  /// behavior. Also, setting the suffix icon yourself will override this option.
  final Icon? resetIcon;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final void Function(DateTime? value)? onChanged;

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();

  /// Returns an empty string if [DateFormat.format()] throws or [date] is null.
  static String tryFormat(DateTime? date, DateFormat format) {
    if (date != null) {
      try {
        return format.format(date);
      } catch (e) {
        // print('Error formatting date: $e');
      }
    }
    return '';
  }

  /// Returns null if [format.parse()] throws.
  static DateTime? tryParse(String string, DateFormat format) {
    if (string.isNotEmpty) {
      try {
        return format.parse(string);
      } catch (e) {
        // print('Error parsing date: $e');
      }
    }
    return null;
  }

  /// Sets the hour and minute of a [DateTime] from a [TimeOfDay].
  static DateTime combine(DateTime date, TimeOfDay? time) =>
      DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);

  static DateTime? convert(TimeOfDay? time) => time == null ? null : DateTime(1, 1, 1, time.hour, time.minute);
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  bool isShowingDialog = false;
  bool hadFocus = false;

  @override
  DateTimeField get widget => super.widget as DateTimeField;

  TextEditingController? get _effectiveController => widget.controller ?? _controller;
  FocusNode? get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  bool get hasFocus => _effectiveFocusNode!.hasFocus;
  bool get hasText => _effectiveController!.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: format(widget.initialValue));
      _controller!.addListener(_handleControllerChanged);
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _focusNode!.addListener(_handleFocusChanged);
    }
    widget.controller?.addListener(_handleControllerChanged);
    widget.focusNode?.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(DateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = TextEditingController.fromValue(oldWidget.controller!.value);
        _controller!.addListener(_handleControllerChanged);
      }
      if (widget.controller != null) {
        setValue(parse(widget.controller!.text));
        // Release the controller since it wont be used
        if (oldWidget.controller == null) {
          _controller?.dispose();
          _controller = null;
        }
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      widget.focusNode?.addListener(_handleFocusChanged);

      if (oldWidget.focusNode != null && widget.focusNode == null) {
        _focusNode = FocusNode();
        _focusNode!.addListener(_handleFocusChanged);
      }
      if (widget.focusNode != null && oldWidget.focusNode == null) {
        // Release the focus node since it wont be used
        _focusNode?.dispose();
        _focusNode = null;
      }
    }
  }

  @override
  void didChange(DateTime? value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    super.didChange(value);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    widget.controller?.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _effectiveController!.text = format(widget.initialValue);
    didChange(widget.initialValue);
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController!.text != format(value)) didChange(parse(_effectiveController!.text));
  }

  String format(DateTime? date) => DateTimeField.tryFormat(date, widget.format);
  DateTime? parse(String text) => DateTimeField.tryParse(text, widget.format);

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      final newValue = await widget.onShowPicker(context, value);
      isShowingDialog = false;
      if (newValue != null) {
        _effectiveController!.text = format(newValue);
      }
    }
  }

  void _handleFocusChanged() {
    if (hasFocus && !hadFocus && (!hasText || widget.readOnly)) {
      hadFocus = hasFocus;
      _hideKeyboard();
      requestUpdate();
    } else {
      hadFocus = hasFocus;
    }
  }

  void _hideKeyboard() {
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  void clear() async {
    _hideKeyboard();
    // Fix for ripple effect throwing exception
    // and the field staying gray.
    // https://github.com/flutter/flutter/issues/36324
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _effectiveController!.clear());
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      widget.resetIcon != null && (hasText || hasFocus) && decoration?.suffixIcon == null;
}
