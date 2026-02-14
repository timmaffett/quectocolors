import 'dart:math';

import 'package:quectocolors/quectocolors.dart';

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


final class QuectoColorsStatic {

  static String debugOut( String instr ) {
    return instr.replaceAll('\x1B[', 'ESC[');
  }

  static QuectoStyler createStyler( final int ansiOpen, final int ansiClose ) {
  //static String Function(String) createStyler( final int ansiOpen, final int ansiClose ) {
    if(ansiColorDisabled) {
      return (String input) => input;
    }


//WAY 1
//    final String openCode = '\x1B[${ansiOpen}m';
//    final String closeCode = '\x1B[${ansiClose}m';


// WAY2
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

    return (String string) {
      //final String string = input;//.toString();
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
      /* WAY 1 * /
      var result = openCode;
      var lastIndex = 0;

      while (index != -1) {
        result += string.substring(lastIndex, index) + openCode;
        lastIndex = index + closeCode.length;
        index = string.indexOf(closeCode, lastIndex);
      }

      result += string.substring(lastIndex) + closeCode;

      return result;
      / * END  WAY 1 */

/* WAY 2 STRING BUFFERS - FASTER than above */
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
/* END WAY 2 */
    };
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
}


/*  we can only compare the static vs non static QuectoColors - the string extensions will collide */
/* USE this STATIC version for string compare because it is faster WEHN COMPILED */
extension QuectoColorsOnStringsStatic on String {


  String get reset => QuectoColorsStatic.reset(this);
  String get bold => QuectoColorsStatic.bold(this);
  String get dim => QuectoColorsStatic.dim(this);
  String get italic => QuectoColorsStatic.italic(this);
  String get underline => QuectoColorsStatic.underline(this);
  String get overline => QuectoColorsStatic.overline(this);
  String get inverse => QuectoColorsStatic.inverse(this);
  String get hidden => QuectoColorsStatic.hidden(this);
  String get strikethrough => QuectoColorsStatic.strikethrough(this);
  String get black => QuectoColorsStatic.black(this);
  String get red => QuectoColorsStatic.red(this);
  String get green => QuectoColorsStatic.green(this);
  String get yellow => QuectoColorsStatic.yellow(this);
  String get blue => QuectoColorsStatic.blue(this);
  String get magenta => QuectoColorsStatic.magenta(this);
  String get cyan => QuectoColorsStatic.cyan(this);
  String get white => QuectoColorsStatic.white(this);
  String get gray => QuectoColorsStatic.gray(this);
  String get bgBlack => QuectoColorsStatic.bgBlack(this);
  String get bgRed => QuectoColorsStatic.bgRed(this);
  String get bgGreen => QuectoColorsStatic.bgGreen(this);
  String get bgYellow => QuectoColorsStatic.bgYellow(this);
  String get bgBlue => QuectoColorsStatic.bgBlue(this);
  String get bgMagenta => QuectoColorsStatic.bgMagenta(this);
  String get bgCyan => QuectoColorsStatic.bgCyan(this);
  String get bgWhite => QuectoColorsStatic.bgWhite(this);
  String get bgGray => QuectoColorsStatic.bgGray(this);
  String get redBright => QuectoColorsStatic.redBright(this);
  String get greenBright => QuectoColorsStatic.greenBright(this);
  String get yellowBright => QuectoColorsStatic.yellowBright(this);
  String get blueBright => QuectoColorsStatic.blueBright(this);
  String get magentaBright => QuectoColorsStatic.magentaBright(this);
  String get cyanBright => QuectoColorsStatic.cyanBright(this);
  String get whiteBright => QuectoColorsStatic.whiteBright(this);
  String get bgRedBright => QuectoColorsStatic.bgRedBright(this);
  String get bgGreenBright => QuectoColorsStatic.bgGreenBright(this);
  String get bgYellowBright => QuectoColorsStatic.bgYellowBright(this);
  String get bgBlueBright => QuectoColorsStatic.bgBlueBright(this);
  String get bgMagentaBright => QuectoColorsStatic.bgMagentaBright(this);
  String get bgCyanBright => QuectoColorsStatic.bgCyanBright(this);
  String get bgWhiteBright      => QuectoColorsStatic.bgWhiteBright(this);

}
