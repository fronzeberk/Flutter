import 'package:flutter/material.dart';
import 'serverDataControl.dart';
import 'addEditProduct.dart';
import 'productTemplateList.dart'; // Добавляем импорт нового экрана

class ProductList extends StatefulWidget {
  final int groupId;
  final String groupName;

  ProductList({required this.groupId, required this.groupName});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await ServerDataControl.getProducts(widget.groupId);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Применяем градиент с больше белого
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.1), Colors.lightGreen], // Больше белого в градиенте
            begin: Alignment.topCenter, // Начинается сверху
            end: Alignment.bottomCenter, // Идет до низа
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white, // Белый фон для AppBar
              elevation: 0, // Убираем тень под AppBar
              title: Text(
                widget.groupName,
                style: TextStyle(color: Colors.black), // Черный текст в AppBar
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text(product['name'] ?? 'Без названия'),
                    subtitle: Text('Годен до: ${product['expirationDate'] ?? 'Не указано'} '),
                    trailing: Text(product['status'] ?? ''),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditProduct(
                            groupId: widget.groupId,
                            product: product,
                          ),
                        ),
                      );
                      if (result != null) {
                        _fetchProducts();
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 30.0), // Отступ слева
              child: ElevatedButton(
                onPressed: () async {
                  // Изменяем нажатие кнопки для открытия списка шаблонов
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductTemplateList(groupId: widget.groupId),
                    ),
                  );
                  if (result != null) {
                    _fetchProducts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Зеленый цвет
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Скругленные углы
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15), // Увеличение высоты
                  minimumSize: Size(MediaQuery.of(context).size.width / 2 - 40, 0), // Уменьшаем ширину в 2 раза
                ),
                child: Text(
                  'Добавить', // Текст кнопки
                  style: TextStyle(
                    color: Colors.white, // Белые буквы
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
