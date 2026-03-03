import 'ansi_color_level.dart';

/// Whether the current platform supports ANSI escape codes.
///
/// On web platforms, defaults to `true` (modern browser consoles support ANSI).
bool get supportsAnsiColor => true;

/// The auto-detected ANSI color capability level for this platform.
///
/// On web platforms, defaults to [AnsiColorLevel.trueColor].
AnsiColorLevel get detectedAnsiColorLevel => AnsiColorLevel.trueColor;
