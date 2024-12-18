import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'addEditProduct.dart';
import 'productList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:postgres/postgres.dart';


class ServerDataControl {
  static const String baseUrl = 'http://our-server-url.com/api'; // сюда вставить фактический url, хз надо будет потом или нет
  /*final connection = PostgreSQLConnection(
      'localhost',
      1450,
      'mydatabase',
      username: 'myuser',
      password: 'mypassword',
  );*/

  // Ключи для SharedPreferences для хранения внутри приложения
  static const String _groupsKey = 'groups_data';
  static const String _productsKey = 'products_data';
  static const String _groupIdKey = 'next_group_id';
  static const String _productIdKey = 'next_product_id';

  // группы пользователя на экране elementGroups
  static List<Map<String, dynamic>> _groups = [];
  static int _nextGroupId = 1;

  // хранилище для продуктов на экарне productList
  static Map<int, List<Map<String, dynamic>>> _products = {};
  static int _nextProductId = 1;

  // инициализация данных при запуске приложения
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // загружаем сохраненные ID
    _nextGroupId = prefs.getInt(_groupIdKey) ?? 1;
    _nextProductId = prefs.getInt(_productIdKey) ?? 1;
    // загружаем группы
    final groupsJson = prefs.getString(_groupsKey);
    if (groupsJson != null) {
      _groups = List<Map<String, dynamic>>.from(
          json.decode(groupsJson).map((x) => Map<String, dynamic>.from(x))
      );
    }
    // Загружаем продукты
    final productsJson = prefs.getString(_productsKey);
    if (productsJson != null) {
      final Map<String, dynamic> productsMap = json.decode(productsJson);
      _products = Map.fromEntries(
        productsMap.entries.map(
              (e) => MapEntry(
            int.parse(e.key),
            List<Map<String, dynamic>>.from(
                (e.value as List).map((x) => Map<String, dynamic>.from(x))
            ),
          ),
        ),
      );
    }
  }

  // сохранение всех данных локально, внутри приложения
  static Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_groupIdKey, _nextGroupId);
    await prefs.setInt(_productIdKey, _nextProductId);
    await prefs.setString(_groupsKey, json.encode(_groups));

    // преобразуем ключи Map в строки для JSON
    final productsForJson = Map.fromEntries(
        _products.entries.map((e) => MapEntry(e.key.toString(), e.value))
    );
    await prefs.setString(_productsKey, json.encode(productsForJson));
  }

  static Future<List<Map<String, dynamic>>> getGroups(int userId) async {
    // заглушка, надо заменить реальным запросом
    await Future.delayed(Duration(seconds: 1)); // задержка сети, надо будет убрать
    //возвращаем только те группы, в которых есть текущий пользователь
    return _groups.where((group) => group['members'].contains(userId)).toList();
  }

  // заглушка для плучения пользователя по ID в поиске
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    // задержка сети, убрать позже
    await Future.delayed(Duration(seconds: 1));
    // Симуляция базы данных пользователей. Сейчас это статичный объект, позже в эту же переменную настроить подгрузку json, когда рабта с БД будет отлажена
    final users = [
      {'id': 1, 'name': 'Райан Гослинг'},
      {'id': 2, 'name': 'Леон Скотт Кеннеди'},
    ];
    // по идее тут должно быть чо-то вроде этого
    /*try {
      await connection.open();

      // Выполнение SQL-запроса для получения пользователя по ID
      final result = await connection.query(
        'SELECT * FROM "Users" WHERE id = @id',
        substitutionValues: {'id': id},
      );*/
    return users.firstWhere((user) => user['id'] == id, orElse: () => {});
  }

  static Future<Map<String, dynamic>> addGroup(String name, bool isPublic, List<int> members, int creatorId) async {
    // задержка сети
    await Future.delayed(Duration(seconds: 1));
    // сюда запрос в БД
    final int groupId = _nextGroupId++;
    // список участников с их ролями
    List<Map<String, dynamic>> membersWithRoles = [];
    //создатель группы с ролью admin
    membersWithRoles.add({
      'userId': creatorId,
      'role': 'admin'
    });
    // остальные участники с ролью member
    for (int memberId in members) {
      if (memberId != creatorId) { // Проверяем, чтобы не добавить создателя дважды
        membersWithRoles.add({
          'userId': memberId,
          'role': membersWithRoles,
        });
      }
    }
    final newGroup = {
      'id': _nextGroupId++,
      'name': name,
      'isPublic': isPublic,
      'members': members,
    };
    _groups.add(newGroup);
    print("НОВАЯ ГРУППА: ");
    print(newGroup);
    // пустой список продуктов для новой группы
    _products[groupId] = [];
    await _saveData(); // Сохраняем изменения локально в приложении
    return newGroup;
  }

  static Future<void> updateGroup(int groupId, String name, List<int> members) async {
    await Future.delayed(Duration(seconds: 1));
    final groupIndex = _groups.indexWhere((group) => group['id'] == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex] = {
        ..._groups[groupIndex],
        'name': name,
        'members': members,
      };
      await _saveData();
    }
  }

  static Future<void> deleteGroup(int groupId) async {
    await Future.delayed(Duration(seconds: 1));
    _groups.removeWhere((group) => group['id'] == groupId);
    _products.remove(groupId);
    await _saveData();
  }

  static Future<void> leaveGroup(int groupId, int userId) async {
    await Future.delayed(Duration(seconds: 1));
    final groupIndex = _groups.indexWhere((group) => group['id'] == groupId);
    if (groupIndex != -1) {
      List<int> members = List<int>.from(_groups[groupIndex]['members']);
      members.remove(userId);
      _groups[groupIndex]['members'] = members;
      await _saveData();
    }
  }

  static bool isGroupOwner(int groupId, int userId) {
    final group = _groups.firstWhere((group) => group['id'] == groupId, orElse: () => {});
    return group.isNotEmpty && group['members'][0] == userId; // Предполагаем, что первый участник - владелец
  }

  // методы для работы с продуктами
  static Future<List<Map<String, dynamic>>> getProducts(int groupId) async {
    await Future.delayed(Duration(seconds: 1));
    //заглушка, сюда вставить запрос с БД
    return _products[groupId] ?? [];
  }

  static Future<Map<String, dynamic>> addProduct(int groupId, Map<String, dynamic> productData) async {
    await Future.delayed(Duration(seconds: 1));
    final newProduct = {
      'id': _nextProductId++,  // Явно добавляем ID для нового продукта
      ...productData,
      'status': productData['status'] ?? '', // Добавляем пустой статус, если его нет
    };

    if (!_products.containsKey(groupId)) {
      _products[groupId] = [];
    }

    _products[groupId]!.add(newProduct);
    await _saveData(); // Сохраняем изменения локально
    return newProduct;
  }

  static Future<Map<String, dynamic>> updateProduct(int groupId, int productId, Map<String, dynamic> productData) async {
    await Future.delayed(Duration(seconds: 1));

    final productIndex = _products[groupId]!.indexWhere((product) => product['id'] == productId);
    if (productIndex != -1) {
      _products[groupId]![productIndex] = {
        'id': productId,
        ...productData,
        'status': productData['status'] ?? '', // Добавляем пустой статус, если его нет
      };

      await _saveData(); // Сохраняем изменения локально
      return _products[groupId]![productIndex];
    }
    throw Exception('Такой продукт не найден');
  }

  // Метод для удаления продукта, пока не доделала
  static Future<void> deleteProduct(int groupId, int productId) async {
    await Future.delayed(Duration(seconds: 1));

    if (_products.containsKey(groupId)) {
      _products[groupId]!.removeWhere((product) => product['id'] == productId);
      await _saveData(); // Сохраняем изменения
    }
  }

  // ДОБАВИТЬ МЕТОД ДЛЯ УВЕДОМЛЕНИЯ, КОГДА СЕРВЕР БУДЕТ ГОТОВ
}