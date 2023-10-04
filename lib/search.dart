import 'package:flutter/material.dart';
import 'package:jatpat_dekho_apk/btm.dart';
import 'package:jatpat_dekho_apk/homepage.dart';
import 'package:jatpat_dekho_apk/main.dart';
import './btm.dart' as nav;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  var search = TextEditingController();
  List<LoggedInUser> userResults = [];
  List<Product> productResults = [];
  List<bool> checkboxes = [false, false, false, false, false, false];
  bool showFilters = false;

  Future<void> fetchSearchResults(String searchTerm) async {
    setState(() {
      userResults.clear();
      productResults.clear();
    });

    final producturl =
        Uri.parse('${nav.baseUrl}/api/search/products/$searchTerm');
    final userurl = Uri.parse('${nav.baseUrl}/api/search/users/$searchTerm');
    try {
      final userResult = await http.get(userurl);
      final productResult = await http.get(producturl);

      if (userResult.statusCode == 200) {
        final dynamic userData = json.decode(userResult.body);
        if (userData is List) {
          LoggedInUser searchUser;
          setState(() {
            userData.forEach((user) => {
                  searchUser = LoggedInUser(
                      name: user['name'],
                      email: user['email'],
                      phone: user['phone'],
                      dob: user['dob'],
                      gender: user['gender'],
                      photo: user['photo']),
                  userResults.add(searchUser)
                });
          });
        } else {
          print('Unexpected user search results format');
          setState(() {
            userResults.clear();
          });
        }
      } else {
        print('Failed to fetch user search results: ${userResult.body}');
        setState(() {
          userResults.clear();
        });
      }

      if (productResult.statusCode == 200) {
        final dynamic productData = json.decode(productResult.body);
        if (productData is List) {
          Product searchproduct;
          setState(() {
            productData.forEach((product) => {
                  searchproduct = Product(
                      pId: product['pId'],
                      name: product['name'],
                      price: product['price'] + 0.0,
                      description: product['description'],
                      media: product['media'],
                      mediaType: product['mediaType'],
                      productCategory: product['productCategory'],
                      productSubCategory: product['productSubCategory'] ?? "",
                      category: product['category']),
                  productResults.add(searchproduct)
                });
          });
        } else {
          print('Unexpected product search results format');
          setState(() {
            productResults.clear();
          });
        }
      } else {
        print('Failed to fetch product search results: ${productResult.body}');
        setState(() {
          productResults.clear();
        });
      }
    } catch (error) {
      print('Error during search: $error');
      setState(() {
        productResults.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Center(child: Text("Search Results")),
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              TextField(
                keyboardType: TextInputType.text,
                controller: search,
                onChanged: (searchTerm) {
                  final searchTerm = search.text;
                  if (searchTerm.isNotEmpty) {
                    fetchSearchResults(searchTerm);
                  } 
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueGrey,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      final searchTerm = search.text;
                      if (searchTerm.isNotEmpty) {
                        fetchSearchResults(searchTerm);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showFilters = !showFilters;
                      });
                    },
                    child: const Text("Advance Search With Filters ▼"),
                  ),
                ],
              ),
              if (showFilters)
                Column(
                  children: [
                    for (int i = 0; i < checkboxes.length; i++)
                      Row(
                        children: [
                          Checkbox(
                            value: checkboxes[i],
                            onChanged: (value) {
                              setState(() {
                                checkboxes[i] = value!;
                              });
                            },
                          ),
                          Text(
                            ['User', 'B2B', 'B2C', 'C2C', 'D', 'E'][i],
                          ),
                        ],
                      ),
                  ],
                ),
              if (userResults.isEmpty)
                const Text(
                  "No user Found",
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: userResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      // Access the user's first photo
                      // Replace with a placeholder URL or image path

                      return ListTile(
                        leading: userResults[index].photo.isNotEmpty
                            ? SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: Image.network(
                                  '$baseUrl/${userResults[index].photo[0].toString().substring(15)}',
                                  width: 50.0,
                                  height: 50.0,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: Image.asset(
                                  'public/images/user.jpg',
                                  width: 50.0,
                                  height: 50.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        title: Text(userResults[index].name),
                        subtitle: Text(userResults[index].email),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => UserProfileScreen(
                          //       userId: userResults[index].id,
                          //     ),
                          //   ),
                          // );
                        },
                      );
                    },
                  ),
                ),
              if (productResults.isEmpty)
                const Text(
                  "No product Found",
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: productResults.length,
                    itemBuilder: (context, index) {
                      final product = productResults[index];

                      return ListTile(
                        leading: SizedBox(
                          width: 55.0,
                          height: 55.0,
                          child: product.media.isNotEmpty
                              ? Image.network(
                                  '$baseUrl/${product.media[0].toString().substring(15)}',
                                  width: 55.0,
                                  height: 55.0,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'public/images/user.jpg',
                                  width: 55.0,
                                  height: 55.0,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.price.toString()),
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
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
