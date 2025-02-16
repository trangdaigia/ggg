import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddCarPhotosPage extends StatefulWidget {
  final CarManagementViewModel model;
  const AddCarPhotosPage({
    super.key,
    required this.model,
    this.showNext = true,
    this.data,
    this.shareRideModel,
  });

  final bool showNext;
  final CarRental? data;
  final SharedRideViewModel? shareRideModel;

  @override
  State<AddCarPhotosPage> createState() => _AddCarPhotosPageState();
}

class _AddCarPhotosPageState extends State<AddCarPhotosPage> {
  List<File> newPhotos = [];
  File? newAvatar;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    widget.model.newPhotos = [];
    widget.model.avatar = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  bool state = false;
  Future<void> fetchData() async {
    // Lấy dữ liệu tempNewUpdatePhotos (có khi người dùng update ảnh, lưu lại để cache)
    if (widget.model.tempNewUpdatePhotos != null) {
      newAvatar = widget.model.tempNewUpdatePhotos![0];
      newPhotos = widget.model.tempNewUpdatePhotos!.skip(1).toList();
    }
    else if (widget.data != null) {
      if (widget.data!.photo!.length != 0) {
        newAvatar = await widget.model.urlToFile(widget.data!.photo![0]);
        List<Future<File>> futureFiles = widget.data!.photo!
            .skip(1)
            .map((e) => widget.model.urlToFile(e))
            .toList();

        List<File> files = await Future.wait(futureFiles);
        newPhotos = files;
      }
    }

    // Cập nhật trạng thái của widget
    setState(() {
      widget.model.avatar = newAvatar;
      widget.model.newPhotos = newPhotos;

      state = !state;
    });
  }

  List<File> photoFiles = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.onboarding3Color,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          title: Text("Image depicting vehicle".tr(),
              style: TextStyle(color: context.textTheme.bodyLarge!.color)),
          centerTitle: true,
          iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
        ),
        body: !state
            ? BusyIndicator().centered()
            : widget.data == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Avatar'.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (widget.model.avatar == null)
                          DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            child: InkWell(
                              onTap: () =>
                                  widget.model.chooseAvatar().whenComplete(
                                () {
                                  setState(() {});
                                },
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.width / 3.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline_outlined)
                                        .pOnly(bottom: 10),
                                    Text(
                                      'Add picture'.tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 300,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  child: Image.file(
                                    widget.model.avatar!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel_outlined),
                                    onPressed: () {
                                      setState(() {
                                        widget.model.avatar = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Photo order'.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: widget.model.newPhotos == null
                                ? 1
                                : widget.model.newPhotos!.length + 1,
                            itemBuilder: (context, index) {
                              if (index == widget.model.newPhotos?.length) {
                                return DottedBorder(
                                  color: Colors.black,
                                  strokeWidth: 1,
                                  child: InkWell(
                                    onTap: () => widget.model
                                        .choosePhotos()
                                        .whenComplete(
                                      () {
                                        setState(() {});
                                      },
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons
                                                  .add_circle_outline_outlined)
                                              .pOnly(bottom: 10),
                                          Text(
                                            'Add picture'.tr(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      child: Image.file(
                                        widget.model.newPhotos![index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel_outlined),
                                        onPressed: () {
                                          setState(() {
                                            widget.model.newPhotos!
                                                .removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Avatar'.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (widget.model.avatar == null)
                          DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            child: InkWell(
                              onTap: () =>
                                  widget.model.chooseAvatar().whenComplete(
                                () {
                                  setState(() {});
                                },
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.width / 3.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline_outlined)
                                        .pOnly(bottom: 10),
                                    Text(
                                      'Add picture'.tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 300,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                    child: Image.file(
                                  widget.model.avatar!,
                                  fit: BoxFit.cover,
                                )),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel_outlined),
                                    onPressed: () {
                                      setState(() {
                                        print('Xóa');
                                        widget.model.avatar = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Photo order'.tr(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: widget.model.newPhotos == null
                                ? 1
                                : widget.model.newPhotos!.length + 1,
                            itemBuilder: (context, index) {
                              if (index == newPhotos.length) {
                                return DottedBorder(
                                  color: Colors.black,
                                  strokeWidth: 1,
                                  child: InkWell(
                                    onTap: () => widget.model
                                        .choosePhotos()
                                        .whenComplete(
                                      () {
                                        setState(() {});
                                      },
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons
                                                  .add_circle_outline_outlined)
                                              .pOnly(bottom: 10),
                                          Text(
                                            'Add picture'.tr(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                        child: Image.file(
                                      widget.model.newPhotos![index],
                                      fit: BoxFit.cover,
                                    )),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel_outlined),
                                        onPressed: () {
                                          setState(() {
                                            widget.model.newPhotos!
                                                .removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: widget.showNext
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'next'.tr().capitalized,
                      onPressed: () {
                        if (widget.model.avatar != null) {
                          widget.model.newPhotos!
                              .insert(0, widget.model.avatar!);
                          context.nextPage(NavigationService().addCarRentalPage(
                            shareRideModel: widget.shareRideModel,
                            model: widget.model,
                            type: "detail",
                          ));
                        } else {
                          AlertService.error(
                            title: "Error".tr(),
                            text: "Field is required".tr(),
                          );
                        }
                      },
                    )),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: SizedBox(
                      child: CustomButton(
                        title: 'Completed'.tr(),
                        loading: isUpdate,
                        onPressed: () async {
                          setState(() {
                            isUpdate = true;
                          });
                          photoFiles = [];
                          if (widget.model.avatar == null) {
                            AlertService.error(
                              title: "Error".tr(),
                              text: "Field is required".tr(),
                            );
                          } else if (widget.model.avatar != null) {
                            photoFiles.add(widget.model.avatar!);
                          }
                          if (widget.model.newPhotos != null) {
                            photoFiles.addAll(widget.model.newPhotos!);
                          }
                          print('Tổng số hình: ${photoFiles.length}');
                          bool checkUpdate;
                          checkUpdate = await widget.model.updateCar(
                              id: widget.data!.id!, photo: photoFiles);
                          if (checkUpdate) {
                            await AlertService.success(
                              title: "Cập nhật thành công".tr(),
                              text: "Thành công rồi".tr(),
                            );
                            //update tempNewUpdatePhotos cache
                            widget.model.tempNewUpdatePhotos = photoFiles;
                            Navigator.of(context).pop();
                          } else {
                            await AlertService.error(
                              title: "Cập nhật thất bại".tr(),
                              text: "Thất bại rồi".tr(),
                            );
                          }
                          setState(() {
                            isUpdate = false;
                          });
                        },
                      ),
                    )),
              ),
      ),
    );
  }
}
