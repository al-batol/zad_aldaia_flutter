import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/helpers/font_weight_helper.dart';

class CircularImageButton extends StatelessWidget {
  final String image;
  final Color color;
  final String title;
  final Function() onPressed;

  const CircularImageButton({
    super.key,
    required this.image,
    required this.color,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(),
      elevation: 3,
      color: color,
      shape: CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(5.w),
        width: 100.w,
        height: 100.h,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              image,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeightHelper.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
