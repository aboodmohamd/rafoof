import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/auth/presentation/provider/auth_provider.dart';
import 'package:rafoof/features/home/presentation/provider/home_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      await context.read<AuthProvider>().login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final auth = context.watch<AuthProvider>();
    final bannerImage = context.watch<HomeProvider>().bannerProduct?.thumbnail;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.accent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(colors, bannerImage),
              Expanded(child: _buildForm(auth, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors, String? bannerImage) {
    return SizedBox(
      height: 250.h,
      child: Stack(
        children: [
          if (bannerImage != null)
            Positioned(
              right: 8.w,
              bottom: 6.h,
              width: 150.w,
              height: 150.w,
              child: AppNetworkImage(url: bannerImage, colors: colors),
            ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 20.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.onAccent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'R',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: colors.onAccent,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: 220.w,
                  child: Text(
                    AppStrings.welcomeBack,
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.12,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: 190.w,
                  child: Text(
                    AppStrings.signInSubtitle,
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 15.sp,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthProvider auth, AppColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(24.w, 26.h, 24.w, 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(AppStrings.username, colors),
              SizedBox(height: 7.h),
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                cursorColor: colors.ink,
                style: TextStyle(color: colors.ink, fontSize: 16.sp),
                decoration: _inputDecoration(colors),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? AppStrings.enterUsername
                    : null,
              ),
              SizedBox(height: 16.h),
              _buildLabel(AppStrings.password, colors),
              SizedBox(height: 7.h),
              TextFormField(
                controller: _passwordController,
                obscureText: auth.obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                cursorColor: colors.ink,
                style: TextStyle(color: colors.ink, fontSize: 16.sp),
                onFieldSubmitted: (_) => _signIn(),
                decoration: _inputDecoration(colors).copyWith(
                  suffixIcon: IconButton(
                    onPressed: () =>
                        context.read<AuthProvider>().togglePasswordVisibility(),
                    icon: Icon(
                      auth.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colors.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ),
                validator: (value) =>
                    (value ?? '').isEmpty ? AppStrings.enterPassword : null,
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<AuthProvider>().toggleKeepSignedIn(),
                child: SizedBox(
                  height: 44.h,
                  child: Row(
                    children: [
                      Checkbox(
                        value: auth.keepSignedIn,
                        activeColor: colors.ink,
                        checkColor: colors.onInk,
                        side: BorderSide(color: colors.borderStrong, width: 2),
                        onChanged: (_) =>
                            context.read<AuthProvider>().toggleKeepSignedIn(),
                      ),
                      Text(
                        AppStrings.keepSignedIn,
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.ink,
                    foregroundColor: colors.onInk,
                    disabledBackgroundColor: colors.ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  onPressed: auth.isLoading ? null : _signIn,
                  child: auth.isLoading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.onInk,
                          ),
                        )
                      : Text(
                          AppStrings.signIn,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.continueAsGuest,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colors.imageTile,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.ink, size: 18.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: colors.textBody,
                            fontSize: 13.sp,
                            height: 1.45,
                          ),
                          children: [
                            TextSpan(text: AppStrings.demoAccount),
                            TextSpan(
                              text: 'emilys',
                              style: TextStyle(
                                color: colors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' / '),
                            TextSpan(
                              text: 'emilyspass',
                              style: TextStyle(
                                color: colors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, AppColors colors) {
    return Text(
      text,
      style: TextStyle(
        color: colors.ink,
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(AppColors colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colors.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: colors.ink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
