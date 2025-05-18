import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageContainer extends StatelessWidget {
  final String flagAsset;
  final String languageName;
  final VoidCallback onTap;

  const LanguageContainer({
    super.key,
    required this.flagAsset,
    required this.languageName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Image.asset(
              flagAsset,
              height: 30.h,
              width: 30.w,
            ),
            SizedBox(width: 16.w),
            Text(
              languageName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
