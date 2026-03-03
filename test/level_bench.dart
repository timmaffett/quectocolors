import 'package:quectocolors/quectocolors.dart';

/// Benchmark measuring the overhead of AnsiColorLevel checks.
///
/// Compile to exe for accurate results:
///   dart compile exe test/level_bench.dart -o test/level_bench.exe
///   ./test/level_bench.exe

void main() {
  ansiColorDisabled = false;
  ansiColorLevel = AnsiColorLevel.trueColor;

  const int warmup = 50000;
  const int iterations = 2000000;

  const shortPlain = 'Hello';

  print('=== AnsiColorLevel Overhead Benchmark ===');
  print('Warmup: $warmup  |  Iterations: $iterations');
  print('');

  // =====================================================================
  // PART A: Styler CREATION cost (this is where the switch lives)
  // Every call to QuectoColors.rgb() / .ansi256() now has a switch.
  // String extensions like 'text'.rgb(r,g,b) call this per-use.
  // =====================================================================

  print('--- Part A: Styler Creation (switch overhead per call) ---');
  print('');

  // Warmup
  for (int i = 0; i < warmup; i++) {
    QuectoColors.rgb(255, 128, 0);
    QuectoColors.ansi256(196);
    QuectoColors.bgRgb(0, 128, 255);
    QuectoColors.bgAnsi256(21);
  }

  // A1: rgb() styler creation
  var sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.rgb(255, 128, 0);
  }
  sw.stop();
  final createRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('A1. QuectoColors.rgb(255,128,0)     : ${createRgbNs.toStringAsFixed(1)} ns/call');

  // A2: bgRgb() styler creation
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.bgRgb(0, 128, 255);
  }
  sw.stop();
  final createBgRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('A2. QuectoColors.bgRgb(0,128,255)   : ${createBgRgbNs.toStringAsFixed(1)} ns/call');

  // A3: ansi256() styler creation
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.ansi256(196);
  }
  sw.stop();
  final createAnsi256Ns = sw.elapsedMicroseconds * 1000 / iterations;
  print('A3. QuectoColors.ansi256(196)        : ${createAnsi256Ns.toStringAsFixed(1)} ns/call');

  // A4: bgAnsi256() styler creation
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoColors.bgAnsi256(21);
  }
  sw.stop();
  final createBgAnsi256Ns = sw.elapsedMicroseconds * 1000 / iterations;
  print('A4. QuectoColors.bgAnsi256(21)       : ${createBgAnsi256Ns.toStringAsFixed(1)} ns/call');

  // A5: String extension .rgb() (create + apply in one shot)
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.rgb(255, 128, 0);
  }
  sw.stop();
  final strRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('A5. "Hello".rgb(255,128,0)           : ${strRgbNs.toStringAsFixed(1)} ns/call');

  // A6: String extension .bgRgb()
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.bgRgb(0, 128, 255);
  }
  sw.stop();
  final strBgRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('A6. "Hello".bgRgb(0,128,255)         : ${strBgRgbNs.toStringAsFixed(1)} ns/call');

  // A7: String extension .ansi256()
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    shortPlain.ansi256(196);
  }
  sw.stop();
  final strAnsi256Ns = sw.elapsedMicroseconds * 1000 / iterations;
  print('A7. "Hello".ansi256(196)             : ${strAnsi256Ns.toStringAsFixed(1)} ns/call');

  print('');

  // =====================================================================
  // PART B: Styler INVOCATION cost (closures are pre-built, no switch)
  // This should be UNCHANGED from before — the closure is pure.
  // =====================================================================

  print('--- Part B: Pre-cached Styler Invocation (no switch overhead) ---');
  print('');

  final cachedRgb = QuectoColors.rgb(255, 128, 0);
  final cachedAnsi256 = QuectoColors.ansi256(196);
  final cachedBasicRed = QuectoColors.red;

  // Warmup
  for (int i = 0; i < warmup; i++) {
    cachedRgb(shortPlain);
    cachedAnsi256(shortPlain);
    cachedBasicRed(shortPlain);
  }

  // B1: Cached rgb styler
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedRgb(shortPlain);
  }
  sw.stop();
  final invokeRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('B1. cached rgb(255,128,0)("Hello")   : ${invokeRgbNs.toStringAsFixed(1)} ns/call');

  // B2: Cached ansi256 styler
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedAnsi256(shortPlain);
  }
  sw.stop();
  final invokeAnsi256Ns = sw.elapsedMicroseconds * 1000 / iterations;
  print('B2. cached ansi256(196)("Hello")     : ${invokeAnsi256Ns.toStringAsFixed(1)} ns/call');

  // B3: Cached basic red styler (reference baseline)
  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    cachedBasicRed(shortPlain);
  }
  sw.stop();
  final invokeBasicNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('B3. cached red("Hello")              : ${invokeBasicNs.toStringAsFixed(1)} ns/call');

  print('');

  // =====================================================================
  // PART C: QuectoPlain (same tests, plain fast path)
  // =====================================================================

  print('--- Part C: QuectoPlain Creation (plain fast path) ---');
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
  final plainCreateRgbNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('C1. QuectoPlain.rgb(255,128,0)       : ${plainCreateRgbNs.toStringAsFixed(1)} ns/call');

  sw = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    QuectoPlain.ansi256(196);
  }
  sw.stop();
  final plainCreateAnsi256Ns = sw.elapsedMicroseconds * 1000 / iterations;
  print('C2. QuectoPlain.ansi256(196)         : ${plainCreateAnsi256Ns.toStringAsFixed(1)} ns/call');

  print('');

  // =====================================================================
  // PART D: Measure the switch/enum check cost in isolation
  // =====================================================================

  print('--- Part D: Raw overhead of enum switch ---');
  print('');

  // D1: Baseline — just read a global bool (existing ansiColorDisabled check)
  sw = Stopwatch()..start();
  var sink = false;
  for (int i = 0; i < iterations; i++) {
    sink = ansiColorDisabled;
  }
  sw.stop();
  final boolCheckNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('D1. read ansiColorDisabled           : ${boolCheckNs.toStringAsFixed(1)} ns/call');

  // D2: Read global enum + comparison (the new check)
  sw = Stopwatch()..start();
  var sink2 = false;
  for (int i = 0; i < iterations; i++) {
    sink2 = ansiColorLevel == AnsiColorLevel.trueColor;
  }
  sw.stop();
  final enumCheckNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('D2. ansiColorLevel == trueColor      : ${enumCheckNs.toStringAsFixed(1)} ns/call');

  // D3: Full switch on enum (what rgb() actually does)
  sw = Stopwatch()..start();
  var sink3 = 0;
  for (int i = 0; i < iterations; i++) {
    switch (ansiColorLevel) {
      case AnsiColorLevel.basic:
        sink3 = 1;
      case AnsiColorLevel.ansi256:
        sink3 = 2;
      case AnsiColorLevel.none:
      case AnsiColorLevel.trueColor:
        sink3 = 3;
    }
  }
  sw.stop();
  final switchNs = sw.elapsedMicroseconds * 1000 / iterations;
  print('D3. switch(ansiColorLevel) 4-way     : ${switchNs.toStringAsFixed(1)} ns/call');

  // Prevent dead code elimination
  if (sink || sink2 || sink3 == -1) print('');

  print('');
  print('=== Summary ===');
  print('');
  print('Creation overhead (switch) appears in A1-A7 and C1-C2.');
  print('Invocation cost (B1-B3) is UNCHANGED — closures have no switch.');
  print('Raw enum switch cost (D3) shows the isolated overhead per call.');
  print('');
  print('If you cache stylers (B-path), there is ZERO runtime overhead.');
  print('If you use string extensions (A5-A7), each call pays the switch.');
  print('');
  print('Done.');
}
