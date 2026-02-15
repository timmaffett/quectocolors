import 'dart:math';
import 'dart:typed_data';

// ============================================================
// Benchmark: fastest way to find (or rule out) a closeCode
// in a string, to replace string.indexOf(closeCode).
//
// The key insight: closeCode always starts with \x1B (ESC, 0x1B),
// which almost never appears in normal text. We can exploit this.
// ============================================================

const int kEsc = 0x1B;
const int kBracket = 0x5B; // '['
const int kLowerM = 0x6D;  // 'm'

// Two representative close codes (different lengths)
const String closeCode4 = '\x1B[0m';  // length 4 - full reset
const String closeCode5 = '\x1B[39m'; // length 5 - foreground reset

const int iterations = 10000000;

// ──────────────────────────────────────────────────────────────
// Test strings
// ──────────────────────────────────────────────────────────────

final String shortPlain = 'Hello ';

final String medPlain =
    'Hello World this is a medium length test string for perf';

final String longPlain = String.fromCharCodes(
    List.generate(200, (i) => 97 + Random(42).nextInt(26)));

// Simulates output of blue("Hello ") — has ESC codes, including \x1B[39m
final String shortWithEsc = '\x1B[34mHello \x1B[39m';

// 200 chars with close code buried in the middle
final String longWithEscMid =
    longPlain.substring(0, 100) + closeCode5 + longPlain.substring(100);

// 200 chars with close code near the end
final String longWithEscEnd =
    longPlain.substring(0, 190) + closeCode5 + longPlain.substring(190);

// ──────────────────────────────────────────────────────────────
// Approach 0: Original — just indexOf(closeCode)
// This is the current code in createStyler.
// ──────────────────────────────────────────────────────────────
int original(String s, String cc) {
  return s.indexOf(cc);
}

// ──────────────────────────────────────────────────────────────
// Approach 1: contains('\x1B') pre-check
// If no ESC byte in string, skip indexOf entirely.
// ──────────────────────────────────────────────────────────────
int containsPrecheck(String s, String cc) {
  if (!s.contains('\x1B')) return -1;
  return s.indexOf(cc);
}

// ──────────────────────────────────────────────────────────────
// Approach 2: indexOf single ESC char pre-check
// Same idea but using indexOf('\x1B') == -1.
// ──────────────────────────────────────────────────────────────
int indexOfEscPrecheck(String s, String cc) {
  final escPos = s.indexOf('\x1B');
  if (escPos == -1) return -1;
  return s.indexOf(cc, escPos);
}

// ──────────────────────────────────────────────────────────────
// Approach 3: codeUnitAt scan for ESC, then indexOf from there
// Manual byte scan — avoids Pattern overhead of indexOf/contains.
// ──────────────────────────────────────────────────────────────
int codeUnitAtThenIndexOf(String s, String cc) {
  final len = s.length;
  for (int i = 0; i < len; i++) {
    if (s.codeUnitAt(i) == kEsc) {
      return s.indexOf(cc, i);
    }
  }
  return -1;
}

// ──────────────────────────────────────────────────────────────
// Approach 4: Full custom single-pass match with codeUnitAt
// No indexOf at all — do the entire match manually.
// Pre-caches closeCode code units in a Uint16List.
// ──────────────────────────────────────────────────────────────
int customFullMatch(String s, Uint16List closeCU, int closeLen) {
  final sLen = s.length;
  if (closeLen > sLen) return -1;
  final endPos = sLen - closeLen + 1;
  for (int i = 0; i < endPos; i++) {
    if (s.codeUnitAt(i) == kEsc) {
      bool match = true;
      for (int j = 1; j < closeLen; j++) {
        if (s.codeUnitAt(i + j) != closeCU[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
  }
  return -1;
}

// ──────────────────────────────────────────────────────────────
// Approach 5: Custom match — unrolled for length 4 (\x1B[Xm)
// Since close codes are short and fixed-format, unroll the
// inner comparison loop entirely.
// ──────────────────────────────────────────────────────────────
int customUnrolled4(String s, int cu1, int cu2, int cu3) {
  final sLen = s.length;
  if (sLen < 4) return -1;
  final endPos = sLen - 3;
  for (int i = 0; i < endPos; i++) {
    if (s.codeUnitAt(i) == kEsc &&
        s.codeUnitAt(i + 1) == cu1 &&
        s.codeUnitAt(i + 2) == cu2 &&
        s.codeUnitAt(i + 3) == cu3) {
      return i;
    }
  }
  return -1;
}

// ──────────────────────────────────────────────────────────────
// Approach 6: Custom match — unrolled for length 5 (\x1B[XXm)
// ──────────────────────────────────────────────────────────────
int customUnrolled5(String s, int cu1, int cu2, int cu3, int cu4) {
  final sLen = s.length;
  if (sLen < 5) return -1;
  final endPos = sLen - 4;
  for (int i = 0; i < endPos; i++) {
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

// ──────────────────────────────────────────────────────────────
// Approach 7: Hybrid — codeUnitAt ESC scan with manual verify
// Scans for 0x1B, then manually checks just the remaining
// close code bytes (not calling indexOf at all).
// Uses pre-cached Uint16List but NOT unrolled.
// ──────────────────────────────────────────────────────────────
int hybridScan(String s, Uint16List closeCU, int closeLen) {
  final sLen = s.length;
  final lastStart = sLen - closeLen;
  for (int i = 0; i <= lastStart; i++) {
    if (s.codeUnitAt(i) != kEsc) continue;
    // Found ESC — verify remaining bytes
    int j = 1;
    while (j < closeLen && s.codeUnitAt(i + j) == closeCU[j]) {
      j++;
    }
    if (j == closeLen) return i;
  }
  return -1;
}

// ──────────────────────────────────────────────────────────────
// Approach 8: Scan backwards from end (for cases where ESC
// codes tend to be near the end — may not help in general)
// ──────────────────────────────────────────────────────────────
// Skipping — niche use case.

// ──────────────────────────────────────────────────────────────
// Approach 9: Two-byte sentinel — check for \x1B[ pair
// Since all ANSI codes start with \x1B[, check two bytes.
// This filters even more aggressively than single ESC check.
// ──────────────────────────────────────────────────────────────
int twoByteSentinel(String s, Uint16List closeCU, int closeLen) {
  final sLen = s.length;
  final lastStart = sLen - closeLen;
  for (int i = 0; i <= lastStart; i++) {
    if (s.codeUnitAt(i) != kEsc) continue;
    if (s.codeUnitAt(i + 1) != kBracket) continue;
    // Found \x1B[ — verify rest
    int j = 2;
    while (j < closeLen && s.codeUnitAt(i + j) == closeCU[j]) {
      j++;
    }
    if (j == closeLen) return i;
  }
  return -1;
}


// ──────────────────────────────────────────────────────────────
// Harness
// ──────────────────────────────────────────────────────────────

typedef BenchFn = int Function();

void bench(String label, BenchFn fn, int expectedResult) {
  // Warmup
  for (int i = 0; i < 10000; i++) fn();

  final sw = Stopwatch()..start();
  int result = 0;
  for (int i = 0; i < iterations; i++) {
    result = fn();
  }
  sw.stop();

  final ns = (sw.elapsedMicroseconds * 1000) ~/ iterations;
  final ok = result == expectedResult ? '' : ' *** WRONG (got $result, expected $expectedResult)';
  print('  ${label.padRight(42)} ${sw.elapsedMilliseconds.toString().padLeft(6)}ms  ${ns.toString().padLeft(5)}ns/call$ok');
}

void runSuite(String testName, String testString, String closeCode) {
  print('\n${"=" * 70}');
  print('$testName  (${testString.length} chars, closeCode="${closeCode.replaceAll('\x1B', 'ESC')}")');
  print('${"=" * 70}');

  final expected = testString.indexOf(closeCode);
  print('  Expected indexOf result: $expected');
  print('  Iterations: $iterations\n');

  final closeCU = Uint16List.fromList(closeCode.codeUnits);
  final closeLen = closeCode.length;

  // For unrolled versions
  final cu1 = closeCode.codeUnitAt(1);
  final cu2 = closeCode.codeUnitAt(2);
  final cu3 = closeCode.codeUnitAt(3);
  final int? cu4 = closeLen > 4 ? closeCode.codeUnitAt(4) : null;

  bench('0. Original indexOf(closeCode)', () => original(testString, closeCode), expected);
  bench('1. contains(ESC) pre-check', () => containsPrecheck(testString, closeCode), expected);
  bench('2. indexOf(ESC) + indexOf from pos', () => indexOfEscPrecheck(testString, closeCode), expected);
  bench('3. codeUnitAt ESC + indexOf from pos', () => codeUnitAtThenIndexOf(testString, closeCode), expected);
  bench('4. Custom full match (Uint16List)', () => customFullMatch(testString, closeCU, closeLen), expected);

  if (closeLen == 4) {
    bench('5. Custom unrolled (len=4)', () => customUnrolled4(testString, cu1, cu2, cu3), expected);
  } else if (closeLen == 5) {
    bench('6. Custom unrolled (len=5)', () => customUnrolled5(testString, cu1, cu2, cu3, cu4!), expected);
  }

  bench('7. Hybrid ESC scan + manual verify', () => hybridScan(testString, closeCU, closeLen), expected);
  bench('9. Two-byte sentinel (ESC+[)', () => twoByteSentinel(testString, closeCU, closeLen), expected);
}

void main() {
  print('ESC byte scan benchmark — $iterations iterations each');
  print('Testing approaches to replace string.indexOf(closeCode)\n');

  // Test with the 5-char close code (foreground reset) — most common
  runSuite('SHORT PLAIN (no ESC)',       shortPlain,      closeCode5);
  runSuite('MEDIUM PLAIN (no ESC)',      medPlain,        closeCode5);
  runSuite('LONG PLAIN (no ESC)',        longPlain,       closeCode5);
  runSuite('SHORT WITH ESC (match)',     shortWithEsc,    closeCode5);
  runSuite('LONG, ESC IN MIDDLE',        longWithEscMid,  closeCode5);
  runSuite('LONG, ESC NEAR END',         longWithEscEnd,  closeCode5);

  // Also test with the 4-char close code (full reset)
  print('\n\n${"#" * 70}');
  print('# Now testing with 4-char closeCode (\\x1B[0m)');
  print('${"#" * 70}');
  runSuite('SHORT PLAIN (len=4 close)',  shortPlain,      closeCode4);
  runSuite('LONG PLAIN (len=4 close)',   longPlain,       closeCode4);
}
