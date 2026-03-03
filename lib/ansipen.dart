/// Drop-in replacement for the `ansicolor` package's [AnsiPen] API.
///
/// Provides the same fluent pen-style interface plus additional styles
/// (bold, italic, strikethrough, etc.), 16M true color RGB, and correct
/// nested color handling.
///
/// ```dart
/// import 'package:quectocolors/ansipen.dart';
///
/// final pen = AnsiPen()..red();
/// print(pen('Hello'));
/// ```
// ignore_for_file: constant_identifier_names
library;

import 'supports_ansi_color.dart';
export "supports_ansi_color.dart";
export 'src/quectocolors_ansipen.dart';

// ---------------------------------------------------------------------------
// ansicolor-compatible top-level constants and deprecated accessors

/// ANSI Control Sequence Introducer, signals the terminal for new settings.
const ansiEscape = '\x1B[';

/// Deprecated: use [ansiEscape] instead.
@Deprecated('Will be removed in future releases')
// ignore: non_constant_identifier_names
const ansi_esc = ansiEscape;

/// Reset all colors and options for current SGRs to terminal defaults.
const ansiDefault = '${ansiEscape}0m';

/// Deprecated: use [ansiDefault] instead.
@Deprecated('Will be removed in future releases')
// ignore: non_constant_identifier_names
const ansi_default = ansiDefault;

/// Ansi codes that default the terminal's foreground color without
/// altering the background, when printed.
///
/// Does not modify [AnsiPen]!
const ansiResetForeground = '${ansiEscape}39m';

/// Deprecated: use the [ansiResetForeground] constant instead.
@Deprecated('Will be removed in future releases')
String resetForeground() => ansiResetForeground;

/// Ansi codes that default the terminal's background color without
/// altering the foreground, when printed.
///
/// Does not modify [AnsiPen]!
const ansiResetBackground = '${ansiEscape}49m';

/// Deprecated: use the [ansiResetBackground] constant instead.
@Deprecated('Will be removed in future releases')
String resetBackground() => ansiResetBackground;

/// Deprecated: use [ansiColorDisabled] instead.
@Deprecated(
  'Will be removed in future releases in favor of [ansiColorDisabled]',
)
// ignore: non_constant_identifier_names
bool get color_disabled => ansiColorDisabled;

/// Deprecated: use [ansiColorDisabled] instead.
@Deprecated(
  'Will be removed in future releases in favor of [ansiColorDisabled]',
)
// ignore: non_constant_identifier_names
set color_disabled(bool disabled) => ansiColorDisabled = disabled;
