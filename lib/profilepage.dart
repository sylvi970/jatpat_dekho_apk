import 'main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'btm.dart';
import 'signuppage.dart';
import 'package:http/http.dart' as http;

class ProfileWidget extends StatelessWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;

  const ProfileWidget(
      {Key? key, required this.loggedInUser, required this.jwtToken})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(loggedInUser.email);
    return Scaffold(
      appBar: loggedInUser.email != null
          ? AppBar(
              title: const Center(
                child: Text(
                  "PROFILE           ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              if (loggedInUser.email == null)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 133, 38, 70),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                '$baseUrl/${loggedInUser.photo}', // Replace with the path to your asset image
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            loggedInUser.name??"",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 21),
                          ),
                          Text(
                            loggedInUser.email??"",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),

                    // -- BUTTON
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => EditProfilPage(
                              loggedInUser: loggedInUser,
                              jwtToken: jwtToken==""?"":jwtToken,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          "Edit Profile     ",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),

                    ProfileMenuWidget(
                      title: loggedInUser.dob??"",
                      icon: Icons.cake,
                      endIcon: false,
                      onPress: () {},
                    ),

                    ProfileMenuWidget(
                      title: loggedInUser.profession ?? "Profession",
                      icon: Icons.work,
                      endIcon: false,
                      onPress: () {},
                    ),

                    ProfileMenuWidget(
                      title: loggedInUser.education ?? "Education",
                      icon: Icons.school,
                      endIcon: false,
                      onPress: () {},
                    ),

                    ProfileMenuWidget(
                      title: loggedInUser.company ?? "Company",
                      icon: Icons.business,
                      endIcon: false,
                      onPress: () {},
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    ProfileMenuWidget(
                      title: "Logout",
                      icon: Icons.logout,
                      textColor: Colors.red,
                      endIcon: false,
                      onPress: () {
                        Get.defaultDialog(
                          title: "LOGOUT",
                          titleStyle: const TextStyle(fontSize: 20),
                          content: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text("Are you sure, you want to Logout?"),
                          ),
                          confirm: Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('jwtToken');
                                Get.to(() => MainScreen(
                                    jwtToken: "",
                                    loggedInUser: LoggedInUser()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                side: BorderSide.none,
                              ),
                              child: const Text("Yes"),
                            ),
                          ),
                          cancel: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text("No"),
                          ),
                        );
                      },
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

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? Colors.white : Colors.black;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.abc, size: 18.0, color: Colors.grey))
          : null,
    );
  }
}

class ProfileController extends GetxController {
  Rx<File?> profileImage = Rx<File?>(null);

  void setProfileImage(File? image) {
    profileImage.value = image;
  }

  Future<void> updateProfile(
    File? newImage,
    String profession,
    String education,
    String company,
  ) async {
    try {
      // Perform API call or database update here
      // You can use the 'newImage', 'location', 'profession', 'dob', and 'about' parameters
      // to update the user's profile

      // Example: updating profile image
      if (newImage != null) {
        // Save the new image to your server or storage
        // For now, we'll just update the 'profileImage' locally
        profileImage.value = newImage;
      }

      // Show success message or navigate back
      Get.snackbar(
          'Profile Updated', 'Your profile has been updated successfully');
    } catch (error) {
      // Handle errors
      Get.snackbar('Error', 'An error occurred while updating your profile');
    }
  }
}

class EditProfilPage extends StatefulWidget {
  final LoggedInUser loggedInUser;
  final String jwtToken;
  const EditProfilPage(
      {Key? key, required this.loggedInUser, required this.jwtToken})
      : super(
          key: key,
        );

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilPage createState() => _EditProfilPage();
}

class _EditProfilPage extends State<EditProfilPage> {
  void _handleCameraButtonPress(ProfileController controller) async {
    await pickImageFromCamera(controller);
  }

  void _handleGalleryButtonPress(ProfileController controller) async {
    await pickImageFromGallery(controller);
  }

  final controller = Get.put(ProfileController());
  Future<void> imagePickerOption() async {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pic Image From",
                    style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleCameraButtonPress(controller),
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleGalleryButtonPress(controller),
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
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

  File? selectedImage;

  Future<void> pickImageFromGallery(ProfileController controller) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      controller.setProfileImage(File(pickedImage.path));
      Get.back(); // Close the image picker options
    }
  }

  Future<void> pickImageFromCamera(ProfileController controller) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      controller.setProfileImage(File(pickedImage.path));
      Get.back(); // Close the image picker options
    }
  }

  var profession = TextEditingController();
  var education = TextEditingController();
  var company = TextEditingController();

  Future<void> updateprofile() async {
    print("hfbchdj");
    final apiUrl = Uri.parse('$baseUrl/api/updateUser');

    final headers = {
      'Authorization': widget.jwtToken,
    };

    final request = http.MultipartRequest('PUT', apiUrl);

    request.headers.addAll(headers);
    request.fields['id'] = widget.loggedInUser.id;
    request.fields['profession'] = profession.text;
    request.fields['education'] = education.text;
    request.fields['company'] = company.text;

    // Add selectedImages as files to the request
    // for (var image in selectedImages) {
    //   final imageFile = await http.MultipartFile.fromPath(
    //     'productMedia',
    //     image.path,
    //     contentType: MediaType('image', 'jpeg'), // Adjust the content type
    //   );
    //   request.files.add(imageFile);
    // }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Product added successfully, you can handle success here
        print('Product added successfully');
        // Clear the form and reset the selectedImages and selectedVideos lists
        profession.clear();
        education.clear();
        company.clear();
        // setState(() {
        //   selectedImages.clear();
        //   seectedVideos.clear();
        // });
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
    print('${baseUrl}${widget.loggedInUser.photo}');
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Center(
          child: Text(
            "Edit Profile      ",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Obx(() => controller.profileImage.value != null
                          ? Image.file(
                              controller.profileImage.value!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : widget.loggedInUser.photo[0] == ""
                              ? Image.asset(
                                  'public/images/user.jpg', // Replace with the path to your asset image
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  '$baseUrl/${widget.loggedInUser.photo}')),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => imagePickerOption(),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(children: [
                  TextField(
                    controller: profession,
                    decoration: InputDecoration(
                        label: const Text("Profession"),
                        hintText: widget.loggedInUser.profession ?? "",
                        hintStyle: const TextStyle(color: Colors.black)),
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: education,
                    decoration: InputDecoration(
                        label: const Text("Education"),
                        hintText: widget.loggedInUser.education ?? "",
                        hintStyle: const TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: company,
                    decoration: InputDecoration(
                        label: const Text("Company"),
                        hintText: widget.loggedInUser.company ?? "",
                        hintStyle: const TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePassword(),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        ),
                      )),

                  // -- Form Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () async {
                        // const profession = "Profession";
                        // const education = "Education";
                        // const company = "Company";

                        // await controller.updateProfile(
                        //   controller.profileImage.value,
                        //   profession,
                        //   education,
                        //   company,
                        // );

                        // Get.back();
                        await updateprofile();
                      },
                      child: const Text("SUBMIT",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({
    super.key,
  });

  @override
  State<ChangePassword> createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final currentpwd = TextEditingController();
  final newpwd = TextEditingController();
  final confirmpwd = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size screensize1 = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Change Password         ",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screensize1.width * 3.2 / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Current Password",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    controller: currentpwd,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          )),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        "New Password",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    controller: newpwd,
                    decoration: InputDecoration(
                      hintText: "New Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          )),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        "Confirm Password",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    controller: confirmpwd,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          )),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {},
                child:
                    const Text("SUBMIT", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
