import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tablet_tabak/model.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  List<Map> _books = [
    {
      'id': 100,
      'title': ' Winston Blue 17,00 €',
      'price' : '59,95 €',
      'marken': 'Winston'
    },
    {
      'id': 101,
      'title': ' Break Original 4 x 215g mit 2000 King Size Filterhülsen ',
      'price' : '19,95 €* ',
      'marken': 'Brake'
    },
    {
      'id': 102,
      'title': 'TEREA Probierset',
      'price' : '39,95 €',
      'marken': 'Iqos'
    },
    {
      'id': 103,
      'title': 'IQOS ORIGINALS DUO Slate + gratis HEETS ',
      'price' : '49,95 €',
      'marken': 'Iqos'
    },
    {
      'id': 104,
      'title': 'IQOS ORIGINALS DUO Silver + gratis HEETS',
      'price' : '29,95 €',
      'marken': 'Iqos'
    },
  ];
  bool? _isEditMode = false;
   final url = Uri.parse('https://dummyjson.com/products');
   int counter;
   var productResult;

   Future callProduct() async{
     try{
      final response = await http.get(url);
      if(response.statusCode==200){
        var result = productFromJson(response.body);
        if(mounted)
          setState(() {
            counter = result.products.length;
          });
      }else{
        print(response.statusCode);
      }
     }catch(e){
       print(e.toString());
     }
   }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tabak Welt Produkte'),
        ),
        body: ListView(
          children: [
            _createDataTable(),
            _createCheckboxField()
          ],
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: (){
        callProduct();
        },
      ),

      ),
    );
  }
  DataTable _createDataTable() {
    return DataTable(columns: _createColumns(), rows: _createRows());
  }
  List<DataColumn> _createColumns() {
    return [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Produkte')),
      DataColumn(label: Text('Price')),
      DataColumn(label: Text('Marken'))
    ];
  }
  List<DataRow> _createRows() {
    return _books
        .map((book) => DataRow(cells: [
      DataCell(Text('#' + book['id'].toString())),
      _createTitleCell(book['title']),
      _createTitleCell(book['price']),
      DataCell(Text(book['marken']))
    ]))
        .toList();
  }
  DataCell _createTitleCell(bookTitle) {
    return DataCell(_isEditMode == true ?
    TextFormField(initialValue: bookTitle,
        style: TextStyle(fontSize: 16))
        : Text(bookTitle));
  }
  Row _createCheckboxField() {
    return Row(
      children: [
        Checkbox(
          value: _isEditMode,
          onChanged: (value) {
            setState(() {
              _isEditMode = value;
            });
          },
        ),
        Text('Bearbeiten'),
      ],
    );
  }
}