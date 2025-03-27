import 'package:quectocolors/src/quectocolors.dart';

class AnsiPen {


  List<String Function(String)> stack = [];


  dynamic call([Object? input]) {
    if(input==null) return this;
    String string = input.toString();
    for(final stylefunct in stack) {
      string = stylefunct(string);
    }
    return string;
  }


  static String Function(String) format( final int ansiOpen, final int ansiClose ) {
    if(!terminalSupportsColor) {
      return (input) => input;
    }

//WAY 1
//    final String openCode = '\u001B[${ansiOpen}m';
//    final String closeCode = '\u001B[${ansiClose}m';


// WAY2
//    final sb = StringBuffer();
//
//
//    sb.write('\u001B[');
//    sb.write(ansiOpen);
//    sb.write('m');
//   
//    final String openCode = sb.toString();
//    sb.clear();
//
//    sb.write('\u001B[');
//    sb.write(ansiClose);
//    sb.write('m');
//
//    final String closeCode = sb.toString();


    final sb = StringBuffer();


    sb.write('\u001B[${ansiOpen}m');
   
    final String openCode = sb.toString();
    sb.clear();

    sb.write('\u001B[${ansiClose}m');

    final String closeCode = sb.toString();



    return (string) {
      //final String string = input.toString();
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
      /* WAY 1
      var result = openCode;
      var lastIndex = 0;

      while (index != -1) {
        result += string.substring(lastIndex, index) + openCode;
        lastIndex = index + closeCode.length;
        index = string.indexOf(closeCode, lastIndex);
      }

      result += string.substring(lastIndex) + closeCode;

      return result;
      */


      //final sb = StringBuffer();
      sb.clear();
      //var result = openCode;
      var lastIndex = 0;

      while (index != -1) {
        sb.write( string.substring(lastIndex, index) );
        sb.write(openCode );
        lastIndex = index + closeCode.length;
        index = string.indexOf(closeCode, lastIndex);
      }

      sb.write( string.substring(lastIndex) );
      sb.write( closeCode );

      return sb.toString();

    };
  }

  static final _reset = format(0, 0);
  static final _bold = format(1, 22);
  static final _dim = format(2, 22);
  static final _italic = format(3, 23);
  static final _underline = format(4, 24);
  static final _overline = format(53, 55);
  static final _inverse = format(7, 27);
  static final _hidden = format(8, 28);
  static final _strikethrough = format(9, 29);
  static final _black = format(30, 39);
  static final _red = format(31, 39);
  static final _green = format(32, 39);
  static final _yellow = format(33, 39);
  static final _blue = format(34, 39);
  static final _magenta = format(35, 39);
  static final _cyan = format(36, 39);
  static final _white = format(37, 39);
  static final _gray = format(90, 39);
  static final _bgBlack = format(40, 49);
  static final _bgRed = format(41, 49);
  static final _bgGreen = format(42, 49);
  static final _bgYellow = format(43, 49);
  static final _bgBlue = format(44, 49);
  static final _bgMagenta = format(45, 49);
  static final _bgCyan = format(46, 49);
  static final _bgWhite = format(47, 49);
  static final _bgGray = format(100, 49);
  static final _redBright = format(91, 39);
  static final _greenBright = format(92, 39);
  static final _yellowBright = format(93, 39);
  static final _blueBright = format(94, 39);
  static final _magentaBright = format(95, 39);
  static final _cyanBright = format(96, 39);
  static final _whiteBright = format(97, 39);
  static final _bgRedBright = format(101, 49);
  static final _bgGreenBright = format(102, 49);
  static final _bgYellowBright = format(103, 49);
  static final _bgBlueBright = format(104, 49);
  static final _bgMagentaBright = format(105, 49);
  static final _bgCyanBright = format(106, 49);
  static final _bgWhiteBright = format(107, 49);


  AnsiPen get reset {
    stack.add(_reset);
    return this;
  }
  AnsiPen get bold {
    stack.add(_bold);
    return this;
  }
  AnsiPen get dim {
    stack.add(_dim);
    return this;
  }
  AnsiPen get italic {
    stack.add(_italic);
    return this;
  }
  AnsiPen get underline {
    stack.add(_underline);
    return this;
  }
  AnsiPen get overline {
    stack.add(_overline);
    return this;
  }
  AnsiPen get inverse {
    stack.add(_inverse);
    return this;
  }
  AnsiPen get hidden {
    stack.add(_hidden);
    return this;
  }
  AnsiPen get strikethrough {
    stack.add(_strikethrough);
    return this;
  }
  AnsiPen get black {
    stack.add(_black);
    return this;
  }
  AnsiPen get red {
    stack.add(_red);
    return this;
  }
  AnsiPen get green {
    stack.add(_green);
    return this;
  }
  AnsiPen get yellow {
    stack.add(_yellow);
    return this;
  }
  AnsiPen get blue {
    stack.add(_blue);
    return this;
  }
  AnsiPen get magenta {
    stack.add(_magenta);
    return this;
  }
  AnsiPen get cyan {
    stack.add(_cyan);
    return this;
  }
  AnsiPen get white {
    stack.add(_white);
    return this;
  }
  AnsiPen get gray {
    stack.add(_gray);
    return this;
  }
  AnsiPen get bgBlack {
    stack.add(_bgBlack);
    return this;
  }
  AnsiPen get bgRed {
    stack.add(_bgRed);
    return this;
  }
  AnsiPen get bgGreen {
    stack.add(_bgGreen);
    return this;
  }
  AnsiPen get bgYellow {
    stack.add(_bgYellow);
    return this;
  }
  AnsiPen get bgBlue {
    stack.add(_bgBlue);
    return this;
  }
  AnsiPen get bgMagenta {
    stack.add(_bgMagenta);
    return this;
  }
  AnsiPen get bgCyan {
    stack.add(_bgCyan);
    return this;
  }
  AnsiPen get bgWhite {
    stack.add(_bgWhite);
    return this;
  }
  AnsiPen get bgGray {
    stack.add(_bgGray);
    return this;
  }
  AnsiPen get redBright {
    stack.add(_redBright);
    return this;
  }
  AnsiPen get greenBright {
    stack.add(_greenBright);
    return this;
  }
  AnsiPen get yellowBright {
    stack.add(_yellowBright);
    return this;
  }
  AnsiPen get blueBright {
    stack.add(_blueBright);
    return this;
  }
  AnsiPen get magentaBright {
    stack.add(_magentaBright);
    return this;
  }
  AnsiPen get cyanBright {
    stack.add(_cyanBright);
    return this;
  }
  AnsiPen get whiteBright {
    stack.add(_whiteBright);
    return this;
  }
  AnsiPen get bgRedBright {
    stack.add(_bgRedBright);
    return this;
  }
  AnsiPen get bgGreenBright {
    stack.add(_bgGreenBright);
    return this;
  }
  AnsiPen get bgYellowBright {
    stack.add(_bgYellowBright);
    return this;
  }
  AnsiPen get bgBlueBright {
    stack.add(_bgBlueBright);
    return this;
  }
  AnsiPen get bgMagentaBright {
    stack.add(_bgMagentaBright);
    return this;
  }
  AnsiPen get bgCyanBright {
    stack.add(_bgCyanBright);
    return this;
  }
  AnsiPen get bgWhiteBright {
    stack.add(_bgWhiteBright);
    return this;
  }
}