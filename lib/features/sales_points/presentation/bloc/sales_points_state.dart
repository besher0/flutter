part of 'sales_points_bloc.dart';

class SalesPointsState {
  final Status getSalesPointsStatus;
  final List<SalePoint> salesPoints;
  final String errorMessage;

  SalesPointsState({
    this.getSalesPointsStatus = Status.init,
    this.salesPoints = const [],
    this.errorMessage = '',
  });

  SalesPointsState copyWith({
    final Status? getSalesPointsStatus,
    final List<SalePoint>? salesPoints,
    final String? errorMessage,
  }) => SalesPointsState(
    getSalesPointsStatus: getSalesPointsStatus ?? this.getSalesPointsStatus,
    salesPoints: salesPoints ?? this.salesPoints,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
