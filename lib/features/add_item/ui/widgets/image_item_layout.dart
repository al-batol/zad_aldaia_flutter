import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class ImageItemLayout extends StatelessWidget {
  final TextEditingController imageItemNoteController;
  final File? image;
  final String? url;
  final Function(File) onImagePicked;

  const ImageItemLayout({
    super.key,
    required this.imageItemNoteController,
    required this.image,
    required this.onImagePicked,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextForm(
          controller: imageItemNoteController,
          title: S.of(context).itemNote,
        ),
        SizedBox(height: 10.h),
        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                _pickImage();
              },
              child: SizedBox(
                width: 300.w,
                height: 200.h,
                child: Card(
                  child:
                      image != null
                          ? Image.file(image!, fit: BoxFit.cover)
                          : url != null
                          ? Image.network(url!)
                          : Center(child: Text("Add Image +")),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }
}
