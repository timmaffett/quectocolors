import 'package:quectocolors/quectocolors.dart';

/// Baseline benchmark — no AnsiColorLevel references.
/// Run against the stashed (pre-change) codebase.

void main() {
  ansiColorDisabled = false;

  const int warmup = 50000;
  const int iterations = 2000000;

  const shortPlain = 'Hello';

  print('=== BASELINE Benchmark (no color level changes) ===');
  print('Warmup: $warmup  |  Iterations: $iterations');
  print('');

  print('--- Part A: Styler Creation ---');
  print('');

  for (int i = 0; i < warmup; i++) {
    QuectoColors.rgb(255, 128, 0);
    QuectoColors.ansi256(196);
    QuectoColors.bgRgb(0, 128, 255);
    QuectoColors.bgAnsi256(21);
  }

  var sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.rgb(255, 128, 0);
  }
  sw.stop();
  print('A1. QuectoColors.rgb(255,128,0)     : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.bgRgb(0, 128, 255);
  }
  sw.stop();
  print('A2. QuectoColors.bgRgb(0,128,255)   : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.ansi256(196);
  }
  sw.stop();
  print('A3. QuectoColors.ansi256(196)        : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.bgAnsi256(21);
  }
  sw.stop();
  print('A4. QuectoColors.bgAnsi256(21)       : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.rgb(255, 128, 0);
  }
  sw.stop();
  print('A5. "Hello".rgb(255,128,0)           : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.bgRgb(0, 128, 255);
  }
  sw.stop();
  print('A6. "Hello".bgRgb(0,128,255)         : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.ansi256(196);
  }
  sw.stop();
  print('A7. "Hello".ansi256(196)             : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  print('');
  print('--- Part B: Pre-cached Styler Invocation ---');
  print('');

  final cachedRgb = QuectoColors.rgb(255, 128, 0);
  final cachedAnsi256 = QuectoColors.ansi256(196);
  final cachedBasicRed = QuectoColors.red;

  for (int i = 0; i < warmup; i++) {
    cachedRgb(shortPlain);
    cachedAnsi256(shortPlain);
    cachedBasicRed(shortPlain);
  }

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedRgb(shortPlain);
  }
  sw.stop();
  print('B1. cached rgb(255,128,0)("Hello")   : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedAnsi256(shortPlain);
  }
  sw.stop();
  print('B2. cached ansi256(196)("Hello")     : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedBasicRed(shortPlain);
  }
  sw.stop();
  print('B3. cached red("Hello")              : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  print('');
  print('--- Part C: QuectoPlain Creation ---');
  print('');

  for (int i = 0; i < warmup; i++) {
    QuectoPlain.rgb(255, 128, 0);
    QuectoPlain.ansi256(196);
  }

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoPlain.rgb(255, 128, 0);
  }
  sw.stop();
  print('C1. QuectoPlain.rgb(255,128,0)       : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoPlain.ansi256(196);
  }
  sw.stop();
  print('C2. QuectoPlain.ansi256(196)         : ${(sw.elapsedMicroseconds * 1000 / iterations).toStringAsFixed(1)} ns/call');

  print('');
  print('Done.');
}
