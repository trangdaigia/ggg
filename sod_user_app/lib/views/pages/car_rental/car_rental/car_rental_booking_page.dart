import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/booking_result.dart';
import 'package:sod_user/views/pages/car_rental/widgets/custom_rules_list.dart';

class CarRentalBookingPage extends StatefulWidget {
  final CarRentalViewModel model;
  const CarRentalBookingPage({
    super.key,
    required this.model,
  });

  @override
  State<CarRentalBookingPage> createState() => _CarRentalBookingPageState();
}

class _CarRentalBookingPageState extends State<CarRentalBookingPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> requirements =
        widget.model.carDetail.requirementsForRent != null
            ? List<String>.from(
                json.decode(widget.model.carDetail.requirementsForRent!))
            : [];
    final List<String> rulesShort = [
      "- Sử dụng xe đúng mục đích.",
      "- Không sang nhượng hợp đồng.",
      "- Không cắt định vị với bất kỳ lý do gì.",
      "- Không chở hàng quốc cấm dễ cháy nổ.",
      "- Không chở hoa quả, thực phẩm nặng mùi trong xe."
    ];
    final List<String> rulesFull = [
      "- Sử dụng xe đúng mục đích.",
      "- Không sang nhượng hợp đồng.",
      "- Không cắt định vị với bất kỳ lý do gì.",
      "- Không chở hàng quốc cấm dễ cháy nổ.",
      "- Không chở hoa quả, thực phẩm nặng mùi trong xe.",
      "- Không sử dụng xe thuê để bán hay cầm cố thế chấp.",
      "- Không sử dụng xe thuê vào mục đích phi pháp, trái pháp luật.",
      "- Trường hợp vi phạm luật giao thông trong thời gian thuê (kể cả việc không bị xử phạt tại chỗ nhưng khi có biên bản gửi về) hoặc lưu thông qua những nơi bắn tốc độ tự động và phạt nguội (như cao tốc, hầm vượt sông,...). Khách hàng sẽ phải thanh toán tiền phạt cho chủ xe lúc có biên bản gửi về theo đúng mức xử phạt của cơ quan chức năng và phải trả tiền thuê xe trong thời gian chờ xử lý vi phạm giao thông (giam xe) tính như giá thuê ở trên.",
    ];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Thông tin đặt xe".tr(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width * (40 / 100),
                          height:
                              MediaQuery.of(context).size.width * (25 / 100),
                          // imageUrl: data.photo!.isNotEmpty ? data.photo!.first : '',
                          imageUrl:
                              "https://carshop.vn/wp-content/uploads/2022/07/hinh-nen-xe-oto-dep-1.jpg",
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                                  color: AppColor.primaryColor),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.model.carDetail.carModel?.carMake?.name ?? ''} ${widget.model.carDetail.carModel?.name ?? ''} ${widget.model.carDetail.yearMade ?? ''}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Địa điểm giao nhận xe'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    Icon(Icons.add_location),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.model.addressController.text,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Ngày đặt'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: Text(
                        "start_date".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2040))
                            .then((value) {
                          setState(() {
                            widget.model.startDate = DateTime.parse(
                                DateFormat('yyyy-MM-dd 00:00:00')
                                    .format(value!));
                          });
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(widget.model.startDate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: Text(
                        "end_date".tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        showDatePicker(
                                context: context,
                                initialDate: widget.model.startDate,
                                firstDate: widget.model.startDate,
                                lastDate: DateTime(2040))
                            .then((value) {
                          setState(() {
                            widget.model.endDate = DateTime.parse(
                                DateFormat('yyyy-MM-dd 00:00:00')
                                    .format(value!));
                          });
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(widget.model.endDate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Chi tiết giá'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Number of days'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${daysBetween(widget.model.startDate, widget.model.endDate)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Column(
                            children: [
                              Text(
                                "${NumberFormat.currency(locale: "vi_VN", symbol: "").format(widget.model.carDetail.vehicleRentPrice != null ? widget.model.carDetail.vehicleRentPrice?.priceMondayFriday : 0).trim()}đ/ngày (${"T2-T6"})",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "${NumberFormat.currency(locale: "vi_VN", symbol: "").format(widget.model.carDetail.vehicleRentPrice != null ? widget.model.carDetail.vehicleRentPrice?.priceSaturdaySunday : 0).trim()}đ/ngày (${"T7-CN"})",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${NumberFormat.currency(locale: "vi_VN", symbol: "").format(widget.model.carDetail.vehicleRentPrice != null ? totalPrice(widget.model.startDate, widget.model.endDate, widget.model.carDetail.vehicleRentPrice != null ? widget.model.carDetail.vehicleRentPrice!.priceMondayFriday! : 0, widget.model.carDetail.vehicleRentPrice != null ? widget.model.carDetail.vehicleRentPrice!.priceSaturdaySunday! : 0) : 0).trim()}đ",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Text(
                  'Giấy tờ cần chuẩn bị'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListView.builder(
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemCount: (requirements.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              requirements[index * 2],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          if (index * 2 + 1 < requirements.length)
                            Expanded(
                              child: Text(
                                requirements[index * 2 + 1],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Text(
                  'Điều khoản'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: CustomRulesList(
                    itemsFull: rulesFull,
                    itemsShort: rulesShort,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              child: Text(
                'Đặt xe ngay'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                // widget.model
                //     .addRentalRequest(
                //       totalPrice: '0',
                //       status: "pending",
                //       vehicleId: widget.model.carDetail.id!.toString(),
                //       debutDate: DateFormat('yyyy-MM-dd')
                //           .format(widget.model.startDate),
                //       expireDate:
                //           DateFormat('yyyy-MM-dd').format(widget.model.endDate),
                //       totalDays: daysBetween(
                //               widget.model.startDate, widget.model.endDate)
                //           .toString(),
                //       contactPhone: '',
                //     )
                //     .whenComplete(
                //       () => Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => BookingResult(),
                //         ),
                //       ),
                //     );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays + 1;
  }

  int totalPrice(DateTime from, DateTime to, int price26, int price7cn) {
    int total = 0;
    for (int i = 0; i <= to.difference(from).inDays + 1; i++) {
      DateTime currentDay = from.add(Duration(days: i));
      int weekday = currentDay.weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        total += price7cn;
      } else {
        total += price26;
      }
    }
    return total;
  }
}
