import 'dart:math';

// ============================================================
// Round 2: Head-to-head of the top contenders from round 1,
// plus combo approaches.
//
// The finalists:
//   A) contains(ESC) pre-check  — fastest for no-ESC
//   B) Custom unrolled len=5    — fastest for has-ESC
//   C) Combo: contains gate + unrolled  (best of both?)
//   D) indexOf(ESC) + indexOf from pos  (clean & fast)
//   E) Original indexOf(closeCode) — baseline
//
// Also test with a start-position parameter, since the
// nesting do-while loop needs indexOf(closeCode, lastIndex).
// ============================================================

const int kEsc = 0x1B;
const String closeCode = '\x1B[39m'; // len 5, foreground reset
const int iterations = 10000000;

// Test strings
final String shortPlain = 'Hello ';
final String medPlain =
    'Hello World this is a medium length test string for perf';
final String longPlain = String.fromCharCodes(
    List.generate(200, (i) => 97 + Random(42).nextInt(26)));
final String shortWithEsc = '\x1B[34mHello \x1B[39m';
final String longWithEscMid =
    longPlain.substring(0, 100) + closeCode + longPlain.substring(100);

// Simulate "has ESC but NOT our close code" — very common in nested styling
// e.g. bold's closure scanning red's output (bold close = \x1B[22m, input has \x1B[39m)
final String longWrongEsc =
    longPlain.substring(0, 50) + '\x1B[22m' + longPlain.substring(50);

// Pre-cached code units for closeCode '\x1B[39m'
final int cu1 = closeCode.codeUnitAt(1); // 0x5B '['
final int cu2 = closeCode.codeUnitAt(2); // 0x33 '3'
final int cu3 = closeCode.codeUnitAt(3); // 0x39 '9'
final int cu4 = closeCode.codeUnitAt(4); // 0x6D 'm'
const int closeLen = 5;

// ── A) Original indexOf ─────────────────────────────────────
int original(String s, int from) => s.indexOf(closeCode, from);

// ── B) contains(ESC) gate + original indexOf ────────────────
int containsGateOriginal(String s, int from) {
  if (!s.contains('\x1B')) return -1;
  return s.indexOf(closeCode, from);
}

// ── C) Custom unrolled len=5 (with start position) ──────────
int unrolled5(String s, int from) {
  final end = s.length - 4; // closeLen - 1
  for (int i = from; i < end; i++) {
    if (s.codeUnitAt(i) == kEsc &&
        s.codeUnitAt(i + 1) == cu1 &&
        s.codeUnitAt(i + 2) == cu2 &&
        s.codeUnitAt(i + 3) == cu3 &&
        s.codeUnitAt(i + 4) == cu4) {
      return i;
    }
  }
  return -1;
}

// ── D) contains gate + custom unrolled ──────────────────────
int containsGateUnrolled(String s, int from) {
  if (!s.contains('\x1B')) return -1;
  return unrolled5(s, from);
}

// ── E) indexOf(ESC) + indexOf from pos ──────────────────────
int indexOfEscBridge(String s, int from) {
  final escPos = s.indexOf('\x1B', from);
  if (escPos == -1) return -1;
  return s.indexOf(closeCode, escPos);
}

// ── F) indexOf(ESC) + custom unrolled from pos ──────────────
int indexOfEscUnrolled(String s, int from) {
  final escPos = s.indexOf('\x1B', from);
  if (escPos == -1) return -1;
  return unrolled5(s, escPos);
}

// ── G) Pure codeUnitAt ESC check (no match, just bool) ──────
// To measure the raw cost of ESC detection alone.
bool hasEsc_codeUnitAt(String s) {
  final len = s.length;
  for (int i = 0; i < len; i++) {
    if (s.codeUnitAt(i) == kEsc) return true;
  }
  return false;
}

bool hasEsc_contains(String s) {
  return s.contains('\x1B');
}

bool hasEsc_indexOf(String s) {
  return s.indexOf('\x1B') != -1;
}

// ──────────────────────────────────────────────────────────────
// Harness
// ──────────────────────────────────────────────────────────────

typedef IntBench = int Function();
typedef BoolBench = bool Function();

void benchInt(String label, IntBench fn, int expected) {
  for (int i = 0; i < 10000; i++) fn();
  final sw = Stopwatch()..start();
  int r = 0;
  for (int i = 0; i < iterations; i++) r = fn();
  sw.stop();
  final ns = (sw.elapsedMicroseconds * 1000) ~/ iterations;
  final ok = r == expected ? '' : ' *** WRONG ($r != $expected)';
  print('  ${label.padRight(44)} ${sw.elapsedMilliseconds.toString().padLeft(6)}ms  ${ns.toString().padLeft(5)}ns/call$ok');
}

void benchBool(String label, BoolBench fn, bool expected) {
  for (int i = 0; i < 10000; i++) fn();
  final sw = Stopwatch()..start();
  bool r = false;
  for (int i = 0; i < iterations; i++) r = fn();
  sw.stop();
  final ns = (sw.elapsedMicroseconds * 1000) ~/ iterations;
  final ok = r == expected ? '' : ' *** WRONG ($r != $expected)';
  print('  ${label.padRight(44)} ${sw.elapsedMilliseconds.toString().padLeft(6)}ms  ${ns.toString().padLeft(5)}ns/call$ok');
}

void runFindSuite(String name, String testStr) {
  print('\n${"=" * 70}');
  print('$name  (${testStr.length} chars)');
  print('${"=" * 70}');
  final expected = testStr.indexOf(closeCode);
  print('  Expected: $expected\n');

  benchInt('A. Original indexOf(closeCode)',       () => original(testStr, 0), expected);
  benchInt('B. contains(ESC) + indexOf',           () => containsGateOriginal(testStr, 0), expected);
  benchInt('C. Custom unrolled (len=5)',            () => unrolled5(testStr, 0), expected);
  benchInt('D. contains(ESC) + unrolled',           () => containsGateUnrolled(testStr, 0), expected);
  benchInt('E. indexOf(ESC) + indexOf from pos',    () => indexOfEscBridge(testStr, 0), expected);
  benchInt('F. indexOf(ESC) + unrolled from pos',   () => indexOfEscUnrolled(testStr, 0), expected);
}

void runEscDetectSuite(String name, String testStr) {
  print('\n${"=" * 70}');
  print('Raw ESC detection: $name  (${testStr.length} chars)');
  print('${"=" * 70}');
  final expected = testStr.contains('\x1B');
  print('  Expected: $expected\n');

  benchBool('codeUnitAt loop',  () => hasEsc_codeUnitAt(testStr), expected);
  benchBool('contains(ESC)',    () => hasEsc_contains(testStr), expected);
  benchBool('indexOf(ESC)!=-1', () => hasEsc_indexOf(testStr), expected);
}

void main() {
  print('ESC scan benchmark round 2 — $iterations iterations\n');

  // ── Part 1: Raw ESC detection comparison ──
  print('\n${"#" * 70}');
  print('# PART 1: Raw ESC detection speed');
  print('${"#" * 70}');
  runEscDetectSuite('short plain (no ESC)', shortPlain);
  runEscDetectSuite('medium plain (no ESC)', medPlain);
  runEscDetectSuite('long plain (no ESC)', longPlain);
  runEscDetectSuite('short with ESC', shortWithEsc);
  runEscDetectSuite('long with ESC in middle', longWithEscMid);

  // ── Part 2: Full closeCode search comparison ──
  print('\n\n${"#" * 70}');
  print('# PART 2: Full closeCode search');
  print('${"#" * 70}');
  runFindSuite('SHORT PLAIN (no ESC)', shortPlain);
  runFindSuite('MEDIUM PLAIN (no ESC)', medPlain);
  runFindSuite('LONG PLAIN (no ESC)', longPlain);
  runFindSuite('SHORT WITH ESC (match)', shortWithEsc);
  runFindSuite('LONG, ESC IN MIDDLE (match)', longWithEscMid);
  runFindSuite('LONG, WRONG ESC (no match)', longWrongEsc);
}
