import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../components/showSnackbar.dart';
import '../../../constants/constants.dart';
import '../../../services/aut_service.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      var autService = AuthService();
      await autService
          .registerWithEmailAndPassword(email, password)
          .then((value) {
        if (value) {
          ShowMySnackbar.snackbarShow(
              context, true, "Kayıt işlemi başarılıyla gerçekleştirildi.");
          Navigator.pop(context);
        } else {
          ShowMySnackbar.snackbarShow(
              context, false, "Bu Ad'a sahip başka bir kullanıcı var.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              validator: (value) {
                if (value != null && value.length <= 6) {
                  return "En az 6 karakterli email giriniz";
                } else {
                  if (value == null || value.isEmpty) {
                    return 'Email adresi boş olamaz';
                  }
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
                  if (value != null && value.length < 6) {
                    return "En az 6 karakterli şifre giriniz";
                  } else {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz';
                    }
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Şifre",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            ElevatedButton(
              onPressed: _register,
              child: Text("Kayıt ol".toUpperCase()),
            ),
            const SizedBox(height: defaultPadding),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
