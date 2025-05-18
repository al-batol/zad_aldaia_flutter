import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/my_colors.dart';
import '../../../../core/theming/my_text_style.dart';

class ColorPickerWidget extends StatefulWidget {
  final Function(String) onColorSelected;
  final String initialColor;

  const ColorPickerWidget({
    super.key,
    required this.onColorSelected,
    this.initialColor = "#FFFFFF",
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late String selectedColor;

  final List<String> colorOptions = [
    "#FFFFFF",
    "#F5F5DC",
    "#FFE4E1",
    "#E6E6FA",
    "#F0FFF0",
    "#F0FFFF",
    "#FFFACD"

  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Background Color",
          style: MyTextStyle.font14BlackRegular,
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
                widget.onColorSelected(color);
              },
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: HexColor(color),
                  border: Border.all(
                    color: selectedColor == color
                        ? MyColors.primaryColor
                        : Colors.grey,
                    width: selectedColor == color ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}