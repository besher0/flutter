import 'package:coursaty_student_and_teacher/features/sales_points/presentation/bloc/sales_points_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/widgets/loading_indicator/coursaty_app_loader.dart';
import '../../../../app/widgets/title_app_bar.dart';
import '../../../../core/common/constant/configuration/feature_flags.dart';
import '../widgets/point_of_sale_card.dart';

class PointsOfSaleListScreen extends StatefulWidget {
  const PointsOfSaleListScreen({super.key});

  @override
  State<PointsOfSaleListScreen> createState() => _PointsOfSaleListScreenState();
}

class _PointsOfSaleListScreenState extends State<PointsOfSaleListScreen> {
  @override
  void initState() {
    super.initState();
    if (SubscriptionFeatureFlags.showLegacySubscriptionMethods) {
      BlocProvider.of<SalesPointsBloc>(context).add(GetSalesPointsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: TitleAppBar(title: 'نقاط البيع'),
        body: SafeArea(
          child: BlocBuilder<SalesPointsBloc, SalesPointsState>(
            builder: (context, state) {
              return state.getSalesPointsStatus.isLoading
                  ? Center(child: CoursatyAppLoader())
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (SubscriptionFeatureFlags
                            .showLegacySubscriptionMethods) {
                          BlocProvider.of<SalesPointsBloc>(
                            context,
                          ).add(GetSalesPointsEvent());
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: state.salesPoints.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          return PointOfSaleCard(
                            salePoint: state.salesPoints[i],
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
