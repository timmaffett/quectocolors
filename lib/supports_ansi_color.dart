/// Platform-adaptive ANSI color support detection and global configuration.
///
/// Exports [ansiColorDisabled], [ansiColorLevel], and the [AnsiColorLevel]
/// enum for querying and overriding terminal color capabilities.
library;

import 'src/ansi_color_level.dart';
export 'src/ansi_color_level.dart';

import 'src/supports_ansi.dart'
    if (dart.library.io) 'src/supports_ansi_io.dart'
    if (dart.library.js_interop) 'src/supports_ansi_web.dart';

/// Globally enable or disable [AnsiPen] settings.
///
/// Note: defaults to environment support; but can be overridden.
///
/// Handy for turning on and off embedded colors without commenting out code.
bool ansiColorDisabled = !supportsAnsiColor;

/// The detected (or overridden) ANSI color capability level.
///
/// Defaults to the level auto-detected from the platform and environment
/// variables (e.g. `COLORTERM`, `TERM_PROGRAM`, `TERM`, `NO_COLOR`).
///
/// Set to a specific [AnsiColorLevel] to override detection. For example,
/// force 256-color mode: `ansiColorLevel = AnsiColorLevel.ansi256;`
///
/// When [ansiColorDisabled] is `true`, all color output is suppressed
/// regardless of this value.
AnsiColorLevel ansiColorLevel = detectedAnsiColorLevel;
