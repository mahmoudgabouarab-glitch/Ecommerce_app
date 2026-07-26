import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/utils/user_cache.dart';
import '../../../data/repo/profile_repo.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(
    this._repo, {
    String? name,
    String? phone,
    this.showPhone = false,
    String? bio,
    this.gender,
    this.birthDate,
    String? avatarUrl,
  }) : super(EditProfileInitial(avatarUrl)) {
    nameController.text = name ?? '';
    phoneController.text = phone ?? '';
    bioController.text = bio ?? '';
    _avatarUrl = avatarUrl;
  }

  final ProfileRepo _repo;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? gender;
  String? birthDate;
  bool showPhone;

  String? _pickedPath;
  String? _avatarUrl;

  String? get pickedPath => _pickedPath;
  String? get avatarUrl => _avatarUrl;

  void setGender(String value) {
    gender = value;
    emit(EditProfileChanged());
  }

  void setShowPhone(bool value) {
    showPhone = value;
    emit(EditProfileChanged());
  }

  void setBirthDate(DateTime date) {
    birthDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    emit(EditProfileChanged());
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (file != null) {
      _pickedPath = file.path;
      emit(EditProfileImagePicked(file.path));
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    emit(EditProfileSaving());
    final result = await _repo.updateProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      showPhone: showPhone,
      gender: gender,
      birthDate: birthDate,
      bio: bioController.text.trim(),
      avatarPath: _pickedPath,
    );
    await result.fold(
      (failure) async => emit(EditProfileFailure(failure.errorMessage)),
      (user) async {
        await UserCache.save(user);
        emit(EditProfileSuccess());
      },
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    return super.close();
  }
}
