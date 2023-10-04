import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './btm.dart' as nav;
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signuppage.dart';

void main() {
  runApp(const MyApp());
}

class LoggedInUser {
  var id;
  var name;
  var email;
  var phone;
  var dob;
  var gender;
  var photo;
  var profession;
  var education;
  var company;

  LoggedInUser(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.dob,
      this.gender,
      this.photo,
      this.profession,
      this.education,
      this.company});
}

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  const Responsive({
    Key? key,
    required this.desktop,
    required this.mobile,
    required this.tablet,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 1100) {
        return desktop;
      } else if (constraints.maxWidth >= 650) {
        return tablet;
      } else {
        return mobile;
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<LoggedInUser> _fetchUser(String jwtToken) async {
    final response =
        await http.get(Uri.parse('${nav.baseUrl}/verify-token'), headers: {
      'Authorization': jwtToken,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      print(userData);
      return LoggedInUser(
        id: userData['user']['id'],
        name: userData['user']['name'],
        email: userData['user']['email'],
        phone: userData['user']['phone'],
        dob: userData['user']['dob'],
        gender: userData['user']['gender'],
        photo: userData['url'],
        profession: userData['user']['profession'],
        education: userData['user']['education'],
        company: userData['user']['company'],
      );
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      home: FutureBuilder<String?>(
        future: _getJwtToken(),
        builder: (context, tokenSnapshot) {
          if (tokenSnapshot.connectionState == ConnectionState.waiting) {
            // SharedPreferences data is still loading, return a loading screen
            return const CircularProgressIndicator();
          } else if (tokenSnapshot.hasError) {
            // Error while reading SharedPreferences, handle it here
            print(tokenSnapshot.error);
            return Text('Error: ${tokenSnapshot.error}');
          } else {
            final jwtToken = tokenSnapshot.data;
            print(jwtToken);
            if (jwtToken != null) {
              // JWT token found in SharedPreferences, fetch user data
              return FutureBuilder<LoggedInUser>(
                future: _fetchUser(jwtToken),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    // User data is still loading, return a loading screen
                    return const CircularProgressIndicator();
                  } else if (userSnapshot.hasError) {
                    // Handle the case where user data could not be fetched
                    print(userSnapshot.error);
                    return nav.MainScreen(
                      jwtToken: "",
                      loggedInUser: LoggedInUser(),
                    );
                  } else {
                    // User data fetched successfully, navigate to MainScreen
                    return nav.MainScreen(
                      jwtToken: jwtToken,
                      loggedInUser: userSnapshot.data!,
                    );
                  }
                },
              );
            } else {
              print("else");
              // JWT token not found in SharedPreferences, navigate to MainScreen without token
              return nav.MainScreen(jwtToken: "", loggedInUser: LoggedInUser());
            }
          }
        },
      ),
    );
  }
}

//User Login Page

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passwordText = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
        '${nav.baseUrl}/api/login'); // Replace with your login API URL
    final loginData = {
      'email': emailText.text,
      'password': passwordText.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jwtToken =
            data['token'] as String; // Assuming the token key is 'token'

        // Store the JWT token securely using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', jwtToken);

        final verifyTokenUrl = Uri.parse(
            '${nav.baseUrl}/verify-token'); // Replace with your verify-token API URL
        final verifyTokenResponse = await http.get(
          verifyTokenUrl,
          headers: {
            'Authorization': jwtToken
          }, // Include the JWT token in the headers
        );

        if (verifyTokenResponse.statusCode == 200) {
          final userDetails = json.decode(verifyTokenResponse.body);
          final loggedInUserDetails = userDetails['user'];

          final loggedInUser = LoggedInUser(
            id: loggedInUserDetails['id'],
            name: loggedInUserDetails['name'],
            email: loggedInUserDetails['email'],
            phone: loggedInUserDetails['phone'],
            dob: loggedInUserDetails['dob'],
            gender: loggedInUserDetails['gender'],
            photo: userDetails['url'],
            profession: userDetails['profession'],
            education: userDetails['education'],
            company: userDetails['company'],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => nav.MainScreen(
                  jwtToken: jwtToken, loggedInUser: loggedInUser),
            ),
          );
        } else {
          //show message Token Expired. Log In Again
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token Expired. Log In Again'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Login failed, handle error (e.g., display error message)
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(response.body),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          },
        );
        print('Login failed: ${response.body}');
      }
    } catch (error) {
      // Handle connection or server-side errors
      print('Error during login: $error');
    } finally {
      // Set isLoading to false when login is complete (success or failure)
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    // var loggedInUser = _autoLogin();

    return IgnorePointer(
      ignoring: isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: screensize.height,
                width: screensize.width * 3 / 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screensize.height * 2 / 30,
                      width: screensize.width * 4 / 5,
                      child: const Center(
                        child: Text(
                          "Jatpat Dekho",
                          style: TextStyle(
                              color: Color.fromARGB(255, 153, 151, 151),
                              fontWeight: FontWeight.w400,
                              fontSize: 30),
                        ),
                      ),
                    ),
                    TextField(
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      keyboardType: TextInputType.text,
                      controller: emailText,
                      decoration: InputDecoration(
                        hintText: "Enter mail",
                        hintStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 165, 17, 128),
                              width: 1),
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
                    SizedBox(
                      height: screensize.height / 60,
                    ),
                    TextField(
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      controller: passwordText,
                      obscureText: true,
                      obscuringCharacter: ".",
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 165, 17, 128),
                              width: 1),
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
                    SizedBox(
                      height: screensize.height / 60,
                    ),
                    SizedBox(
                      height: screensize.height * 1.5 / 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 165, 17, 128),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          if (!isLoading) {
                            loginUser(context);
                          }
                        },

                        // Call loginUser function on button press
                        child: Center(
                          child: isLoading
                              ? Transform.scale(
                                  scale: 0.7,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  )) // Show loading indicator
                              : const Text(
                                  "Log in",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPawdPage()),
                          );
                        },
                        child: const Center(
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          ),
                        )),
                    SizedBox(
                      height: screensize.height * 5.5 / 30,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Center(
                          child: Text(
                            "Create an Accout",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> signInWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // Successful Facebook login, handle your logic
      final AccessToken accessToken = result.accessToken!;
      print('Facebook access token: ${accessToken.token}');
    }
  } catch (error) {
    // ignore: avoid_print
    print('Facebook login error: $error');
  }
}

Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    if (googleSignInAccount != null) {
      // Successful Google login, handle your logic
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final String? accessToken = googleSignInAuthentication.accessToken;
      final String? idToken = googleSignInAuthentication.idToken;

      print('Google access token: $accessToken');
      print('Google ID token: $idToken');
    }
  } catch (error) {
    print('Google login error: $error');
  }
}

// forgot password page
class ForgotPawdPage extends StatelessWidget {
  final mobileNo = TextEditingController();

  ForgotPawdPage({super.key});
  @override
  Widget build(BuildContext context) {
    Size screensize1 = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screensize1.height * 3 / 4,
              width: screensize1.width * 3.5 / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Enter your mobile number/email",
                    style: TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    controller: mobileNo,
                    decoration: InputDecoration(
                      hintText: "Phone Number/Email Id",
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
                    height: 18,
                  ),
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 165, 17, 128),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () {},
                      child: const Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpVerification extends StatefulWidget {
  final String userId;
  const OtpVerification({super.key, required this.userId});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final _otp = TextEditingController();
  bool isLoading = false;

  Future<void> submitOtp() async {
    setState(() {
      isLoading = true;
    });
    final userData = {
      "userId": widget.userId,
      "otp": _otp.text,
    };

    try {
      final response = await http.post(
        Uri.parse(
            '${nav.baseUrl}/api/verify'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong OTP. Try Again'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      // Handle connection or server-side errors
      print('Error during OTP verification: $error');
    } finally {
      // Set isLoading to false when login is complete (success or failure)
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendOtp() async {
    final userData = {
      "userId": widget.userId,
    };
    try {
      final response = await http.post(
        Uri.parse(
            '${nav.baseUrl}/api/resend-otp'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("New OTP has been sent."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong OTP. Try Again'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      // Handle connection or server-side errors
      print('Error during OTP verification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screensize1 = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screensize1.width * 3.5 / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "OTP Verification",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    controller: _otp,
                    decoration: InputDecoration(
                      hintText: "OTP",
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
                    height: 18,
                  ),
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 165, 17, 128),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () async {
                        await submitOtp();
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
                                "Verify",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
                onPressed: () async {
                  await resendOtp();
                },
                child: const Center(
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(fontSize: 15, color: Colors.blue),
                  ),
                )),
            SizedBox(
              height: screensize1.height * 5.5 / 30,
            ),
          ],
        ),
      ),
    );
  }
}
