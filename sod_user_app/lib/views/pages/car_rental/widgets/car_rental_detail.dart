import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/car_rental_booking_page.dart';
import 'package:sod_user/views/pages/car_rental/widgets/custom_rules_list.dart';
import '../../../../view_models/car_rental.view_model.dart';

class CarRentalDetailPage extends StatefulWidget {
  final CarRentalViewModel model;
  const CarRentalDetailPage({
    super.key,
    required this.model,
  });

  @override
  State<CarRentalDetailPage> createState() => _CarRentalDetailPageState();
}

class _CarRentalDetailPageState extends State<CarRentalDetailPage> {
  @override
  Widget build(BuildContext context) {
    List<String>? utilities = widget.model.carDetail.utilities != null
        ? List<String>.from(json.decode(widget.model.carDetail.utilities!))
        : [];
    final List<String> requirements =
        widget.model.carDetail.requirementsForRent != null
            ? List<String>.from(
                json.decode(widget.model.carDetail.requirementsForRent!))
            : [];
    final List<String> imgList = [
      'https://static-images.vnncdn.net/files/publish/2022/11/25/311338920-10160044701721131-7204310483297976059-n-149.jpeg',
      'https://static-images.vnncdn.net/files/publish/2022/11/25/311338920-10160044701721131-7204310483297976059-n-149.jpeg',
      'https://static-images.vnncdn.net/files/publish/2022/11/25/311338920-10160044701721131-7204310483297976059-n-149.jpeg',
    ];
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
        body: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: <Widget>[
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                    items: imgList
                        .map(
                          (e) => Container(
                            child: Center(
                              child: Image.network(
                                e,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Positioned(
                    top: 20.0,
                    left: 20.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  '${widget.model.carDetail.carModel?.carMake?.name ?? ''} ${widget.model.carDetail.carModel?.name ?? ''} ${widget.model.carDetail.yearMade ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiện ích'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    utilities != []
                        ? ListView.builder(
                            controller: ScrollController(),
                            shrinkWrap: true,
                            itemCount: (utilities.length / 2).ceil(),
                            itemBuilder: (context, index) {
                              return Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      utilities[index * 2],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (index * 2 + 1 < utilities.length)
                                    Expanded(
                                      child: Text(
                                        utilities[index * 2 + 1],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                ],
                              );
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giấy tờ cần chuẩn bị'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
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
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Điều khoản'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CustomRulesList(
                      itemsFull: rulesFull,
                      itemsShort: rulesShort,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${NumberFormat.currency(locale: "vi_VN", symbol: "").format(widget.model.carDetail.vehicleRentPrice == null ? 0 : widget.model.carDetail.vehicleRentPrice!.priceMondayFriday! > widget.model.carDetail.vehicleRentPrice!.priceSaturdaySunday! ? widget.model.carDetail.vehicleRentPrice!.priceSaturdaySunday : widget.model.carDetail.vehicleRentPrice!.priceMondayFriday).trim()}đ/${"ngày".tr()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    'Đặt xe ngay'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarRentalBookingPage(
                        model: widget.model,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
