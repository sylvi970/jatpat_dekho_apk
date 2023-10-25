import 'package:flutter/material.dart';
import 'package:jatpat_dekho_apk/profilepage.dart';
import 'btm.dart';
import 'package:jatpat_dekho_apk/main.dart';
import './search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatpage.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  Future<List<Product>> productsFuture;
  final Future<List<Category>> productCategoryFuture;
  static const int defaultColumnCount = 3;
  final LoggedInUser loggedInUser;
  final String jwtToken; 

  Home({
    Key? key,
    required this.loggedInUser,
    required this.productsFuture,
    required this.jwtToken,
    required this.productCategoryFuture,
  }) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<Home> {
  List<Product> favoriteProducts = [];
  bool isFavorite = false;
  bool addedToFavorites = false;
  List<Category> productCategory = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Call the API to fetch category names

    //fetchData();
  }

  Future<void> _handleRefresh() async {
    try {
      final newProducts = fetchProducts();
      setState(() {
        widget.productsFuture = newProducts;
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
                    builder: (context) => SearchResults(
                        loggedInUser: widget.loggedInUser,
                        jwtToken: widget.jwtToken),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorite(
                        jwtToken: widget.jwtToken,
                        loggedInUser: widget.loggedInUser),
                  ),
                );
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FutureBuilder<List<Category>>(
                      future: widget.productCategoryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading products."));
                        } else {
                          productCategory = snapshot.data!;
                        }

                        return Row(
                          children: [
                            for (int index = 0;
                                index < productCategory.length;
                                index++)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductCategoryPage(
                                        productCategory: productCategory[index],
                                        products: products,
                                        loggedInUser: widget.loggedInUser,
                                        jwtToken: widget.jwtToken,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    productCategory[index].categoryName,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
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
                              categoryImages[index],
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
                                              loggedInUser: widget.loggedInUser,
                                              jwtToken: widget.jwtToken,
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
                                                      width:
                                                          constraints.maxWidth,
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
                                                        if (widget.loggedInUser
                                                                .email ==
                                                            null) {
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
                              loggedInUser: widget.loggedInUser,
                              jwtToken: widget.jwtToken,
                          
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
                              loggedInUser: widget.loggedInUser,
                              jwtToken: widget.jwtToken,
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
    List<Product> requiredProducts = [];

    widget.product.forEach((product) {
      String category;
      if (product.category == 1) {
        category = "B2B";
      } else if (product.category == 2) {
        category = "B2C";
      } else if (product.category == 3) {
        category = "C2C";
      } else if (product.category == 4) {
        category = "Category 4";
      } else {
        category = "Category 5";
      }
      if (category == widget.categoryName) {
        requiredProducts.add(product);
      }
    });
    return requiredProducts.isNotEmpty
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.categoryName),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 2,
              ),
              itemCount: requiredProducts.length,
              itemBuilder: (context, index) {
                //for (var i = 0; i < widget.products.length; i++) {
                Product product = requiredProducts[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDescriptionPage(
                          loggedInUser: widget.loggedInUser,
                          jwtToken: widget.jwtToken,
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
                                      bool isFavorite = await _toggleFavorite(
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
                                  widget.categoryName,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product
                                          .name, // Replace with actual category
                                      style:
                                          const TextStyle(color: Colors.black),
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

                //}
                //return null;
              },
            ))
        : const Center(
            child: Text('No products available.'),
          );
  }
}

class ProductCategoryPage extends StatefulWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;
  final Category productCategory;
  final List<Product> products;

  const ProductCategoryPage(
      {super.key,
      required this.loggedInUser,
      required this.productCategory,
      required this.jwtToken,
      required this.products});

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
    List<Product> requiredProducts = [];

    widget.products.forEach((product) {
      if (product.productCategory == widget.productCategory.categoryName) {
        requiredProducts.add(product);
      }
    });
    return requiredProducts.isNotEmpty
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.productCategory.categoryName),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 2,
              ),
              itemCount: requiredProducts.length,
              itemBuilder: (context, index) {
                String category;
                //for (var i = 0; i < widget.products.length; i++) {
                Product product = requiredProducts[index];

                if (product.category == 1) {
                  category = "B2B";
                } else if (product.category == 2) {
                  category = "B2C";
                } else if (product.category == 3) {
                  category = "C2C";
                } else if (product.category == 4) {
                  category = "Category 4";
                } else {
                  category = "Category 5";
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDescriptionPage(
                          loggedInUser: widget.loggedInUser,
                          jwtToken: widget.jwtToken,
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
                                      bool isFavorite = await _toggleFavorite(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product
                                          .name, // Replace with actual category
                                      style:
                                          const TextStyle(color: Colors.black),
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

                //}
                //return null;
              },
            ))
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.productCategory.categoryName),
            ),
            body: const Center(
                child: Text(
              "No products available",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            )));
  }
}

class ProductDescriptionPage extends StatelessWidget {
  final Product product;
  final LoggedInUser loggedInUser;
  final String jwtToken;
  final Function(bool isFavorite) onFavoriteChanged;

  const ProductDescriptionPage({
    Key? key,
    required this.product,
    required this.loggedInUser,
    required this.jwtToken,
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
                  MaterialPageRoute(
                      builder: (context) => ChatPageScreen(jwtToken: jwtToken,loggedInUser: loggedInUser,),),
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
  final String jwtToken;
  final LoggedInUser loggedInUser;

  const Favorite({Key? key, required this.jwtToken, required this.loggedInUser})
      : super(key: key);

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  List<Product> favoriteProducts = []; // Store favorite products here

  @override
  void initState() {
    super.initState();
    // Fetch favorite products when the widget initializes
    _fetchFavoriteProducts();
  }

  Future<void> _fetchFavoriteProducts() async {
    try {
      final products = await fetchFavoriteProducts(widget.jwtToken);
      setState(() {
        favoriteProducts = products;
      });
    } catch (error) {
      // Handle any errors that occur during the API request
      // ignore: use_build_context_synchronously
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (favoriteProducts.isEmpty) {
          return const Center(
            child: Text(
              "No Favorite Products",
              style: TextStyle(fontSize: 20),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _fetchFavoriteProducts(),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 200,
              crossAxisSpacing: 1,
              mainAxisSpacing: 2,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDescriptionPage(
                        loggedInUser: widget.loggedInUser,
                        jwtToken: widget.jwtToken,
                        product: product,
                        onFavoriteChanged: (isFavorite) {
                          // Handle favorite icon tap here
                          setState(() {
                            product.isFavorite = isFavorite;
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
                                height: constraints.maxHeight * 0.15,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                onPressed: () async {
                                  product.isFavorite = true;
                                  await _toggleFavorite(
                                      product, widget.jwtToken);
                                  _fetchFavoriteProducts();
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
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
          ),
        );
      }),
    );
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
  final LoggedInUser loggedInUser;
  final String jwtToken;
  const MyProductsPage(
      {super.key,
      required this.myProducts,
      required this.loggedInUser,
      required this.jwtToken});

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
            itemCount: widget.myProducts.length,
            itemBuilder: (context, index) {
              final product = widget.myProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDescriptionPage(
                        loggedInUser: widget.loggedInUser,
                        jwtToken: widget.jwtToken,
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
