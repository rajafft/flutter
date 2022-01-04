import 'package:wean_app/models/yardItemModel.dart';

class DummyViews{
  static void addProduct(){
    items.add(YardItemModel(title: "Nestle Coffee", description: "Aromatic coffee from african coffee beans.", createdDate: DateTime.parse('2021-01-01 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-01 00:00:00.000'), sellerName: "Ark Enterprises", sellerAddress: "North view, Atlantis Street, SA", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/61CQMq2GP2L._SL1000_.jpg"));

    items.add(YardItemModel(title: "Nestea", description: "Amazing tea experience from India.", createdDate: DateTime.parse('2021-01-15 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-15 00:00:00.000'), sellerName: "Ark Enterprises", sellerAddress: "North view, Atlantis Street, SA", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/81F-OAW9atL._SL1500_.jpg"));

    items.add(YardItemModel(title: "Coconut Milk Tea", description: "Finest quality coconuts sourced directly from Southern India", createdDate: DateTime.parse('2021-01-16 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-16 00:00:00.000'), sellerName: "Urban Platter", sellerAddress: "West Street, Bengaluru, KA"));

    items.add(YardItemModel(title: "Happilo 100% Natural Premium Californian Almonds", description: "High protein, dietary fiber, no gluten, no GMO, zero trans fat, zero cholesterol", createdDate: DateTime.parse('2021-01-17 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-17 00:00:00.000'), sellerName: "Cloudtail", sellerAddress: "Alaska streets, west kolkatta", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/71h3rvTqyGS._SL1500_.jpg"));

    items.add(YardItemModel(title: "Kellogg's Corn Flakes Original", description: "Kellogg's Corn Flakes is a nourishing and tasty ready-to-eat breakfast cereal which is High in Iron, Vitamin C and key essential B group Vitamins such as B1, B2, B3, B6, B12 and Folate.", createdDate: DateTime.parse('2021-01-19 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-19 00:00:00.000'), sellerName: "Kettle bros", sellerAddress: "Pearl kentra, Cochin", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/71HsQr-pYjL._SL1500_.jpg"));

    items.add(YardItemModel(title: "Aashirvaad Salt,with 4-Step Advantage, 1kg", description: "Aashirvaad Iodised Salt is made with the 4-step advantage process which ensures its good quality.", createdDate: DateTime.parse('2021-01-20 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-20 00:00:00.000'), sellerName: "Unique Enterprises", sellerAddress: "Gem view, East Mumbai, MH, IN"));

    items.add(YardItemModel(title: "Britannia NutriChoice Digestive High Fibre Biscuits", description: "Goodness of Wheat: Healthy digestive biscuit with rich blend of wheat (atta) flour and wheat bran", createdDate: DateTime.parse('2021-01-21 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-21 00:00:00.000'), sellerName: "Unique Enterprises", sellerAddress: "Gem view, East Mumbai, MH, IN", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/71EeR2OoVsL._SL1500_.jpg"));

    items.add(YardItemModel(title: "Dark Fantasy Choco Fills", description: "An exquisite combination of luscious chocolate filling enrobed within a perfectly baked rich cookie outer", createdDate: DateTime.parse('2021-01-21 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-21 00:00:00.000'), sellerName: "Magic pantry", sellerAddress: "North agra street, Delhi", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/81rt1QmhZIL._SL1500_.jpg"));

    items.add(YardItemModel(title: "HyperDrive 3 in 1 USB C hub for MacBook Pro/Air", description: "USB C with Power Delivery : Latest 3.1 Gen 1 USB C port with 5Gbps speed and pass through charging", createdDate: DateTime.parse('2021-01-22 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-22 00:00:00.000'), sellerName: "Hyper Store", sellerAddress: "Ellena Tech hub, CA", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/61gcxxRphJL._SL1500_.jpg"));

    items.add(YardItemModel(title: "Mi 10i 5G (Atlantic Blue, 6GB RAM, 128GB Storage)", description: "Camera: 108 MP Quad Rear camera with Ultra-wide and Macro mode.", createdDate: DateTime.parse('2021-01-22 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-22 00:00:00.000'), sellerName: "Gee stores", sellerAddress: "yin street, Shanghai", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/71w4n2itCNL._SL1500_.jpg"));

    items.add(YardItemModel(title: "Seagate One Touch 1TB External HDD with Password Protection – Silver", description: "Aromatic Coffee", createdDate: DateTime.parse('2021-01-23 00:00:00.000'), lastUpdated: DateTime.parse('2021-01-23 00:00:00.000'), sellerName: "Seagate stores", sellerAddress: "Amenda street, Wales, EN", imageUrl: "https://images-na.ssl-images-amazon.com/images/I/712JlOmkwUL._SL1500_.jpg"));
    // print("iLength ${items.length}");
  }
  static const List<YardItemModel> items = [];
}