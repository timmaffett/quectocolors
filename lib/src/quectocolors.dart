import 'dart:math';

import "/supports_ansi_color.dart";

//import 'package:ansicolor/ansicolor.dart';

///import tty from 'node:tty';
///
///// eslint-disable-next-line no-warning-comments
///// TODO: Use a better method when it's added to Node.js (https://github.com/nodejs/node/pull/40240)
///// Lots of optionals here to support Deno.
///const hasColors = tty?.WriteStream?.prototype?.hasColors?.() ?? false;

/*


/// Globally enable or disable [AnsiPen] settings.
///
/// Note: defaults to environment support; but can be overridden.
///
/// Handy for turning on and off embedded colors without commenting out code.
bool ansiColorDisabled = !supportsAnsiColor;

@Deprecated(
    'Will be removed in future releases in favor of [ansiColorDisabled]')
// ignore: non_constant_identifier_names
bool get color_disabled => ansiColorDisabled;
@Deprecated(
    'Will be removed in future releases in favor of [ansiColorDisabled]')
// ignore: non_constant_identifier_names
set color_disabled(bool disabled) => ansiColorDisabled = disabled;

/// Pen attributes for foreground and background colors.
///
/// Use the pen in string interpolation to output ansi codes.
/// Use [up] in string interpolation to globally reset colors.
class AnsiPen {
  /// Treat a pen instance as a function such that `pen('msg')` is the same as
  /// `pen.write('msg')`.
  String call(Object msg) => write(msg);

  /// Allow pen colors to be used in a string.
  ///
  /// Note: Once the pen is down, its attributes remain in effect till they are
  ///     changed by another pen or [up].
  @override
  String toString() {
    if (ansiColorDisabled) return '';
    if (!_dirty) return _pen;

    final sb = StringBuffer();
    if (_fcolor != -1) {
      sb.write('${ansiEscape}38;5;${_fcolor}m');
    }

    if (_bcolor != -1) {
      sb.write('${ansiEscape}48;5;${_bcolor}m');
    }

    _dirty = false;
    _pen = sb.toString();
    return _pen;
  }

  /// Returns control codes to change the terminal colors.
  String get down => '${this}';

  /// Resets all pen attributes in the terminal.
  String get up => ansiColorDisabled ? '' : ansiDefault;

  /// Write the [msg.toString()] with the pen's current settings and then
  /// reset all attributes.
  String write(Object msg) => '${this}$msg$up';

  void black({bool bg = false, bool bold = false}) => _std(0, bold, bg);
  void red({bool bg = false, bool bold = false}) => _std(1, bold, bg);
  void green({bool bg = false, bool bold = false}) => _std(2, bold, bg);
  void yellow({bool bg = false, bool bold = false}) => _std(3, bold, bg);
  void blue({bool bg = false, bool bold = false}) => _std(4, bold, bg);
  void magenta({bool bg = false, bool bold = false}) => _std(5, bold, bg);
  void cyan({bool bg = false, bool bold = false}) => _std(6, bold, bg);
  void white({bool bg = false, bool bold = false}) => _std(7, bold, bg);

  /// Sets the pen color to the rgb value between 0.0..1.0.
  void rgb({num r = 1.0, num g = 1.0, num b = 1.0, bool bg = false}) => xterm(
      (r.clamp(0.0, 1.0) * 5).toInt() * 36 +
          (g.clamp(0.0, 1.0) * 5).toInt() * 6 +
          (b.clamp(0.0, 1.0) * 5).toInt() +
          16,
      bg: bg);

  /// Sets the pen color to a grey scale value between 0.0 and 1.0.
  void gray({num level = 1.0, bool bg = false}) =>
      xterm(232 + (level.clamp(0.0, 1.0) * 23).round(), bg: bg);

*/

typedef QuectoStyler = String Function(String);

/// Known-plain fast path stylers — ZERO ESC scanning.
/// Use when the caller guarantees the input string contains no nested
/// ANSI escape codes (i.e., it's plain text or a literal string).
/// This matches ansicolor's speed exactly: pure '$openCode$string$closeCode'.
///
/// Usage:
///   quectoColors.plain.red('Hello')        // instance-based
///   QuectoColorsStatic.plain.red('Hello')   // static version
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

  final QuectoStyler reset = createPlainStyler(0, 0);
  final QuectoStyler bold = createPlainStyler(1, 22);
  final QuectoStyler dim = createPlainStyler(2, 22);
  final QuectoStyler italic = createPlainStyler(3, 23);
  final QuectoStyler underline = createPlainStyler(4, 24);
  final QuectoStyler overline = createPlainStyler(53, 55);
  final QuectoStyler inverse = createPlainStyler(7, 27);
  final QuectoStyler hidden = createPlainStyler(8, 28);
  final QuectoStyler strikethrough = createPlainStyler(9, 29);

  final QuectoStyler black = createPlainStyler(30, 39);
  final QuectoStyler red = createPlainStyler(31, 39);
  final QuectoStyler green = createPlainStyler(32, 39);
  final QuectoStyler yellow = createPlainStyler(33, 39);
  final QuectoStyler blue = createPlainStyler(34, 39);
  final QuectoStyler magenta = createPlainStyler(35, 39);
  final QuectoStyler cyan = createPlainStyler(36, 39);
  final QuectoStyler white = createPlainStyler(37, 39);
  final QuectoStyler gray = createPlainStyler(90, 39);

  final QuectoStyler bgBlack = createPlainStyler(40, 49);
  final QuectoStyler bgRed = createPlainStyler(41, 49);
  final QuectoStyler bgGreen = createPlainStyler(42, 49);
  final QuectoStyler bgYellow = createPlainStyler(43, 49);
  final QuectoStyler bgBlue = createPlainStyler(44, 49);
  final QuectoStyler bgMagenta = createPlainStyler(45, 49);
  final QuectoStyler bgCyan = createPlainStyler(46, 49);
  final QuectoStyler bgWhite = createPlainStyler(47, 49);
  final QuectoStyler bgGray = createPlainStyler(100, 49);

  final QuectoStyler redBright = createPlainStyler(91, 39);
  final QuectoStyler greenBright = createPlainStyler(92, 39);
  final QuectoStyler yellowBright = createPlainStyler(93, 39);
  final QuectoStyler blueBright = createPlainStyler(94, 39);
  final QuectoStyler magentaBright = createPlainStyler(95, 39);
  final QuectoStyler cyanBright = createPlainStyler(96, 39);
  final QuectoStyler whiteBright = createPlainStyler(97, 39);

  final QuectoStyler bgRedBright = createPlainStyler(101, 49);
  final QuectoStyler bgGreenBright = createPlainStyler(102, 49);
  final QuectoStyler bgYellowBright = createPlainStyler(103, 49);
  final QuectoStyler bgBlueBright = createPlainStyler(104, 49);
  final QuectoStyler bgMagentaBright = createPlainStyler(105, 49);
  final QuectoStyler bgCyanBright = createPlainStyler(106, 49);
  final QuectoStyler bgWhiteBright = createPlainStyler(107, 49);
}

final class QuectoColors {

  static String debugOut( String instr ) {
    return instr.replaceAll('\x1B[', 'ESC[');
  }

  static QuectoStyler createStyler( final int ansiOpen, final int ansiClose ) {
  //static String Function(String) createStyler( final int ansiOpen, final int ansiClose ) {
    if(ansiColorDisabled) {
      return (String input) => input;
    }


// --- OPEN/CLOSE CODE CONSTRUCTION HISTORY ---

//WAY 1 - string interpolation (FASTEST for building open/close codes)
//    final String openCode = '\x1B[${ansiOpen}m';
//    final String closeCode = '\x1B[${ansiClose}m';

// WAY2 - StringBuffer with separate writes - slower than WAY 1
//    final sb = StringBuffer();
//
//
//    sb.write('\x1B[');
//    sb.write(ansiOpen);
//    sb.write('m');
//
//    final String openCode = sb.toString();
//    sb.clear();
//
//    sb.write('\x1B[');
//    sb.write(ansiClose);
//    sb.write('m');
//
//    final String closeCode = sb.toString();

/* WAY 3 - sometimes appeared to test faster but REALLY??
    final sb = StringBuffer();


    sb.write('\x1B[${ansiOpen}m');

    final String openCode = sb.toString();
    sb.clear();

    sb.write('\x1B[${ansiClose}m');

    final String closeCode = sb.toString();
WAY 3*/

    final String openCode = '\x1B[${ansiOpen}m';
    final String closeCode = '\x1B[${ansiClose}m';
    final closeLength = closeCode.length;
    final sb = StringBuffer(); // create our string buffer here - so scoped for each styler but not having to be created each styling


// --- CLOSE CODE SEARCH & NESTING HISTORY ---
// The main performance bottleneck is finding the closeCode in the input string.
// We take String directly instead of Object to avoid .toString() overhead.

/* WAY 3 - string.indexOf(closeCode) — the original approach.
    // Simple but slow: indexOf does general pattern matching on every call,
    // even though the close code always starts with the rare 0x1B (ESC) byte.
    // ~2.5x slower than WAY 4 on simple (no-nesting) case,
    // ~2.4x slower on complex nested case with 200-char strings.

    return (String string) {
      //final String string = input.toString();  // we just take string instead, the conversion overhead is not worth it
      int index = string.indexOf(closeCode);

      if (index == -1) {
        // ADDING STRINGS VERSION
        //    return openCode + string + closeCode; // 25% slower then string interpolation
        // STRING BUFFER VERSION,
        //    sb.clear();
        //    sb.write(openCode);
        //    sb.write(string);
        //    sb.write(closeCode);
        //    return sb.toString(); //30+% slower than string interpolation
        return '$openCode$string$closeCode';
      }

      // Handle nested colors.

      // We could do this:
      // return openCode + string.replaceAll(closeCode, openCode) + closeCode;
      // but this version is 20 to 30 % faster:
      / * NESTING WAY 1 - string concatenation with += * /
      var result = openCode;
      var lastIndex = 0;

      while (index != -1) {
        result += string.substring(lastIndex, index) + openCode;
        lastIndex = index + closeCode.length;
        index = string.indexOf(closeCode, lastIndex);
      }

      result += string.substring(lastIndex) + closeCode;

      return result;
      / * END NESTING WAY 1 * /

/ * NESTING WAY 2 STRING BUFFERS - FASTER than NESTING WAY 1 above * /
      //Use other scoped sb//final sb = StringBuffer();

      // CREATE HERE WITH INITIAL VALUE
      //final sb = StringBuffer(openCode);

      //USE OUTER - fastest
      sb.clear();  // we are using persistently scoped sb, so clear and start fresh
      sb.write(openCode);

      int lastIndex = 0;

      // avoid one comparison by doing index!=-1 check at END of loop since the first time we come in
      // we know it is NOT -1 or we would have exited above..
      //while (index != -1) {
      //  sb.write( string.substring(lastIndex, index) );
      //  sb.write(openCode );
      //  lastIndex = index + closeLength;
      //  index = string.indexOf(closeCode, lastIndex);
      //}

      do {
        sb.write( string.substring(lastIndex, index) );
        sb.write(openCode );
        lastIndex = index + closeLength;
        index = string.indexOf(closeCode, lastIndex);
      } while (index != -1);


      sb.write( string.substring(lastIndex) );
      sb.write( closeCode );

      return sb.toString();
/ * END NESTING WAY 2 * /
    };
END WAY 3 */


// WAY 4 - codeUnitAt unrolled scan — CURRENT FASTEST
// Pre-cache close code unit values for fast single-pass scanning.
// All ANSI close codes are \x1B[Xm (4 chars) or \x1B[XXm (5 chars).
// Instead of string.indexOf(closeCode) which does a general pattern
// search, we scan for the rare 0x1B byte and immediately verify the
// remaining bytes with unrolled comparisons.
// ~2.5-3x faster than WAY 3 indexOf on simple case (74ns vs 81ns per call),
// ~1.4x faster on 3-style nesting (285ns vs 411ns),
// ~2.4x faster on complex nested with 200-char strings (3064ns vs 7304ns).
// Also uses NESTING WAY 2 (StringBuffer with do-while) for the nesting path.

    final int cc2 = closeCode.codeUnitAt(2);
    final int cc3 = closeCode.codeUnitAt(3);

    if (closeLength == 5) {
      // Length-5 path: covers all styles except reset (bold, italic,
      // underline, colors, bg colors, etc.)
      final int cc4 = closeCode.codeUnitAt(4);

      return (String string) {
        // Single-pass scan: check for 0x1B, then verify \x1B[XXm inline.
        final int sLen = string.length;
        final int endPos = sLen - 4; // sLen - closeLength + 1
        int index = -1;
        for (int i = 0; i < endPos; i++) {
          if (string.codeUnitAt(i) == 0x1B &&
              string.codeUnitAt(i + 1) == 0x5B && // '['
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

        // Handle nested colors using StringBuffer (NESTING WAY 2).
        sb.clear();
        sb.write(openCode);

        int lastIndex = 0;
        do {
          sb.write( string.substring(lastIndex, index) );
          sb.write( openCode );
          lastIndex = index + closeLength;
          // Continue scanning from lastIndex
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

        sb.write( string.substring(lastIndex) );
        sb.write( closeCode );

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
          sb.write( string.substring(lastIndex, index) );
          sb.write( openCode );
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

        sb.write( string.substring(lastIndex) );
        sb.write( closeCode );

        return sb.toString();
      };
    }
/* END WAY 4 */
  }

  final QuectoStyler reset = createStyler(0, 0);
  final QuectoStyler bold = createStyler(1, 22);
  final QuectoStyler dim = createStyler(2, 22);
  final QuectoStyler italic = createStyler(3, 23);
  final QuectoStyler underline = createStyler(4, 24);
  final QuectoStyler overline = createStyler(53, 55);
  final QuectoStyler inverse = createStyler(7, 27);
  final QuectoStyler hidden = createStyler(8, 28);
  final QuectoStyler strikethrough = createStyler(9, 29);

  
  final QuectoStyler black = createStyler(30, 39);
  final QuectoStyler red = createStyler(31, 39);
  final QuectoStyler green = createStyler(32, 39);
  final QuectoStyler yellow = createStyler(33, 39);
  final QuectoStyler blue = createStyler(34, 39);
  final QuectoStyler magenta = createStyler(35, 39);
  final QuectoStyler cyan = createStyler(36, 39);
  final QuectoStyler white = createStyler(37, 39);
  final QuectoStyler gray = createStyler(90, 39);


  final QuectoStyler bgBlack = createStyler(40, 49);
  final QuectoStyler bgRed = createStyler(41, 49);
  final QuectoStyler bgGreen = createStyler(42, 49);
  final QuectoStyler bgYellow = createStyler(43, 49);
  final QuectoStyler bgBlue = createStyler(44, 49);
  final QuectoStyler bgMagenta = createStyler(45, 49);
  final QuectoStyler bgCyan = createStyler(46, 49);
  final QuectoStyler bgWhite = createStyler(47, 49);
  final QuectoStyler bgGray = createStyler(100, 49);

  final QuectoStyler redBright = createStyler(91, 39);
  final QuectoStyler greenBright = createStyler(92, 39);
  final QuectoStyler yellowBright = createStyler(93, 39);
  final QuectoStyler blueBright = createStyler(94, 39);
  final QuectoStyler magentaBright = createStyler(95, 39);
  final QuectoStyler cyanBright = createStyler(96, 39);
  final QuectoStyler whiteBright = createStyler(97, 39);

  final QuectoStyler bgRedBright = createStyler(101, 49);
  final QuectoStyler bgGreenBright = createStyler(102, 49);
  final QuectoStyler bgYellowBright = createStyler(103, 49);
  final QuectoStyler bgBlueBright = createStyler(104, 49);
  final QuectoStyler bgMagentaBright = createStyler(105, 49);
  final QuectoStyler bgCyanBright = createStyler(106, 49);
  final QuectoStyler bgWhiteBright = createStyler(107, 49);

  /// Known-plain fast path: zero ESC scanning, pure string interpolation.
  /// Use when caller guarantees the input has no nested ANSI escape codes.
  /// Example: quectoColors.plain.red('Hello World')
  final QuectoPlain plain = QuectoPlain();
}


/* WE USE THE static versions as when COMPILED the static code is faster 

extension QuectoColorsOnStrings on String {

  static QuectoColors quectoColors = QuectoColors();

  String get reset => quectoColors.reset(this);
  String get bold => quectoColors.bold(this);
  String get dim => quectoColors.dim(this);
  String get italic => quectoColors.italic(this);
  String get underline => quectoColors.underline(this);
  String get overline => quectoColors.overline(this);
  String get inverse => quectoColors.inverse(this);
  String get hidden => quectoColors.hidden(this);
  String get strikethrough => quectoColors.strikethrough(this);
  String get black => quectoColors.black(this);
  String get red => quectoColors.red(this);
  String get green => quectoColors.green(this);
  String get yellow => quectoColors.yellow(this);
  String get blue => quectoColors.blue(this);
  String get magenta => quectoColors.magenta(this);
  String get cyan => quectoColors.cyan(this);
  String get white => quectoColors.white(this);
  String get gray => quectoColors.gray(this);
  String get bgBlack => quectoColors.bgBlack(this);
  String get bgRed => quectoColors.bgRed(this);
  String get bgGreen => quectoColors.bgGreen(this);
  String get bgYellow => quectoColors.bgYellow(this);
  String get bgBlue => quectoColors.bgBlue(this);
  String get bgMagenta => quectoColors.bgMagenta(this);
  String get bgCyan => quectoColors.bgCyan(this);
  String get bgWhite => quectoColors.bgWhite(this);
  String get bgGray => quectoColors.bgGray(this);
  String get redBright => quectoColors.redBright(this);
  String get greenBright => quectoColors.greenBright(this);
  String get yellowBright => quectoColors.yellowBright(this);
  String get blueBright => quectoColors.blueBright(this);
  String get magentaBright => quectoColors.magentaBright(this);
  String get cyanBright => quectoColors.cyanBright(this);
  String get whiteBright => quectoColors.whiteBright(this);
  String get bgRedBright => quectoColors.bgRedBright(this);
  String get bgGreenBright => quectoColors.bgGreenBright(this);
  String get bgYellowBright => quectoColors.bgYellowBright(this);
  String get bgBlueBright => quectoColors.bgBlueBright(this);
  String get bgMagentaBright => quectoColors.bgMagentaBright(this);
  String get bgCyanBright => quectoColors.bgCyanBright(this);
  String get bgWhiteBright      => quectoColors.bgWhiteBright(this);

}
*/

QuectoColors quectoColors = QuectoColors();
