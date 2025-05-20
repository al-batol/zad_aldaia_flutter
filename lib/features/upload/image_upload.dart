import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/features/upload/upload_cubit.dart';

class ImageUpload extends StatefulWidget {
  final String? url;
  final String? identifier;
  final Function(String?, String?) onImageUpdated;

  const ImageUpload({super.key, required this.onImageUpdated, this.url, this.identifier});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? image;
  late UploadCubit cubit = getIt<UploadCubit>();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      final now = DateTime.now().toIso8601String(); // image!.path
      cubit.upload(image!, now);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Stack(
          children: [
            SizedBox(
              height: 200,
              child: GestureDetector(
                onTap: _pickImage,
                child: BlocProvider(
                  create: (context) => cubit,
                  child: BlocListener<UploadCubit, UploadState>(
                    listener: (context, state) {
                      if (state is UploadedState) {
                        widget.onImageUpdated(state.identifier, state.url);
                      }
                    },
                    child: BlocBuilder<UploadCubit, UploadState>(
                      builder: (context, state) {
                        return Card(
                          child:
                              image != null
                                  ? Image.file(image!, fit: BoxFit.cover)
                                  : widget.url != null
                                  ? CachedNetworkImage(imageUrl: widget.url!)
                                  : Center(child: Text("Add Image +")),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            if (widget.identifier != null) IconButton(onPressed: () => cubit.delete(widget.identifier!), icon: Icon(Icons.close)),
          ],
        ),
      ],
    );
  }
}
