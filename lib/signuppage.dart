import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './btm.dart' as nav;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class SignUpController extends GetxController {
  Rx<File?> profileImage = Rx<File?>(null);

  void setProfileImage(File? image) {
    profileImage.value = image;
  }
}

class _SignUpPageState extends State<SignUpPage> {
  void _handleCameraButtonPress(SignUpController controller) async {
    await pickImageFromCamera(controller);
  }

  void _handleGalleryButtonPress(SignUpController controller) async {
    await pickImageFromGallery(controller);
  }

  final controller = Get.put(SignUpController());
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

  final bool _obscureText = true;
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passwordText = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool isLoading = false;

  File? selectedImage;

  Future<void> pickImageFromGallery(SignUpController controller) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      controller.setProfileImage(File(pickedImage.path));
      Get.back(); // Close the image picker options
    }
  }

  Future<void> pickImageFromCamera(SignUpController controller) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      controller.setProfileImage(File(pickedImage.path));
      Get.back(); // Close the image picker options
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screensize1 = MediaQuery.of(context).size;

    Future<void> signUpUser() async {
      setState(() {
        isLoading = true;
      });
      final url = Uri.parse('${nav.baseUrl}/api/users');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the image file to the request
      if (selectedImage != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'photo', // This should match the field name expected by the server
          selectedImage!.path,
          contentType:
              MediaType('image', 'jpeg'), // Adjust the content type as needed
        );
        request.files.add(imageFile);
      }

      // Add other user data fields to the request
      request.fields['sname'] = name.text;
      request.fields['semail'] = emailText.text;
      request.fields['sphone'] = phone.text;
      request.fields['password'] = passwordText.text;
      request.fields['cPassword'] = confirmPassword.text;

      // ignore: avoid_print

      try {
        final response = await request.send();

        var responses = await response.stream.bytesToString();
        var responseKeys = responses.split('"');
        if (response.statusCode == 200) {
          // Registration success, handle navigation or display success message
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtpVerification(userId: responseKeys[7])),
          );
        } else {
          // Registration failed, handle error (e.g., display error message)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseKeys[3]),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        // Handle connection or server-side errors
        print('Error during registration: $error');
      } finally {
        // Set isLoading to false when login is complete (success or failure)
        setState(() {
          isLoading = false;
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: SizedBox(
            width: screensize1.width * 3 / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Stack(
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
                              : Image.asset(
                                  'public/images/user.jpg', // Replace with the path to your asset image
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            imagePickerOption();
                          },
                          icon: const Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.text,
                  controller: name,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.text,
                  controller: emailText,
                  decoration: InputDecoration(
                    hintText: "Email Id",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.phone,
                  controller: phone,
                  decoration: InputDecoration(
                    hintText: "Phone",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  controller: passwordText,
                  obscureText: _obscureText,
                  obscuringCharacter: ".",
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  controller: confirmPassword,
                  obscureText: true,
                  obscuringCharacter: ".",
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const CheckboxExample(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 165, 17, 128),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      if (!isLoading) {
                        signUpUser();
                      }
                    },
                    child: Center(
                      child: isLoading
                          ? Transform.scale(
                              scale: 0.7,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              )) // Show loading indicator
                          : const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "Already a User?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Or Sign Up with",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () => signInWithFacebook(),
                        child: const Text("Facebook")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: signInWithGoogle,
                        child: const Text("Google"))
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      "Join Our Team",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const JoinTeamPage()),
                          );
                        },
                        child: const Text(
                          'Click Here',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({Key? key}) : super(key: key);

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool checkedValue = false;
  bool showReferralCode = false;
  TextEditingController referralCodeController = TextEditingController();

  @override
  void dispose() {
    referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text(
            "Join Us",
            style: TextStyle(color: Colors.blue),
          ),
          value: checkedValue,
          onChanged: (bool? value) {
            setState(() {
              checkedValue = value ?? false;
              showReferralCode =
                  value ?? false; // Show referral code input field
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (showReferralCode)
          TextField(
            controller: referralCodeController,
            decoration: InputDecoration(
              hintText: "Referal Code",
              hintStyle: const TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 165, 17, 128), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Colors.blueGrey,
                    width: 2,
                  )),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  )),
            ),
          ),
      ],
    );
  }
}

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final TextEditingController pan = TextEditingController();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screensize1 = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: screensize1.height,
            width: screensize1.width * 3 / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screensize1.width * 4 / 5,
                  child: const Center(
                    child: Text(
                      "Team Sign Up",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 35),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.text,
                  controller: pan,
                  decoration: InputDecoration(
                    hintText: "PAN",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.text,
                  controller: name,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  controller: email,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Email Id",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  keyboardType: TextInputType.text,
                  controller: phone,
                  decoration: InputDecoration(
                    hintText: "Phone",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 165, 17, 128), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 2,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        )),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 165, 17, 128),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
