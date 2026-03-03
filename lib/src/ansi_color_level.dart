/// Terminal color capability levels, ordered from least to most capable.
enum AnsiColorLevel implements Comparable<AnsiColorLevel> {
  /// No color output. All stylers return identity functions.
  none,

  /// Basic 16 colors (SGR 30-37, 40-47, 90-97, 100-107).
  basic,

  /// 256-color xterm palette (SGR 38;5;n / 48;5;n).
  ansi256,

  /// 24-bit true color RGB (SGR 38;2;r;g;b / 48;2;r;g;b).
  trueColor;

  @override
  int compareTo(AnsiColorLevel other) => index.compareTo(other.index);

  /// Whether this level supports at least [other].
  bool supports(AnsiColorLevel other) => index >= other.index;
}
