import "/supports_ansi_color.dart";
import 'ansi_color_downgrade.dart';

/// A closure that wraps a string with ANSI escape codes.
///
/// All QuectoColors stylers (colors, text styles, etc.) are functions of
/// this type. When [ansiColorDisabled] is `true` or [ansiColorLevel] is
/// [AnsiColorLevel.none], stylers return the input string unchanged.
typedef QuectoStyler = String Function(String);

// --- Level-resolved dispatch (decided once at first access) ---

// QuectoPlain dispatch (zero-scan fast path)
final _plainRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic =>
    (int r, int g, int b) =>
        QuectoPlain.createPlainStyler(rgbToBasicAnsiFg(r, g, b), 39),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
      '\x1B[38;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      39,
    ),
  _ => (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[38;2;$r;$g;${b}m',
    39,
  ),
};

final _plainBgRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic =>
    (int r, int g, int b) =>
        QuectoPlain.createPlainStyler(rgbToBasicAnsiBg(r, g, b), 49),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
      '\x1B[48;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      49,
    ),
  _ => (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[48;2;$r;$g;${b}m',
    49,
  ),
};

final _plainAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoPlain.createPlainStyler(
    ansi256ToBasicAnsiCode(code, foreground: true),
    39,
  ),
  _ => (int code) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[38;5;${code}m',
    39,
  ),
};

final _plainBgAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoPlain.createPlainStyler(
    ansi256ToBasicAnsiCode(code, foreground: false),
    49,
  ),
  _ => (int code) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[48;5;${code}m',
    49,
  ),
};

final _plainUnderlineRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic =>
    (int r, int g, int b) => QuectoPlain.createPlainStyler(4, 24),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
      '\x1B[58;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      59,
    ),
  _ => (int r, int g, int b) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[58;2;$r;$g;${b}m',
    59,
  ),
};

final _plainUnderlineAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoPlain.createPlainStyler(4, 24),
  _ => (int code) => QuectoPlain.createPlainExtendedStyler(
    '\x1B[58;5;${code}m',
    59,
  ),
};

// QuectoColors dispatch (nesting-aware)
final _colorsRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int r, int g, int b) => QuectoColors.createStyler(
    rgbToBasicAnsiFg(r, g, b),
    39,
  ),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoColors.createExtendedStyler(
      '\x1B[38;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      39,
    ),
  _ => (int r, int g, int b) => QuectoColors.createExtendedStyler(
    '\x1B[38;2;$r;$g;${b}m',
    39,
  ),
};

final _colorsBgRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int r, int g, int b) => QuectoColors.createStyler(
    rgbToBasicAnsiBg(r, g, b),
    49,
  ),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoColors.createExtendedStyler(
      '\x1B[48;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      49,
    ),
  _ => (int r, int g, int b) => QuectoColors.createExtendedStyler(
    '\x1B[48;2;$r;$g;${b}m',
    49,
  ),
};

final _colorsAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoColors.createStyler(
    ansi256ToBasicAnsiCode(code, foreground: true),
    39,
  ),
  _ => (int code) => QuectoColors.createExtendedStyler(
    '\x1B[38;5;${code}m',
    39,
  ),
};

final _colorsBgAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoColors.createStyler(
    ansi256ToBasicAnsiCode(code, foreground: false),
    49,
  ),
  _ => (int code) => QuectoColors.createExtendedStyler(
    '\x1B[48;5;${code}m',
    49,
  ),
};

final _colorsUnderlineRgb = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int r, int g, int b) => QuectoColors.createStyler(
    4,
    24,
  ),
  AnsiColorLevel.ansi256 =>
    (int r, int g, int b) => QuectoColors.createExtendedStyler(
      '\x1B[58;5;${QuectoColors.rgbToAnsi256(r, g, b)}m',
      59,
    ),
  _ => (int r, int g, int b) => QuectoColors.createExtendedStyler(
    '\x1B[58;2;$r;$g;${b}m',
    59,
  ),
};

final _colorsUnderlineAnsi256 = switch (ansiColorLevel) {
  AnsiColorLevel.basic => (int code) => QuectoColors.createStyler(4, 24),
  _ => (int code) => QuectoColors.createExtendedStyler(
    '\x1B[58;5;${code}m',
    59,
  ),
};

/// Known-plain fast path stylers — ZERO ESC scanning.
/// Use when the caller guarantees the input string contains no nested
/// ANSI escape codes (i.e., it's plain text or a literal string).
/// Access via `QuectoPlain.red('Hello')`.
final class QuectoPlain {
  /// Not intended for instantiation — use static members directly.
  const QuectoPlain._();

  /// Creates a plain styler that just wraps the string with open/close codes.
  /// No ESC scanning, no nesting support. Maximum speed for known-plain text.
  static QuectoStyler createPlainStyler(
    final int ansiOpen,
    final int ansiClose,
  ) {
    if (ansiColorDisabled || ansiColorLevel == AnsiColorLevel.none) {
      return (String input) => input;
    }
    final String openCode = '\x1B[${ansiOpen}m';
    final String closeCode = '\x1B[${ansiClose}m';
    return (String string) => '$openCode$string$closeCode';
  }

  /// Reset all styles and colors (SGR 0).
  static final QuectoStyler reset = createPlainStyler(0, 0);

  /// Bold / increased intensity (SGR 1).
  static final QuectoStyler bold = createPlainStyler(1, 22);

  /// Dim / decreased intensity (SGR 2).
  static final QuectoStyler dim = createPlainStyler(2, 22);

  /// Italic (SGR 3).
  static final QuectoStyler italic = createPlainStyler(3, 23);

  /// Underline (SGR 4).
  static final QuectoStyler underline = createPlainStyler(4, 24);

  /// Overline (SGR 53).
  static final QuectoStyler overline = createPlainStyler(53, 55);

  /// Reverse video / inverse (SGR 7).
  static final QuectoStyler inverse = createPlainStyler(7, 27);

  /// Hidden / conceal (SGR 8).
  static final QuectoStyler hidden = createPlainStyler(8, 28);

  /// Strikethrough / crossed out (SGR 9).
  static final QuectoStyler strikethrough = createPlainStyler(9, 29);

  /// Slow blink (SGR 5).
  static final QuectoStyler blink = createPlainStyler(5, 25);

  /// Rapid blink (SGR 6). Not widely supported.
  static final QuectoStyler rapidBlink = createPlainStyler(6, 25);

  /// Superscript (SGR 73). Not widely supported.
  static final QuectoStyler superscript = createPlainStyler(73, 75);

  /// Subscript (SGR 74). Not widely supported.
  static final QuectoStyler subscript = createPlainStyler(74, 75);

  /// set foreground color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  static final QuectoStyler black = createPlainStyler(30, 39);

  /// set foreground color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  static final QuectoStyler red = createPlainStyler(31, 39);

  /// set foreground color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  static final QuectoStyler green = createPlainStyler(32, 39);

  /// set foreground color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  static final QuectoStyler yellow = createPlainStyler(33, 39);

  /// set foreground color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  static final QuectoStyler blue = createPlainStyler(34, 39);

  /// set foreground color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  static final QuectoStyler magenta = createPlainStyler(35, 39);

  /// set foreground color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  static final QuectoStyler cyan = createPlainStyler(36, 39);

  /// set foreground color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler white = createPlainStyler(37, 39);

  /// set foreground color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler gray = createPlainStyler(90, 39);

  /// set foreground color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  static final QuectoStyler grey = createPlainStyler(90, 39);

  /// set background color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  static final QuectoStyler bgBlack = createPlainStyler(40, 49);

  /// set background color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  static final QuectoStyler bgRed = createPlainStyler(41, 49);

  /// set background color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  static final QuectoStyler bgGreen = createPlainStyler(42, 49);

  /// set background color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  static final QuectoStyler bgYellow = createPlainStyler(43, 49);

  /// set background color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  static final QuectoStyler bgBlue = createPlainStyler(44, 49);

  /// set background color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  static final QuectoStyler bgMagenta = createPlainStyler(45, 49);

  /// set background color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  static final QuectoStyler bgCyan = createPlainStyler(46, 49);

  /// set background color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler bgWhite = createPlainStyler(47, 49);

  /// set background color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler bgGray = createPlainStyler(100, 49);

  /// set background color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  static final QuectoStyler bgGrey = createPlainStyler(100, 49);

  /// Alias for [bgBlack]. Sets background color to black.
  static final QuectoStyler onBlack = bgBlack;

  /// Alias for [bgRed]. Sets background color to red.
  static final QuectoStyler onRed = bgRed;

  /// Alias for [bgGreen]. Sets background color to green.
  static final QuectoStyler onGreen = bgGreen;

  /// Alias for [bgYellow]. Sets background color to yellow.
  static final QuectoStyler onYellow = bgYellow;

  /// Alias for [bgBlue]. Sets background color to blue.
  static final QuectoStyler onBlue = bgBlue;

  /// Alias for [bgMagenta]. Sets background color to magenta.
  static final QuectoStyler onMagenta = bgMagenta;

  /// Alias for [bgCyan]. Sets background color to cyan.
  static final QuectoStyler onCyan = bgCyan;

  /// Alias for [bgWhite]. Sets background color to white.
  static final QuectoStyler onWhite = bgWhite;

  /// Alias for [bgGray]. Sets background color to gray.
  static final QuectoStyler onGray = bgGray;

  /// Alias for [bgGrey]. Sets background color to grey.
  static final QuectoStyler onGrey = bgGrey;

  /// set foreground color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  static final QuectoStyler redBright = createPlainStyler(91, 39);

  /// set foreground color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  static final QuectoStyler greenBright = createPlainStyler(92, 39);

  /// set foreground color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  static final QuectoStyler yellowBright = createPlainStyler(93, 39);

  /// set foreground color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  static final QuectoStyler blueBright = createPlainStyler(94, 39);

  /// set foreground color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  static final QuectoStyler magentaBright = createPlainStyler(95, 39);

  /// set foreground color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  static final QuectoStyler cyanBright = createPlainStyler(96, 39);

  /// set foreground color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  static final QuectoStyler whiteBright = createPlainStyler(97, 39);

  /// set background color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  static final QuectoStyler bgRedBright = createPlainStyler(101, 49);

  /// set background color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  static final QuectoStyler bgGreenBright = createPlainStyler(102, 49);

  /// set background color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  static final QuectoStyler bgYellowBright = createPlainStyler(103, 49);

  /// set background color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  static final QuectoStyler bgBlueBright = createPlainStyler(104, 49);

  /// set background color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  static final QuectoStyler bgMagentaBright = createPlainStyler(105, 49);

  /// set background color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  static final QuectoStyler bgCyanBright = createPlainStyler(106, 49);

  /// set background color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  static final QuectoStyler bgWhiteBright = createPlainStyler(107, 49);

  /// Alias for [bgRedBright]. Sets background to bright red.
  static final QuectoStyler onRedBright = bgRedBright;

  /// Alias for [bgGreenBright]. Sets background to bright green.
  static final QuectoStyler onGreenBright = bgGreenBright;

  /// Alias for [bgYellowBright]. Sets background to bright yellow.
  static final QuectoStyler onYellowBright = bgYellowBright;

  /// Alias for [bgBlueBright]. Sets background to bright blue.
  static final QuectoStyler onBlueBright = bgBlueBright;

  /// Alias for [bgMagentaBright]. Sets background to bright magenta.
  static final QuectoStyler onMagentaBright = bgMagentaBright;

  /// Alias for [bgCyanBright]. Sets background to bright cyan.
  static final QuectoStyler onCyanBright = bgCyanBright;

  /// Alias for [bgWhiteBright]. Sets background to bright white.
  static final QuectoStyler onWhiteBright = bgWhiteBright;

  /// Creates a plain styler for extended ANSI codes (256-color, 16M truecolor).
  /// No ESC scanning, no nesting support. Maximum speed for known-plain text.
  static QuectoStyler createPlainExtendedStyler(
    final String openCode,
    final int ansiClose,
  ) {
    if (ansiColorDisabled || ansiColorLevel == AnsiColorLevel.none) {
      return (String input) => input;
    }
    final String closeCode = '\x1B[${ansiClose}m';
    return (String string) => '$openCode$string$closeCode';
  }

  // --- 256-color xterm palette (plain fast path) ---

  /// Sets foreground to xterm 256-color palette index [code] (0–255).
  static QuectoStyler ansi256(int code) => _plainAnsi256(code);

  /// Sets background to xterm 256-color palette index [code] (0–255).
  static QuectoStyler bgAnsi256(int code) => _plainBgAnsi256(code);

  /// Alias for [bgAnsi256]. Sets background to xterm 256-color palette index.
  static QuectoStyler onAnsi256(int code) => bgAnsi256(code);

  /// Sets underline color to xterm 256-color palette index [code] (0–255).
  static QuectoStyler underlineAnsi256(int code) =>
      _plainUnderlineAnsi256(code);

  // --- 16M true color RGB (plain fast path) ---

  /// Sets foreground to 24-bit true color RGB.
  static QuectoStyler rgb(int r, int g, int b) => _plainRgb(r, g, b);

  /// Sets background to 24-bit true color RGB.
  static QuectoStyler bgRgb(int r, int g, int b) => _plainBgRgb(r, g, b);

  /// Alias for [bgRgb]. Sets background to 24-bit true color RGB.
  static QuectoStyler onRgb(int r, int g, int b) => bgRgb(r, g, b);

  /// Sets underline color to 24-bit true color RGB.
  static QuectoStyler underlineRgb(int r, int g, int b) =>
      _plainUnderlineRgb(r, g, b);
}

/// Shared core: creates a styler closure from pre-built open/close code strings.
/// Handles both length-4 (\x1B[0m for reset) and length-5 (\x1B[XXm) close codes.
/// Used by both createStyler() and createExtendedStyler().
QuectoStyler _createStylerFromCodes(
  final String openCode,
  final String closeCode,
) {
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

/// Nesting-aware ANSI stylers with single-pass ESC byte scanning.
///
/// Unlike [QuectoPlain], these stylers detect nested ANSI close codes within
/// the input and re-inject the parent style's open code after each close,
/// ensuring correct color nesting.
///
/// ```dart
/// print(QuectoColors.red('Hello ${QuectoColors.blue('world')} !'));
/// ```
final class QuectoColors {
  /// Not intended for instantiation — use static members directly.
  const QuectoColors._();

  /// Returns [instr] with ESC bytes replaced by the literal text `ESC[`
  /// for debugging/inspection of ANSI escape sequences.
  static String debugOut(String instr) {
    return instr.replaceAll('\x1B[', 'ESC[');
  }

  /// Creates a nesting-aware styler from SGR open/close code integers.
  static QuectoStyler createStyler(final int ansiOpen, final int ansiClose) {
    if (ansiColorDisabled || ansiColorLevel == AnsiColorLevel.none) {
      return (String input) => input;
    }
    return _createStylerFromCodes('\x1B[${ansiOpen}m', '\x1B[${ansiClose}m');
  }

  /// Reset all styles and colors (SGR 0).
  static final QuectoStyler reset = createStyler(0, 0);

  /// Bold / increased intensity (SGR 1).
  static final QuectoStyler bold = createStyler(1, 22);

  /// Dim / decreased intensity (SGR 2).
  static final QuectoStyler dim = createStyler(2, 22);

  /// Italic (SGR 3).
  static final QuectoStyler italic = createStyler(3, 23);

  /// Underline (SGR 4).
  static final QuectoStyler underline = createStyler(4, 24);

  /// Overline (SGR 53).
  static final QuectoStyler overline = createStyler(53, 55);

  /// Reverse video / inverse (SGR 7).
  static final QuectoStyler inverse = createStyler(7, 27);

  /// Hidden / conceal (SGR 8).
  static final QuectoStyler hidden = createStyler(8, 28);

  /// Strikethrough / crossed out (SGR 9).
  static final QuectoStyler strikethrough = createStyler(9, 29);

  /// Slow blink (SGR 5).
  static final QuectoStyler blink = createStyler(5, 25);

  /// Rapid blink (SGR 6). Not widely supported.
  static final QuectoStyler rapidBlink = createStyler(6, 25);

  /// Superscript (SGR 73). Not widely supported.
  static final QuectoStyler superscript = createStyler(73, 75);

  /// Subscript (SGR 74). Not widely supported.
  static final QuectoStyler subscript = createStyler(74, 75);

  /// set foreground color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  static final QuectoStyler black = createStyler(30, 39);

  /// set foreground color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  static final QuectoStyler red = createStyler(31, 39);

  /// set foreground color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  static final QuectoStyler green = createStyler(32, 39);

  /// set foreground color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  static final QuectoStyler yellow = createStyler(33, 39);

  /// set foreground color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  static final QuectoStyler blue = createStyler(34, 39);

  /// set foreground color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  static final QuectoStyler magenta = createStyler(35, 39);

  /// set foreground color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  static final QuectoStyler cyan = createStyler(36, 39);

  /// set foreground color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler white = createStyler(37, 39);

  /// set foreground color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler gray = createStyler(90, 39);

  /// set foreground color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  static final QuectoStyler grey = createStyler(90, 39);

  /// set background color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  static final QuectoStyler bgBlack = createStyler(40, 49);

  /// set background color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  static final QuectoStyler bgRed = createStyler(41, 49);

  /// set background color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  static final QuectoStyler bgGreen = createStyler(42, 49);

  /// set background color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  static final QuectoStyler bgYellow = createStyler(43, 49);

  /// set background color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  static final QuectoStyler bgBlue = createStyler(44, 49);

  /// set background color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  static final QuectoStyler bgMagenta = createStyler(45, 49);

  /// set background color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  static final QuectoStyler bgCyan = createStyler(46, 49);

  /// set background color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler bgWhite = createStyler(47, 49);

  /// set background color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  static final QuectoStyler bgGray = createStyler(100, 49);

  /// set background color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  static final QuectoStyler bgGrey = createStyler(100, 49);

  /// Alias for [bgBlack]. Sets background color to black.
  static final QuectoStyler onBlack = bgBlack;

  /// Alias for [bgRed]. Sets background color to red.
  static final QuectoStyler onRed = bgRed;

  /// Alias for [bgGreen]. Sets background color to green.
  static final QuectoStyler onGreen = bgGreen;

  /// Alias for [bgYellow]. Sets background color to yellow.
  static final QuectoStyler onYellow = bgYellow;

  /// Alias for [bgBlue]. Sets background color to blue.
  static final QuectoStyler onBlue = bgBlue;

  /// Alias for [bgMagenta]. Sets background color to magenta.
  static final QuectoStyler onMagenta = bgMagenta;

  /// Alias for [bgCyan]. Sets background color to cyan.
  static final QuectoStyler onCyan = bgCyan;

  /// Alias for [bgWhite]. Sets background color to white.
  static final QuectoStyler onWhite = bgWhite;

  /// Alias for [bgGray]. Sets background color to gray.
  static final QuectoStyler onGray = bgGray;

  /// Alias for [bgGrey]. Sets background color to grey.
  static final QuectoStyler onGrey = bgGrey;

  /// set foreground color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  static final QuectoStyler redBright = createStyler(91, 39);

  /// set foreground color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  static final QuectoStyler greenBright = createStyler(92, 39);

  /// set foreground color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  static final QuectoStyler yellowBright = createStyler(93, 39);

  /// set foreground color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  static final QuectoStyler blueBright = createStyler(94, 39);

  /// set foreground color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  static final QuectoStyler magentaBright = createStyler(95, 39);

  /// set foreground color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  static final QuectoStyler cyanBright = createStyler(96, 39);

  /// set foreground color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  static final QuectoStyler whiteBright = createStyler(97, 39);

  /// set background color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  static final QuectoStyler bgRedBright = createStyler(101, 49);

  /// set background color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  static final QuectoStyler bgGreenBright = createStyler(102, 49);

  /// set background color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  static final QuectoStyler bgYellowBright = createStyler(103, 49);

  /// set background color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  static final QuectoStyler bgBlueBright = createStyler(104, 49);

  /// set background color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  static final QuectoStyler bgMagentaBright = createStyler(105, 49);

  /// set background color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  static final QuectoStyler bgCyanBright = createStyler(106, 49);

  /// set background color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  static final QuectoStyler bgWhiteBright = createStyler(107, 49);

  /// Alias for [bgRedBright]. Sets background to bright red.
  static final QuectoStyler onRedBright = bgRedBright;

  /// Alias for [bgGreenBright]. Sets background to bright green.
  static final QuectoStyler onGreenBright = bgGreenBright;

  /// Alias for [bgYellowBright]. Sets background to bright yellow.
  static final QuectoStyler onYellowBright = bgYellowBright;

  /// Alias for [bgBlueBright]. Sets background to bright blue.
  static final QuectoStyler onBlueBright = bgBlueBright;

  /// Alias for [bgMagentaBright]. Sets background to bright magenta.
  static final QuectoStyler onMagentaBright = bgMagentaBright;

  /// Alias for [bgCyanBright]. Sets background to bright cyan.
  static final QuectoStyler onCyanBright = bgCyanBright;

  /// Alias for [bgWhiteBright]. Sets background to bright white.
  static final QuectoStyler onWhiteBright = bgWhiteBright;

  /// Creates a styler for extended ANSI codes (256-color, 16M truecolor).
  /// Takes a pre-built openCode string and a close code int.
  /// Delegates to the shared _createStylerFromCodes() core.
  static QuectoStyler createExtendedStyler(
    final String openCode,
    final int ansiClose,
  ) {
    if (ansiColorDisabled || ansiColorLevel == AnsiColorLevel.none) {
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
    return 16 +
        (36 * (red / 255 * 5).round()) +
        (6 * (green / 255 * 5).round()) +
        (blue / 255 * 5).round();
  }

  // --- 256-color xterm palette ---

  /// Sets foreground to xterm 256-color palette index [code] (0–255).
  static QuectoStyler ansi256(int code) => _colorsAnsi256(code);

  /// Sets background to xterm 256-color palette index [code] (0–255).
  static QuectoStyler bgAnsi256(int code) => _colorsBgAnsi256(code);

  /// Alias for [bgAnsi256]. Sets background to xterm 256-color palette index.
  static QuectoStyler onAnsi256(int code) => bgAnsi256(code);

  /// Sets underline color to xterm 256-color palette index [code] (0–255).
  static QuectoStyler underlineAnsi256(int code) =>
      _colorsUnderlineAnsi256(code);

  // --- 16M true color (RGB) ---

  /// Sets foreground to 24-bit true color RGB.
  static QuectoStyler rgb(int r, int g, int b) => _colorsRgb(r, g, b);

  /// Sets background to 24-bit true color RGB.
  static QuectoStyler bgRgb(int r, int g, int b) => _colorsBgRgb(r, g, b);

  /// Alias for [bgRgb]. Sets background to 24-bit true color RGB.
  static QuectoStyler onRgb(int r, int g, int b) => bgRgb(r, g, b);

  /// Sets underline color to 24-bit true color RGB.
  static QuectoStyler underlineRgb(int r, int g, int b) =>
      _colorsUnderlineRgb(r, g, b);
}

/// String extensions for concise styling: `'text'.red`, `'text'.bold.italic`.
extension QuectoColorsOnStrings on String {
  /// Reset all styles and colors (SGR 0).
  String get reset => QuectoColors.reset(this);

  /// Bold / increased intensity (SGR 1).
  String get bold => QuectoColors.bold(this);

  /// Dim / decreased intensity (SGR 2).
  String get dim => QuectoColors.dim(this);

  /// Italic (SGR 3).
  String get italic => QuectoColors.italic(this);

  /// Underline (SGR 4).
  String get underline => QuectoColors.underline(this);

  /// Overline (SGR 53).
  String get overline => QuectoColors.overline(this);

  /// Reverse video / inverse (SGR 7).
  String get inverse => QuectoColors.inverse(this);

  /// Hidden / conceal (SGR 8).
  String get hidden => QuectoColors.hidden(this);

  /// Strikethrough / crossed out (SGR 9).
  String get strikethrough => QuectoColors.strikethrough(this);

  /// set foreground color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  String get black => QuectoColors.black(this);

  /// set foreground color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  String get red => QuectoColors.red(this);

  /// set foreground color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  String get green => QuectoColors.green(this);

  /// set foreground color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  String get yellow => QuectoColors.yellow(this);

  /// set foreground color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  String get blue => QuectoColors.blue(this);

  /// set foreground color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  String get magenta => QuectoColors.magenta(this);

  /// set foreground color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  String get cyan => QuectoColors.cyan(this);

  /// set foreground color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  String get white => QuectoColors.white(this);

  /// set foreground color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  String get gray => QuectoColors.gray(this);

  /// set foreground color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  String get grey => QuectoColors.grey(this);

  /// set background color to ANSI color black ![black](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000000)/rgb(0, 0, 0)
  String get bgBlack => QuectoColors.bgBlack(this);

  /// set background color to ANSI color red ![red](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880000)/rgb(136, 0, 0)
  String get bgRed => QuectoColors.bgRed(this);

  /// set background color to ANSI color green ![green](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008800)/rgb(0, 136, 0)
  String get bgGreen => QuectoColors.bgGreen(this);

  /// set background color to ANSI color yellow ![yellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888800)/rgb(136, 136, 0)
  String get bgYellow => QuectoColors.bgYellow(this);

  /// set background color to ANSI color blue ![blue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x000088)/rgb(0, 0, 136)
  String get bgBlue => QuectoColors.bgBlue(this);

  /// set background color to ANSI color magenta ![magenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,0,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x880088)/rgb(136, 0, 136)
  String get bgMagenta => QuectoColors.bgMagenta(this);

  /// set background color to ANSI color cyan ![cyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x008888)/rgb(0, 136, 136)
  String get bgCyan => QuectoColors.bgCyan(this);

  /// set background color to ANSI color white ![white](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  String get bgWhite => QuectoColors.bgWhite(this);

  /// set background color to ANSI color gray (brightBlack) ![gray](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  String get bgGray => QuectoColors.bgGray(this);

  /// set background color to ANSI color grey (brightBlack) ![grey](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28136,136,136%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x888888)/rgb(136, 136, 136)
  /// (alternate spelling for gray)
  String get bgGrey => QuectoColors.bgGrey(this);

  /// Alias for [bgBlack]. Sets background color to black.
  String get onBlack => bgBlack;

  /// Alias for [bgRed]. Sets background color to red.
  String get onRed => bgRed;

  /// Alias for [bgGreen]. Sets background color to green.
  String get onGreen => bgGreen;

  /// Alias for [bgYellow]. Sets background color to yellow.
  String get onYellow => bgYellow;

  /// Alias for [bgBlue]. Sets background color to blue.
  String get onBlue => bgBlue;

  /// Alias for [bgMagenta]. Sets background color to magenta.
  String get onMagenta => bgMagenta;

  /// Alias for [bgCyan]. Sets background color to cyan.
  String get onCyan => bgCyan;

  /// Alias for [bgWhite]. Sets background color to white.
  String get onWhite => bgWhite;

  /// Alias for [bgGray]. Sets background color to gray.
  String get onGray => bgGray;

  /// Alias for [bgGrey]. Sets background color to grey.
  String get onGrey => bgGrey;

  /// set foreground color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  String get redBright => QuectoColors.redBright(this);

  /// set foreground color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  String get greenBright => QuectoColors.greenBright(this);

  /// set foreground color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  String get yellowBright => QuectoColors.yellowBright(this);

  /// set foreground color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  String get blueBright => QuectoColors.blueBright(this);

  /// set foreground color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  String get magentaBright => QuectoColors.magentaBright(this);

  /// set foreground color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  String get cyanBright => QuectoColors.cyanBright(this);

  /// set foreground color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  String get whiteBright => QuectoColors.whiteBright(this);

  /// set background color to ANSI color brightRed ![brightRed](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF0000)/rgb(255, 0, 0)
  String get bgRedBright => QuectoColors.bgRedBright(this);

  /// set background color to ANSI color brightGreen ![brightGreen](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FF00)/rgb(0, 255, 0)
  String get bgGreenBright => QuectoColors.bgGreenBright(this);

  /// set background color to ANSI color brightYellow ![brightYellow](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,0%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFF00)/rgb(255, 255, 0)
  String get bgYellowBright => QuectoColors.bgYellowBright(this);

  /// set background color to ANSI color brightBlue ![brightBlue](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x0000FF)/rgb(0, 0, 255)
  String get bgBlueBright => QuectoColors.bgBlueBright(this);

  /// set background color to ANSI color brightMagenta ![brightMagenta](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,0,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFF00FF)/rgb(255, 0, 255)
  String get bgMagentaBright => QuectoColors.bgMagentaBright(this);

  /// set background color to ANSI color brightCyan ![brightCyan](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%280,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0x00FFFF)/rgb(0, 255, 255)
  String get bgCyanBright => QuectoColors.bgCyanBright(this);

  /// set background color to ANSI color brightWhite ![brightWhite](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='32'%20height='32'%3E%3Crect%20width='32'%20height='32'%20fill='rgb%28255,255,255%29'%20stroke='black'%20stroke-width='2'/%3E%3C/svg%3E|width=32,height=32) (0xFFFFFF)/rgb(255, 255, 255)
  String get bgWhiteBright => QuectoColors.bgWhiteBright(this);

  /// Alias for [bgRedBright]. Sets background to bright red.
  String get onRedBright => bgRedBright;

  /// Alias for [bgGreenBright]. Sets background to bright green.
  String get onGreenBright => bgGreenBright;

  /// Alias for [bgYellowBright]. Sets background to bright yellow.
  String get onYellowBright => bgYellowBright;

  /// Alias for [bgBlueBright]. Sets background to bright blue.
  String get onBlueBright => bgBlueBright;

  /// Alias for [bgMagentaBright]. Sets background to bright magenta.
  String get onMagentaBright => bgMagentaBright;

  /// Alias for [bgCyanBright]. Sets background to bright cyan.
  String get onCyanBright => bgCyanBright;

  /// Alias for [bgWhiteBright]. Sets background to bright white.
  String get onWhiteBright => bgWhiteBright;

  // --- 256-color xterm palette ---

  /// Sets foreground to xterm 256-color palette index [code] (0–255).
  String ansi256(int code) => QuectoColors.ansi256(code)(this);

  /// Sets background to xterm 256-color palette index [code] (0–255).
  String bgAnsi256(int code) => QuectoColors.bgAnsi256(code)(this);

  /// Alias for [bgAnsi256]. Sets background to xterm 256-color palette index.
  String onAnsi256(int code) => bgAnsi256(code);

  /// Sets underline color to xterm 256-color palette index [code] (0–255).
  String underlineAnsi256(int code) =>
      QuectoColors.underlineAnsi256(code)(this);

  // --- 16M true color (RGB) ---

  /// Sets foreground to 24-bit true color RGB.
  String rgb(int r, int g, int b) => QuectoColors.rgb(r, g, b)(this);

  /// Sets background to 24-bit true color RGB.
  String bgRgb(int r, int g, int b) => QuectoColors.bgRgb(r, g, b)(this);

  /// Alias for [bgRgb]. Sets background to 24-bit true color RGB.
  String onRgb(int r, int g, int b) => bgRgb(r, g, b);

  /// Sets underline color to 24-bit true color RGB.
  String underlineRgb(int r, int g, int b) =>
      QuectoColors.underlineRgb(r, g, b)(this);
}
