class UserService {
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // MVP: Always succeeds after tiny delay
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    // MVP: Accepts any email and password (min 6 chars)
    // Will be replaced with real API call later
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return password.length >= 6;
  }
}
