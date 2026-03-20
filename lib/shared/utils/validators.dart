abstract final class AppValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El email es requerido';
    final re = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!re.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? required(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // opcional
    final re = RegExp(r'^\+?[0-9]{8,15}$');
    if (!re.hasMatch(value)) return 'Teléfono inválido';
    return null;
  }
}
