import 'package:flutter/material.dart';
import 'serverDataControl.dart';

class addGroup extends StatefulWidget {
  final int currentUserId;
  final Map<String, dynamic>? existingGroup; // null для создания новой группы

  addGroup({
    required this.currentUserId,
    this.existingGroup,
  });

  @override
  _addGroupState createState() => _addGroupState();
}

class _addGroupState extends State<addGroup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  bool _isPublic = false;
  List<Map<String, dynamic>> _selectedUsers = [];
  bool get isEditMode => widget.existingGroup != null;
  bool get isOwner => isEditMode &&
      ServerDataControl.isGroupOwner(widget.existingGroup!['id'], widget.currentUserId);

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.existingGroup!['name'];
      _isPublic = widget.existingGroup!['isPublic'];
      _loadGroupMembers();
    }
  }

  Future<void> _loadGroupMembers() async {
    for (int userId in widget.existingGroup!['members']) {
      if (userId != widget.currentUserId) {
        final user = await ServerDataControl.getUserById(userId);
        if (user != null && user.isNotEmpty) {
          setState(() {
            _selectedUsers.add(user);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Белый фон для всего экрана
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white, // Белый фон для AppBar
        elevation: 0, // Убираем тень
        title: Text(
          isEditMode ? 'Редактировать группу' : 'Добавить группу',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
          ), // Черный цвет для текста
        ),
        actions: isEditMode ? [
          if (!isOwner)
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _leaveGroup,
              tooltip: 'Выйти из группы',
            ),
          if (isOwner)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded),
              onPressed: _deleteGroup,
              tooltip: 'Удалить группу',
            ),
        ] : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.lightGreen],
            stops: [0.6, 1.0], // Белый цвет занимает 50%, зеленый - остальную часть
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Название группы'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название группы';
                  }
                  return null;
                },
              ),
              if (!isEditMode) // Переключатель публичности только при создании
                SwitchListTile(
                  title: Text('Публичная группа'),
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                      if (!_isPublic) {
                        _selectedUsers.clear();
                      }
                    });
                  },
                  activeColor: Colors.green, // Зеленый цвет ползунка при активном состоянии
                  inactiveThumbColor: Colors.white, // Белый цвет ползунка при неактивном состоянии
                  inactiveTrackColor: Colors.black, // Черный цвет трека при неактивном состоянии
                ),
              if (_isPublic || isEditMode) ...[
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(labelText: 'ID пользователя'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0), // Отступ сверху для кнопки
                ElevatedButton(
                  onPressed: _addUser,
                  child: Text('Добавить пользователя'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Скругленные углы
                    ),
                    backgroundColor: Colors.lightGreen, // Зеленый цвет фона
                    foregroundColor: Colors.white, // Белый цвет текста
                    padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличен вертикальный отступ
                  ),
                ),
                SizedBox(height: 10),
                Text('Участники группы:'),
                ..._selectedUsers.map((user) => ListTile(
                  title: Text('${user['name']} (ID: ${user['id']})'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _selectedUsers.removeWhere(
                                (selectedUser) => selectedUser['id'] == user['id']
                        );
                      });
                    },
                  ),
                )),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditMode ? 'Сохранить изменения' : 'Создать группу'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Скругленные углы
                  ),
                  backgroundColor: Colors.lightGreen, // Зеленый цвет фона
                  foregroundColor: Colors.white, // Белый цвет текста
                  padding: EdgeInsets.symmetric(vertical: 12.0), // Увеличен вертикальный отступ
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addUser() async {
    final userId = int.tryParse(_userIdController.text);
    if (userId != null) {
      try {
        final user = await ServerDataControl.getUserById(userId);
        if (user != null && user.isNotEmpty) {
          if (!_selectedUsers.any((selectedUser) => selectedUser['id'] == userId)) {
            setState(() {
              _selectedUsers.add(user);
              _userIdController.clear();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Этот пользователь уже добавлен')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Пользователь с таким ID не найден')),
          );
        }
      } catch (e) {
        print('Error fetching user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при поиске пользователя')),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final List<int> members = [
          widget.currentUserId,
          ..._selectedUsers.map((user) => user['id'])
        ];

        if (isEditMode) {
          await ServerDataControl.updateGroup(
            widget.existingGroup!['id'],
            _nameController.text,
            members,
          );
        } else {
          await ServerDataControl.addGroup(
            _nameController.text,
            _isPublic,
            members,
            widget.currentUserId,
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving group: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении группы')),
        );
      }
    }
  }

  void _leaveGroup() async {
    // Показываем диалог подтверждения
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подтверждение'),
        content: Text('Вы уверены, что хотите выйти из группы?'),
        actions: [
          TextButton(
            child: Text('Отмена'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Выйти'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ServerDataControl.leaveGroup(widget.existingGroup!['id'], widget.currentUserId);
        Navigator.pop(context, true);
      } catch (e) {
        print('Error leaving group: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе из группы')),
        );
      }
    }
  }

  void _deleteGroup() async {
    // Показываем диалог подтверждения
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подтверждение'),
        content: Text('Вы уверены, что хотите удалить группу? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            child: Text('Отмена'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Удалить'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ServerDataControl.deleteGroup(widget.existingGroup!['id']);
        Navigator.pop(context, true);
      } catch (e) {
        print('Error deleting group: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении группы')),
        );
      }
    }
  }
}
