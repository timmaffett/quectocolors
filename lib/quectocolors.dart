/// Full QuectoColors library — core colors, string extensions, extras, and
/// all 149 CSS/X11 named colors.
///
/// ```dart
/// import 'package:quectocolors/quectocolors.dart';
///
/// print('Hello'.red.bold);
/// print(QuectoColors.rgb(255, 128, 0)('orange text'));
/// ```
library;

export "supports_ansi_color.dart";
export "src/quectocolors.dart"; // QuectoColors, Quecto
export "src/quectocolors_extras.dart"; // QuectoColors, QuectoStyler, QuectoPlain
// Adds String extensions for all the CSS/X11 color names.
export "src/quectocolors_css.g.dart";
