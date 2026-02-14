import 'package:quectocolors/src/quectocolors.dart';

class AnsiPen {
  List<QuectoStyler> styleStack = [];

  /// Treat a pen instance as a function such that `pen('msg')` is the same as
  /// `pen.write('msg')`.
  dynamic call([Object? input]) {
    if(input==null) return this;  // getter called without args
    String string = input.toString();
    // Faster handle common cases directly without loop
    switch(styleStack.length) {
      case 0:
        return string;
      case 1:
        return styleStack[0](string);
      case 2:
        return styleStack[0](styleStack[1](string));
      case 3:
        return styleStack[0](styleStack[1](styleStack[2](string)));
      case _:
        for(int i=styleStack.length-1;i>=0;i--) {
          string = styleStack[i](string);
        }
        return string;
    }
    //ORIG//for(final styleFunction in styleStack) {
    //ORIG//  string = styleFunction(string);
    //ORIG//}
    //ORIG//return string;
  }

  // mirror AnsiPen write() method as alternative to call()
  dynamic write(Object? input) => call(input);

  static final _reset = QuectoColors.createStyler(0, 0);
  static final _bold = QuectoColors.createStyler(1, 22);
  static final _dim = QuectoColors.createStyler(2, 22);
  static final _italic = QuectoColors.createStyler(3, 23);
  static final _underline = QuectoColors.createStyler(4, 24);
  static final _overline = QuectoColors.createStyler(53, 55);
  static final _inverse = QuectoColors.createStyler(7, 27);
  static final _hidden = QuectoColors.createStyler(8, 28);
  static final _strikethrough = QuectoColors.createStyler(9, 29);
  static final _black = QuectoColors.createStyler(30, 39);
  static final _red = QuectoColors.createStyler(31, 39);
  static final _green = QuectoColors.createStyler(32, 39);
  static final _yellow = QuectoColors.createStyler(33, 39);
  static final _blue = QuectoColors.createStyler(34, 39);
  static final _magenta = QuectoColors.createStyler(35, 39);
  static final _cyan = QuectoColors.createStyler(36, 39);
  static final _white = QuectoColors.createStyler(37, 39);
  static final _gray = QuectoColors.createStyler(90, 39);
  static final _bgBlack = QuectoColors.createStyler(40, 49);
  static final _bgRed = QuectoColors.createStyler(41, 49);
  static final _bgGreen = QuectoColors.createStyler(42, 49);
  static final _bgYellow = QuectoColors.createStyler(43, 49);
  static final _bgBlue = QuectoColors.createStyler(44, 49);
  static final _bgMagenta = QuectoColors.createStyler(45, 49);
  static final _bgCyan = QuectoColors.createStyler(46, 49);
  static final _bgWhite = QuectoColors.createStyler(47, 49);
  static final _bgGray = QuectoColors.createStyler(100, 49);
  static final _redBright = QuectoColors.createStyler(91, 39);
  static final _greenBright = QuectoColors.createStyler(92, 39);
  static final _yellowBright = QuectoColors.createStyler(93, 39);
  static final _blueBright = QuectoColors.createStyler(94, 39);
  static final _magentaBright = QuectoColors.createStyler(95, 39);
  static final _cyanBright = QuectoColors.createStyler(96, 39);
  static final _whiteBright = QuectoColors.createStyler(97, 39);
  static final _bgRedBright = QuectoColors.createStyler(101, 49);
  static final _bgGreenBright = QuectoColors.createStyler(102, 49);
  static final _bgYellowBright = QuectoColors.createStyler(103, 49);
  static final _bgBlueBright = QuectoColors.createStyler(104, 49);
  static final _bgMagentaBright = QuectoColors.createStyler(105, 49);
  static final _bgCyanBright = QuectoColors.createStyler(106, 49);
  static final _bgWhiteBright = QuectoColors.createStyler(107, 49);


  // These method signatures match the original AnsiPen color methods
  // We don't implement `up`, `down`

  AnsiPen get reset {
    styleStack.add(_reset);
    return this;
  }
  AnsiPen black({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgGray); break;
      case (true, false): styleStack.add(_bgBlack); break;
      case (false, true): styleStack.add(_gray); break;
      case (false, false): styleStack.add(_black); break;
    }
    return this;
  }
  AnsiPen red({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgRedBright); break;
      case (true, false): styleStack.add(_bgRed); break;
      case (false, true): styleStack.add(_redBright); break;
      case (false, false): styleStack.add(_red); break;
    }
    return this;
  }
  AnsiPen green({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgGreenBright); break;
      case (true, false): styleStack.add(_bgGreen); break;
      case (false, true): styleStack.add(_greenBright); break;
      case (false, false): styleStack.add(_green); break;
    }
    return this;
  }
  AnsiPen yellow({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgYellowBright); break;
      case (true, false): styleStack.add(_bgYellow); break;
      case (false, true): styleStack.add(_yellowBright); break;
      case (false, false): styleStack.add(_yellow); break;
    }
    return this;
  }
  AnsiPen blue({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgBlueBright); break;
      case (true, false): styleStack.add(_bgBlue); break;
      case (false, true): styleStack.add(_blueBright); break;
      case (false, false): styleStack.add(_blue); break;
    }
    return this;
  }
  AnsiPen magenta({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgMagentaBright); break;
      case (true, false): styleStack.add(_bgMagenta); break;
      case (false, true): styleStack.add(_magentaBright); break;
      case (false, false): styleStack.add(_magenta); break;
    }
    return this;
  }
  AnsiPen cyan({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgCyanBright); break;
      case (true, false): styleStack.add(_bgCyan); break;
      case (false, true): styleStack.add(_cyanBright); break;
      case (false, false): styleStack.add(_cyan); break;
    }
    return this;
  }
  AnsiPen white({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(_bgWhiteBright); break;
      case (true, false): styleStack.add(_bgWhite); break;
      case (false, true): styleStack.add(_whiteBright); break;
      case (false, false): styleStack.add(_white); break;
    }
    return this;
  }


  //--------------------------------------------------------------------------
  // These method match the QuectoColors color methods
  
  AnsiPen get bold {
    styleStack.add(_bold);
    return this;
  }
  AnsiPen get dim {
    styleStack.add(_dim);
    return this;
  }
  AnsiPen get italic {
    styleStack.add(_italic);
    return this;
  }
  AnsiPen get underline {
    styleStack.add(_underline);
    return this;
  }
  AnsiPen get overline {
    styleStack.add(_overline);
    return this;
  }
  AnsiPen get inverse {
    styleStack.add(_inverse);
    return this;
  }
  AnsiPen get hidden {
    styleStack.add(_hidden);
    return this;
  }
  AnsiPen get strikethrough {
    styleStack.add(_strikethrough);
    return this;
  }
  AnsiPen get gray {
    styleStack.add(_gray);
    return this;
  }
  AnsiPen get bgBlack {
    styleStack.add(_bgBlack);
    return this;
  }
  AnsiPen get bgRed {
    styleStack.add(_bgRed);
    return this;
  }
  AnsiPen get bgGreen {
    styleStack.add(_bgGreen);
    return this;
  }
  AnsiPen get bgYellow {
    styleStack.add(_bgYellow);
    return this;
  }
  AnsiPen get bgBlue {
    styleStack.add(_bgBlue);
    return this;
  }
  AnsiPen get bgMagenta {
    styleStack.add(_bgMagenta);
    return this;
  }
  AnsiPen get bgCyan {
    styleStack.add(_bgCyan);
    return this;
  }
  AnsiPen get bgWhite {
    styleStack.add(_bgWhite);
    return this;
  }
  AnsiPen get bgGray {
    styleStack.add(_bgGray);
    return this;
  }
  AnsiPen get redBright {
    styleStack.add(_redBright);
    return this;
  }
  AnsiPen get greenBright {
    styleStack.add(_greenBright);
    return this;
  }
  AnsiPen get yellowBright {
    styleStack.add(_yellowBright);
    return this;
  }
  AnsiPen get blueBright {
    styleStack.add(_blueBright);
    return this;
  }
  AnsiPen get magentaBright {
    styleStack.add(_magentaBright);
    return this;
  }
  AnsiPen get cyanBright {
    styleStack.add(_cyanBright);
    return this;
  }
  AnsiPen get whiteBright {
    styleStack.add(_whiteBright);
    return this;
  }
  AnsiPen get bgRedBright {
    styleStack.add(_bgRedBright);
    return this;
  }
  AnsiPen get bgGreenBright {
    styleStack.add(_bgGreenBright);
    return this;
  }
  AnsiPen get bgYellowBright {
    styleStack.add(_bgYellowBright);
    return this;
  }
  AnsiPen get bgBlueBright {
    styleStack.add(_bgBlueBright);
    return this;
  }
  AnsiPen get bgMagentaBright {
    styleStack.add(_bgMagentaBright);
    return this;
  }
  AnsiPen get bgCyanBright {
    styleStack.add(_bgCyanBright);
    return this;
  }
  AnsiPen get bgWhiteBright {
    styleStack.add(_bgWhiteBright);
    return this;
  }
}