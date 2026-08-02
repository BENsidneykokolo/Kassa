import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// État de session courant : qui est connecté et avec quel rôle.
/// Persisté localement pour fonctionner hors-ligne (pas de dépendance réseau
/// pour rester connecté).
class SessionState {
  final bool isLoggedIn;
  final String? userName;
  final StaffRole? role;

  const SessionState({this.isLoggedIn = false, this.userName, this.role});

  SessionState copyWith({bool? isLoggedIn, String? userName, StaffRole? role}) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userName: userName ?? this.userName,
      role: role ?? this.role,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState()) {
    _restore();
  }

  static const _keyLoggedIn = 'session_logged_in';
  static const _keyUserName = 'session_user_name';
  static const _keyRole = 'session_role';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    final name = prefs.getString(_keyUserName);
    final roleIndex = prefs.getInt(_keyRole);
    state = SessionState(
      isLoggedIn: loggedIn,
      userName: name,
      role: roleIndex != null ? StaffRole.values[roleIndex] : null,
    );
  }

  Future<void> login({required String userName, required StaffRole role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserName, userName);
    await prefs.setInt(_keyRole, role.index);
    state = SessionState(isLoggedIn: true, userName: userName, role: role);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController();
});
