import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Tabak Welt App';

  static Future<bool> loginControl(String email, String password) async {
    // API
    String apiUrl = "https://app.tabak-welt.de/api/v1/login";
    Map<String, String> loginInformation = {
      "email": email,
      "password": password,
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginInformation),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController passwordControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
          Container(
          width: 500,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          child: Image.network(
            'https://www.tabak-welt.de/raucherlounge/wp-content/uploads/2021/09/favicon-tabakwelt.png',
            fit: BoxFit.contain,
            width: 300,
            height: 150,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'TABAK WELT LAGERKONTROL',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12.0),
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: emailControl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Kundenname',
            ),
          ),
        ),
        Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: TextField(
      obscureText: true,
      controller: passwordControl,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Kennwort',
      ),
    ),
        ),
            Container(
              height: 50,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: const Text('Anmeldung'),
                onPressed: () async {
                  String email = emailControl.text;
                  String password = passwordControl.text;

                  bool loginResult = await MyApp.loginControl(email, password);
                  if (loginResult) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Başarılı giriş'),
                      ),
                    );
                    // Başarılı giriş işlemi
                    // İstediğiniz işlemleri burada gerçekleştirebilirsiniz.
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Giriş Başarısız'),
                          content: Text('Kullanıcı adı veya şifre hatalı.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Tamam'),
                            ),
                          ],
                        );
                      },
                    );
                    // Başarısız giriş işlemi
                    // Kullanıcıyı bilgilendirebilirsiniz.
                  }
                },
              ),
            ),
          ],
        ),
    );
  }
}
