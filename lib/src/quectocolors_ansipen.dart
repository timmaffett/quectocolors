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
  }

  // mirror AnsiPen write() method as alternative to call()
  dynamic write(Object? input) => call(input);

  // These method signatures match the original AnsiPen color methods
  // We don't implement `up`, `down`

  AnsiPen get reset {
    styleStack.add(QuectoColors.reset);
    return this;
  }
  AnsiPen black({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgGray); break;
      case (true, false): styleStack.add(QuectoColors.bgBlack); break;
      case (false, true): styleStack.add(QuectoColors.gray); break;
      case (false, false): styleStack.add(QuectoColors.black); break;
    }
    return this;
  }
  AnsiPen red({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgRedBright); break;
      case (true, false): styleStack.add(QuectoColors.bgRed); break;
      case (false, true): styleStack.add(QuectoColors.redBright); break;
      case (false, false): styleStack.add(QuectoColors.red); break;
    }
    return this;
  }
  AnsiPen green({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgGreenBright); break;
      case (true, false): styleStack.add(QuectoColors.bgGreen); break;
      case (false, true): styleStack.add(QuectoColors.greenBright); break;
      case (false, false): styleStack.add(QuectoColors.green); break;
    }
    return this;
  }
  AnsiPen yellow({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgYellowBright); break;
      case (true, false): styleStack.add(QuectoColors.bgYellow); break;
      case (false, true): styleStack.add(QuectoColors.yellowBright); break;
      case (false, false): styleStack.add(QuectoColors.yellow); break;
    }
    return this;
  }
  AnsiPen blue({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgBlueBright); break;
      case (true, false): styleStack.add(QuectoColors.bgBlue); break;
      case (false, true): styleStack.add(QuectoColors.blueBright); break;
      case (false, false): styleStack.add(QuectoColors.blue); break;
    }
    return this;
  }
  AnsiPen magenta({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgMagentaBright); break;
      case (true, false): styleStack.add(QuectoColors.bgMagenta); break;
      case (false, true): styleStack.add(QuectoColors.magentaBright); break;
      case (false, false): styleStack.add(QuectoColors.magenta); break;
    }
    return this;
  }
  AnsiPen cyan({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgCyanBright); break;
      case (true, false): styleStack.add(QuectoColors.bgCyan); break;
      case (false, true): styleStack.add(QuectoColors.cyanBright); break;
      case (false, false): styleStack.add(QuectoColors.cyan); break;
    }
    return this;
  }
  AnsiPen white({bool bg = false, bool bold = false}) {
    switch ((bg,bold)) {
      case (true, true): styleStack.add(QuectoColors.bgWhiteBright); break;
      case (true, false): styleStack.add(QuectoColors.bgWhite); break;
      case (false, true): styleStack.add(QuectoColors.whiteBright); break;
      case (false, false): styleStack.add(QuectoColors.white); break;
    }
    return this;
  }


  //--------------------------------------------------------------------------
  // These method match the QuectoColors color methods

  AnsiPen get bold {
    styleStack.add(QuectoColors.bold);
    return this;
  }
  AnsiPen get dim {
    styleStack.add(QuectoColors.dim);
    return this;
  }
  AnsiPen get italic {
    styleStack.add(QuectoColors.italic);
    return this;
  }
  AnsiPen get underline {
    styleStack.add(QuectoColors.underline);
    return this;
  }
  AnsiPen get overline {
    styleStack.add(QuectoColors.overline);
    return this;
  }
  AnsiPen get inverse {
    styleStack.add(QuectoColors.inverse);
    return this;
  }
  AnsiPen get hidden {
    styleStack.add(QuectoColors.hidden);
    return this;
  }
  AnsiPen get strikethrough {
    styleStack.add(QuectoColors.strikethrough);
    return this;
  }
  AnsiPen get gray {
    styleStack.add(QuectoColors.gray);
    return this;
  }
  AnsiPen get bgBlack {
    styleStack.add(QuectoColors.bgBlack);
    return this;
  }
  AnsiPen get bgRed {
    styleStack.add(QuectoColors.bgRed);
    return this;
  }
  AnsiPen get bgGreen {
    styleStack.add(QuectoColors.bgGreen);
    return this;
  }
  AnsiPen get bgYellow {
    styleStack.add(QuectoColors.bgYellow);
    return this;
  }
  AnsiPen get bgBlue {
    styleStack.add(QuectoColors.bgBlue);
    return this;
  }
  AnsiPen get bgMagenta {
    styleStack.add(QuectoColors.bgMagenta);
    return this;
  }
  AnsiPen get bgCyan {
    styleStack.add(QuectoColors.bgCyan);
    return this;
  }
  AnsiPen get bgWhite {
    styleStack.add(QuectoColors.bgWhite);
    return this;
  }
  AnsiPen get bgGray {
    styleStack.add(QuectoColors.bgGray);
    return this;
  }
  AnsiPen get redBright {
    styleStack.add(QuectoColors.redBright);
    return this;
  }
  AnsiPen get greenBright {
    styleStack.add(QuectoColors.greenBright);
    return this;
  }
  AnsiPen get yellowBright {
    styleStack.add(QuectoColors.yellowBright);
    return this;
  }
  AnsiPen get blueBright {
    styleStack.add(QuectoColors.blueBright);
    return this;
  }
  AnsiPen get magentaBright {
    styleStack.add(QuectoColors.magentaBright);
    return this;
  }
  AnsiPen get cyanBright {
    styleStack.add(QuectoColors.cyanBright);
    return this;
  }
  AnsiPen get whiteBright {
    styleStack.add(QuectoColors.whiteBright);
    return this;
  }
  AnsiPen get bgRedBright {
    styleStack.add(QuectoColors.bgRedBright);
    return this;
  }
  AnsiPen get bgGreenBright {
    styleStack.add(QuectoColors.bgGreenBright);
    return this;
  }
  AnsiPen get bgYellowBright {
    styleStack.add(QuectoColors.bgYellowBright);
    return this;
  }
  AnsiPen get bgBlueBright {
    styleStack.add(QuectoColors.bgBlueBright);
    return this;
  }
  AnsiPen get bgMagentaBright {
    styleStack.add(QuectoColors.bgMagentaBright);
    return this;
  }
  AnsiPen get bgCyanBright {
    styleStack.add(QuectoColors.bgCyanBright);
    return this;
  }
  AnsiPen get bgWhiteBright {
    styleStack.add(QuectoColors.bgWhiteBright);
    return this;
  }

  // --- 256-color xterm palette ---
  AnsiPen ansi256Fg(int code) { styleStack.add(QuectoColors.ansi256(code)); return this; }
  AnsiPen ansi256Bg(int code) { styleStack.add(QuectoColors.bgAnsi256(code)); return this; }
  AnsiPen underlineAnsi256(int code) { styleStack.add(QuectoColors.underlineAnsi256(code)); return this; }

  // --- 16M true color (RGB) ---
  AnsiPen rgbFg(int r, int g, int b) { styleStack.add(QuectoColors.rgb(r, g, b)); return this; }
  AnsiPen rgbBg(int r, int g, int b) { styleStack.add(QuectoColors.bgRgb(r, g, b)); return this; }
  AnsiPen underlineRgb(int r, int g, int b) { styleStack.add(QuectoColors.underlineRgb(r, g, b)); return this; }
}
