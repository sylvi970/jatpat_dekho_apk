import 'package:flutter/material.dart';
import 'package:jatpat_dekho_apk/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'chatpage.dart';
import 'profilepage.dart';
import 'postadspage.dart';

String baseUrl = "http://192.168.0.110:3000";

class Product {
  final String pId;
  final String name;
  final String description;
  final double price;
  var media;
  var mediaType;
  final String productCategory;
  final String productSubCategory;
  final int category;
  bool isFavorite;

  Product({
    required this.pId,
    required this.name,
    required this.description,
    required this.price,
    required this.media,
    required this.mediaType,
    required this.productCategory,
    required this.productSubCategory,
    required this.category,
    this.isFavorite = false,
  });
}

class Category {
  final String categoryName;
  List<dynamic> subCategories;
  Category({
    required this.categoryName,
    required this.subCategories,
  });
}

List<Product> products = [];
List<Category> productCategory = [];

class MainScreen extends StatefulWidget {
  final String jwtToken;
  final LoggedInUser loggedInUser;

  const MainScreen(
      {Key? key, required this.jwtToken, required this.loggedInUser})
      : super(key: key);

  @override
  MainScreen1 createState() => MainScreen1();
}

Future<List<Product>> fetchProducts() async {
  List<String> favoriteProductIds = [];

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var jwtToken = prefs.getString('jwtToken');
  print(jwtToken);

  if(jwtToken != null && jwtToken != ""){
    print("still coming");
  final favoriteResponse = await fetchFavoriteProducts(jwtToken);
  if (favoriteResponse.isNotEmpty) {
    for (var favoriteProduct in favoriteResponse) {
      favoriteProductIds.add(favoriteProduct.pId);
    }
  }
  }
  final url =
      Uri.parse('$baseUrl/api/products'); // Replace with your products API URL
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Product> products = data
          .map((item) => Product(
              pId: item["pId"],
              name: item['name'],
              description: item['description'],
              price: item['price'].toDouble(),
              media:
                  List<String>.from(item['media']), // Convert to List<String>
              mediaType:
                  List<bool>.from(item['mediaType']), // Convert to List<String>
              category: item['category'],
              productCategory: item['productCategory'],
              productSubCategory: '',
              isFavorite:
                  favoriteProductIds.contains(item['pId']) ? true : false))
          .toList();
      return products; // Return the list of products
    } else {
      print('Failed to fetch products: ${response.body}');
      throw Exception('Failed to fetch products');
    }
  } catch (error) {
    print('Error during product fetch: $error');
    throw Exception('Error during product fetch');
  }
}

class MainScreen1 extends State<MainScreen> {
  var padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 5);
  double gap = 10;

  int _index = 0;

  PageController controller = PageController();

  late Future<List<Category>> productCategoryFuture;
  late Future<List<Product>> productsFuture;
  late Future<LoggedInUser> loggedInUserFuture;

  int pageIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    productsFuture = fetchProducts();
    productCategoryFuture = fetchCategories();
    pages = [
      Home(
        loggedInUser: widget.loggedInUser,
        productsFuture: productsFuture,
        jwtToken: widget.jwtToken,
        productCategoryFuture: productCategoryFuture,
      ),
      ChatPageScreen(jwtToken: widget.jwtToken, loggedInUser: widget.loggedInUser),
      PostAds(loggedInUser: widget.loggedInUser, jwtToken: widget.jwtToken),
      ProfileWidget(
          loggedInUser: widget.loggedInUser, jwtToken: widget.jwtToken),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          itemCount: 4,
          controller: controller,
          onPageChanged: (page) {
            setState(() {
              pageIndex = page;
            });
          },
          itemBuilder: (context, position) {
            return Container(
              child: pages[pageIndex],
            );
          }),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  spreadRadius: -10,
                  blurRadius: 60,
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(0, 25),
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: GNav(
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 900),
              tabs: [
                GButton(
                  gap: gap,
                  icon: LineIcons.home,
                  iconColor: Colors.black,
                  iconActiveColor: Colors.purple,
                  text: 'Home',
                  textColor: Colors.purple,
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  iconSize: 24,
                  padding: padding,
                ),
                GButton(
                  gap: gap,
                  icon: LineIcons.facebookMessenger,
                  iconColor: Colors.black,
                  iconActiveColor: Colors.pink,
                  text: 'Chat',
                  textColor: Colors.pink,
                  backgroundColor: Colors.pink.withOpacity(0.2),
                  iconSize: 24,
                  padding: padding,
                ),
                GButton(
                  gap: gap,
                  icon: LineIcons.productHunt,
                  iconColor: Colors.black,
                  iconActiveColor: Colors.blue,
                  text: 'Products',
                  textColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  iconSize: 24,
                  padding: padding,
                ),
                GButton(
                  gap: gap,
                  icon: LineIcons.user,
                  iconColor: Colors.black,
                  iconActiveColor: Colors.teal,
                  text: 'Profile',
                  textColor: Colors.teal,
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  iconSize: 24,
                  padding: padding,
                ),
              ],
              selectedIndex: _index,
              onTabChange: (index) {
                setState(() {
                  _index = index;
                });
                controller.jumpToPage(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Category>> fetchCategories() async {
    final url =
        Uri.parse('$baseUrl/categories'); // Replace with your API endpoint
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Category> categories = responseData.map((item) {
          return Category(
              categoryName: item["category"],
              subCategories: item['subCategories']);
        }).toList();

        return categories;
      } else {
        print('Failed to fetch categories: ${response.body}');
        throw Exception('Failed to fetch categories');
      }
    } catch (error) {
      print('Error during categories fetch: $error');
      throw Exception('Error during categories fetch');
    }
  }
}
