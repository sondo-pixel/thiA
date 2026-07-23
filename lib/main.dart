import 'dart:convert';
import 'package:flutter/material.dart';
import 'order.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const OrderScreen(),
    );
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final String rawJson = '[{"Item": "A1000","ItemName": "Iphone 15","Price": 1200,"Currency": "USD","Quantity":1},{"Item": "A1001","ItemName": "Iphone 16","Price": 1500,"Currency": "USD","Quantity":1}]';

  List<Order> allOrders = []; 
  List<Order> displayedOrders = []; 

  final TextEditingController itemController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(text: 'USD');
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData(); 
  }

  void _loadInitialData() {
    final List<dynamic> decodedList = jsonDecode(rawJson);
    setState(() {
      allOrders = decodedList.map((item) => Order.fromJson(item)).toList();
      displayedOrders = List.from(allOrders); 
    });
  }

  void _insertOrder() {
    if (itemController.text.isEmpty || nameController.text.isEmpty || priceController.text.isEmpty || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường dữ liệu!')),
      );
      return;
    }

    final newOrder = Order(
      item: itemController.text,
      itemName: nameController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      currency: currencyController.text,
      quantity: int.tryParse(quantityController.text) ?? 1,
    );

    setState(() {
      allOrders.add(newOrder);
      _searchOrder(searchController.text); 
      
      itemController.clear();
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      currencyController.text = 'USD';
    });
  }

  void _searchOrder(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedOrders = List.from(allOrders);
      } else {
        displayedOrders = allOrders
            .where((order) => order.itemName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildInputField(String label, TextEditingController controller, {double width = 200, bool isNumber = false}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'My Order',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildInputField('Item', itemController, width: 250),
                  _buildInputField('Item Name', nameController, width: 250),
                  _buildInputField('Price', priceController, width: 250, isNumber: true),
                  _buildInputField('Quantity', quantityController, width: 120, isNumber: true),
                  _buildInputField('Currency', currencyController, width: 120),
                ],
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _insertOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC86446),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Add Item to Cart'),
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm theo tên sản phẩm (ItemName)...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchOrder,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(1.5),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFC86446)),
                      children: const [
                        _CellText('Id', isHeader: true),
                        _CellText('Item', isHeader: true),
                        _CellText('Item Name', isHeader: true),
                        _CellText('Quantity', isHeader: true),
                        _CellText('Price', isHeader: true),
                        _CellText('Currency', isHeader: true),
                      ],
                    ),
                    ...displayedOrders.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Order order = entry.value;
                      return TableRow(
                        children: [
                          _CellText('$index'),
                          _CellText(order.item),
                          _CellText(order.itemName),
                          _CellText(order.quantity.toString()),
                          _CellText(order.price.toStringAsFixed(3)), 
                          _CellText(order.currency),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFC86446),
                child: const Text(
                  'Số 8, Tôn Thất Thuyết, Cầu Giấy, Hà Nội',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _CellText(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isHeader ? Colors.white : Colors.black87,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
