import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../handler/database_handler.dart';
import '../model/user.dart';
import '../widgets/button_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHandler = DatabaseHandler();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xff151f2c) : Colors.white,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.003),
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.001),
                        child: Align(
                          child: Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              color: isDarkMode ? Colors.white : const Color(0xff1D1617),
                              fontSize: size.height * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: size.height * 0.015)),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildTextField(
                              "Username",
                              Icons.person_outlined,
                              false,
                              size,
                                  (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                              _usernameController,
                              isDarkMode,
                            ),
                            SizedBox(height: size.height * 0.025),
                            buildTextField(
                              "Password",
                              Icons.lock_outline,
                              true,
                              size,
                                  (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              _passwordController,
                              isDarkMode,
                            ),
                            SizedBox(height: size.height * 0.025),
                            ButtonWidget(
                              text: "Login",
                              backColor: isDarkMode ? [Colors.black, Colors.black] : const [Color(0xff92A3FD), Color(0xff9DCEFF)],
                              textColor: const [Colors.white, Colors.white],
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  List<User> users = await _dbHandler.retrieveUsers();
                                  bool isValidUser = users.any((user) => user.username == _usernameController.text && user.password == _passwordController.text);
                                  if (isValidUser) {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid username or password')));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.025),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Don’t have an account yet? ",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : const Color(0xff1D1617),
                                  fontSize: size.height * 0.018,
                                ),
                              ),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/register'),
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [Color(0xffEEA4CE), Color(0xffC58BF2)],
                                        ).createShader(
                                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                        ),
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool pwVisible = false;

  Widget buildTextField(
      String hintText,
      IconData icon,
      bool password,
      Size size,
      FormFieldValidator validator,
      TextEditingController controller,
      bool isDarkMode,
      ) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.0),
      child: Container(
        child: SizedBox(
          width: size.width * 0.9,
          height: size.height * 0.09,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color(0xffF7F8F8),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: isDarkMode ? const Color(0xffADA4A5) : Colors.black),
              validator: validator,
              textInputAction: TextInputAction.next,
              obscureText: password ? !pwVisible : false,
              decoration: InputDecoration(
                errorStyle: const TextStyle(height: 0),
                hintStyle: const TextStyle(color: Color(0xffADA4A5)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: size.height * 0.027),
                hintText: hintText,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.025),
                  child: Icon(icon, color: const Color(0xff7B6F72)),
                ),
                suffixIcon: password
                    ? Padding(
                  padding: EdgeInsets.only(top: size.height * 0.028),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pwVisible = !pwVisible;
                      });
                    },
                    child: pwVisible
                        ? const Icon(Icons.visibility_off_outlined, color: Color(0xff7B6F72))
                        : const Icon(Icons.visibility_outlined, color: Color(0xff7B6F72)),
                  ),
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}