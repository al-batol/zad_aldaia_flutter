import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/routing/routes.dart';
import '../../core/theming/my_colors.dart';
import '../../core/theming/my_text_style.dart';
import '../../generated/assets.dart';
import '../../generated/l10n.dart';
import '../home/logic/home_cubit.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final GlobalKey<FormState> adminPasswordFormKey = GlobalKey();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  String? passwordError;
  bool checkingPassword = false;

  late final HomeCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>();
  }

  void _onRoleSelected(BuildContext context, String role) {
    if (role == 'Preacher') {
      Navigator.popAndPushNamed(context, MyRoutes.homeScreen);
    } else if (role == 'Admin') {
      _showAdminPasswordDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 120),
            Center(
              child: const Text(
                'Please select account type',
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 23),
              ),
            ),
            const SizedBox(height: 50),
            _buildRoleCard(context, title: 'Preacher', image: Assets.quran),
            const SizedBox(height: 20),
            _buildRoleCard(context, title: 'Admin', image: Assets.admin),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String image,
  }) {
    return GestureDetector(
      onTap: () => _onRoleSelected(context, title),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset(image, height: 90.h, width: 90.w),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (builderContext, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter Admin Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: adminPasswordFormKey,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        errorText: passwordError,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (adminPasswordFormKey.currentState!.validate()) {
                            setState(() {
                              checkingPassword = true;
                            });
                            if (await cubit.signIn(passwordController.text)) {
                              passwordError = null;
                              Navigator.of(
                                context,
                              ).popAndPushNamed(MyRoutes.adminScreen);
                            } else {
                              setState(() {
                                passwordError = S.of(context).wrongPassword;
                              });
                            }
                            checkingPassword = false;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryColor,
                        ),
                        child:
                            checkingPassword == true
                                ? Center(
                                  child: SizedBox(
                                    width: 24.h,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  S.of(context).continu,
                                  style: MyTextStyle.font16WhiteBold,
                                ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
