import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import 'color_wedgit.dart';

class ImageItemLayout extends StatefulWidget {
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
  State<ImageItemLayout> createState() => _ImageItemLayoutState();
}

class _ImageItemLayoutState extends State<ImageItemLayout> {
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        MyTextForm(
          controller: widget.imageItemNoteController,
          title: S.of(context).itemNote,
        ),
        SizedBox(height: 10.h),
        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                _pickImage();
              },
              child: Column(
                children: [
                  SizedBox(
                    width: 300.w,
                    height: 200.h,
                    child: Card(
                      child:
                          widget.image != null
                              ? Image.file(widget.image!, fit: BoxFit.cover)
                              : widget.url != null
                              ? Image.network(widget.url!)
                              : Center(child: Text("Add Image +")),
                    ),
                  ),
                ],
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
      widget.onImagePicked(File(pickedFile.path));
    }
  }
}
