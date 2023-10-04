import 'package:flutter/material.dart';
import 'package:jatpat_dekho_apk/profilepage.dart';
import 'btm.dart';
import 'package:jatpat_dekho_apk/main.dart';
import './search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatpage.dart';

class Home extends StatefulWidget {
  final Future<List<Product>> productsFuture;
  static const int defaultColumnCount = 3;
  final loggedInUser;
  final String jwtToken;

  const Home({
    Key? key,
    required this.loggedInUser,
    required this.productsFuture,
    required this.jwtToken,
  }) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<Home> {
  List<Product> favoriteProducts = [];
  bool isFavorite = false;
  bool addedToFavorites = false;
  List<Category> productCategory = [];
  List<String> productCategoryNames = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Call the API to fetch category names
    fetchCategories();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Implement your initial data fetching logic here, for example, fetch products
      final products = await widget.productsFuture;
      setState(() {
        // Update the state with the fetched products
        // You might need to update other properties too
        // For example: productCategory, productCategoryNames, etc.
      });
    } catch (error) {
      // Handle errors if needed
      print('Error fetching initial data: $error');
    }
  }

  Future<void> _handleRefresh() async {
    try {
      // Implement your refresh logic here, for example, fetch new data
      final newProducts = await widget.productsFuture;
      setState(() {
        // Update your product list with the new data
        products = newProducts;
        // You might need to update other properties too
        // For example: productCategory, productCategoryNames, etc.
      });
    } catch (error) {
      // Handle errors if needed
      print('Error during refresh: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 10).floor();
    if (crossAxisCount < 1) crossAxisCount = 1;
    String name = "JatPat Dekho";
    if (widget.loggedInUser.email != null) {
      List<String> names = "${widget.loggedInUser.name}".split(' ');
      name = "Welcome ${names[0]} ";
    }
    print(widget.loggedInUser.photo);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchResults(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                if (widget.loggedInUser.email == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                  return;
                }
                // Make the API request when the icon is pressed
                fetchFavoriteProducts(widget.jwtToken).then((favoriteProducts) {
                  // Navigate to the Favorite screen and pass the favoriteProducts data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Favorite(
                          favoriteProducts: favoriteProducts,
                          jwtToken: widget.jwtToken),
                    ),
                  );
                }).catchError((error) {
                  // Handle any errors that occur during the API request
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('Error: $error'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          key:
              _refreshIndicatorKey, // Attach the GlobalKey to the RefreshIndicator
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(productCategory.length, (index) {
                    print(productCategory[index].categoryName);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductCategoryPage(
                              productCategoryName:
                                  productCategory[index].categoryName,
                              productFuture: widget.productsFuture,
                              loggedInUser: widget.loggedInUser,
                              jwtToken: widget.jwtToken,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 70,
                          ),
                          Text(
                            productCategoryNames[index],
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (index) {
                    List<String> categoryNames = [
                      'B2B',
                      'B2C',
                      'C2C',
                      'Category D',
                      'Category E',
                    ];
                    List<String> categoryImages = [
                      'public/images/B2B.png',
                      'public/images/B2C.jpg',
                      'public/images/C2C.png',
                      'public/images/B2B.png',
                      'public/images/B2C.jpg',
                    ];

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the CategoryPage with the selected category name
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPage(
                              categoryName: categoryNames[index],
                              loggedInUser: widget.loggedInUser,
                              jwtToken: widget.jwtToken,
                              product: products,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 70,
                        height: 70,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              categoryImages[
                                  index], // Use the image for the current category
                              width: 35,
                              height: 35,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryNames[index],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FutureBuilder<List<Product>>(
                      future: widget.productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading products."));
                        } else {
                          products = snapshot.data!;
                          String category;

                          return products.isNotEmpty
                              ? GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: constraints.maxWidth ~/ 200,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 2,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    if (product.category == 1) {
                                      category = "B2B";
                                    } else if (product.category == 2) {
                                      category = "B2C";
                                    } else if (product.category == 3) {
                                      category = "C2C";
                                    } else if (product.category == 4) {
                                      category = "Category 4";
                                    } else {
                                      category = "category 5";
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDescriptionPage(
                                              product: product,
                                              onFavoriteChanged: (isFavorite) {
                                                setState(() {
                                                  if (isFavorite) {
                                                    favoriteProducts
                                                        .add(product);
                                                  } else {
                                                    favoriteProducts
                                                        .remove(product);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(5.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0),
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.network(
                                                      '$baseUrl/${product.media[0].substring(15)}',
                                                      height: constraints
                                                              .maxHeight *
                                                          0.19,
                                                          width: constraints.maxWidth,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color:
                                                            product.isFavorite
                                                                ? Colors.red
                                                                : Colors.grey,
                                                      ),
                                                      onPressed: () async {
                                                        print(widget
                                                            .loggedInUser
                                                            .email);
                                                        if (widget.loggedInUser
                                                                .email ==
                                                            null) {
                                                          print("success");
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please login to add to favorites.'),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        } else {
                                                          bool isFavorite =
                                                              await _toggleFavorite(
                                                                  product,
                                                                  widget
                                                                      .jwtToken);
                                                          print(isFavorite);
                                                        }

                                                        setState(() {
                                                          if (isFavorite ==
                                                              true) {
                                                            favoriteProducts
                                                                .add(product);
                                                          } else {
                                                            favoriteProducts
                                                                .remove(
                                                                    product);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: ListTile(
                                                    title: Text(
                                                      category,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product
                                                              .name, // Replace with actual category
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        Text(
                                                          '₹ ${product.price.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFFfbb02c),
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text('No products available.'),
                                );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.black),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileWidget(
                                loggedInUser: widget
                                    .loggedInUser,
                                    jwtToken:widget.jwtToken ,
                                    ), // Replace with your profile screen widget
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: widget.loggedInUser.photo != null
                                ? Image.network(
                                    '$baseUrl/${widget.loggedInUser.photo}')
                                : Image.asset(
                                    'public/images/user.jpg', // Replace with the path to your asset image
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.loggedInUser.name == "" ||
                              widget.loggedInUser.name == null
                          ? "Hello User"
                          : widget.loggedInUser.name,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      fetchMyProducts(widget.jwtToken).then((myProducts) {
                        // Navigate to the Favorite screen and pass the favoriteProducts data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProductsPage(
                              myProducts: myProducts,
                            ),
                          ),
                        );
                      }).catchError((error) {
                        // Handle any errors that occur during the API request
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text('Error: $error'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    },
                    child: const ListTile(
                      title: Text("My Products"),
                      leading: Icon(Icons.badge),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const ListTile(
                      title: Text("Notifications"),
                      leading: Icon(Icons.notification_add),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const ListTile(
                      title: Text("Privacy Policy"),
                      leading: Icon(Icons.privacy_tip),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const ListTile(
                      title: Text("Settings"),
                      leading: Icon(Icons.privacy_tip),
                    ),
                  ),
                ],
              ),
            ],
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
        // print(responseData);
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

Future<List<Product>> fetchFavoriteProducts(jwtToken) async {
  List<Product> favoriteProducts = [];
  if (jwtToken == "") {
    return favoriteProducts = [];
  }
  final url =
      Uri.parse('$baseUrl/api/getFavorites'); // Replace with your API endpoint
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': jwtToken, // Assuming it's a Bearer token
        // Add other headers if needed
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check if the response contains 'favoriteProductIds'
      if (responseData.containsKey('favoriteProductIds')) {
        final List<dynamic> favoriteProductIds =
            responseData['favoriteProductIds'];

        // Fetch detailed product information based on product IDs
        for (var productId in favoriteProductIds) {
          final productResponse = await http.get(
            Uri.parse(
                '$baseUrl/api/products/$productId'), // Replace with the API endpoint to fetch product details by ID
          );

          if (productResponse.statusCode == 200) {
            final Map<String, dynamic> productData =
                json.decode(productResponse.body);

            final Product product = Product(
              pId: productData['pId'],
              name: productData['name'],
              description: productData['description'],
              price: productData['price'].toDouble(),
              media: List<String>.from(productData['media']),
              mediaType: List<bool>.from(productData['mediaType']),
              category: productData['category'],
              productCategory: productData['productCategory'],
              productSubCategory: productData['productSubCategory'] ?? '',
            );

            favoriteProducts.add(product);
          }
        }

        return favoriteProducts;
      } else {
        throw Exception('Response data does not contain favoriteProductIds');
      }
    } else {
      print('Failed to fetch favorite products: ${response.body}');
      throw Exception('Please login again');
    }
  } catch (error) {
    print('Error during favorite products fetch: $error');
    throw Exception('Error during favorite products fetch');
  }
}

Future<bool> _toggleFavorite(Product product, String token) async {
  bool isFavorite = product.isFavorite;
  try {
    // Simulate an API call

    final addToFavoritesUrl =
        Uri.parse('$baseUrl/api/addToFavorites/${product.pId}');
    final removeFromFavoritesUrl =
        Uri.parse('$baseUrl/api/removeFromFavorites/${product.pId}');

    // If you want to make an HTTP request to update the server, use http package
    // Replace this with your actual API endpoints and headers

    await http.post(
      isFavorite ? removeFromFavoritesUrl : addToFavoritesUrl,
      headers: {
        'Authorization': token,
        'Accept': 'application/json',
      },
    );

    product.isFavorite = !isFavorite;

    return !isFavorite;

    // Handle the response and errors accordingly
  } catch (error) {
    print('Error toggling favorite: $error');
    return isFavorite;
  }
}

class CategoryPage extends StatefulWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;
  final String categoryName;
  final List<Product> product;

  const CategoryPage(
      {super.key,
      required this.loggedInUser,
      required this.categoryName,
      required this.jwtToken,
      required this.product});

  @override
  _CategoryPage createState() => _CategoryPage();
}

class _CategoryPage extends State<CategoryPage> {
  List<Product> favoriteProducts = [];
  bool isFavorite = false;
  bool addedToFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
        ),
        body: widget.product.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 2,
                ),
                itemCount: widget.product.length,
                itemBuilder: (context, index) {
                  String category;
                  final product = widget.product[index];
                  if (product.category == 1) {
                    category = "B2B";
                  } else if (product.category == 2) {
                    category = "B2C";
                  } else if (product.category == 3) {
                    category = "C2C";
                  } else if (product.category == 4) {
                    category = "Category 4";
                  } else {
                    category = "category 5";
                  }

                  if (category.trim() == widget.categoryName.trim()) {
                    print("Hello entered if");
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDescriptionPage(
                              product: product,
                              onFavoriteChanged: (isFavorite) {
                                setState(() {
                                  if (isFavorite) {
                                    favoriteProducts.add(product);
                                  } else {
                                    favoriteProducts.remove(product);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Image.network(
                                      '$baseUrl/${product.media[0].substring(15)}',
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: product.isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        print(widget.loggedInUser.email);
                                        if (widget.loggedInUser.email == null) {
                                          print("success");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Please login to add to favorites.'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          bool isFavorite =
                                              await _toggleFavorite(
                                                  product, widget.jwtToken);
                                          print(isFavorite);
                                        }

                                        setState(() {
                                          if (isFavorite == true) {
                                            favoriteProducts.add(product);
                                          } else {
                                            favoriteProducts.remove(product);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: ListTile(
                                    title: Text(
                                      category,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product
                                              .name, // Replace with actual category
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        Text(
                                          '₹ ${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFFfbb02c),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              )
            : const Center(
                child: Text('No products available.'),
              ));
  }
}

class ProductCategoryPage extends StatefulWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;
  final String productCategoryName;
  final Future<List<Product>> productFuture;

  const ProductCategoryPage(
      {super.key,
      required this.loggedInUser,
      required this.productCategoryName,
      required this.jwtToken,
      required this.productFuture});

  @override
  _ProductCategoryPage createState() => _ProductCategoryPage();
}

class _ProductCategoryPage extends State<ProductCategoryPage> {
  List<Product> favoriteProducts = [];
  bool isFavorite = false;
  bool addedToFavorites = false;
  List<Category> productCategory = [];
  List<String> productCategoryNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productCategoryName),
      ),
      // body: Expanded(
      //   child: LayoutBuilder(
      //     builder: (context, constraints) {
      //       return FutureBuilder<List<Product>>(
      //         future: widget.productFuture,
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Center(child: CircularProgressIndicator());
      //           } else if (snapshot.hasError) {
      //             return const Center(child: Text("Error loading products."));
      //           } else {
      //             final products = snapshot.data!;
      //             String category;
      //             print("heena");

      //             return products.isNotEmpty
      //                 ? GridView.builder(
      //                     gridDelegate:
      //                         SliverGridDelegateWithFixedCrossAxisCount(
      //                       crossAxisCount: constraints.maxWidth ~/ 200,
      //                       crossAxisSpacing: 1,
      //                       mainAxisSpacing: 2,
      //                     ),
      //                     itemCount: products.length,
      //                     itemBuilder: (context, index) {
      //                       final product = products[index];
      //                       if (product.category == 1) {
      //                         category = "B2B";
      //                       } else if (product.category == 2) {
      //                         category = "B2C";
      //                       } else if (product.category == 3) {
      //                         category = "C2C";
      //                       } else if (product.category == 4) {
      //                         category = "Category 4";
      //                       } else {
      //                         category = "category 5";
      //                       }

      //                       if (category == widget.productCategoryName) {
      //                         return GestureDetector(
      //                           onTap: () {
      //                             Navigator.push(
      //                               context,
      //                               MaterialPageRoute(
      //                                 builder: (context) =>
      //                                     ProductDescriptionPage(
      //                                   product: product,
      //                                   onFavoriteChanged: (isFavorite) {
      //                                     setState(() {
      //                                       if (isFavorite) {
      //                                         favoriteProducts.add(product);
      //                                       } else {
      //                                         favoriteProducts.remove(product);
      //                                       }
      //                                     });
      //                                   },
      //                                 ),
      //                               ),
      //                             );
      //                           },
      //                           child: Container(
      //                             margin: const EdgeInsets.all(5.0),
      //                             child: Card(
      //                               shape: RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(8.0),
      //                               ),
      //                               child: Column(
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.stretch,
      //                                 children: <Widget>[
      //                                   ClipRRect(
      //                                     borderRadius: const BorderRadius.only(
      //                                       topLeft: Radius.circular(8.0),
      //                                       topRight: Radius.circular(8.0),
      //                                     ),
      //                                     child: Stack(
      //                                       alignment: Alignment.topRight,
      //                                       children: [
      //                                         Image.network(
      //                                           '$baseUrl/${product.media[0].substring(15)}',
      //                                           height:
      //                                               constraints.maxHeight * 0.2,
      //                                           fit: BoxFit.cover,
      //                                         ),
      //                                         IconButton(
      //                                           icon: Icon(
      //                                             Icons.favorite,
      //                                             color: product.isFavorite
      //                                                 ? Colors.red
      //                                                 : Colors.grey,
      //                                           ),
      //                                           onPressed: () async {
      //                                             print(widget
      //                                                 .loggedInUser.email);
      //                                             if (widget
      //                                                     .loggedInUser.email ==
      //                                                 null) {
      //                                               print("success");
      //                                               ScaffoldMessenger.of(
      //                                                       context)
      //                                                   .showSnackBar(
      //                                                 const SnackBar(
      //                                                   content: Text(
      //                                                       'Please login to add to favorites.'),
      //                                                   duration: Duration(
      //                                                       seconds: 2),
      //                                                 ),
      //                                               );
      //                                             } else {
      //                                               bool isFavorite =
      //                                                   await _toggleFavorite(
      //                                                       product,
      //                                                       widget.jwtToken);
      //                                               print(isFavorite);
      //                                             }

      //                                             setState(() {
      //                                               if (isFavorite == true) {
      //                                                 favoriteProducts
      //                                                     .add(product);
      //                                               } else {
      //                                                 favoriteProducts
      //                                                     .remove(product);
      //                                               }
      //                                             });
      //                                           },
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                   Expanded(
      //                                     child: Align(
      //                                       alignment: Alignment.bottomLeft,
      //                                       child: ListTile(
      //                                         title: Text(
      //                                           category,
      //                                           style: const TextStyle(
      //                                               fontSize: 10,
      //                                               color: Colors.grey),
      //                                         ),
      //                                         subtitle: Column(
      //                                           crossAxisAlignment:
      //                                               CrossAxisAlignment.start,
      //                                           children: [
      //                                             Text(
      //                                               product
      //                                                   .name, // Replace with actual category
      //                                               style: const TextStyle(
      //                                                   color: Colors.black),
      //                                             ),
      //                                             Text(
      //                                               '₹ ${product.price.toStringAsFixed(2)}',
      //                                               style: const TextStyle(
      //                                                 color: Color(0xFFfbb02c),
      //                                                 fontSize: 13,
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                         );
      //                       }
      //                     },
      //                   )
      //                 : const Center(
      //                     child: Text('No products available.'),
      //                   );
      //           }
      //         },
      //       );
      //     },
      //   ),
      // ),
      body: const Text('No products available'),
    );
  }
}

class ProductDescriptionPage extends StatelessWidget {
  final Product product;
  final Function(bool isFavorite) onFavoriteChanged;

  const ProductDescriptionPage({
    Key? key,
    required this.product,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(product.media[1]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Description'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200, // Set the height of the photo slideshow container
              child: PageView.builder(
                itemCount: product.media.length,
                itemBuilder: (context, index) {
                  // Build each image in the slideshow
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      '$baseUrl/${product.media[index].substring(15)}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Price: ₹${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              icon: const Icon(Icons.chat), // You can change the icon as needed
              label: const Text("Chat with Seller"),
            ),
          ],
        ),
      ),
    );
  }
}

class Favorite extends StatefulWidget {
  final List<Product> favoriteProducts;
  final String jwtToken;

  const Favorite(
      {Key? key, required this.favoriteProducts, required this.jwtToken})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Favorite createState() => _Favorite();
}

class _Favorite extends State<Favorite> {
  // Set<int> favoritedProducts = Set<int>();
  bool isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          if (widget.favoriteProducts.isEmpty) {
            return const Center(
              child: Text(
                "No Favorite Products",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 200,
              crossAxisSpacing: 1,
              mainAxisSpacing: 2,
            ),
            itemCount: widget.favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = widget.favoriteProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDescriptionPage(
                        product: product,
                        onFavoriteChanged: (isFavorite) {},
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.network(
                                '$baseUrl/${product.media[0].substring(15)}',
                                height: constraints.maxHeight * 0.15,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await _toggleFavorite(
                                      product, widget.jwtToken);
                                  widget.favoriteProducts.remove(product);
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: ListTile(
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                              subtitle: Text(
                                '₹ ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFfbb02c),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100,
        width: 100,
        color: const Color(0xFF000000),
      ),
    );
  }
}

class MyProductsPage extends StatefulWidget {
  final List<Product> myProducts;
  const MyProductsPage({super.key, required this.myProducts});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Products'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          if (widget.myProducts.isEmpty) {
            return const Center(
              child: Text(
                "No Products Found",
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 200,
              crossAxisSpacing: 1,
              mainAxisSpacing: 2,
            ),
            itemCount: widget.myProducts.length,
            itemBuilder: (context, index) {
              final product = widget.myProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDescriptionPage(
                        product: product,
                        onFavoriteChanged: (isFavorite) {},
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.network(
                                '$baseUrl/${product.media[0].substring(15)}',
                                height: constraints.maxHeight * 0.15,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: ListTile(
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                              subtitle: Text(
                                '₹ ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFfbb02c),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}

Future<List<Product>> fetchMyProducts(jwtToken) async {
  List<Product> myProducts = [];
  if (jwtToken == "") {
    return myProducts = [];
  }
  final url =
      Uri.parse('$baseUrl/api/myProducts'); // Replace with your API endpoint
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': jwtToken, // Assuming it's a Bearer token
        // Add other headers if needed
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // var productData = responseData['products'];
      responseData.forEach((product) {
        final Product myProduct = Product(
          pId: product['pId'],
          name: product['name'],
          description: product['description'],
          price: product['price'].toDouble(),
          media: List<String>.from(product['media']),
          mediaType: List<bool>.from(product['mediaType']),
          category: product['category'],
          productCategory: product['productCategory'],
          productSubCategory: product['productSubCategory'] ?? "",
        );

        myProducts.add(myProduct);
      });

      return myProducts;
    } else {
      print('Failed to fetch My products: ${response.body}');
      throw Exception('Please login again');
    }
  } catch (error) {
    print('Error during My products fetch: $error');
    throw Exception('Error during my products fetch');
  }
}
