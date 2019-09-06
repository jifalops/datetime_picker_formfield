## [1.0.0-pre.5] - September 6, 2019

- Upgrade dep, requires Flutter master channel.

## [0.4.3], [1.0.0-pre.4] - September 4, 2019

- Fix #61, use null instead of container for empty suffix icon.

## [0.4.2], [1.0.0-pre.3] - August 9, 2019

- Fix #55, ensure controller/focusNode is disposed.

## [0.4.1], [1.0.0-pre.2] - August 4, 2019

- Fix #50 and #51.

## [0.4.0], [1.0.0-pre.1] - July 16, 2019

- [child] removed and the parameters of [TextFormField] were added to the widget directly.
- Fix bugs when using with a form.

## [0.3.2] - July 16, 2019

- Fix for ripple effect exception causing the field to turn gray.

## [0.3.1] - July 14, 2019

* Improved interaction with forms.

## [0.3.0] - July 14, 2019

* Rewrote widget to remove extraneous functionality and clean up the logic. It no
longer calls the system date/time pickers for you, instead many common use cases
are shown in the included example.
* Renamed DateTimePickerFormField to DateTimeField.
* Lots of bugfixes.

## [0.2.0] - May 29, 2019

* Add [datePicker] and [timePicker] callback functions to enable full control of the system dialogs (material vs cupertino, language, theme, etc.)
* Remove deprecated [dateOnly] and [TimePickerFormField]
* Remove accidental log messages
* Add [builder] param for localization and theming

## [0.1.8] - January 21, 2019

* Remove state reference to widget (#22)
* Allow DateTimePickerFormField to use time-only.
* Deprecate TimePickerFormField.

## [0.1.7] - November 25, 2018

* Fix #11, previous time forgotten when `editable` is false.

## [0.1.6] - November 5, 2018

* Add `editable` option to `TimePickerFormField`.

## [0.1.5] - November 2, 2018

* Add `editable` option to disable manual editing and always show the picker(s) when the field gains focus.

## [0.1.4] - October 16, 2018

* Setting `initialTime` to `null` will cause it to start at the current time when shown.
* Add screenshot to readme.

## [0.1.3] - August 12, 2018

* Add remaining parameters from showDatePicker().

## [0.1.2] - August 9, 2018

* Fix autovalidate setting.

## [0.1.1] - July 21, 2018

* Fix and improve documentation.

## [0.1.0] - July 21, 2018

* Support Dart 2.0

## [0.0.3] - June 13, 2018

* Added License (MIT).

## [0.0.2] - June 13, 2018

* Fix pubspec.yaml Flutter SDK version requirements.

## [0.0.1] - June 13, 2018

* Initial release.
