import 'package:flutter/material.dart';
import 'addEditProduct.dart';
import 'package:intl/intl.dart';

class ProductTemplateList extends StatefulWidget {
  final int groupId;

  ProductTemplateList({required this.groupId});

  @override
  _ProductTemplateListState createState() => _ProductTemplateListState();
}

class _ProductTemplateListState extends State<ProductTemplateList> {
  final List<Map<String, dynamic>> _productTemplates = [
    {'id': 1, 'name': 'Молоко', 'shelfLife': 7},
    {'id': 2, 'name': 'Хлеб', 'shelfLife': 5},
    {'id': 3, 'name': 'Йогурт', 'shelfLife': 14},
    {'id': 4, 'name': 'Сыр', 'shelfLife': 30},
    {'id': 5, 'name': 'Колбаса', 'shelfLife': 10},
    {'id': 6, 'name': 'Яйца', 'shelfLife': 21},
    {'id': 7, 'name': 'Творог', 'shelfLife': 7},
    {'id': 8, 'name': 'Сметана', 'shelfLife': 14},
    {'id': 9, 'name': 'Масло сливочное', 'shelfLife': 30},
    {'id': 10, 'name': 'Рыба охлажденная', 'shelfLife': 3},
  ];

  List<Map<String, dynamic>> _filteredTemplates = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTemplates = List.from(_productTemplates);
    _searchController.addListener(_filterTemplates);
  }

  void _filterTemplates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = _productTemplates.where((template) =>
          template['name'].toString().toLowerCase().contains(query)).toList();
    });
  }

  void _selectTemplate(Map<String, dynamic> template) async {
    final purchaseDate = DateTime.now();
    final expirationDate = purchaseDate.add(Duration(days: template['shelfLife']));

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    final productData = {
      'name': template['name'],
      'purchaseDate': dateFormat.format(purchaseDate),
      'manufactureDate': dateFormat.format(purchaseDate),
      'expirationDate': dateFormat.format(expirationDate),
      'quantity': 1,
      'quality': 'годен',
      'availability': 'есть',
      'status': '',
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProduct(
          groupId: widget.groupId,
          product: productData,
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Возвращаемся к ProductList с обновлением
    }
  }

  void _addCustomProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProduct(
          groupId: widget.groupId,
          product: null, // Передаем null для создания нового продукта
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Возвращаемся к ProductList с обновлением
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Выберите продукт',
          style: TextStyle(color: Colors.black), // Черный текст
        ),
        backgroundColor: Colors.white, // Белый фон для AppBar
        elevation: 0, // Убираем тень
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.1), Colors.lightGreen], // Больше белого в градиенте
            begin: Alignment.topCenter, // Начинается сверху
            end: Alignment.bottomCenter, // Идет до низа
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Поиск продукта',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Скругленные углы для поиска
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = _filteredTemplates[index];
                  return ListTile(
                    title: Text(template['name']),
                    subtitle: Text('Срок годности: ${template['shelfLife']} дней'),
                    onTap: () => _selectTemplate(template),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Размещение кнопки по центру снизу
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Установка ширины кнопки в 2 раза больше
        child: ElevatedButton(
          onPressed: _addCustomProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Зеленый цвет кнопки
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Скругленные углы кнопки
            ),
          ),
          child: Text(
            'Добавить',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
