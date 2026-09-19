// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

const int _obfKey = 0x5A;

String _obfuscate(String input) {
  final bytes = utf8.encode(input);
  final xored = bytes.map((b) => b ^ _obfKey).toList();
  return base64Encode(xored);
}

String _deobfuscate(String encoded) {
  try {
    final bytes = base64Decode(encoded);
    final unxored = bytes.map((b) => b ^ _obfKey).toList();
    return utf8.decode(unxored);
  } catch (_) {
    // If not encoded (legacy session), return raw
    return encoded;
  }
}

void saveSession(String key, String value) {
  try {
    html.window.localStorage[key] = _obfuscate(value);
  } catch (_) {}
}

String? loadSession(String key) {
  try {
    final raw = html.window.localStorage[key];
    if (raw == null || raw.isEmpty) return null;
    return _deobfuscate(raw);
  } catch (_) {
    return null;
  }
}

void clearSession(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {}
}
