import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "WELCOME TO ",
                style: TextStyle(
                  color: Colors.black, // Màu đen
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "QUETDI",
                style: TextStyle(
                  color: Colors.blue, // Màu xanh
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ".COM",
                style: TextStyle(
                  color: Colors.red, // Màu đỏ
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                "assets/icons/chat.svg",
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}