// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт для работы с системными сервисами (буфер обмена)
import 'package:flutter/services.dart';
// Импорт сервиса аутентификации
import '../services/auth_service.dart';
// Импорт клиента для работы с API
import '../api/openrouter_client.dart';

// Экран для ввода ключа API
class ApiKeyScreen extends StatefulWidget {
  // Функция обратного вызова при успешной аутентификации
  final Function(String) onAuthSuccess;

  const ApiKeyScreen({super.key, required this.onAuthSuccess});

  @override
  _ApiKeyScreenState createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  // Контроллер для управления текстовым полем
  final _apiKeyController = TextEditingController();
  // Сервис аутентификации
  final _authService = AuthService();
  // Клиент для работы с API
  final _apiClient = OpenRouterClient();
  // Флаг загрузки
  bool _isLoading = false;
  // Сообщение об ошибке
  String? _errorMessage;
  // Сообщение об успехе
  String? _successMessage;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  // Метод проверки ключа API
  Future<void> _checkApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = 'Введите ключ API';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Проверка ключа API
      final result = await _authService.checkApiKey(apiKey);

      if (result['success'] == true) {
        // Обновление ключа API в клиенте
        await _apiClient.updateApiKey(apiKey, result['apiType']);

        setState(() {
          _isLoading = false;
          _successMessage =
              'Ключ API успешно проверен. Ваш PIN-код: ${result['pin']}';
        });

        // Показываем диалог с PIN-кодом
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF333333),
                title: const Text(
                  'PIN-код создан',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Запомните ваш PIN-код для входа в приложение:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${result['pin']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Этот PIN-код будет использоваться при каждом запуске приложения.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Вызов функции обратного вызова с PIN-кодом
                      widget.onAuthSuccess(result['pin']);
                    },
                    child: const Text(
                      'Понятно',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка проверки ключа API: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        title: const Text(
          'Ввод ключа API',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Введите ключ API от OpenRouter.ai или VSEGPT',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ключ OpenRouter начинается с sk-or-v1-...\nКлюч VSEGPT начинается с sk-or-vv-...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  hintText: 'Введите ключ API',
                  hintStyle: TextStyle(color: Colors.white54),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkApiKey,
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
                      'Проверить ключ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
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
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            const Text(
              'Ключ API будет сохранен только на вашем устройстве',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
