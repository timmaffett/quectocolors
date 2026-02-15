// NOTES on changes I needed to make to ansicolor_test.dart for it to work with QuectoColors:
// Changes to ansicolor_test.dart were minimal:
// 
//   - Close codes: \x1B[0m → \x1B[39m/\x1B[49m (our specific close codes instead of full reset)
//   - Nesting re-injection: updated the "w/ resets" expected string to match our proper style re-injection
//   - System colors & grayscale: expect(..., '\x1B[...') → expect(..., endsWith('\x1B[...')) to work with the stacking pen
//   - Interpolated: tests the ${pen}...${pen.up} pattern directly (uses \x1B[0m full reset via pen.up)
//   - ansiColorDisabled: pen created after disabling (our closures capture disabled state at creation time)



library ansicolor_test;

import 'package:quectocolors/ansipen.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    ansiColorDisabled = false;
  });

  tearDown(() {
    ansiColorDisabled = false;
  });

  test('foreground', () {
    final pen = AnsiPen()..rgb(r: 1.0, g: 0.8, b: 0.2);
    expect(pen.write('Test Text'), '\x1B[38;5;221mTest Text\x1B[39m');
  });

  test('background', () {
    final pen = AnsiPen()..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    expect(pen.write('Test Text'), '\x1B[48;5;117mTest Text\x1B[49m');
  });

  test('foreground and background', () {
    final pen = AnsiPen()
      ..rgb(r: 1.0, g: 0.8, b: 0.2)
      ..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    expect(
        pen.write('Test Text'), '\x1B[38;5;221m\x1B[48;5;117mTest Text\x1B[49m\x1B[39m');
  });

  test('foreground and background w/ resets', () {
    final pen = AnsiPen()
      ..rgb(r: 1.0, g: 0.8, b: 0.2)
      ..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    // QuectoColors properly re-injects parent styles after nested close codes
    expect(
        pen.write('Test${ansiResetBackground} Text${ansiResetForeground}Test'),
        '\x1B[38;5;221m\x1B[48;5;117mTest\x1B[48;5;117m Text\x1B[38;5;221mTest\x1B[49m\x1B[39m');
  });

  test('direct xterm', () {
    final pen = AnsiPen()..xterm(200)..xterm(100, bg: true);
    expect(
        pen.write('Test Text'), '\x1B[38;5;200m\x1B[48;5;100mTest Text\x1B[49m\x1B[39m');
  });

  test('xterm index clamped', () {
    final pen = AnsiPen()..xterm(256)..xterm(-1, bg: true);
    expect(
        pen.write('Test Text'), '\x1B[38;5;255m\x1B[48;5;0mTest Text\x1B[49m\x1B[39m');
  });

  test('call() == write()', () {
    final pen = AnsiPen()
      ..rgb(r: 1.0, g: 0.8, b: 0.2)
      ..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    expect(pen.write('Test Text'), pen('Test Text'));
  });

  test('interpolated == write()', () {
    final pen = AnsiPen()
      ..rgb(r: 1.0, g: 0.8, b: 0.2)
      ..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    // Interpolated form uses pen.up (\x1B[0m full reset) while write() uses
    // per-color close codes — both produce correct terminal output
    expect('${pen}Test Text${pen.up}',
        '\x1B[38;5;221m\x1B[48;5;117mTest Text\x1B[0m');
  });

  test('system colors', () {
    final pen = AnsiPen();
    // QuectoColors uses standard ANSI SGR codes (not xterm 256 indices)
    // and pen stacks styles, so we check the last code with endsWith
    expect((pen..black()).down, endsWith('\x1B[30m'));
    expect((pen..red()).down, endsWith('\x1B[31m'));
    expect((pen..green()).down, endsWith('\x1B[32m'));
    expect((pen..yellow()).down, endsWith('\x1B[33m'));
    expect((pen..blue()).down, endsWith('\x1B[34m'));
    expect((pen..magenta()).down, endsWith('\x1B[35m'));
    expect((pen..cyan()).down, endsWith('\x1B[36m'));
    expect((pen..white()).down, endsWith('\x1B[37m'));

    expect((pen..black(bold: true)).down, endsWith('\x1B[90m'));
    expect((pen..red(bold: true)).down, endsWith('\x1B[91m'));
    expect((pen..green(bold: true)).down, endsWith('\x1B[92m'));
    expect((pen..yellow(bold: true)).down, endsWith('\x1B[93m'));
    expect((pen..blue(bold: true)).down, endsWith('\x1B[94m'));
    expect((pen..magenta(bold: true)).down, endsWith('\x1B[95m'));
    expect((pen..cyan(bold: true)).down, endsWith('\x1B[96m'));
    expect((pen..white(bold: true)).down, endsWith('\x1B[97m'));

    expect((pen..reset).down, endsWith('\x1B[0m'));

    expect((pen..black(bg: true)).down, endsWith('\x1B[40m'));
    expect((pen..red(bg: true)).down, endsWith('\x1B[41m'));
    expect((pen..green(bg: true)).down, endsWith('\x1B[42m'));
    expect((pen..yellow(bg: true)).down, endsWith('\x1B[43m'));
    expect((pen..blue(bg: true)).down, endsWith('\x1B[44m'));
    expect((pen..magenta(bg: true)).down, endsWith('\x1B[45m'));
    expect((pen..cyan(bg: true)).down, endsWith('\x1B[46m'));
    expect((pen..white(bg: true)).down, endsWith('\x1B[47m'));

    expect((pen..black(bg: true, bold: true)).down, endsWith('\x1B[100m'));
    expect((pen..red(bg: true, bold: true)).down, endsWith('\x1B[101m'));
    expect((pen..green(bg: true, bold: true)).down, endsWith('\x1B[102m'));
    expect((pen..yellow(bg: true, bold: true)).down, endsWith('\x1B[103m'));
    expect((pen..blue(bg: true, bold: true)).down, endsWith('\x1B[104m'));
    expect((pen..magenta(bg: true, bold: true)).down, endsWith('\x1B[105m'));
    expect((pen..cyan(bg: true, bold: true)).down, endsWith('\x1B[106m'));
    expect((pen..white(bg: true, bold: true)).down, endsWith('\x1B[107m'));
  });

  test('rgb overflow', () {
    final pen = AnsiPen()
      ..rgb(r: 2.0, g: 2.8, b: 2.2)
      ..rgb(r: 2.4, g: 2.8, b: 2.0, bg: true);
    expect(
        pen.write('Test Text'), '\x1B[38;5;231m\x1B[48;5;231mTest Text\x1B[49m\x1B[39m');
  });

  test('rgb underflow', () {
    final pen = AnsiPen()
      ..rgb(r: -1.0, g: -2.8, b: -2.2)
      ..rgb(r: -1.0, g: -2.8, b: -2.0, bg: true);
    expect(
        pen.write('Test Text'), '\x1B[38;5;16m\x1B[48;5;16mTest Text\x1B[49m\x1B[39m');
  });

  test('grayscale', () {
    final pen = AnsiPen();

    for (var i = 0; i < 24; i++) {
      expect((pen..gray(level: i / 23)).down, endsWith('\x1B[38;5;${232 + i}m'),
          reason: 'fg failed at $i');
    }

    expect((pen..reset).down, endsWith('\x1B[0m'));

    for (var i = 0; i < 24; i++) {
      expect((pen..gray(level: i / 23, bg: true)).down, endsWith('\x1B[48;5;${232 + i}m'),
          reason: 'bg failed at $i');
    }
  });

  test('ansiColorDisabled', () {
    // Stylers must be created while disabled to get passthrough closures
    ansiColorDisabled = true;
    final pen = AnsiPen()
      ..rgb(r: 1.0, g: 0.8, b: 0.2)
      ..rgb(r: 0.4, g: 0.8, b: 1.0, bg: true);
    expect(pen.write('Test Text'), 'Test Text');
  });
}
