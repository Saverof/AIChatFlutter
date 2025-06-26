// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт сервиса аутентификации
import '../services/auth_service.dart';
// Импорт экрана для ввода ключа API
import 'api_key_screen.dart';
// Импорт экрана чата
import 'chat_screen.dart';
// Импорт клиента для работы с API
import '../api/openrouter_client.dart';

// Экран аутентификации
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Контроллер для управления текстовым полем PIN-кода
  final _pinController = TextEditingController();
  // Сервис аутентификации
  final _authService = AuthService();
  // Клиент для работы с API
  final _apiClient = OpenRouterClient();
  // Флаг загрузки
  bool _isLoading = true;
  // Флаг наличия данных аутентификации
  bool _hasAuthData = false;
  // Сообщение об ошибке
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Проверка наличия данных аутентификации
    _checkAuth();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // Метод проверки наличия данных аутентификации
  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Проверка наличия данных аутентификации
      final hasAuth = await _authService.isAuthenticated();

      setState(() {
        _isLoading = false;
        _hasAuthData = hasAuth;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasAuthData = false;
        _errorMessage = 'Ошибка проверки аутентификации: $e';
      });
    }
  }

  // Метод проверки PIN-кода
  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Введите PIN-код';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Проверка PIN-кода
      final isValid = await _authService.verifyPin(pin);

      if (isValid) {
        // Инициализация клиента API
        await _apiClient.ensureInitialized();

        // Переход на экран чата
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Неверный PIN-код';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка проверки PIN-кода: $e';
      });
    }
  }

  // Метод сброса данных аутентификации
  Future<void> _resetAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Сброс данных аутентификации
      await _authService.resetAuth();

      setState(() {
        _isLoading = false;
        _hasAuthData = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка сброса аутентификации: $e';
      });
    }
  }

  // Метод обработки успешной аутентификации
  void _handleAuthSuccess(String pin) {
    // Переход на экран чата
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  // Построение экрана ввода PIN-кода
  Widget _buildPinScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Введите PIN-код',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                hintText: 'Введите 4-значный PIN',
                hintStyle: TextStyle(color: Colors.white54),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, letterSpacing: 8),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _verifyPin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Войти',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _resetAuth,
            child: const Text(
              'Сбросить ключ API',
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
          ),
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        title: const Text(
          'AI Chat Flutter',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _hasAuthData
              ? _buildPinScreen()
              : ApiKeyScreen(onAuthSuccess: _handleAuthSuccess),
    );
  }
}
