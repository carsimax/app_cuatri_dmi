class User {
  final int id;
  final String email;
  final String nombre;
  final String apellido;
  final bool activo;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.activo,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      activo: json['activo'],
      emailVerified: json['emailVerified'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'activo': activo,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Retorna el nombre completo del usuario
  String get fullName => '$nombre $apellido';

  /// Retorna las iniciales del usuario
  String get initials {
    final firstInitial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final lastInitial = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Verifica si el usuario está activo y verificado
  bool get isVerifiedAndActive => activo && emailVerified;

  /// Crea una copia del usuario con algunos campos modificados
  User copyWith({
    int? id,
    String? email,
    String? nombre,
    String? apellido,
    bool? activo,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      activo: activo ?? this.activo,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.activo == activo &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        nombre.hashCode ^
        apellido.hashCode ^
        activo.hashCode ^
        emailVerified.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, nombre: $nombre, apellido: $apellido, activo: $activo, emailVerified: $emailVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
