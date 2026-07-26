import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repo/auth_repo.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._repo) : super(SignupInitial());

  final AuthRepo _repo;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();
  String? avatarPath; // chosen profile photo

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (file != null) {
      avatarPath = file.path;
      emit(SignupImagePicked(file.path));
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    emit(SignupLoading());
    final result = await _repo.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: confirmController.text,
      phone: phoneController.text.trim(),
      avatarPath: avatarPath,
    );

    result.fold(
      (failure) => emit(SignupFailure(failure.errorMessage)),
      (email) => emit(SignupCodeSent(email)),
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    return super.close();
  }
}
