import 'ansi_color_level.dart';

/// Whether the current platform supports ANSI escape codes.
///
/// Defaults to `true` on unknown platforms.
bool get supportsAnsiColor => true;

/// The auto-detected ANSI color capability level for this platform.
///
/// Defaults to [AnsiColorLevel.trueColor] on unknown platforms.
AnsiColorLevel get detectedAnsiColorLevel => AnsiColorLevel.trueColor;
