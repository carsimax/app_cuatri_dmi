import 'constants.dart';

class Validators {
  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Valida contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    // Debe contener al menos una letra y un número
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }
    
    return null;
  }

  /// Valida confirmación de contraseña
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Valida nombre
  static String? name(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El $fieldName es requerido';
    }
    
    if (value.length < AppConstants.minNameLength) {
      return 'El $fieldName debe tener al menos ${AppConstants.minNameLength} caracteres';
    }
    
    if (value.length > AppConstants.maxNameLength) {
      return 'El $fieldName no puede tener más de ${AppConstants.maxNameLength} caracteres';
    }
    
    // Solo letras, espacios y caracteres especiales del español
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'El $fieldName solo puede contener letras y espacios';
    }
    
    return null;
  }

  /// Valida nombre específico
  static String? firstName(String? value) => name(value, 'nombre');
  
  /// Valida apellido específico
  static String? lastName(String? value) => name(value, 'apellido');

  /// Valida campo requerido genérico
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El $fieldName es requerido';
    }
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return 'El $fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return 'El $fieldName no puede tener más de $maxLength caracteres';
    }
    return null;
  }

  /// Combinador de validadores - ejecuta todos y retorna el primer error
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Valida que no sea null o vacío
  static String? notEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El $fieldName no puede estar vacío';
    }
    return null;
  }

  /// Valida que sea un número
  static String? isNumber(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return 'El $fieldName debe ser un número válido';
      }
    }
    return null;
  }

  /// Valida que sea un entero
  static String? isInteger(String? value, String fieldName) {
    if (value != null && value.isNotEmpty) {
      if (int.tryParse(value) == null) {
        return 'El $fieldName debe ser un número entero válido';
      }
    }
    return null;
  }
}
