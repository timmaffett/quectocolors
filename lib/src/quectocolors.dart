import 'dart:math';

import 'package:quectocolors/src/quectocolors_pen.dart';
//import 'package:ansicolor/ansicolor.dart';

///import tty from 'node:tty';
///
///// eslint-disable-next-line no-warning-comments
///// TODO: Use a better method when it's added to Node.js (https://github.com/nodejs/node/pull/40240)
///// Lots of optionals here to support Deno.
///const hasColors = tty?.WriteStream?.prototype?.hasColors?.() ?? false;


bool terminalSupportsColor = true;

class QuectoColors {

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
      //final String string = input;//.toString(); // eslint-disable-line no-implicit-coercion -- This is faster.
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

  static final reset = format(0, 0);
  static final bold = format(1, 22);
  static final dim = format(2, 22);
  static final italic = format(3, 23);
  static final underline = format(4, 24);
  static final overline = format(53, 55);
  static final inverse = format(7, 27);
  static final hidden = format(8, 28);
  static final strikethrough = format(9, 29);
  static final black = format(30, 39);
  static final red = format(31, 39);
  static final green = format(32, 39);
  static final yellow = format(33, 39);
  static final blue = format(34, 39);
  static final magenta = format(35, 39);
  static final cyan = format(36, 39);
  static final white = format(37, 39);
  static final gray = format(90, 39);
  static final bgBlack = format(40, 49);
  static final bgRed = format(41, 49);
  static final bgGreen = format(42, 49);
  static final bgYellow = format(43, 49);
  static final bgBlue = format(44, 49);
  static final bgMagenta = format(45, 49);
  static final bgCyan = format(46, 49);
  static final bgWhite = format(47, 49);
  static final bgGray = format(100, 49);
  static final redBright = format(91, 39);
  static final greenBright = format(92, 39);
  static final yellowBright = format(93, 39);
  static final blueBright = format(94, 39);
  static final magentaBright = format(95, 39);
  static final cyanBright = format(96, 39);
  static final whiteBright = format(97, 39);
  static final bgRedBright = format(101, 49);
  static final bgGreenBright = format(102, 49);
  static final bgYellowBright = format(103, 49);
  static final bgBlueBright = format(104, 49);
  static final bgMagentaBright = format(105, 49);
  static final bgCyanBright = format(106, 49);
  static final bgWhiteBright = format(107, 49);
}


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
  String get bgWhiteBright      => QuectoColors.bgWhiteBright(this);

}


enum TestLevels {
  simple,
  complex,
  largerandom_complex,
}

enum ResultsToPrint {
  none,
  oneAtStart,
  someAtStartAndEnd,
}

const int test = 2;

void main() {
  TestLevels testMode = TestLevels.complex;
  const ResultsToPrint printSomeResults = ResultsToPrint.someAtStartAndEnd;
  const int printSomeNumberOfLinesAtStartAndEnd = 10;

  // The large random test Tests the speed of indexing to find the next ESC sequence and handle nesting - 
  final random = Random();
  final randomBigString = List.generate(200, (_) => String.fromCharCode(random.nextInt(26) + 97)).join(); // Generate a large random string

  print('Running testMode = ${testMode} '.yellowBright );

  print('-----------------------------------------------\n'.magentaBright );
  final iterations = 100000;
  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = QuectoColors.red( 'Hello '+ QuectoColors.blue(randomBigString) + QuectoColors.green(' Here is inner ${QuectoColors.yellow(innerString2)} and end of green') + testThisStr);   
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        outStr = QuectoColors.red( 'Hello '+ QuectoColors.blue(testThisStr) + QuectoColors.green(' Here is inner ${QuectoColors.yellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        outStr = QuectoColors.red( 'Hello ');
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }

  stopwatch.stop();

  print('QuectoColors performance test:'.blue);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch.elapsedMilliseconds / iterations} ms');

  print('-----------------------------------------------\n'.magentaBright );
  //Test the built in substring method for comparison.
  final stopwatch2 = Stopwatch()..start();

  // make pen outside loop for fastest possible
  AnsiPen pred = AnsiPen()..red();
  AnsiPen pgreen = AnsiPen()..green();
  AnsiPen pblue = AnsiPen()..blue();
  AnsiPen pyellow= AnsiPen()..yellow();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        //shows broken nesting      
        //WRONG  OUTPUT
        outStr =pred( 'Hello '+ pblue(randomBigString) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + testThisStr);
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
        //shows broken nesting      
        //WRONG  output
        outStr =pred( 'Hello '+ pblue(testThisStr) + pgreen(' Here is inner ${pyellow(innerString2)} and end of green') + ' and end of red');
      case TestLevels.simple:
        //AnsiPen pred = AnsiPen()..red();
        outStr = pred( 'Hello ' );
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  print('\nBuilt in USING ANSICOLORS performance test:'.green);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch2.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch2.elapsedMilliseconds / iterations} ms');

  double percent_2div1 = stopwatch2.elapsedMilliseconds/stopwatch.elapsedMilliseconds;

  double percent_1div2 = stopwatch.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;

  print('PERCENT diff    ansicolors/quectocolors = ${(percent_2div1*100.0).toStringAsFixed(2)}%  (<100% means faster)  quectocolors/ansicolors =${(percent_1div2*100.0).toStringAsFixed(2)}%'.blueBright);


  print('-----------------------------------------------\n'.magentaBright );
  //Test the string extensions version
  final stopwatch3 = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    late final String outStr;
    switch(testMode) {
      case TestLevels.largerandom_complex:
        String testThisStr = 'This is our string to test $i'+randomBigString;
        String innerString2 = "inner $i str"+randomBigString;
        outStr = ('Hello '+ randomBigString.blue + ' Here is inner ${innerString2.yellow} and end of green'.green + ' and end of red').red;   
      case TestLevels.complex:
        String testThisStr = 'This is our string to test $i';
        String innerString2 = "inner $i str";
    
        outStr = ('Hello '+ testThisStr.blue + ' Here is inner ${(innerString2.yellow)} and end of green'.green + ' and end of red').red;
      case TestLevels.simple:
        outStr = 'Hello '.red;
    }
    if(printSomeResults == ResultsToPrint.none) {
      // do nothing
    } else if(printSomeResults == ResultsToPrint.oneAtStart && i==0) {
      print(outStr);
    } else if (printSomeResults == ResultsToPrint.someAtStartAndEnd && (i<printSomeNumberOfLinesAtStartAndEnd || i>=(iterations-printSomeNumberOfLinesAtStartAndEnd))) {
      print(outStr);
    }
  }
  stopwatch3.stop();

  print('\nBuilt in USING STRING EXTENTIONS performance test:'.yellow);
  print('Iterations: $iterations');
  print('Total time: ${stopwatch3.elapsedMilliseconds} ms');
  print('Average time per iteration: ${stopwatch3.elapsedMilliseconds / iterations} ms');

  double percent_3div1 = stopwatch3.elapsedMilliseconds/stopwatch.elapsedMilliseconds;
  double percent_1div3 = stopwatch.elapsedMilliseconds/stopwatch3.elapsedMilliseconds;

  double percent_3div2 = stopwatch3.elapsedMilliseconds/stopwatch2.elapsedMilliseconds;
  double percent_2div3 = stopwatch2.elapsedMilliseconds/stopwatch3.elapsedMilliseconds;


  print('PERCENT diff    quecto strings/quectocolors = ${(percent_3div1*100.0).toStringAsFixed(2)}%  (<100% means faster)  quectocolors/quecto strings = ${(percent_1div3*100.0).toStringAsFixed(2)}%'.blueBright);
  print('PERCENT diff    quecto strings/ANSICOLORS = ${(percent_3div2*100.0).toStringAsFixed(2)}%  (<100% means faster)   ANSICOLORS/quecto strings = ${(percent_2div3*100.0).toStringAsFixed(2)}%'.cyan);
}