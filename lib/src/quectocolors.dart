import "/supports_ansi_color.dart";

typedef QuectoStyler = String Function(String);

/// Known-plain fast path stylers — ZERO ESC scanning.
/// Use when the caller guarantees the input string contains no nested
/// ANSI escape codes (i.e., it's plain text or a literal string).
/// Access via `QuectoPlain.red('Hello')`.
final class QuectoPlain {

  /// Creates a plain styler that just wraps the string with open/close codes.
  /// No ESC scanning, no nesting support. Maximum speed for known-plain text.
  static QuectoStyler createPlainStyler(final int ansiOpen, final int ansiClose) {
    if (ansiColorDisabled) {
      return (String input) => input;
    }
    final String openCode = '\x1B[${ansiOpen}m';
    final String closeCode = '\x1B[${ansiClose}m';
    return (String string) => '$openCode$string$closeCode';
  }

  static final QuectoStyler reset = createPlainStyler(0, 0);
  static final QuectoStyler bold = createPlainStyler(1, 22);
  static final QuectoStyler dim = createPlainStyler(2, 22);
  static final QuectoStyler italic = createPlainStyler(3, 23);
  static final QuectoStyler underline = createPlainStyler(4, 24);
  static final QuectoStyler overline = createPlainStyler(53, 55);
  static final QuectoStyler inverse = createPlainStyler(7, 27);
  static final QuectoStyler hidden = createPlainStyler(8, 28);
  static final QuectoStyler strikethrough = createPlainStyler(9, 29);

  static final QuectoStyler black = createPlainStyler(30, 39);
  static final QuectoStyler red = createPlainStyler(31, 39);
  static final QuectoStyler green = createPlainStyler(32, 39);
  static final QuectoStyler yellow = createPlainStyler(33, 39);
  static final QuectoStyler blue = createPlainStyler(34, 39);
  static final QuectoStyler magenta = createPlainStyler(35, 39);
  static final QuectoStyler cyan = createPlainStyler(36, 39);
  static final QuectoStyler white = createPlainStyler(37, 39);
  static final QuectoStyler gray = createPlainStyler(90, 39);

  static final QuectoStyler bgBlack = createPlainStyler(40, 49);
  static final QuectoStyler bgRed = createPlainStyler(41, 49);
  static final QuectoStyler bgGreen = createPlainStyler(42, 49);
  static final QuectoStyler bgYellow = createPlainStyler(43, 49);
  static final QuectoStyler bgBlue = createPlainStyler(44, 49);
  static final QuectoStyler bgMagenta = createPlainStyler(45, 49);
  static final QuectoStyler bgCyan = createPlainStyler(46, 49);
  static final QuectoStyler bgWhite = createPlainStyler(47, 49);
  static final QuectoStyler bgGray = createPlainStyler(100, 49);

  static final QuectoStyler redBright = createPlainStyler(91, 39);
  static final QuectoStyler greenBright = createPlainStyler(92, 39);
  static final QuectoStyler yellowBright = createPlainStyler(93, 39);
  static final QuectoStyler blueBright = createPlainStyler(94, 39);
  static final QuectoStyler magentaBright = createPlainStyler(95, 39);
  static final QuectoStyler cyanBright = createPlainStyler(96, 39);
  static final QuectoStyler whiteBright = createPlainStyler(97, 39);

  static final QuectoStyler bgRedBright = createPlainStyler(101, 49);
  static final QuectoStyler bgGreenBright = createPlainStyler(102, 49);
  static final QuectoStyler bgYellowBright = createPlainStyler(103, 49);
  static final QuectoStyler bgBlueBright = createPlainStyler(104, 49);
  static final QuectoStyler bgMagentaBright = createPlainStyler(105, 49);
  static final QuectoStyler bgCyanBright = createPlainStyler(106, 49);
  static final QuectoStyler bgWhiteBright = createPlainStyler(107, 49);

  /// Creates a plain styler for extended ANSI codes (256-color, 16M truecolor).
  /// No ESC scanning, no nesting support. Maximum speed for known-plain text.
  static QuectoStyler createPlainExtendedStyler(final String openCode, final int ansiClose) {
    if (ansiColorDisabled) return (String input) => input;
    final String closeCode = '\x1B[${ansiClose}m';
    return (String string) => '$openCode$string$closeCode';
  }

  // --- 256-color xterm palette (plain fast path) ---
  static QuectoStyler ansi256(int code) => createPlainExtendedStyler('\x1B[38;5;${code}m', 39);
  static QuectoStyler bgAnsi256(int code) => createPlainExtendedStyler('\x1B[48;5;${code}m', 49);
  static QuectoStyler underlineAnsi256(int code) => createPlainExtendedStyler('\x1B[58;5;${code}m', 59);

  // --- 16M true color RGB (plain fast path) ---
  static QuectoStyler rgb(int r, int g, int b) => createPlainExtendedStyler('\x1B[38;2;$r;$g;${b}m', 39);
  static QuectoStyler bgRgb(int r, int g, int b) => createPlainExtendedStyler('\x1B[48;2;$r;$g;${b}m', 49);
  static QuectoStyler underlineRgb(int r, int g, int b) => createPlainExtendedStyler('\x1B[58;2;$r;$g;${b}m', 59);
}

/// Shared core: creates a styler closure from pre-built open/close code strings.
/// Handles both length-4 (\x1B[0m for reset) and length-5 (\x1B[XXm) close codes.
/// Used by both createStyler() and createExtendedStyler().
QuectoStyler _createStylerFromCodes(final String openCode, final String closeCode) {
  final closeLength = closeCode.length;
  final sb = StringBuffer();
  sb.write(openCode); // pre-warm StringBuffer capacity
  sb.clear();

  final int cc2 = closeCode.codeUnitAt(2);
  final int cc3 = closeCode.codeUnitAt(3);

  if (closeLength == 5) {
    final int cc4 = closeCode.codeUnitAt(4);

    return (String string) {
      final int sLen = string.length;
      final int endPos = sLen - 4; // sLen - closeLength + 1
      int index = -1;
      for (int i = 0; i < endPos; i++) {
        if (string.codeUnitAt(i) == 0x1B &&
            string.codeUnitAt(i + 1) == 0x5B &&
            string.codeUnitAt(i + 2) == cc2 &&
            string.codeUnitAt(i + 3) == cc3 &&
            string.codeUnitAt(i + 4) == cc4) {
          index = i;
          break;
        }
      }

      if (index == -1) {
        return '$openCode$string$closeCode';
      }

      sb.clear();
      sb.write(openCode);

      int lastIndex = 0;
      do {
        sb.write(string.substring(lastIndex, index));
        sb.write(openCode);
        lastIndex = index + closeLength;
        index = -1;
        for (int i = lastIndex; i < endPos; i++) {
          if (string.codeUnitAt(i) == 0x1B &&
              string.codeUnitAt(i + 1) == 0x5B &&
              string.codeUnitAt(i + 2) == cc2 &&
              string.codeUnitAt(i + 3) == cc3 &&
              string.codeUnitAt(i + 4) == cc4) {
            index = i;
            break;
          }
        }
      } while (index != -1);

      sb.write(string.substring(lastIndex));
      sb.write(closeCode);

      return sb.toString();
    };
  } else {
    // Length-4 path: only reset (\x1B[0m)
    return (String string) {
      final int sLen = string.length;
      final int endPos = sLen - 3; // sLen - closeLength + 1
      int index = -1;
      for (int i = 0; i < endPos; i++) {
        if (string.codeUnitAt(i) == 0x1B &&
            string.codeUnitAt(i + 1) == 0x5B &&
            string.codeUnitAt(i + 2) == cc2 &&
            string.codeUnitAt(i + 3) == cc3) {
          index = i;
          break;
        }
      }

      if (index == -1) {
        return '$openCode$string$closeCode';
      }

      sb.clear();
      sb.write(openCode);

      int lastIndex = 0;
      do {
        sb.write(string.substring(lastIndex, index));
        sb.write(openCode);
        lastIndex = index + closeLength;
        index = -1;
        for (int i = lastIndex; i < endPos; i++) {
          if (string.codeUnitAt(i) == 0x1B &&
              string.codeUnitAt(i + 1) == 0x5B &&
              string.codeUnitAt(i + 2) == cc2 &&
              string.codeUnitAt(i + 3) == cc3) {
            index = i;
            break;
          }
        }
      } while (index != -1);

      sb.write(string.substring(lastIndex));
      sb.write(closeCode);

      return sb.toString();
    };
  }
}

final class QuectoColors {

  static String debugOut( String instr ) {
    return instr.replaceAll('\x1B[', 'ESC[');
  }

  static QuectoStyler createStyler( final int ansiOpen, final int ansiClose ) {
    if(ansiColorDisabled) {
      return (String input) => input;
    }
    return _createStylerFromCodes('\x1B[${ansiOpen}m', '\x1B[${ansiClose}m');
  }

  static final QuectoStyler reset = createStyler(0, 0);
  static final QuectoStyler bold = createStyler(1, 22);
  static final QuectoStyler dim = createStyler(2, 22);
  static final QuectoStyler italic = createStyler(3, 23);
  static final QuectoStyler underline = createStyler(4, 24);
  static final QuectoStyler overline = createStyler(53, 55);
  static final QuectoStyler inverse = createStyler(7, 27);
  static final QuectoStyler hidden = createStyler(8, 28);
  static final QuectoStyler strikethrough = createStyler(9, 29);

  static final QuectoStyler black = createStyler(30, 39);
  static final QuectoStyler red = createStyler(31, 39);
  static final QuectoStyler green = createStyler(32, 39);
  static final QuectoStyler yellow = createStyler(33, 39);
  static final QuectoStyler blue = createStyler(34, 39);
  static final QuectoStyler magenta = createStyler(35, 39);
  static final QuectoStyler cyan = createStyler(36, 39);
  static final QuectoStyler white = createStyler(37, 39);
  static final QuectoStyler gray = createStyler(90, 39);

  static final QuectoStyler bgBlack = createStyler(40, 49);
  static final QuectoStyler bgRed = createStyler(41, 49);
  static final QuectoStyler bgGreen = createStyler(42, 49);
  static final QuectoStyler bgYellow = createStyler(43, 49);
  static final QuectoStyler bgBlue = createStyler(44, 49);
  static final QuectoStyler bgMagenta = createStyler(45, 49);
  static final QuectoStyler bgCyan = createStyler(46, 49);
  static final QuectoStyler bgWhite = createStyler(47, 49);
  static final QuectoStyler bgGray = createStyler(100, 49);

  static final QuectoStyler redBright = createStyler(91, 39);
  static final QuectoStyler greenBright = createStyler(92, 39);
  static final QuectoStyler yellowBright = createStyler(93, 39);
  static final QuectoStyler blueBright = createStyler(94, 39);
  static final QuectoStyler magentaBright = createStyler(95, 39);
  static final QuectoStyler cyanBright = createStyler(96, 39);
  static final QuectoStyler whiteBright = createStyler(97, 39);

  static final QuectoStyler bgRedBright = createStyler(101, 49);
  static final QuectoStyler bgGreenBright = createStyler(102, 49);
  static final QuectoStyler bgYellowBright = createStyler(103, 49);
  static final QuectoStyler bgBlueBright = createStyler(104, 49);
  static final QuectoStyler bgMagentaBright = createStyler(105, 49);
  static final QuectoStyler bgCyanBright = createStyler(106, 49);
  static final QuectoStyler bgWhiteBright = createStyler(107, 49);

  /// Creates a styler for extended ANSI codes (256-color, 16M truecolor).
  /// Takes a pre-built openCode string and a close code int.
  /// Delegates to the shared _createStylerFromCodes() core.
  static QuectoStyler createExtendedStyler(final String openCode, final int ansiClose) {
    if (ansiColorDisabled) {
      return (String input) => input;
    }
    return _createStylerFromCodes(openCode, '\x1B[${ansiClose}m');
  }

  /// Converts RGB values to the nearest xterm 256-color palette index.
  static int rgbToAnsi256(int red, int green, int blue) {
    if (red == green && green == blue) {
      if (red < 8) return 16;
      if (red > 248) return 231;
      return (((red - 8) / 247) * 24).round() + 232;
    }
    return 16 + (36 * (red / 255 * 5).round()) + (6 * (green / 255 * 5).round()) + (blue / 255 * 5).round();
  }

  // --- 256-color xterm palette ---
  static QuectoStyler ansi256(int code) => createExtendedStyler('\x1B[38;5;${code}m', 39);
  static QuectoStyler bgAnsi256(int code) => createExtendedStyler('\x1B[48;5;${code}m', 49);
  static QuectoStyler underlineAnsi256(int code) => createExtendedStyler('\x1B[58;5;${code}m', 59);

  // --- 16M true color (RGB) ---
  static QuectoStyler rgb(int r, int g, int b) => createExtendedStyler('\x1B[38;2;$r;$g;${b}m', 39);
  static QuectoStyler bgRgb(int r, int g, int b) => createExtendedStyler('\x1B[48;2;$r;$g;${b}m', 49);
  static QuectoStyler underlineRgb(int r, int g, int b) => createExtendedStyler('\x1B[58;2;$r;$g;${b}m', 59);
}


/// String extensions for concise styling: `'text'.red`, `'text'.bold.italic`.
extension QuectoColorsOnStrings on String {
  String get reset => QuectoColors.reset(this);
  String get bold => QuectoColors.bold(this);
  String get dim => QuectoColors.dim(this);
  String get italic => QuectoColors.italic(this);
  String get underline => QuectoColors.underline(this);
  String get overline => QuectoColors.overline(this);
  String get inverse => QuectoColors.inverse(this);
  String get hidden => QuectoColors.hidden(this);
  String get strikethrough => QuectoColors.strikethrough(this);
  String get black => QuectoColors.black(this);
  String get red => QuectoColors.red(this);
  String get green => QuectoColors.green(this);
  String get yellow => QuectoColors.yellow(this);
  String get blue => QuectoColors.blue(this);
  String get magenta => QuectoColors.magenta(this);
  String get cyan => QuectoColors.cyan(this);
  String get white => QuectoColors.white(this);
  String get gray => QuectoColors.gray(this);
  String get bgBlack => QuectoColors.bgBlack(this);
  String get bgRed => QuectoColors.bgRed(this);
  String get bgGreen => QuectoColors.bgGreen(this);
  String get bgYellow => QuectoColors.bgYellow(this);
  String get bgBlue => QuectoColors.bgBlue(this);
  String get bgMagenta => QuectoColors.bgMagenta(this);
  String get bgCyan => QuectoColors.bgCyan(this);
  String get bgWhite => QuectoColors.bgWhite(this);
  String get bgGray => QuectoColors.bgGray(this);
  String get redBright => QuectoColors.redBright(this);
  String get greenBright => QuectoColors.greenBright(this);
  String get yellowBright => QuectoColors.yellowBright(this);
  String get blueBright => QuectoColors.blueBright(this);
  String get magentaBright => QuectoColors.magentaBright(this);
  String get cyanBright => QuectoColors.cyanBright(this);
  String get whiteBright => QuectoColors.whiteBright(this);
  String get bgRedBright => QuectoColors.bgRedBright(this);
  String get bgGreenBright => QuectoColors.bgGreenBright(this);
  String get bgYellowBright => QuectoColors.bgYellowBright(this);
  String get bgBlueBright => QuectoColors.bgBlueBright(this);
  String get bgMagentaBright => QuectoColors.bgMagentaBright(this);
  String get bgCyanBright => QuectoColors.bgCyanBright(this);
  String get bgWhiteBright => QuectoColors.bgWhiteBright(this);

  // --- 256-color xterm palette ---
  String ansi256(int code) => QuectoColors.ansi256(code)(this);
  String bgAnsi256(int code) => QuectoColors.bgAnsi256(code)(this);
  String underlineAnsi256(int code) => QuectoColors.underlineAnsi256(code)(this);

  // --- 16M true color (RGB) ---
  String rgb(int r, int g, int b) => QuectoColors.rgb(r, g, b)(this);
  String bgRgb(int r, int g, int b) => QuectoColors.bgRgb(r, g, b)(this);
  String underlineRgb(int r, int g, int b) => QuectoColors.underlineRgb(r, g, b)(this);
}
