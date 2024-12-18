import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'serverDataControl.dart';
import 'addGroup.dart';
import 'productList.dart';
import 'authController.dart';
import 'authScreen.dart';

class elementGroups extends StatefulWidget {
  final int currentUserId; // id пользователя
  elementGroups({required this.currentUserId});

  @override
  _ElementGroupsState createState() => _ElementGroupsState();
}

class _ElementGroupsState extends State<elementGroups> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final groups = await ServerDataControl.getGroups(widget.currentUserId);
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching groups: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await AuthController.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выходе из профиля')),
      );
    }
  }

  void _copyIdToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.currentUserId.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ID скопирован в буфер обмена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Белый фон для AppBar
        toolbarHeight: 100, // Высота AppBar
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание содержимого по левому краю
          children: [
            // Верхний ряд: иконка и текст
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Разделение заголовка и кнопки выхода
              crossAxisAlignment: CrossAxisAlignment.center, // Выравнивание по вертикали
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end, // Иконка и текст на одной линии
                  children: [
                    SizedBox(width: 10),
                    Icon(
                      Icons.people_alt_outlined,
                      color: Colors.lightGreen,
                      size: 40.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Активные группы",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                // Кнопка выхода
                IconButton(
                  iconSize: 40.0,
                  icon: Icon(
                    Icons.logout,
                    color: Colors.black,
                  ), // Черный цвет для иконки
                  onPressed: _logout,
                ),
              ],
            ),
            //SizedBox(height: 4), // Отступ между заголовком и ID
            // ID пользователя
            GestureDetector(
              onTap: _copyIdToClipboard,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ваш личный ID: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54, // Серый цвет для первой части
                          ),
                        ),
                        TextSpan(
                          text: '${widget.currentUserId}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.lightGreen, // Зеленый цвет для ID
                            fontWeight: FontWeight.bold, // Дополнительно можно выделить жирным
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Colors.lightGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.1), Colors.lightGreen], // Больше белого в градиенте
            begin: Alignment.topCenter, // Начинается сверху
            end: Alignment.bottomCenter, // Идет до низа
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            final bool isOwner = ServerDataControl.isGroupOwner(
                group['id'], widget.currentUserId);
            return ListTile(
              leading: Stack(
                alignment: Alignment.topRight, // Расположение текста в правом верхнем углу
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 30,
                    ),
                    color: Colors.lightGreen, // Салатовый цвет заливки
                    iconSize: 24, // Размер иконки
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => addGroup(
                            currentUserId: widget.currentUserId,
                            existingGroup: group,
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchGroups();
                      }
                    },
                  ),
                  Positioned(
                    top: 4, // Смещение сверху
                    right: 4, // Смещение справа
                    child: Text(
                      '${group['members'].length}', // Количество участников
                      style: TextStyle(
                        fontSize: 14.0, // Размер шрифта поменьше
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                group['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    group['isPublic'] ? 'Публичная' : 'Личная',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '•   ${isOwner ? "Владелец" : "Участник"}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                      groupId: group['id'],
                      groupName: group['name'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter, // Привязка к центру внизу
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0, left: 30.0), // Отступ слева
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => addGroup(
                    currentUserId: widget.currentUserId,
                  ),
                ),
              );
              if (result == true) {
                _fetchGroups();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Зеленый фон для кнопки
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Скругленные углы
              ),
              padding: EdgeInsets.symmetric(vertical: 12), // Уменьшение высоты кнопки
              minimumSize: Size((MediaQuery.of(context).size.width - 40) / 2, 0), // Уменьшение ширины в 2 раза
            ),
            child: Text(
              'Добавить', // Текст без плюсика
              style: TextStyle(
                color: Colors.white, // Белые буквы
                fontSize: 16, // Немного уменьшен размер шрифта
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
