import 'user.dart';

class AuthResponse {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }

  /// Retorna si el usuario está autenticado y activo
  bool get isAuthenticated => user.activo && token.isNotEmpty;

  /// Retorna si el usuario está verificado
  bool get isVerified => user.emailVerified;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AuthResponse &&
        other.user == user &&
        other.token == token;
  }

  @override
  int get hashCode {
    return user.hashCode ^ token.hashCode;
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, token: $token)';
  }
}

class ValidateSessionResponse {
  final bool valid;
  final User user;

  const ValidateSessionResponse({
    required this.valid,
    required this.user,
  });

  factory ValidateSessionResponse.fromJson(Map<String, dynamic> json) {
    return ValidateSessionResponse(
      valid: json['valid'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'user': user.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ValidateSessionResponse &&
        other.valid == valid &&
        other.user == user;
  }

  @override
  int get hashCode {
    return valid.hashCode ^ user.hashCode;
  }

  @override
  String toString() {
    return 'ValidateSessionResponse(valid: $valid, user: $user)';
  }
}
