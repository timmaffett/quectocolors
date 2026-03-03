import 'dart:io';

import 'ansi_color_level.dart';

/// Whether the current platform supports ANSI escape codes.
///
/// On IO platforms, delegates to [stdout.supportsAnsiEscapes].
bool get supportsAnsiColor => stdout.supportsAnsiEscapes;

/// The auto-detected ANSI color capability level for this platform.
///
/// Inspects environment variables (`COLORTERM`, `TERM_PROGRAM`, `TERM`,
/// `NO_COLOR`, `FORCE_COLOR`, etc.) to determine the highest supported level.
/// Returns [AnsiColorLevel.none] if ANSI escapes are not supported.
AnsiColorLevel get detectedAnsiColorLevel {
  if (!stdout.supportsAnsiEscapes) return AnsiColorLevel.none;
  return _detectColorLevel();
}

AnsiColorLevel _detectColorLevel() {
  final env = Platform.environment;

  // NO_COLOR spec (https://no-color.org/) — presence means no color.
  if (env.containsKey('NO_COLOR')) return AnsiColorLevel.none;

  // FORCE_COLOR overrides detection.
  // Values: '0'=none, '1'=basic, '2'=256, '3'=truecolor, present=basic.
  if (env.containsKey('FORCE_COLOR')) {
    switch (env['FORCE_COLOR']) {
      case '0':
        return AnsiColorLevel.none;
      case '1':
        return AnsiColorLevel.basic;
      case '2':
        return AnsiColorLevel.ansi256;
      case '3':
        return AnsiColorLevel.trueColor;
      default:
        return AnsiColorLevel.basic;
    }
  }

  // COLORTERM is the most reliable indicator of true color.
  final colorterm = (env['COLORTERM'] ?? '').toLowerCase();
  if (colorterm == 'truecolor' || colorterm == '24bit') {
    return AnsiColorLevel.trueColor;
  }

  // Check specific terminal emulators by TERM_PROGRAM.
  final termProgram = env['TERM_PROGRAM'] ?? '';

  // macOS Terminal.app — supports 256 colors but NOT true color.
  if (termProgram == 'Apple_Terminal') {
    return AnsiColorLevel.ansi256;
  }

  // iTerm2 — version 3+ supports true color.
  if (termProgram == 'iTerm.app') {
    final version = env['TERM_PROGRAM_VERSION'] ?? '';
    final major = int.tryParse(version.split('.').first) ?? 0;
    return major >= 3 ? AnsiColorLevel.trueColor : AnsiColorLevel.ansi256;
  }

  // Known true-color terminal emulators.
  const trueColorPrograms = [
    'vscode',
    'WezTerm',
    'Hyper',
    'Alacritty',
    'ghostty',
  ];
  if (trueColorPrograms.contains(termProgram)) {
    return AnsiColorLevel.trueColor;
  }

  // Windows Terminal.
  if (env.containsKey('WT_SESSION')) return AnsiColorLevel.trueColor;

  // KDE Konsole — generally supports true color.
  if (env.containsKey('KONSOLE_VERSION')) return AnsiColorLevel.trueColor;

  // VTE-based terminals (GNOME Terminal, Xfce Terminal, etc.)
  // VTE >= 0.36.00 (version int 3600) supports true color.
  final vte = env['VTE_VERSION'];
  if (vte != null) {
    final ver = int.tryParse(vte) ?? 0;
    return ver >= 3600 ? AnsiColorLevel.trueColor : AnsiColorLevel.ansi256;
  }

  // Check TERM variable.
  final term = env['TERM'] ?? '';

  if (term == 'dumb') return AnsiColorLevel.none;

  if (term.contains('256color')) return AnsiColorLevel.ansi256;

  // Common terminal types — without COLORTERM=truecolor, assume 256.
  if (term.startsWith('xterm') ||
      term.startsWith('screen') ||
      term.startsWith('tmux') ||
      term.startsWith('rxvt') ||
      term == 'linux') {
    return AnsiColorLevel.ansi256;
  }

  // stdout supports ANSI escapes (checked at top), assume at least basic.
  return AnsiColorLevel.basic;
}
