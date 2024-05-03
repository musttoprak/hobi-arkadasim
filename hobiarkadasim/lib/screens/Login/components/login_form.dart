import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/bottom_navigation_bar.dart';
import 'package:hobiarkadasim/screens/SelectCategory/select_category.dart';
import 'package:hobiarkadasim/screens/home_screen.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/showSnackbar.dart';
import '../../../constants/constants.dart';
import '../../../services/aut_service.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    UserService userService = UserService();

    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      var autService = AuthService();
      await autService
          .signInWithEmailAndPassword(email, password)
          .then((value) async {
        if (value != null) {
          await SharedPreferences.getInstance().then((prefs) async {
            prefs.setString('id', value.toString());
            prefs.setString('email', email);
            prefs.setString('password', password);

            UserService userService = UserService();
            await userService.checkUserExists(value).then((value) async {
              ShowMySnackbar.snackbarShow(
                  context, true, "Giriş işlemi başarılıyla gerçekleştirildi");
              await userService.getCategoryNames().then((value) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await userService
                    .getUserHobbies(prefs.getString('id')!)
                    .then((value2) {
                  if (value2.isEmpty) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectCategory(
                              categories: value, savedCategories: value2);
                        },
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const HomeTabbarView();
                        },
                      ),
                      (route) => false,
                    );
                  }
                });
              });
            });
          });
        } else {
          ShowMySnackbar.snackbarShow(
              context, false, "Lütfen giriş bilgilerinizi kontrol ediniz.");
        }
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email adresi boş olamaz';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: "Email Adresiniz",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre boş olamaz';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Şifreniz",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _login,
            child: const Text(
              "GİRİŞ",
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
