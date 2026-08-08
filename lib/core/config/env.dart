/// Claves de entorno leídas EN COMPILACIÓN vía --dart-define /
/// --dart-define-from-file. Nunca hardcodear valores acá: el archivo con
/// las claves reales es env.json (en .gitignore).
///
/// Correr con: `flutter run --dart-define-from-file=env.json`
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True si falta alguna clave (build sin --dart-define-from-file).
  static bool get isMissing => supabaseUrl.isEmpty || supabaseAnonKey.isEmpty;
}
