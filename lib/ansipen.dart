// ignore_for_file: constant_identifier_names

import 'supports_ansi_color.dart';
export "supports_ansi_color.dart";
export 'src/quectocolors_ansipen.dart';

// ---------------------------------------------------------------------------
// ansicolor-compatible top-level constants and deprecated accessors

/// ANSI Control Sequence Introducer, signals the terminal for new settings.
const ansiEscape = '\x1B[';

@Deprecated('Will be removed in future releases')
// ignore: non_constant_identifier_names
const ansi_esc = ansiEscape;

/// Reset all colors and options for current SGRs to terminal defaults.
const ansiDefault = '${ansiEscape}0m';

@Deprecated('Will be removed in future releases')
// ignore: non_constant_identifier_names
const ansi_default = ansiDefault;

/// Ansi codes that default the terminal's foreground color without
/// altering the background, when printed.
///
/// Does not modify [AnsiPen]!
const ansiResetForeground = '${ansiEscape}39m';

@Deprecated('Will be removed in future releases')
String resetForeground() => ansiResetForeground;

/// Ansi codes that default the terminal's background color without
/// altering the foreground, when printed.
///
/// Does not modify [AnsiPen]!
const ansiResetBackground = '${ansiEscape}49m';

@Deprecated('Will be removed in future releases')
String resetBackground() => ansiResetBackground;

// Here for compatibility with ansicolor package
@Deprecated(
  'Will be removed in future releases in favor of [ansiColorDisabled]',
)
// ignore: non_constant_identifier_names
bool get color_disabled => ansiColorDisabled;
@Deprecated(
  'Will be removed in future releases in favor of [ansiColorDisabled]',
)
// ignore: non_constant_identifier_names
set color_disabled(bool disabled) => ansiColorDisabled = disabled;
