import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MubasharApp());
}

class MubasharApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: MaterialApp(
        title: 'Mubashar 2',
        theme: ThemeData(
          primaryColor: Color(0xFFFF6600),
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orangeAccent),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class Product {
  final String id;
  final String title;
  final String category;
  final String image;
  final double price;
  final String description;
  Product({required this.id, required this.title, required this.category, required this.image, required this.price, required this.description});
}

final sampleProducts = [
  Product(id: 'p1', title: 'Running Shoes', category: 'Shoes', image: 'assets/images/shoes1.png', price: 49.99, description: 'Comfortable running shoes.'),
  Product(id: 'p2', title: 'Casual Shirt', category: 'Clothes', image: 'assets/images/clothes1.png', price: 29.99, description: 'Stylish casual shirt.'),
  Product(id: 'p3', title: 'Phone Case', category: 'Mobile Accessories', image: 'assets/images/acc1.png', price: 9.99, description: 'Durable phone case.'),
  Product(id: 'p4', title: 'Formal Shoes', category: 'Shoes', image: 'assets/images/shoes2.png', price: 59.99, description: 'Elegant formal shoes.'),
  Product(id: 'p5', title: 'Jeans', category: 'Clothes', image: 'assets/images/clothes2.png', price: 39.99, description: 'Comfort-fit jeans.'),
];

class CartModel extends ChangeNotifier {
  final Map<String, int> _items = {};
  Map<String,int> get items => _items;

  void add(Product p) {
    _items[p.id] = (_items[p.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeOne(Product p) {
    if (!_items.containsKey(p.id)) return;
    if (_items[p.id]! > 1) {
      _items[p.id] = _items[p.id]! - 1;
    } else {
      _items.remove(p.id);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double totalPrice() {
    double t = 0;
    _items.forEach((id, qty) {
      final prod = sampleProducts.firstWhere((p) => p.id == id);
      t += prod.price * qty;
    });
    return t;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';

  List<String> categories = ['All', 'Shoes', 'Clothes', 'Mobile Accessories'];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final products = selectedCategory == 'All'
        ? sampleProducts
        : sampleProducts.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mubashar 2'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cart.items.isNotEmpty)
                  Positioned(right:0, child: CircleAvatar(radius:8, child: Text('${cart.items.values.fold<int>(0,(a,b)=>a+b)}', style: TextStyle(fontSize:10)), backgroundColor: Colors.white))
              ],
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage())),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal:12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];
                final selected = c == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = c),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal:8, vertical:10),
                    padding: EdgeInsets.symmetric(horizontal:16),
                    decoration: BoxDecoration(
                      color: selected ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20)
                    ),
                    alignment: Alignment.center,
                    child: Text(c, style: TextStyle(color: selected?Colors.white:Colors.black)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.7, crossAxisSpacing:12, mainAxisSpacing:12),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductPage(product: p))),
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(child: Image.asset(p.image, fit: BoxFit.contain)),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(p.title, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height:4),
                              Text('\$${p.price.toStringAsFixed(2)}'),
                              SizedBox(height:6),
                              ElevatedButton(
                                onPressed: () { cart.add(p); final snack = SnackBar(content: Text('Added to cart')); ScaffoldMessenger.of(context).showSnackBar(snack); },
                                child: Text('Add'),
                                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final Product product;
  ProductPage({required this.product});
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: Column(
        children: [
          Expanded(child: Padding(padding: EdgeInsets.all(12), child: Image.asset(product.image))),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Text(product.title, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                Text(product.description),
                SizedBox(height:12),
                Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize:18)),
                SizedBox(height:12),
                ElevatedButton(
                  onPressed: () { cart.add(product); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart'))); },
                  child: Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,48), primary: Theme.of(context).primaryColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: cart.items.isEmpty ? Center(child: Text('Cart is empty')) : Column(
        children: [
          Expanded(
            child: ListView(
              children: cart.items.entries.map((e) {
                final prod = sampleProducts.firstWhere((p)=>p.id==e.key);
                return ListTile(
                  leading: Image.asset(prod.image),
                  title: Text(prod.title),
                  subtitle: Text('Qty: ${e.value}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.remove), onPressed: () => cart.removeOne(prod)),
                  ]),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Text('Total: \$${cart.totalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize:18)),
                SizedBox(height:8),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage())),
                  child: Text('Checkout'),
                  style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor, minimumSize: Size(double.infinity,48)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String payment = 'Cash on Delivery';
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _name, decoration: InputDecoration(labelText: 'Full name')),
            TextField(controller: _phone, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: _address, decoration: InputDecoration(labelText: 'Delivery address')),
            SizedBox(height:12),
            DropdownButtonFormField<String>(
              value: payment,
              items: ['Cash on Delivery', 'JazzCash'].map((e)=>DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (v)=>setState(()=>payment = v ?? payment),
              decoration: InputDecoration(labelText: 'Payment method'),
            ),
            Spacer(),
            Text('Total: \$${cart.totalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize:18)),
            SizedBox(height:8),
            ElevatedButton(
              onPressed: () {
                // Simple "order placed" mock
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: Text('Order Placed'),
                  content: Text('Thank you! Your order is placed. Payment: $payment'),
                  actions: [TextButton(onPressed: () { Provider.of<CartModel>(context, listen:false).clear(); Navigator.of(context)..pop()..pop(); }, child: Text('OK'))],
                ));
              },
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,48), primary: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
    );
  }
}
