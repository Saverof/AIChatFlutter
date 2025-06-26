// Импорт библиотеки для работы с HTTP
import 'package:http/http.dart' as http;
// Импорт библиотеки для работы с JSON
import 'dart:convert';
// Импорт библиотеки для генерации случайных чисел
import 'dart:math';
// Импорт основных классов Flutter
import 'package:flutter/foundation.dart';
// Импорт сервиса для работы с базой данных
import 'database_service.dart';
// Импорт модели данных аутентификации
import '../models/auth_data.dart';

// Класс сервиса для работы с аутентификацией
class AuthService {
  // Единственный экземпляр класса (Singleton)
  static final AuthService _instance = AuthService._internal();
  // Сервис для работы с базой данных
  final DatabaseService _db = DatabaseService();

  // Фабричный метод для получения экземпляра
  factory AuthService() {
    return _instance;
  }

  // Приватный конструктор для реализации Singleton
  AuthService._internal();

  // Метод для проверки наличия данных аутентификации
  Future<bool> isAuthenticated() async {
    return await _db.hasAuthData();
  }

  // Метод для получения данных аутентификации
  Future<AuthData?> getAuthData() async {
    final data = await _db.getAuthData();
    if (data != null) {
      return AuthData.fromJson(data);
    }
    return null;
  }

  // Метод для генерации случайного PIN-кода
  String _generatePin() {
    final random = Random();
    // Генерация 4-значного PIN-кода
    return (1000 + random.nextInt(9000)).toString();
  }

  // Метод для проверки баланса API ключа
  Future<Map<String, dynamic>> checkApiKey(String apiKey) async {
    try {
      // Определение типа API на основе ключа
      final apiType = AuthData.determineApiType(apiKey);

      if (apiType == 'Unknown') {
        return {
          'success': false,
          'message': 'Неизвестный формат ключа API',
          'balance': '0',
          'apiType': apiType,
        };
      }

      // Формирование URL в зависимости от типа API
      final url = apiType == 'VSEGPT'
          ? 'https://api.vsegpt.ru/balance'
          : 'https://openrouter.ai/api/v1/credits';

      // Формирование заголовков запроса
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      // Выполнение GET запроса для получения баланса
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (kDebugMode) {
        print('Balance response status: ${response.statusCode}');
        print('Balance response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Парсинг данных о балансе
        final data = json.decode(response.body);

        // Извлечение баланса в зависимости от типа API
        String balance = '0';
        bool hasPositiveBalance = false;

        if (apiType == 'VSEGPT') {
          if (data != null && data['data'] != null) {
            final credits =
                double.tryParse(data['data']['credits'].toString()) ?? 0.0;
            balance = '${credits.toStringAsFixed(2)}₽';
            hasPositiveBalance = credits > 0;
          }
        } else {
          // OpenRouter
          if (data != null && data['data'] != null) {
            final credits = data['data']['total_credits'] ?? 0;
            final usage = data['data']['total_usage'] ?? 0;
            final availableBalance = credits - usage;
            balance = '\$${availableBalance.toStringAsFixed(2)}';
            hasPositiveBalance = availableBalance > 0;
          }
        }

        if (hasPositiveBalance) {
          // Генерация PIN-кода
          final pin = _generatePin();

          // Сохранение данных аутентификации
          await _db.saveAuthData(apiKey, pin, apiType);

          return {
            'success': true,
            'message': 'Ключ API успешно проверен',
            'balance': balance,
            'pin': pin,
            'apiType': apiType,
          };
        } else {
          return {
            'success': false,
            'message': 'Недостаточно средств на балансе',
            'balance': balance,
            'apiType': apiType,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Ошибка проверки ключа API: ${response.statusCode}',
          'apiType': apiType,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking API key: $e');
      }
      return {
        'success': false,
        'message': 'Ошибка проверки ключа API: $e',
        'apiType': 'Unknown',
      };
    }
  }

  // Метод для проверки PIN-кода
  Future<bool> verifyPin(String pin) async {
    try {
      final authData = await getAuthData();
      if (authData != null) {
        return authData.pin == pin;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying PIN: $e');
      }
      return false;
    }
  }

  // Метод для сброса данных аутентификации
  Future<void> resetAuth() async {
    await _db.clearAuthData();
  }
}
