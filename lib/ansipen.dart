import 'supports_ansi_color.dart';
export "supports_ansi_color.dart";
export 'src/quectocolors_ansipen.dart';

// Here for compatibility with ansicolor package
@Deprecated(
    'Will be removed in future releases in favor of [ansiColorDisabled]')
// ignore: non_constant_identifier_names
bool get color_disabled => ansiColorDisabled;
@Deprecated(
    'Will be removed in future releases in favor of [ansiColorDisabled]')
// ignore: non_constant_identifier_names
set color_disabled(bool disabled) => ansiColorDisabled = disabled;