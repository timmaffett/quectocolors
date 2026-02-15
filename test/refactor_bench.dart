import 'package:quectocolors/quectocolors.dart';

/// Benchmark comparing basic and extended styler performance.
/// Compile to exe for accurate results:
///   dart compile exe test/refactor_bench.dart -o test/refactor_bench.exe
///   ./test/refactor_bench.exe

void main() {
  ansiColorDisabled = false;

  const int warmup = 50000;
  const int iterations = 500000;

  // Test strings
  const shortPlain = 'Hello';
  const longPlain =
      'The quick brown fox jumps over the lazy dog and then runs around the yard several times before finally settling down for a nice long nap in the warm afternoon sunshine';
  final shortNested = QuectoColors.blue('inner');
  final nestedString = 'before $shortNested after';
  final multiNested =
      '${QuectoColors.blue("a")}${QuectoColors.green("b")}${QuectoColors.cyan("c")}';

  // Cache extended stylers (as users should)
  final ansi256Red = QuectoColors.ansi256(196);
  final rgbOrange = QuectoColors.rgb(255, 128, 0);

  // Pre-cache basic stylers (already static final, just alias for clarity)
  final basicRed = QuectoColors.red;
  final basicBold = QuectoColors.bold;
  final resetStyler = QuectoColors.reset;

  print('=== Refactor Benchmark ===');
  print('Warmup: $warmup  |  Iterations: $iterations');
  print('');

  // --- Warmup ---
  for (int i = 0; i < warmup; i++) {
    basicRed(shortPlain);
    ansi256Red(shortPlain);
    rgbOrange(shortPlain);
    basicRed(nestedString);
    ansi256Red(nestedString);
    resetStyler(shortPlain);
  }

  // --- Test 1: Basic red, short plain string (no nesting) ---
  var sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    basicRed(shortPlain);
  }
  sw.stop();
  final basicRedShortNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '1. basic red(short plain)    : ${basicRedShortNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 2: Extended ansi256, short plain string (no nesting) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    ansi256Red(shortPlain);
  }
  sw.stop();
  final ext256ShortNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '2. ansi256(short plain)      : ${ext256ShortNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 3: Extended rgb, short plain string (no nesting) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    rgbOrange(shortPlain);
  }
  sw.stop();
  final extRgbShortNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '3. rgb(short plain)          : ${extRgbShortNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 4: Basic red, long plain string (no nesting) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    basicRed(longPlain);
  }
  sw.stop();
  final basicRedLongNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '4. basic red(long plain)     : ${basicRedLongNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 5: Extended ansi256, long plain string (no nesting) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    ansi256Red(longPlain);
  }
  sw.stop();
  final ext256LongNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '5. ansi256(long plain)       : ${ext256LongNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 6: Basic red, nested string (nesting path) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    basicRed(nestedString);
  }
  sw.stop();
  final basicRedNestedNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '6. basic red(nested)         : ${basicRedNestedNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 7: Extended ansi256, nested string (nesting path) ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    ansi256Red(nestedString);
  }
  sw.stop();
  final ext256NestedNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '7. ansi256(nested)           : ${ext256NestedNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 8: Basic red, multi-nested string ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    basicRed(multiNested);
  }
  sw.stop();
  final basicRedMultiNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '8. basic red(multi-nested)   : ${basicRedMultiNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 9: Extended ansi256, multi-nested string ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    ansi256Red(multiNested);
  }
  sw.stop();
  final ext256MultiNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '9. ansi256(multi-nested)     : ${ext256MultiNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 10: reset (length-4 path), short plain ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    resetStyler(shortPlain);
  }
  sw.stop();
  final resetShortNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '10. reset(short plain)       : ${resetShortNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 11: bold (length-5), short plain ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    basicBold(shortPlain);
  }
  sw.stop();
  final boldShortNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '11. bold(short plain)        : ${boldShortNs.toStringAsFixed(1)} ns/call',
  );

  // --- Test 12: Extended styler creation overhead ---
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.ansi256(196);
  }
  sw.stop();
  final createExtNs = sw.elapsedMicroseconds * 1000 / iterations;
  print(
    '12. create ansi256(196)      : ${createExtNs.toStringAsFixed(1)} ns/call',
  );

  print('');
  print('Done.');
}
