part of 'sales_points_bloc.dart';

@immutable
sealed class SalesPointsEvent {}

class GetSalesPointsEvent extends SalesPointsEvent {
  GetSalesPointsEvent();
}

class ClearSalesPointsState extends SalesPointsEvent {}
