import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:coursaty_student_and_teacher/core/error/failures.dart';
import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/core/use_case/use_case.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/academic_years_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/colleges_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/departments_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/guest_account_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/profile_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/data/model/universities_model.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/change_password_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/create_guest_account_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/delete_account_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/edit_profile_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_academic_years_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_colleges_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_departments_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_guest_account_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_profile_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/get_universities_usecase.dart';
import 'package:coursaty_student_and_teacher/features/auth/domain/use_case/update_student_usecase.dart';
import 'package:coursaty_student_and_teacher/features/common/data/models/upload_file_response_model.dart';
import 'package:coursaty_student_and_teacher/features/common/domain/usecases/upload_file_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/request_status.dart';
import '../../data/model/auth_model.dart';
import '../../domain/use_case/log_in_use_case.dart';
import '../../domain/use_case/sign_up_use_case.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@LazySingleton()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final LogInUseCase logInUseCase;
  final GetUniversitiesUsecase getUniversitiesUsecase;
  final GetCollegesUsecase getCollegesUsecase;
  final GetDepartmentsUsecase getDepartmentsUsecase;
  final GetAcademicYearsUsecase getAcademicYearsUsecase;
  final GetProfileUsecase getProfileUsecase;
  final EditProfileUsecase editProfileUsecase;

  final CreateGuestAccountUsecase createGuestAccountUsecase;
  final GetGuestAccountUsecase getGuestAccountUsecase;
  final UpdateStudentUsecase updateStudentUsecase;

  final UploadFileUsecase uploadFileUsecase;
  final ChangePasswordUsecase changePasswordUsecase;

  final DeleteAccountUsecase deleteAccountUsecase;

  AuthBloc(
    this.logInUseCase,
    this.signUpUseCase,
    this.getUniversitiesUsecase,
    this.getCollegesUsecase,
    this.getDepartmentsUsecase,
    this.getAcademicYearsUsecase,
    this.getProfileUsecase,
    this.editProfileUsecase, {
    required this.createGuestAccountUsecase,
    required this.getGuestAccountUsecase,
    required this.updateStudentUsecase,
    required this.uploadFileUsecase,
    required this.changePasswordUsecase,
    required this.deleteAccountUsecase,
  }) : super(AuthState()) {
    on<SignUpEvent>(_onSignUpEvent);
    on<LogInEvent>(_onLogInEvent);
    on<GetUniversitiesEvent>(_onGetUniversitiesEvent);
    on<GetCollegesEvent>(_onGetCollegesEvent);
    on<GetDepartmentsEvent>(_onGetDepartmentsEvent);
    on<GetAcademicYearsEvent>(_onGetAcademicYearsEvent);
    on<GetProfileEvent>(_onGetProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<ClearAuthState>(_onClearState);
    on<GetGuestEvent>(_onGetGuestEvent);
    on<CreateGuestEvent>(_onCreateGuestEvent);
    on<UpdateStudentEvent>(_onUpdateStudentEvent);
    on<ChangePasswordEvent>(_onChangePasswordEvent);
    on<DeleteAccountEvent>(_onDeleteAccountEvent);
  }

  final PrefsRepository prefs = GetIt.I<PrefsRepository>();

  void _saveUser(AuthModel data, String name) {
    prefs.setToken(data.accessToken!);
    prefs.setIsGuest(false);
    prefs.setUserId(data.user!.id!);
    _saveName(data.user!.phone!);
    prefs.setUserType(data.user!.userableType!);
    _saveName(name);
  }

  void _saveStudyInfo(
    String universityId,
    String collegeId,
    String? departmentId,
  ) {
    prefs.setUniversityId(universityId);
    prefs.setCollegeId(collegeId);
    if (departmentId != null) {
      prefs.setDepartmentId(departmentId);
    } else {
      prefs.removeDepartmentId();
    }
  }

  void _saveYearCollegeId(String id) {
    prefs.setYearCollegeId(id);
  }

  void _saveName(String name) {
    prefs.setName(name);
  }

  void _saveGender(String gender) {
    prefs.setGender(gender);
  }

  void _savePhone(String phone) {
    prefs.setPhone(phone);
  }

  void _saveUniversityNumber(String number) {
    prefs.setUniversityNumber(number);
  }

  FutureOr<void> _onSignUpEvent(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(createUser: Status.loading));
    final res = await signUpUseCase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(createUser: Status.failure, errorMessage: l.message),
      ),
      (r) {
        _saveUser(r, event.params.name);
        _saveGender(event.params.gender);
        emit(state.copyWith(authModel: r, createUser: Status.loaded));
      },
    );
  }

  FutureOr<void> _onLogInEvent(
    LogInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(authStatus: Status.loading));
    final res = await logInUseCase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(authStatus: Status.failure, errorMessage: l.message),
      ),
      (r) {
        _saveUser(r, ''); // name is missing
        _saveGender(r.user?.gender ?? '');
        _savePhone(r.user?.phone ?? '');
        _disableGuest();
        emit(state.copyWith(authModel: r, authStatus: Status.loaded));
      },
    );
  }

  FutureOr<void> _onGetUniversitiesEvent(
    GetUniversitiesEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getUniversities: Status.loading));
    final res = await getUniversitiesUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getUniversities: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        emit(
          state.copyWith(
            getUniversities: Status.loaded,
            universitiesResponseModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetProfileEvent(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(profileStatus: Status.loading));
    final res = await getProfileUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          profileStatus: Status.failure,
          errorMessage: l.message,
          failure: l,
        ),
      ),
      (r) {
        _saveName(r.student?.name ?? r.teacher?.name ?? '');
        _saveYearCollegeId(r.student?.collegeYearId ?? '');
        _saveStudyInfo(
          r.student?.universityId ?? '',
          r.student?.collegeId ?? '',
          r.student?.departmentId,
        );
        _saveUniversityNumber(r.student?.universityNumber ?? '');
        if (r.user?.gender != null) {
          _saveGender(r.user?.gender ?? '');
        }
        if (r.user?.phone != null) {
          _savePhone(r.user?.phone ?? '');
        }
        emit(state.copyWith(profileStatus: Status.loaded, profileModel: r));
      },
    );
  }

  FutureOr<void> _onGetCollegesEvent(
    GetCollegesEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getColleges: Status.loading));
    final res = await getCollegesUsecase(event.universityId);
    res.fold(
      (l) => emit(
        state.copyWith(getColleges: Status.failure, errorMessage: l.message),
      ),
      (r) {
        emit(
          state.copyWith(getColleges: Status.loaded, collegesResponseModel: r),
        );
      },
    );
  }

  FutureOr<void> _onGetDepartmentsEvent(
    GetDepartmentsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getDepartments: Status.loading));
    final res = await getDepartmentsUsecase(event.collegeId);
    res.fold(
      (l) => emit(
        state.copyWith(getDepartments: Status.failure, errorMessage: l.message),
      ),
      (r) {
        emit(
          state.copyWith(
            getDepartments: Status.loaded,
            departmentsResponseModel: r,
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetAcademicYearsEvent(
    GetAcademicYearsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getYears: Status.loading));
    final res = await getAcademicYearsUsecase(event.collegeId);
    res.fold(
      (l) => emit(
        state.copyWith(getYears: Status.failure, errorMessage: l.message),
      ),
      (r) {
        List<AcademicYearsResponseModel> data = List.of(r);
        data.removeWhere((item) => !(item.isActive ?? true));
        emit(
          state.copyWith(
            getYears: Status.loaded,
            academicYearsResponseModel: data,
          ),
        );
      },
    );
  }

  FutureOr<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(updateProfileStatus: Status.loading));
    UploadFileResponseModel? uploadFileResponseModel;
    if (event.image != null) {
      final res = await uploadFileUsecase(
        UploadFileParams(file: File(event.image!.path)),
      );
      res.fold(
        (l) {
          emit(
            state.copyWith(
              updateProfileStatus: Status.failure,
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          uploadFileResponseModel = r;
          log(r.toJson().toString());
          event.params.imageUrl = uploadFileResponseModel!.fileUrl;
        },
      );
    }
    if (event.image != null && uploadFileResponseModel == null) {
      emit(
        state.copyWith(
          updateProfileStatus: Status.failure,
          errorMessage: "حدث خطأ ما",
        ),
      );
      return;
    }
    final res = await editProfileUsecase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(
          updateProfileStatus: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        if (event.params.name != null) {
          _saveName(event.params.name!);
        }
        if (event.params.gender != null) {
          _saveGender(event.params.gender!);
        }
        if (event.params.phone != null) {
          _savePhone(event.params.phone!);
        }
        if (event.params.universityNumber != null) {
          _saveUniversityNumber(event.params.universityNumber!);
        }
        add(GetProfileEvent());
        emit(state.copyWith(updateProfileStatus: Status.loaded));
      },
    );
  }

  FutureOr<void> _onClearState(ClearAuthState event, Emitter<AuthState> emit) {
    emit(AuthState());
  }

  FutureOr<void> _onGetGuestEvent(
    GetGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getOrCreateGuest: Status.loading));
    final res = await getGuestAccountUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(
          getOrCreateGuest: Status.failure,
          isNotFoundGuestError: l is NotFoundFailure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        _saveName("ضيف كورساتي");
        _savePhone("أنت الآن في وضع الزائر");
        prefs.setUserType("STUDENT");
        _saveStudyInfo(r.universityId!, r.collegeId!, r.departmentId);
        if (r.collegeYearId != null) {
          _saveYearCollegeId(r.collegeYearId!);
        }
        emit(
          state.copyWith(getOrCreateGuest: Status.loaded, guestAccountModel: r),
        );
      },
    );
  }

  FutureOr<void> _onCreateGuestEvent(
    CreateGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getOrCreateGuest: Status.loading));
    final res = await createGuestAccountUsecase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(
          getOrCreateGuest: Status.failure,
          errorMessage: l.message,
        ),
      ),
      (r) {
        _saveName("ضيف كورساتي");
        _savePhone("أنت الآن في وضع الزائر");
        prefs.setUserType("STUDENT");
        _saveStudyInfo(r.universityId!, r.collegeId!, r.departmentId);
        _saveYearCollegeId(event.params.yearCollegeId);
        emit(
          state.copyWith(getOrCreateGuest: Status.loaded, guestAccountModel: r),
        );
      },
    );
  }

  void _disableGuest() {
    prefs.setIsGuest(false);
  }

  FutureOr<void> _onUpdateStudentEvent(
    UpdateStudentEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(updateStudent: Status.loading));
    final response = await updateStudentUsecase(event.params);
    response.fold(
      (l) {
        emit(
          state.copyWith(
            updateStudent: Status.failure,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        _saveStudyInfo(
          event.params.universityId,
          event.params.collegeId,
          event.params.departmentId,
        );
        _saveYearCollegeId(event.params.collegeYearId);
        emit(state.copyWith(updateStudent: Status.loaded));
      },
    );
  }

  FutureOr<void> _onChangePasswordEvent(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(changePassword: Status.loading));
    final res = await changePasswordUsecase(event.params);
    res.fold(
      (l) => emit(
        state.copyWith(changePassword: Status.failure, errorMessage: l.message),
      ),
      (r) {
        emit(state.copyWith(changePassword: Status.loaded));
      },
    );
  }

  FutureOr<void> _onDeleteAccountEvent(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(authStatus: Status.loading));
    final res = await deleteAccountUsecase(NoParams());
    res.fold(
      (l) => emit(
        state.copyWith(authStatus: Status.failure, errorMessage: l.message),
      ),
      (r) {
        emit(state.copyWith(authStatus: Status.loaded));
      },
    );
  }
}
