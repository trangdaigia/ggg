import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/user.dart';

class Trip {
  int? id;
  String? totalDays;
  String? debutDate;
  String? expireDate;
  String? contactPhone;
  String? status;
  User? user;
  CarRental? vehicle;
  int? totalPrice;
  bool? deposit;
  bool? isSelfDriving;
  String? created_at;
  int? route;
  String? pickup_latitude;
  String? pickup_longitude;
  String? dropoff_latitude;
  String? dropoff_longitude;
  bool? delivery_to_home;
  int? deliveryFee;
  int? subTotal;
  String? orderCode;
  String? paymentLink;
  Trip({
    this.id,
    this.totalDays,
    this.debutDate,
    this.expireDate,
    this.contactPhone,
    this.status,
    this.user,
    this.vehicle,
    this.totalPrice,
    this.deposit,
    this.isSelfDriving,
    this.created_at,
    this.route,
    this.pickup_latitude,
    this.pickup_longitude,
    this.dropoff_latitude,
    this.dropoff_longitude,
    this.delivery_to_home,
    this.deliveryFee,
    this.subTotal,
    this.orderCode,
    this.paymentLink,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      totalDays: json['total_days'].toString(),
      debutDate: json['debut_date'],
      expireDate: json['expire_date'],
      contactPhone: json['contact_phone'],
      status: json['status'],
      user: User.fromJson(json['user']),
      vehicle:
          json['vehicle'] == null ? null : CarRental.fromJson(json['vehicle']),
      totalPrice: json["total_price"],
      deposit: json["deposit"] == 1 ? true : false,
      isSelfDriving: json["is_self_driving"] == 1 ? true : false,
      created_at: json["created_at"],
      route: json["route"] ?? 0,
      pickup_latitude: json["pickup_latitude"] ?? '0',
      pickup_longitude: json["pickup_longitude"] ?? '0',
      dropoff_latitude: json["dropoff_latitude"] ?? '0',
      dropoff_longitude: json["dropoff_longitude"] ?? '0',
      delivery_to_home: json["delivery_to_home"] == 1 ? true : false,
      deliveryFee: json["deliveryFee"],
      subTotal: json["sub_total"] ?? 0,
      orderCode: json["order_code"] ?? '',
      paymentLink: json["payment_link"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_days': totalDays,
      'debut_date': debutDate,
      'expire_date': expireDate,
      'contact_phone': contactPhone,
      'status': status,
      'user': user?.toJson(),
      'vehicle': vehicle?.toJson(),
    };
  }
}
