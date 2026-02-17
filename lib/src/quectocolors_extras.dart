// Copyright (c) 2020-2026, tim maffett.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'quectocolors.dart';
import '../supports_ansi_color.dart';

/// Parses a hex color value (String or int) to an (r, g, b) tuple.
///
/// Accepts: '#FF0000', 'FF0000', '#F00', 'F00', 0xFF0000
(int, int, int) _parseHexToRgb(dynamic hex) {
  if (hex is int) {
    return ((hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF);
  }
  String s = hex.toString().replaceAll('#', '').replaceAll('0x', '');
  if (s.length == 3) {
    s = '${s[0]}${s[0]}${s[1]}${s[1]}${s[2]}${s[2]}';
  }
  final v = int.parse(s, radix: 16);
  return ((v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF);
}

/// Regex matching ANSI SGR escape sequences: ESC[ ... m
final RegExp _ansiPattern = RegExp(r'\x1B\[[0-9;]*m');

/// Extra string extensions providing ChalkDart-compatible aliases,
/// additional styles, hex color methods, and ANSI stripping utilities.
///
/// Import via `package:quectocolors/quectocolors_extras.dart`.
extension QuectoExtrasOnStrings on String {
  // ── Style aliases ──────────────────────────────────────────────────

  /// Alias for [reset] (SGR 0).
  String get normal => QuectoColors.reset(this);

  /// Alias for [underline].
  String get underlined => QuectoColors.underline(this);

  /// Alias for [overline].
  String get overlined => QuectoColors.overline(this);

  /// Alias for [inverse].
  String get invert => QuectoColors.inverse(this);

  // ── New ANSI styles ────────────────────────────────────────────────

  /// Slow blink (SGR 5).
  String get blink => QuectoColors.blink(this);

  /// Rapid blink (SGR 6). Not widely supported.
  String get rapidBlink => QuectoColors.rapidBlink(this);

  /// Superscript (SGR 73). Not widely supported.
  String get superscript => QuectoColors.superscript(this);

  /// Subscript (SGR 74). Not widely supported.
  String get subscript => QuectoColors.subscript(this);

  /// Returns the string as-is when ANSI colors are enabled,
  /// or an empty string when they are disabled.
  /// Useful for text that should only appear in color-capable terminals.
  String get visible => ansiColorDisabled ? '' : this;

  // ── brightXYZ aliases for xyzBright foreground colors ──────────────

  /// Alias for [redBright].
  String get brightRed => QuectoColors.redBright(this);

  /// Alias for [greenBright].
  String get brightGreen => QuectoColors.greenBright(this);

  /// Alias for [yellowBright].
  String get brightYellow => QuectoColors.yellowBright(this);

  /// Alias for [blueBright].
  String get brightBlue => QuectoColors.blueBright(this);

  /// Alias for [magentaBright].
  String get brightMagenta => QuectoColors.magentaBright(this);

  /// Alias for [cyanBright].
  String get brightCyan => QuectoColors.cyanBright(this);

  /// Alias for [whiteBright].
  String get brightWhite => QuectoColors.whiteBright(this);

  /// Alias for [gray] / [grey] (brightBlack).
  String get brightBlack => QuectoColors.gray(this);

  // ── brightXYZ aliases for xyzBright background colors (bg*) ────────

  /// Alias for [bgRedBright].
  String get bgBrightRed => QuectoColors.bgRedBright(this);

  /// Alias for [bgGreenBright].
  String get bgBrightGreen => QuectoColors.bgGreenBright(this);

  /// Alias for [bgYellowBright].
  String get bgBrightYellow => QuectoColors.bgYellowBright(this);

  /// Alias for [bgBlueBright].
  String get bgBrightBlue => QuectoColors.bgBlueBright(this);

  /// Alias for [bgMagentaBright].
  String get bgBrightMagenta => QuectoColors.bgMagentaBright(this);

  /// Alias for [bgCyanBright].
  String get bgBrightCyan => QuectoColors.bgCyanBright(this);

  /// Alias for [bgWhiteBright].
  String get bgBrightWhite => QuectoColors.bgWhiteBright(this);

  /// Alias for [bgGray] (bgBrightBlack).
  String get bgBrightBlack => QuectoColors.bgGray(this);

  // ── brightXYZ aliases for xyzBright background colors (on*) ────────

  /// Alias for [onRedBright].
  String get onBrightRed => QuectoColors.onRedBright(this);

  /// Alias for [onGreenBright].
  String get onBrightGreen => QuectoColors.onGreenBright(this);

  /// Alias for [onYellowBright].
  String get onBrightYellow => QuectoColors.onYellowBright(this);

  /// Alias for [onBlueBright].
  String get onBrightBlue => QuectoColors.onBlueBright(this);

  /// Alias for [onMagentaBright].
  String get onBrightMagenta => QuectoColors.onMagentaBright(this);

  /// Alias for [onCyanBright].
  String get onBrightCyan => QuectoColors.onCyanBright(this);

  /// Alias for [onWhiteBright].
  String get onBrightWhite => QuectoColors.onWhiteBright(this);

  /// Alias for [onGray] (onBrightBlack).
  String get onBrightBlack => QuectoColors.onGray(this);

  // ── Hex color methods ──────────────────────────────────────────────

  /// Set foreground color from a hex value.
  ///
  /// Accepts: '#FF0000', 'FF0000', '#F00', 'F00', 0xFF0000
  String hex(dynamic hex) {
    final (r, g, b) = _parseHexToRgb(hex);
    return QuectoColors.rgb(r, g, b)(this);
  }

  /// Set background color from a hex value.
  ///
  /// Accepts: '#FF0000', 'FF0000', '#F00', 'F00', 0xFF0000
  String onHex(dynamic hex) {
    final (r, g, b) = _parseHexToRgb(hex);
    return QuectoColors.bgRgb(r, g, b)(this);
  }

  /// Alias for [onHex]. Set background color from a hex value.
  String bgHex(dynamic hex) => onHex(hex);

  // ── ANSI stripping utilities ───────────────────────────────────────

  /// Returns this string with all ANSI SGR escape sequences removed.
  String get stripAnsi => replaceAll(_ansiPattern, '');

  /// Returns the total length of all ANSI escape sequences in this string.
  /// Uses match iteration to avoid allocating intermediate strings.
  int get ansiLength => _ansiPattern
      .allMatches(this)
      .fold(0, (sum, match) => sum + match.end - match.start);

  /// Returns the visible length of this string (excluding ANSI escape codes).
  int get lengthWithoutAnsi => length - ansiLength;
}
