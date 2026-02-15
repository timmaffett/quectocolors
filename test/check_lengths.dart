void main() {
  final codes = [0, 22, 23, 24, 27, 28, 29, 39, 49, 55];
  for (final c in codes) {
    final s = '\x1B[${c}m';
    print('close=$c  code="ESC[${c}m"  length=${s.length}');
  }
}
