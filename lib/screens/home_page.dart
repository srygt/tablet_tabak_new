import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tablet_tabak/main.dart';
import 'package:tablet_tabak/theme/colors/light_colors.dart';
import 'package:http/http.dart' as http;

class Order {
  final int id;
  final String productId;
  final int quantity;
  final String orderDate;
  final String deliveryStatusName;
  final String? deliveryDate;
  final int userId;
  final String? remark;
  final int supplierId;
  final String? ordered;
  final int status;
  final int? weight;
  final String price;
  final String createdAt;
  final String updatedAt;
  final String productName;
  final String productNumber;

  Order({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.orderDate,
    required this.deliveryStatusName,
    this.deliveryDate,
    required this.userId,
    this.remark,
    required this.supplierId,
    this.ordered,
    required this.status,
    this.weight,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.productName,
    required this.productNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      orderDate: json['order_date'],
      deliveryStatusName: json['name'],
      deliveryDate: json['delivery_date'],
      userId: json['user_id'],
      remark: json['remark'],
      supplierId: json['supplier_id'],
      ordered: json['ordered'],
      status: json['status'],
      weight: json['weight'],
      price: json['price'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      productNumber: json['product_number'],
      productName: json['product_name'],
    );
  }
}

class OrderDataTable extends StatefulWidget {
  final List<Order> orders;

  const OrderDataTable({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  _OrderDataTableState createState() => _OrderDataTableState();
}

class _OrderDataTableState extends State<OrderDataTable> {
  List<bool> selected = [];
  late List<TextEditingController> quantityControllers;
  late List<TextEditingController> remarkControllers;
  late TextEditingController searchController;
  List<Order> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    selected = List<bool>.generate(widget.orders.length, (index) => false);
    quantityControllers = List.generate(
      widget.orders.length,
          (index) => TextEditingController(text: widget.orders[index].quantity.toString()),
    );
    remarkControllers = List.generate(
      widget.orders.length,
          (index) => TextEditingController(text: widget.orders[index].remark ?? ''),
    );
    searchController = TextEditingController();
    filteredOrders = widget.orders;
  }
  @override
  void dispose() {
    for (final controller in quantityControllers) {
      controller.dispose();
    }
    for (final controller in remarkControllers) {
      controller.dispose();
    }
    searchController.dispose();
    super.dispose();
  }
  void filterOrders(String query) {
    setState(() {
      filteredOrders = widget.orders.where((order) {
        final productNameLower = order.productName.toLowerCase();
        final productNumberLower = order.productNumber.toLowerCase();
        final queryLower = query.toLowerCase();

        return productNameLower.contains(queryLower) || productNumberLower.contains(queryLower);
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    Padding(padding: EdgeInsets.all(25.0));
    return Column(
        children: [
          Padding(padding: const EdgeInsets.only(top:10.0),
            child: Text('Bestellliste',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Suchen...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterOrders,
            ),
          ),
          DataTable(
            columns: const <DataColumn>[

              DataColumn(
                label: Text('Produktname'),
              ),
              DataColumn(
                label: Text('Gewicht'),
              ),
              DataColumn(
                label: Text('Preise'),
              ),
              DataColumn(
                label: Text('Produktnummer'),
              ),
              DataColumn(
                label: Text('Anzahl'),
              ),
              DataColumn(
                label: Text('Bemerkung'),
              ),
              DataColumn(
                label: Text('Bestelldatum'),
              ),
              DataColumn(
                label: Text('Lieferstatus'),
              )
            ],
            rows: List<DataRow>.generate(
              filteredOrders.length,
                  (index) => DataRow(

                cells: <DataCell>[
                  DataCell(Text(filteredOrders[index].productName)),
                  DataCell(Text(widget.orders[index].weight.toString())),
                  DataCell(Text(widget.orders[index].price)),
                  DataCell(Text(filteredOrders[index].productNumber)),
                  DataCell(
                    TextField(
                      controller: quantityControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Geben Sie die Menge ein', // Placeholder text
                        border: OutlineInputBorder( // Define the border
                          borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          borderSide: BorderSide( // Define the border color and width
                            color: Colors.blue, // Customize the border color
                            width: 2.0, // Customize the border width
                          ),
                        ),
                      ),
                      onChanged: (newValue) {
                        //widget.orders[index].quantity = int.parse(newValue);
                      },
                    ),
                  ),
                  DataCell(
                    TextField(
                      controller: remarkControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Beschreibung eingeben', // Placeholder text
                        border: OutlineInputBorder( // Define the border
                          borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                          borderSide: BorderSide( // Define the border color and width
                            color: Colors.blue, // Customize the border color
                            width: 2.0, // Customize the border width
                          ),
                        ),
                      ),
                      onChanged: (newValue) {
                        // Handle the updated remark value here
                        // You can access it using newValue
                      },
                    ),
                  ),
                  DataCell(Text(widget.orders[index].orderDate)),
                  DataCell(Text(widget.orders[index].deliveryStatusName)),
                ],
                selected: selected[index],
                onSelectChanged: (bool? value) {
                  setState(() {
                    selected[index] = value!;
                  });
                },
              ),
            ),
          ),
        ],
    );
  }

}
class HomePage extends StatelessWidget {
  Future<List<Order>> fetchOrders() async {
    String? authToken = TokenHolder.authToken;
    final String apiUrl = 'https://app.tabak-welt.de/api/v1/order/list';
    final String token = authToken ?? '19|eZVE9k5EdWxqsf74GDX0EnihU1vznUaiNPmK0emw'; // Bearer tokeni buraya ekleyin

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch orders');
    }
  }
  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  static CircleAvatar calendarIcon() {
    return CircleAvatar(
      radius: 25.0,
      backgroundColor: LightColors.kGreen,
      child: Icon(
        Icons.calendar_today,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Row(
          children: [
            Image.network('https://www.tabak-welt.de/raucherlounge/wp-content/uploads/2021/09/favicon-tabakwelt.png',
              fit: BoxFit.contain,
              width: 100,
              height: 50,),
            IconButton(
                icon: Icon(Icons.logout),
              onPressed: (){
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (route) => false,);
              },
            ),
            Image.network('https://cdn-icons-png.flaticon.com/512/5987/5987420.png',
              fit: BoxFit.contain,
              width: 75,
              height: 40,),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Armaturenbrett'),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Bestellliste'),
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Warebestellung'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Einstellungen'),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Helfen'),
            ),
            ListTile(
              leading: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp()), (route) => false,);
                  },
              ),
              title: Text('Ausloggen'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                child: Container(
                                  width: 200,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.teal,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(50))
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_road, color: Colors.white, size: 30),
                                      Text(' Lagereintrag',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  // Başka bir sayfaya yönlendir.
                                },
                              ),
                              InkWell(
                                child: Container(
                                  width: 200,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(50))
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_box, color: Colors.white, size: 30),
                                      Text(' Produkte',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  // Başka bir sayfaya yönlendir.
                                },
                              ),
                              InkWell(
                                child: Container(
                                  width: 200,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade900,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(50))
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_alert, color: Colors.white, size: 30),
                                      Text(' Kritisches Inventar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  // Başka bir sayfaya yönlendir.
                                },
                              ),
                              InkWell(
                                child: Container(
                                  width: 200,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.brown,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(50))
                                  ),
                                  padding: EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.crisis_alert_outlined, color: Colors.white, size: 30),
                                      Text(' Bestandsausgabe',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  // Başka bir sayfaya yönlendir.
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 15.0),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(20.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            FutureBuilder<List<Order>>(
                              future: fetchOrders(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Veriler alınamadı: ${snapshot.error.toString()}');
                                } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
                                  return Text('Hiç sipariş bulunamadı.');
                                } else {
                                  return OrderDataTable(orders: snapshot.data!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
