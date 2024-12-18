import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _authKey = 'is_authenticated';
  static const String _userIdKey = 'current_user_id';
  static const String _usersKey = 'users_data';

  // Заглушка для базы данных пользователей, позже ее надо убрать и добавить запрос к БД
  static List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'login': 'user1',
      'password': 'password1',
      'email': 'user1@example.com'
    },
    {
      'id': 2,
      'login': 'user2',
      'password': 'password2',
      'email': 'user2@example.com'
    }
  ];
  static int _nextUserId = 3;

  // Проверка, авторизован ли пользователь
  static Future<bool> isAuthenticated() async {
    // запрос к БД
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }

  // Получение текущего пользователя
  static Future<int?> getCurrentUserId() async {
    // запрос к БД
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Авторизация
  static Future<Map<String, dynamic>> login(String login, String password) async {
    // Имитация задержки сети
    await Future.delayed(Duration(seconds: 1));
    // запрос к БД
    // Поиск пользователя
    final user = _users.firstWhere(
          (u) => u['login'] == login && u['password'] == password,
      orElse: () => throw Exception('Неверный логин или пароль'),
    );
    print("АВТОРИЗАЦИЯ: ");
    print(user);

    // Сохранение состояния авторизации ЛОКАЛЬНО
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    await prefs.setInt(_userIdKey, user['id']);
    return user;
  }

  // Регистрация
  static Future<void> register(String login, String password, String email) async {
    // Имитация задержки сети
    // запрос к БД
    await Future.delayed(Duration(seconds: 1));

    // Проверка существования пользователя
    // запрос к БД
    if (_users.any((u) => u['login'] == login)) {
      throw Exception('Пользователь с таким логином уже существует');
    }
    // запрос к БД
    if (_users.any((u) => u['email'] == email)) {
      throw Exception('Пользователь с такой почтой уже существует');
    }

    // Создание нового пользователя
    // нужен запрос к БД
    final newUser = {
      'id': _nextUserId++,
      'login': login,
      'password': password,
      'email': email,
    };
    print("НОВЫЙ ПОЛЬЗОВАТЕЛЬ: ");
    print(newUser);
    _users.add(newUser);
  }

  // Выход из профиля
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    await prefs.remove(_userIdKey);
  }
}
