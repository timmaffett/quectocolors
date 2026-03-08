import 'package:quectocolors/src/quectocolors.dart';
import 'package:quectocolors/supports_ansi_color.dart';

/// A fluent pen-style API for building ANSI-styled strings.
///
/// Drop-in replacement for the `ansicolor` package's `AnsiPen`, with
/// additional styles (bold, italic, strikethrough, etc.), 16M true color RGB,
/// and correct nested color handling.
///
/// ```dart
/// final pen = AnsiPen()..red();
/// print(pen('Hello'));
///
/// final fancy = AnsiPen().red().bold.italic;
/// print(fancy('Fancy text'));
/// ```
class AnsiPen {
  /// Creates a new [AnsiPen] with no styles applied.
  AnsiPen();

  /// The stack of [QuectoStyler] closures applied by this pen.
  List<QuectoStyler> styleStack = [];

  /// Applies this pen's styles to [input] and returns the styled string.
  ///
  /// `pen('msg')` is equivalent to `pen.write('msg')`.
  /// Compatible with `ansicolor`'s `AnsiPen.call()` signature.
  String call(Object msg) {
    String string = msg.toString();
    // Faster handle common cases directly without loop
    switch (styleStack.length) {
      case 0:
        return string;
      case 1:
        return styleStack[0](string);
      case 2:
        return styleStack[0](styleStack[1](string));
      case 3:
        return styleStack[0](styleStack[1](styleStack[2](string)));
      case _:
        for (int i = styleStack.length - 1; i >= 0; i--) {
          string = styleStack[i](string);
        }
        return string;
    }
  }

  /// Applies this pen's styles to [input] and returns the styled string.
  ///
  /// Equivalent to [call]. Compatible with `ansicolor`'s `pen.write()`.
  String write(Object msg) => call(msg);

  /// Returns the ANSI escape codes that open the pen's current styles.
  /// Compatible with ansicolor's `pen.down` / `'${pen}'` usage.
  String get down {
    if (ansiColorDisabled || styleStack.isEmpty) return '';
    // Apply stylers to a sentinel, extract the open codes (everything before it).
    const sentinel = '\x00';
    String result = sentinel;
    for (int i = styleStack.length - 1; i >= 0; i--) {
      result = styleStack[i](result);
    }
    final idx = result.indexOf(sentinel);
    return idx >= 0 ? result.substring(0, idx) : result;
  }

  /// Resets all pen attributes in the terminal.
  /// Compatible with ansicolor's `pen.up` usage.
  String get up => ansiColorDisabled ? '' : '\x1B[0m';

  /// Allow pen colors to be used inline: `'${pen}text${pen.up}'`.
  /// Compatible with ansicolor's toString() behavior.
  @override
  String toString() => down;

  /// Adds a reset style (SGR 0) to the pen.
  AnsiPen get reset {
    styleStack.add(QuectoColors.reset);
    return this;
  }

  /// Sets black foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen black({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgGray);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgBlack);
        break;
      case (false, true):
        styleStack.add(QuectoColors.gray);
        break;
      case (false, false):
        styleStack.add(QuectoColors.black);
        break;
    }
    return this;
  }

  /// Sets red foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen red({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgRedBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgRed);
        break;
      case (false, true):
        styleStack.add(QuectoColors.redBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.red);
        break;
    }
    return this;
  }

  /// Sets green foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen green({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgGreenBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgGreen);
        break;
      case (false, true):
        styleStack.add(QuectoColors.greenBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.green);
        break;
    }
    return this;
  }

  /// Sets yellow foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen yellow({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgYellowBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgYellow);
        break;
      case (false, true):
        styleStack.add(QuectoColors.yellowBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.yellow);
        break;
    }
    return this;
  }

  /// Sets blue foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen blue({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgBlueBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgBlue);
        break;
      case (false, true):
        styleStack.add(QuectoColors.blueBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.blue);
        break;
    }
    return this;
  }

  /// Sets magenta foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen magenta({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgMagentaBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgMagenta);
        break;
      case (false, true):
        styleStack.add(QuectoColors.magentaBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.magenta);
        break;
    }
    return this;
  }

  /// Sets cyan foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen cyan({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgCyanBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgCyan);
        break;
      case (false, true):
        styleStack.add(QuectoColors.cyanBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.cyan);
        break;
    }
    return this;
  }

  /// Sets white foreground (or background with `bg: true`, bright with `bold: true`).
  AnsiPen white({bool bg = false, bool bold = false}) {
    switch ((bg, bold)) {
      case (true, true):
        styleStack.add(QuectoColors.bgWhiteBright);
        break;
      case (true, false):
        styleStack.add(QuectoColors.bgWhite);
        break;
      case (false, true):
        styleStack.add(QuectoColors.whiteBright);
        break;
      case (false, false):
        styleStack.add(QuectoColors.white);
        break;
    }
    return this;
  }

  //--------------------------------------------------------------------------
  // ansicolor-compatible methods: rgb, gray/grey, xterm

  /// Sets the pen color to the rgb value between 0.0..1.0.
  /// Compatible with ansicolor's AnsiPen.rgb() signature.
  /// Maps to xterm 256-color palette (same as ansicolor).
  AnsiPen rgb({num r = 1.0, num g = 1.0, num b = 1.0, bool bg = false}) {
    final int code =
        (r.clamp(0.0, 1.0) * 5).toInt() * 36 +
        (g.clamp(0.0, 1.0) * 5).toInt() * 6 +
        (b.clamp(0.0, 1.0) * 5).toInt() +
        16;
    styleStack.add(
      bg ? QuectoColors.bgAnsi256(code) : QuectoColors.ansi256(code),
    );
    return this;
  }

  // gray/grey methods are defined below, combining the QuectoColors getter
  // behavior with ansicolor-compatible gray(level:, bg:) support.

  /// Directly index the xterm 256 color palette.
  /// Compatible with ansicolor's AnsiPen.xterm() signature.
  AnsiPen xterm(int color, {bool bg = false}) {
    final int code = color < 0
        ? 0
        : color > 255
        ? 255
        : color;
    styleStack.add(
      bg ? QuectoColors.bgAnsi256(code) : QuectoColors.ansi256(code),
    );
    return this;
  }

  //--------------------------------------------------------------------------
  // These methods match the QuectoColors color methods

  /// Adds bold style (SGR 1).
  AnsiPen get bold {
    styleStack.add(QuectoColors.bold);
    return this;
  }

  /// Adds dim/faint style (SGR 2).
  AnsiPen get dim {
    styleStack.add(QuectoColors.dim);
    return this;
  }

  /// Adds italic style (SGR 3).
  AnsiPen get italic {
    styleStack.add(QuectoColors.italic);
    return this;
  }

  /// Adds underline style (SGR 4).
  AnsiPen get underline {
    styleStack.add(QuectoColors.underline);
    return this;
  }

  /// Adds overline style (SGR 53).
  AnsiPen get overline {
    styleStack.add(QuectoColors.overline);
    return this;
  }

  /// Adds inverse/reverse video style (SGR 7).
  AnsiPen get inverse {
    styleStack.add(QuectoColors.inverse);
    return this;
  }

  /// Adds hidden/conceal style (SGR 8).
  AnsiPen get hidden {
    styleStack.add(QuectoColors.hidden);
    return this;
  }

  /// Adds strikethrough style (SGR 9).
  AnsiPen get strikethrough {
    styleStack.add(QuectoColors.strikethrough);
    return this;
  }

  /// Set foreground to ANSI gray when called with no args (`pen.gray`),
  /// or set to a xterm256 grayscale value when called with `level:`
  /// (compatible with ansicolor's AnsiPen.gray() signature).
  AnsiPen gray({num? level, bool bg = false}) {
    if (level != null) {
      final int code = 232 + (level.clamp(0.0, 1.0) * 23).round();
      styleStack.add(
        bg ? QuectoColors.bgAnsi256(code) : QuectoColors.ansi256(code),
      );
    } else if (bg) {
      styleStack.add(QuectoColors.bgGray);
    } else {
      styleStack.add(QuectoColors.gray);
    }
    return this;
  }

  /// Alternate spelling for [gray].
  AnsiPen grey({num? level, bool bg = false}) => gray(level: level, bg: bg);

  /// Sets background color to black.
  AnsiPen get bgBlack {
    styleStack.add(QuectoColors.bgBlack);
    return this;
  }

  /// Sets background color to red.
  AnsiPen get bgRed {
    styleStack.add(QuectoColors.bgRed);
    return this;
  }

  /// Sets background color to green.
  AnsiPen get bgGreen {
    styleStack.add(QuectoColors.bgGreen);
    return this;
  }

  /// Sets background color to yellow.
  AnsiPen get bgYellow {
    styleStack.add(QuectoColors.bgYellow);
    return this;
  }

  /// Sets background color to blue.
  AnsiPen get bgBlue {
    styleStack.add(QuectoColors.bgBlue);
    return this;
  }

  /// Sets background color to magenta.
  AnsiPen get bgMagenta {
    styleStack.add(QuectoColors.bgMagenta);
    return this;
  }

  /// Sets background color to cyan.
  AnsiPen get bgCyan {
    styleStack.add(QuectoColors.bgCyan);
    return this;
  }

  /// Sets background color to white.
  AnsiPen get bgWhite {
    styleStack.add(QuectoColors.bgWhite);
    return this;
  }

  /// Sets background color to gray (bright black).
  AnsiPen get bgGray {
    styleStack.add(QuectoColors.bgGray);
    return this;
  }

  /// Sets foreground color to bright red.
  AnsiPen get redBright {
    styleStack.add(QuectoColors.redBright);
    return this;
  }

  /// Sets foreground color to bright green.
  AnsiPen get greenBright {
    styleStack.add(QuectoColors.greenBright);
    return this;
  }

  /// Sets foreground color to bright yellow.
  AnsiPen get yellowBright {
    styleStack.add(QuectoColors.yellowBright);
    return this;
  }

  /// Sets foreground color to bright blue.
  AnsiPen get blueBright {
    styleStack.add(QuectoColors.blueBright);
    return this;
  }

  /// Sets foreground color to bright magenta.
  AnsiPen get magentaBright {
    styleStack.add(QuectoColors.magentaBright);
    return this;
  }

  /// Sets foreground color to bright cyan.
  AnsiPen get cyanBright {
    styleStack.add(QuectoColors.cyanBright);
    return this;
  }

  /// Sets foreground color to bright white.
  AnsiPen get whiteBright {
    styleStack.add(QuectoColors.whiteBright);
    return this;
  }

  /// Sets background color to bright red.
  AnsiPen get bgRedBright {
    styleStack.add(QuectoColors.bgRedBright);
    return this;
  }

  /// Sets background color to bright green.
  AnsiPen get bgGreenBright {
    styleStack.add(QuectoColors.bgGreenBright);
    return this;
  }

  /// Sets background color to bright yellow.
  AnsiPen get bgYellowBright {
    styleStack.add(QuectoColors.bgYellowBright);
    return this;
  }

  /// Sets background color to bright blue.
  AnsiPen get bgBlueBright {
    styleStack.add(QuectoColors.bgBlueBright);
    return this;
  }

  /// Sets background color to bright magenta.
  AnsiPen get bgMagentaBright {
    styleStack.add(QuectoColors.bgMagentaBright);
    return this;
  }

  /// Sets background color to bright cyan.
  AnsiPen get bgCyanBright {
    styleStack.add(QuectoColors.bgCyanBright);
    return this;
  }

  /// Sets background color to bright white.
  AnsiPen get bgWhiteBright {
    styleStack.add(QuectoColors.bgWhiteBright);
    return this;
  }

  // --- 256-color xterm palette ---

  /// Sets foreground to xterm 256-color palette index [code] (0–255).
  AnsiPen ansi256Fg(int code) {
    styleStack.add(QuectoColors.ansi256(code));
    return this;
  }

  /// Sets background to xterm 256-color palette index [code] (0–255).
  AnsiPen ansi256Bg(int code) {
    styleStack.add(QuectoColors.bgAnsi256(code));
    return this;
  }

  /// Sets underline color to xterm 256-color palette index [code] (0–255).
  AnsiPen underlineAnsi256(int code) {
    styleStack.add(QuectoColors.underlineAnsi256(code));
    return this;
  }

  // --- 16M true color (RGB) ---

  /// Sets foreground to 24-bit true color RGB.
  AnsiPen rgbFg(int r, int g, int b) {
    styleStack.add(QuectoColors.rgb(r, g, b));
    return this;
  }

  /// Sets background to 24-bit true color RGB.
  AnsiPen rgbBg(int r, int g, int b) {
    styleStack.add(QuectoColors.bgRgb(r, g, b));
    return this;
  }

  /// Sets underline color to 24-bit true color RGB.
  AnsiPen underlineRgb(int r, int g, int b) {
    styleStack.add(QuectoColors.underlineRgb(r, g, b));
    return this;
  }
}
