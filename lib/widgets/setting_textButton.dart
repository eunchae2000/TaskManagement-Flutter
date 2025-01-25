import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData leadingIcon;
  final String text;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color trailingIconColor;

  const CustomTextButton({
    Key? key,
    required this.onPressed,
    required this.leadingIcon,
    required this.text,
    this.backgroundColor = const Color(0x10ffe7d6),
    this.iconColor = const Color(0xff2f4858),
    this.textColor = const Color(0xff2f4858),
    this.trailingIconColor = const Color(0xff2f4858),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leadingIcon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: trailingIconColor,
          ),
        ],
      ),
    );
  }
}
