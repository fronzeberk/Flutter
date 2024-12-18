import 'package:flutter/material.dart';
import 'serverDataControl.dart';
import 'package:intl/intl.dart';

class AddEditProduct extends StatefulWidget {
  final int groupId;
  final Map<String, dynamic>? product;

  AddEditProduct({required this.groupId, this.product});

  @override
  _AddEditProductState createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _manufactureDateController;
  late TextEditingController _expirationDateController;
  late TextEditingController _quantityController;
  String _quality = 'годен';
  String _availability = 'есть';
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры с пустой строкой, если значение null
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _purchaseDateController = TextEditingController(text: widget.product?['purchaseDate'] ?? '');
    _manufactureDateController = TextEditingController(text: widget.product?['manufactureDate'] ?? '');
    _expirationDateController = TextEditingController(text: widget.product?['expirationDate'] ?? '');
    _quantityController = TextEditingController(text: (widget.product?['quantity'] ?? '').toString());
    _quality = widget.product?['quality'] ?? 'годен';
    _availability = widget.product?['availability'] ?? 'есть';
  }

  // Метод для показа DatePicker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? initialDate;
    if (controller.text.isNotEmpty) {
      try {
        initialDate = _dateFormat.parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _dateFormat.format(picked); // Форматируем дату как ГГГГ-ММ-ДД
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Белый фон для всего экрана
      appBar: AppBar(
        title: Text(widget.product == null ? 'Добавить продукт' : 'Редактировать продукт'),
        backgroundColor: Colors.white, // Белый фон для AppBar
        elevation: 0, // Убираем тень
        iconTheme: IconThemeData(color: Colors.black), // Черный цвет иконок
        actionsIconTheme: IconThemeData(color: Colors.black), // Черный цвет иконок в действиях
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название продукта',
                fillColor: Colors.white, // Белый фон для текста
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название продукта';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _purchaseDateController,
              decoration: InputDecoration(
                labelText: 'Дата покупки',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _purchaseDateController),
                ),
                fillColor: Colors.white, // Белый фон для текста
                filled: true,
              ),
              readOnly: true, // Делаем поле только для чтения
              onTap: () => _selectDate(context, _purchaseDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, выберите дату покупки';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _manufactureDateController,
              decoration: InputDecoration(
                labelText: 'Дата изготовления',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _manufactureDateController),
                ),
                fillColor: Colors.white, // Белый фон для текста
                filled: true,
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _manufactureDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, выберите дату изготовления';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _expirationDateController,
              decoration: InputDecoration(
                labelText: 'Срок годности',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _expirationDateController),
                ),
                fillColor: Colors.white, // Белый фон для текста
                filled: true,
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _expirationDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, выберите срок годности';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Количество',
                fillColor: Colors.white, // Белый фон для текста
                filled: true,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите количество';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _quality,
              decoration: InputDecoration(
                labelText: 'Качество',
                fillColor: Colors.white, // Белый фон для выпадающего списка
                filled: true,
              ),
              items: ['годен', 'не годен'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _quality = newValue!;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _availability,
              decoration: InputDecoration(
                labelText: 'Наличие',
                fillColor: Colors.white, // Белый фон для выпадающего списка
                filled: true,
              ),
              items: ['есть', 'кончился'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _availability = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Сохранить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Зеленая кнопка
                foregroundColor: Colors.white, // Белый текст на кнопке
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text.trim(),
        'purchaseDate': _purchaseDateController.text.trim(),
        'manufactureDate': _manufactureDateController.text.trim(),
        'expirationDate': _expirationDateController.text.trim(),
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
        'quality': _quality,
        'availability': _availability,
        'status': '', // Добавляем пустой статус для нового продукта
      };

      try {
        if (widget.product != null && widget.product!['id'] != null) {
          // Обновляем существующий продукт
          await ServerDataControl.updateProduct(
            widget.groupId,
            widget.product!['id'],
            productData,
          );
        } else {
          // Создаем новый продукт
          await ServerDataControl.addProduct(widget.groupId, productData);
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении продукта')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseDateController.dispose();
    _manufactureDateController.dispose();
    _expirationDateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
