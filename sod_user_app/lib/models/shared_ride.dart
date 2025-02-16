import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';

class SharedRide {
  int? id;
  int? userID;
  String? departureName;
  String? destinationName;
  int? numberOfSeat;
  String? duration;
  String? status;
  String? distance;
  String? startDate;
  String? startTime;
  String? endTime;
  int? price;
  String? minPrice;
  String? maxPrice;
  String? note;
  String? cancelReason;
  User? user;
  Vehicle? vehicle;
  String? type;
  PackageDetail? package;
  List<Order>? orders;

  SharedRide({
    this.id,
    this.userID,
    this.departureName,
    this.destinationName,
    this.numberOfSeat,
    this.duration,
    this.status,
    this.distance,
    this.startDate,
    this.startTime,
    this.endTime,
    this.price,
    this.minPrice,
    this.maxPrice,
    this.note,
    this.cancelReason,
    this.user,
    this.vehicle,
    this.type,
    this.package,
    this.orders,
  });
  bool get expired => DateTime.now().isAfter(
      DateTime.parse("${startDate?.split("-").reversed.join("-")}T$startTime"));
  bool get isMine => userID == (AuthServices.currentUser?.id ?? 0);
  factory SharedRide.fromJson(Map<String, dynamic> json) {
    return SharedRide(
      id: json['id'],
      userID: json['user_id'],
      departureName: json['departure_name'],
      destinationName: json['destination_name'],
      numberOfSeat: json['number_of_seat'] ?? 0,
      duration: json['duration'],
      status: json['status'],
      distance: json['distance'],
      startDate: json['start_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      price: json['price'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      cancelReason: json['cancel_reason'] == null ? '' : json['cancel_reason'],
      note: json['note'] == null ? '' : json['note'],
      user: User.fromJson(json['user']),
      vehicle:
          json['vehicle'] == null ? null : Vehicle.fromJson(json['vehicle']),
      type: json['type'],
      package: json['package_details'] == null
          ? null
          : PackageDetail.fromJson(json['package_details']),
      orders: json['orders'] == null
          ? []
          : List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userID;
    data['departure_name'] = departureName;
    data['destination_name'] = destinationName;
    data['number_of_seat'] = numberOfSeat;
    data['status'] = status;
    data['distance'] = distance;
    data['start_date'] = startDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['price'] = price;
    data['min_price'] = minPrice;
    data['max_price'] = maxPrice;
    data['note'] = note;
    data['cancel_reason'] = cancelReason;
    return data;
  }
}

class PackageDetail {
  String? width;
  String? height;
  String? length;
  String? weight;
  String? price;

  PackageDetail(
      {this.width, this.height, this.length, this.weight, this.price});

  PackageDetail.fromJson(Map<String, dynamic> json) {
    width = json['width'];
    height = json['height'];
    length = json['length'];
    weight = json['weight'];
    price = json['price'];
  }
}
