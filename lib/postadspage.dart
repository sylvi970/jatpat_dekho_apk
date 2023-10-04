import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'btm.dart';
import 'package:jatpat_dekho_apk/main.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'signuppage.dart';

// ignore: must_be_immutable
class PostAds extends StatefulWidget {
  LoggedInUser loggedInUser;
  String jwtToken;
  PostAds({super.key, required this.loggedInUser, required this.jwtToken});

  @override
  State<PostAds> createState() => _PostAdsState();
}

class _PostAdsState extends State<PostAds> {
  List<File> selectedImages = [];
  List<File> selectedVideos = [];

  List<String?> videoThumbnails = [];
  bool catagory2Selected = false;

  List<DropdownMenuItem<String>> dropdownItems = [
    const DropdownMenuItem<String>(
      value: '1',
      child: Text('B2B'),
    ),
    const DropdownMenuItem<String>(
      value: '2',
      child: Text('B2C'),
    ),
    const DropdownMenuItem<String>(
      value: '3',
      child: Text('C2C'),
    ),
    const DropdownMenuItem<String>(
      value: '4',
      child: Text('D'),
    ),
    const DropdownMenuItem<String>(
      value: '5',
      child: Text('E'),
    ),
  ];

  List<DropdownMenuItem<String>> dropdownItemCatagory = [
    const DropdownMenuItem<String>(
      value: '6',
      child: Text('A'),
    ),
    const DropdownMenuItem<String>(
      value: '7',
      child: Text('B'),
    ),
    const DropdownMenuItem<String>(
      value: '8',
      child: Text('C'),
    ),
    const DropdownMenuItem<String>(
      value: '9',
      child: Text('D'),
    ),
    const DropdownMenuItem<String>(
      value: '10',
      child: Text('E'),
    ),
  ];

  List<DropdownMenuItem<String>> dropdownItemSubCatagory = [
    const DropdownMenuItem<String>(
      value: '11',
      child: Text('1wdfghj'),
    ),
    const DropdownMenuItem<String>(
      value: '12',
      child: Text('2'),
    ),
    const DropdownMenuItem<String>(
      value: '13',
      child: Text('3'),
    ),
    const DropdownMenuItem<String>(
      value: '14',
      child: Text('4'),
    ),
    const DropdownMenuItem<String>(
      value: '15',
      child: Text('5'),
    ),
  ];

  String? category;
  String? productCategory;
  String? productSubCategory;

  void imagePickerOption() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 260,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pick Image/Video From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickMedia(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickMedia(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickMedia(ImageSource.gallery, isVideo: true);
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text("VIDEO"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      setState(() {
        selectedImages.add(tempImage);
      });

      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // void videoPickerOption() {
  //   Get.bottomSheet(
  //     SingleChildScrollView(
  //       child: ClipRRect(
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(10.0),
  //           topRight: Radius.circular(10.0),
  //         ),
  //         child: Container(
  //           color: Colors.white,
  //           height: 250,
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 const Text(
  //                   "Pick Video From",
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () {
  //                     pickVideo();
  //                   },
  //                   icon: const Icon(Icons.videocam),
  //                   label: const Text("VIDEO"),
  //                 ),
  //                 // ... Other buttons for different video sources

  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () {
  //                     Get.back();
  //                   },
  //                   icon: const Icon(Icons.close),
  //                   label: const Text("CANCEL"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> pickMedia(ImageSource imageType, {bool isVideo = false}) async {
    try {
      final media = isVideo
          ? await ImagePicker().pickVideo(source: imageType)
          : await ImagePicker().pickImage(source: imageType);

      if (media == null) return;

      if (isVideo) {
        final videoController = VideoPlayerController.file(File(media.path));
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: media.path,
          quality: 100,
        );

        setState(() {
          selectedVideos.add(videoController as File);
          videoThumbnails.add(thumbnail);
        });
      } else {
        final tempImage = File(media.path);
        setState(() {
          selectedImages.add(tempImage);
        });
      }

      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  var productName = TextEditingController();
  var productDesc = TextEditingController();
  var price = TextEditingController();

  Future<void> addProductToDatabase() async {
    final apiUrl = Uri.parse('$baseUrl/api/products');

    final headers = {
      'Authorization': widget.jwtToken,
    };

    final request = http.MultipartRequest('POST', apiUrl);

    request.headers.addAll(headers);
    request.fields['productName'] = productName.text;
    request.fields['productDesc'] = productDesc.text;
    request.fields['price'] = price.text;
    request.fields['category'] = category ?? '1';
    request.fields['productCategory'] = productCategory ?? '6';
    request.fields['productSubCategory'] = productSubCategory ?? '';

    // Add selectedImages as files to the request
    for (var image in selectedImages) {
      final imageFile = await http.MultipartFile.fromPath(
        'productMedia',
        image.path,
        contentType: MediaType('image', 'jpeg'), // Adjust the content type
      );
      request.files.add(imageFile);
    }

    // Add selectedVideos as files to the request
    for (var video in selectedVideos) {
      final videoFile = await http.MultipartFile.fromPath(
        'productMedia',
        video.path,
        contentType: MediaType('video', 'mp4'), // Adjust the content type
      );
      request.files.add(videoFile);
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Product added successfully, you can handle success here
        print('Product added successfully');
        // Clear the form and reset the selectedImages and selectedVideos lists
        productName.clear();
        productDesc.clear();
        price.clear();
        setState(() {
          selectedImages.clear();
          selectedVideos.clear();
        });
      } else {
        // Handle API errors here, display an error message or take appropriate action
        final responseJson = await response.stream.bytesToString();
        print('Error adding product: $responseJson');
      }
    } catch (error) {
      // Handle connection or server-side errors here
      print('Error during API request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screensize1 = MediaQuery.of(context).size;
    bool isLoggedIn = widget.loggedInUser.email != null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: widget.loggedInUser.email != null
          ? AppBar(
              title: const Text(
                "POST YOUR ADS",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(
                      context); // This line will navigate back to the previous screen
                },
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screensize1.width * 3.5 / 4,
            child: Column(
              children: isLoggedIn
                  ? [
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: screensize1.width * 3.3 / 4,
                        height: 50,
                        child: TextField(
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0)),
                          keyboardType: TextInputType.text,
                          controller: productName,
                          decoration: InputDecoration(
                            hintText: "ProductName",
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.3,
                                )),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: screensize1.width * 3.3 / 4,
                        height: 50,
                        child: TextField(
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0)),
                          keyboardType: TextInputType.text,
                          controller: productDesc,
                          decoration: InputDecoration(
                            hintText: "Product Desc",
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.3,
                                )),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: screensize1.width * 3.3 / 4,
                        height: 50,
                        child: TextField(
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0)),
                          keyboardType: TextInputType.number,
                          controller: price,
                          decoration: InputDecoration(
                            hintText: "Price",
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.3,
                                )),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          DropdownButton<String>(
                            value: category,
                            onChanged: (value) {
                              setState(() {
                                category = value;
                              });
                            },
                            items: dropdownItems,
                            hint: const Text('Catagory-1'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          DropdownButton<String>(
                            value: productCategory,
                            onChanged: (value) {
                              setState(() {
                                productCategory = value;
                                // Update the catagory2Selected variable based on the selected value.
                                catagory2Selected =
                                    value != null && value.isNotEmpty;
                              });
                            },
                            items: [
                              const DropdownMenuItem<String>(
                                value:
                                    null, // Add a null option at the beginning.
                                child: Text('Catagory-2'),
                              ),
                              ...dropdownItemCatagory,
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          AbsorbPointer(
                            absorbing:
                                !catagory2Selected, // Disable if "Catagory-2" is not selected.
                            child: DropdownButton<String>(
                              value: productSubCategory,
                              onChanged: (value) {
                                setState(() {
                                  productSubCategory = value;
                                });
                              },
                              items: dropdownItemSubCatagory,
                              hint: const Text('Sub-Catagory'),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: selectedImages.length < 6
                                  ? imagePickerOption
                                  : null,
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.upload,
                                    color: Color.fromARGB(255, 5, 73, 129),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "UPLOAD IMAGE",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 34, 101, 156)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (productName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a product name.'),
                                  ),
                                );
                              } else if (productDesc.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter a product description.'),
                                  ),
                                );
                              } else if (price.text.isEmpty) {
                             
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter a price for the product.'),
                                  ),
                                );
                              } else if (category == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a category.'),
                                  ),
                                );
                              } else if (productCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select a product-category.'),
                                  ),
                                );
                              } else if (selectedImages.length +
                                          selectedVideos.length >
                                      6 ||
                                  selectedImages.length +
                                          selectedVideos.length <
                                      2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select at least two images or one video.'),
                                  ),
                                );
                              }
                               else {
                                addProductToDatabase();
                              }
                            },
                            child: const Text(
                              "SUBMIT",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 217, 28, 14)),
                            ),
                          ),
                          if (selectedVideos.isNotEmpty)
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedVideos.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 140,
                                      child: VideoPlayer(selectedVideos[index]
                                          as VideoPlayerController),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // Display selected images
                      if (selectedImages.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 140,
                                  child: Image.file(
                                    selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ]
                  : [
                      const SizedBox(height: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text("Log In"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 133, 38, 70),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text("Sign Up"),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
