import '../../data/models/vendor_dashboard_summary_model.dart';

abstract class VendorDashboardRepository {
  Future<VendorDashboardSummaryModel> getSummary();
}
