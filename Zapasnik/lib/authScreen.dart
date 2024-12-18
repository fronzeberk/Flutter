import 'package:flutter/material.dart';
import 'authController.dart';
import 'elementGroups.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // true для входа, false для регистрации
  bool _isLoading = false;

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Задний фон с изображением, который занимает всю страницу
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('background.jpg'), // Укажите путь к вашему изображению
                //fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Наложение черного градиента
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8), // черный
                  Colors.transparent, // Переход к прозрачному
                ],
                begin: Alignment.topCenter,
                end: Alignment.center, // Градиент от верхней части к середине
                stops: [0.1, 0.75],
              ),
            ),
          ),
          // Центрируем форму с градиентом
          Column(
            mainAxisAlignment: MainAxisAlignment.end, // Опускаем содержимое вниз
            children: [
              Container(
                width: MediaQuery.of(context).size.width, // Ширина формы 100% от экрана
                height: 550, // Фиксированная высота формы
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white, Colors.lightGreen],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.6, 2.0], // Белого будет больше, чем зелёного
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40.0), // Скругленные углы только сверху
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, -4), // Тень сверху
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        //_isLogin ? 'Вход' : 'Регистрация',
                        'Запасник',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 250), // Ограничение ширины
                          child: TextFormField(
                            controller: _loginController,
                            decoration: InputDecoration(
                              labelText: 'Логин',
                              labelStyle: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 21.0
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.lightGreen, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                              ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, введите логин';
                              }
                              return null;
                            },
                          ),
                      ),
                      SizedBox(height: 16),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 250), // Ограничение ширины
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              labelStyle: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21.0
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.lightGreen, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, введите пароль';
                              }
                              if (!_isLogin && value.length < 6) {
                                return 'Пароль должен быть не менее 6 символов';
                              }
                              return null;
                            },
                          ),
                      ),
                      if (!_isLogin) ...[
                        SizedBox(height: 16),
                        ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 250), // Ограничение ширины
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(color: Colors.lightGreen, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите email';
                                }
                                if (!value.contains('@')) {
                                  return 'Пожалуйста, введите корректный email';
                                }
                                return null;
                                },
                            ),
                        ),
                      ],
                      //Spacer(), // Заполнение пустого пространства
                      const SizedBox(height: 45),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(_isLogin ? 'Вход' : 'Зарегистрироваться'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(160, 38), // Кнопка на всю ширину
                            maximumSize: Size(210, 38),
                            backgroundColor: Colors.lightGreen, // Зеленый цвет кнопки
                            foregroundColor: Colors.white, // белый цвет текста
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Слегка закругленные углы
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54, // Цвет текста серый
                          textStyle: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline, // Подчеркнутый текст
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'Регистрация' : 'Вход',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          // Авторизация
          final user = await AuthController.login(
            _loginController.text,
            _passwordController.text,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => elementGroups(currentUserId: user['id']),
            ),
          );
        } else {
          // Регистрация
          await AuthController.register(
            _loginController.text,
            _passwordController.text,
            _emailController.text,
          );
          // После успешной регистрации показываем сообщение и переключаемся на форму входа
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Регистрация успешна. Пожалуйста, войдите')),
          );
          setState(() {
            _isLogin = true;
            _loginController.clear();
            _passwordController.clear();
            _emailController.clear();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
