import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:rasid_test/Core/util/custom_btn.dart';

class FinishTaskView extends StatelessWidget {
  const FinishTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/check.png",
              width: 150,
            ),
            const Gap(16),
            const Text(
              "Thank you for you time",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const Gap(12),
            const Text(
              textAlign: TextAlign.center,
              "We will review your application \nand get back to you.",
            ),
            const Gap(40),
            CustomBtn(
              onPressed: () {
                SystemNavigator.pop();
              },
              text: "Close the application",
            ),
          ],
        ),
      ),
    );
  }
}
