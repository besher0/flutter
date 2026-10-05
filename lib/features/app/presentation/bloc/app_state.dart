part of 'app_bloc.dart';

class AppState {
  final Status scanCode, getCustomerService;
  final CustomerServiceModel? customerServiceModel;
  final String errorMessage;
  final bool isThemeLight;
  final String? currentScannedCourseId;

  AppState({
    this.getCustomerService = Status.init,
    this.scanCode = Status.init,
    this.customerServiceModel,
    this.errorMessage = '',
    this.isThemeLight = true,
    this.currentScannedCourseId,
  });

  AppState copyWith({
    final Status? scanCode,
    getCustomerService,
    final CustomerServiceModel? customerServiceModel,
    final String? errorMessage,
    final String? currentScannedCourseId,
    final bool? isThemeLight,
  }) {
    return AppState(
      scanCode: scanCode ?? this.scanCode,
      errorMessage: errorMessage ?? this.errorMessage,
      isThemeLight: isThemeLight ?? this.isThemeLight,
      currentScannedCourseId:
          currentScannedCourseId ?? this.currentScannedCourseId,
      getCustomerService: getCustomerService ?? this.getCustomerService,
      customerServiceModel: customerServiceModel ?? this.customerServiceModel,
    );
  }
}
