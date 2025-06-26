// Импорт основных классов Flutter
import 'package:flutter/foundation.dart';

// Класс, представляющий данные аутентификации
class AuthData {
  // API ключ пользователя
  final String apiKey;
  // PIN-код для входа
  final String pin;
  // Тип API (VSEGPT или OpenRouter)
  final String apiType;
  // Время последнего обновления
  final DateTime updatedAt;

  // Конструктор класса AuthData
  AuthData({
    required this.apiKey,
    required this.pin,
    required this.apiType,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // Преобразование объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'pin': pin,
      'apiType': apiType,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Фабричный метод для создания объекта из JSON
  factory AuthData.fromJson(Map<String, dynamic> json) {
    try {
      return AuthData(
        apiKey: json['apiKey'] as String,
        pin: json['pin'] as String,
        apiType: json['apiType'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('Error decoding auth data: $e');
      return AuthData(
        apiKey: json['apiKey'] as String,
        pin: json['pin'] as String,
        apiType: json['apiType'] as String,
      );
    }
  }

  // Определение типа API на основе ключа
  static String determineApiType(String apiKey) {
    if (apiKey.startsWith('sk-or-vv-')) {
      return 'VSEGPT';
    } else if (apiKey.startsWith('sk-or-v1-')) {
      return 'OpenRouter';
    } else {
      return 'Unknown';
    }
  }

  // Создание копии с обновленными полями
  AuthData copyWith({
    String? apiKey,
    String? pin,
    String? apiType,
    DateTime? updatedAt,
  }) {
    return AuthData(
      apiKey: apiKey ?? this.apiKey,
      pin: pin ?? this.pin,
      apiType: apiType ?? this.apiType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
