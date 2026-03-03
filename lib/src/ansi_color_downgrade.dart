// Pure conversion functions for downgrading RGB and 256-color values
// to the basic 16-color ANSI palette.

/// Reference RGB values for the 16 basic ANSI colors (standard VGA palette).
const List<(int, int, int)> _basicAnsiRgb = [
  (0, 0, 0), //  0: black
  (170, 0, 0), //  1: red
  (0, 170, 0), //  2: green
  (170, 85, 0), //  3: yellow (brown)
  (0, 0, 170), //  4: blue
  (170, 0, 170), //  5: magenta
  (0, 170, 170), //  6: cyan
  (170, 170, 170), //  7: white (light gray)
  (85, 85, 85), //  8: bright black (dark gray)
  (255, 85, 85), //  9: bright red
  (85, 255, 85), // 10: bright green
  (255, 255, 85), // 11: bright yellow
  (85, 85, 255), // 12: bright blue
  (255, 85, 255), // 13: bright magenta
  (85, 255, 255), // 14: bright cyan
  (255, 255, 255), // 15: bright white
];

/// Foreground SGR codes for the 16 basic ANSI colors.
const List<int> _basicAnsiFgCodes = [
  30, 31, 32, 33, 34, 35, 36, 37, // normal 0-7
  90, 91, 92, 93, 94, 95, 96, 97, // bright 8-15
];

/// Background SGR codes for the 16 basic ANSI colors.
const List<int> _basicAnsiBgCodes = [
  40, 41, 42, 43, 44, 45, 46, 47, // normal 0-7
  100, 101, 102, 103, 104, 105, 106, 107, // bright 8-15
];

/// Find the nearest basic ANSI color index (0-15) for an RGB value.
/// Uses squared Euclidean distance in RGB space.
int _nearestBasicAnsiIndex(int r, int g, int b) {
  int bestIndex = 0;
  int bestDist = 0x7FFFFFFF;
  for (int i = 0; i < 16; i++) {
    final (cr, cg, cb) = _basicAnsiRgb[i];
    final dr = r - cr;
    final dg = g - cg;
    final db = b - cb;
    final dist = dr * dr + dg * dg + db * db;
    if (dist < bestDist) {
      bestDist = dist;
      bestIndex = i;
      if (dist == 0) break;
    }
  }
  return bestIndex;
}

/// Returns the foreground SGR code for the nearest basic ANSI color to [r],[g],[b].
int rgbToBasicAnsiFg(int r, int g, int b) =>
    _basicAnsiFgCodes[_nearestBasicAnsiIndex(r, g, b)];

/// Returns the background SGR code for the nearest basic ANSI color to [r],[g],[b].
int rgbToBasicAnsiBg(int r, int g, int b) =>
    _basicAnsiBgCodes[_nearestBasicAnsiIndex(r, g, b)];

/// Convert a 256-color palette index to the nearest basic ANSI SGR code.
///
/// Set [foreground] to true for foreground codes (30-37, 90-97),
/// false for background codes (40-47, 100-107).
int ansi256ToBasicAnsiCode(int code, {required bool foreground}) {
  final codes = foreground ? _basicAnsiFgCodes : _basicAnsiBgCodes;

  // System colors 0-15 map directly.
  if (code < 16) return codes[code];

  int r, g, b;
  if (code < 232) {
    // 6x6x6 color cube: indices 16-231
    // Each axis has values: 0, 95, 135, 175, 215, 255
    final int c = code - 16;
    final int ri = c ~/ 36;
    final int gi = (c % 36) ~/ 6;
    final int bi = c % 6;
    r = ri == 0 ? 0 : 55 + ri * 40;
    g = gi == 0 ? 0 : 55 + gi * 40;
    b = bi == 0 ? 0 : 55 + bi * 40;
  } else {
    // Grayscale ramp: indices 232-255
    // Values: 8, 18, 28, ..., 238
    final int gray = 8 + (code - 232) * 10;
    r = gray;
    g = gray;
    b = gray;
  }

  return codes[_nearestBasicAnsiIndex(r, g, b)];
}
