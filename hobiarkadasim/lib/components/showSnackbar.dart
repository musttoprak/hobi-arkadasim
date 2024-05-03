import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ShowMySnackbar {
  static void snackbarShow(BuildContext context, bool isSuccess, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: false,
        content: Row(
          children: [
            SizedBox(
                width: 40,
                child: Lottie.asset(
                    isSuccess ? "assets/success.json" : "assets/fail.json")),
            const SizedBox(width: 12),
            Text(text, overflow: TextOverflow.ellipsis,maxLines: 1),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
