/// Uygulama genel konfigürasyonu.
/// İstersen `--dart-define=API_BASE_URL=...` ile override edebilirsin.
///
/// NOT:
/// - Varsayılan olarak Android emülatöründen backend'e erişim için `10.0.2.2:3000` kullanılır.
/// - Web veya diğer platformlarda çalıştırırken istersen
///   `--dart-define=API_BASE_URL=http://localhost:3000` ile override edebilirsin.
/// - Backend portu 3000 ve route'lar doğrudan `/auth/...` şeklinde; global `/api` prefix'i yok.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}

