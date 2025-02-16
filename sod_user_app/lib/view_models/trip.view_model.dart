import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/requests/trip.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class TripViewModel extends MyBaseViewModel {
  List<Trip> tripsCompleted = [];
  List<Trip> tripsPending = [];
  TripRequest request = TripRequest();
  RefreshController refreshController = RefreshController();
  RefreshController completed_RC = RefreshController();
  

  initialise() async {
    setBusy(true);
    await getTripCompleted();
    await getTripPendingAndInProgress();
    setBusy(false);
    notifyListeners();
  }

  
  getTripCompleted({bool getTrip = false}) async {
    try {
      setBusy(true);
      tripsCompleted = await request.getTripCompleted();
      completed_RC.refreshCompleted();
      if (getTrip) setBusy(false);
    } catch (e) {
      print('Error: $e');
    }
  }

  getTripPendingAndInProgress({bool getTrip = false}) async {
    try {
      setBusy(true);
      tripsPending = await request.getTripPendingAndInProgress();
      print('Số lượng request: ${tripsPending.length}');
      refreshController.refreshCompleted();
      if (getTrip) setBusy(false);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> cancelTrip(int id) async {
    try {
      bool checkCancel;
      checkCancel = await request.cancelTrip(id);
      await getTripPendingAndInProgress(getTrip: true);
      notifyListeners();
      return checkCancel;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> depositedTrip(int id) async {
    try {
      bool checkCancel;
      checkCancel = await request.depositedTrip(id);
      notifyListeners();
      return checkCancel;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> acceptTrip(int id) async {
    try {
      bool checkAccept;
      checkAccept = await request.acceptTrip(id);
      await getTripPendingAndInProgress(getTrip: true);
      notifyListeners();
      return checkAccept;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> completedTrip(int id) async {
    try {
      bool checkAccept;
      checkAccept = await request.completedTrip(id);
      await getTripPendingAndInProgress(getTrip: true);
      notifyListeners();
      return checkAccept;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
