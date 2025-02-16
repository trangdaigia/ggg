import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/global/service.registry.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/services/hive.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:stacked/stacked.dart';

import 'auth.service.dart';
import 'local_storage.service.dart';

class HttpService with ListenableServiceMixin {
  String host = Api.baseUrl;
  BaseOptions? baseOptions;
  Dio? dio;
  SharedPreferences? prefs;
  Response<dynamic>? data;
  late HiveService<Map<dynamic, dynamic>> hiveService;
  Future<Map<String, String>> getHeaders() async {
    final userToken = await AuthServices.getAuthBearerToken();
    print('User token:(${userToken})');
    return {
      'Accept': "application/json",
      "Authorization": "Bearer ${userToken}",
      "lang": translator.activeLocale.languageCode,
    };
  }

  HttpService() {
    LocalStorageService.getPrefs();
    baseOptions = new BaseOptions(
      baseUrl: host,
      validateStatus: (status) {
        return status != null && status <= 500;
      },
      // connectTimeout: 300,
    );
    if (dio == null) {
      dio = new Dio(baseOptions);
      if (!kIsWeb) {
        dio!.interceptors.add(getCacheManager().interceptor);
      }
      dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (r, handler) {
          print("Response received:");
          print("Status code: ${r.statusCode}");
          print("Data: ${r.data}");
          handler.next(r);
        },
        onError: (e, handler) {
          print("Request failed: ${e.response?.statusCode}");
          print("Error message: ${e.message}");
          print("Server response: ${e.response?.data}");
          handler.next(e);
        },
      ));
    }
    //Add the service to ServiceRegistery
    ServiceRegistry.register(this);
    //Init hive
    hiveService = HiveService(name: "default");
    listenToReactiveValues([data]);
  }

  DioCacheManager getCacheManager() {
    return DioCacheManager(
      CacheConfig(
        baseUrl: host,
        defaultMaxAge: Duration(hours: 1),
      ),
    );
  }

  bool? forceRefresh = null;
  //for get api calls
  //for get api calls with cache options
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool includeHeaders = true,
    bool staleWhileRevalidate = true,
    String? hostUrl,
    Map<String, dynamic>? headers,
    bool forceRefresh = false, // add this parameter for cache control
  }) async {
    // Preparing the API URI
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }

    // Set up cache options for Dio
    final cacheOptions = buildCacheOptions(
      Duration(hours: 1), // Set cache duration
      forceRefresh: GlobalVariable.refreshCache == true
          ? true
          : forceRefresh, // Use this to force a refresh, // Use this to force a refresh
    );

    final dioOptions = Options(
      headers: headers != null ? headers : await getHeaders(),
      extra: !kIsWeb ? cacheOptions.extra : null,
    );

    GlobalVariable.refreshCache = false;

    // Attempt to fetch cached data from Dio cache
    Response? cachedResponse;
    if (!forceRefresh) {
      try {
        cachedResponse = await dio!.get(
          uri,
          options: dioOptions.copyWith(
            extra: {
              ...?dioOptions.extra,
              'fromNetwork': false, // Fetch from cache only
            },
          ),
          queryParameters: queryParameters,
        );
      } catch (_) {
        // No valid cache found; fallback to Hive
      }
    }

    if (cachedResponse != null && cachedResponse.data != null) {
      debugPrint("Found data from Dio cache: ${cachedResponse.data}");
      return cachedResponse;
    }
    if (staleWhileRevalidate) {
      // Initialize Hive for the specific endpoint
      if (uri != hiveService.name) {
        hiveService = HiveService<Map<dynamic, dynamic>>(
            name: url.replaceAll("/", ".").substring(1));
      }
      // Attempt to fetch data from Hive
      final hiveData = await hiveService.readData(Utils.toQueryString(
          queryParameters ?? {},
          exclude: ["longitude", "latitude"]));
      if (hiveData != null) {
        debugPrint("Found data from HiveStorage: ${hiveData}");
        final hiveResponse = Response<Map<String, dynamic>>(
          data: _parser(hiveData),
          requestOptions:
              RequestOptions(path: uri, queryParameters: queryParameters),
          statusCode: 200,
          statusMessage: "OK",
        );
        this.data = hiveResponse;
        callApiAndSave(uri, dioOptions, queryParameters).then((response) {
          this.data = response;
          notifyListeners();
        });
        return this.data!;
      } else {
        await callApiAndSave(uri, dioOptions, queryParameters).then((response) {
          this.data = response;
        });
        return this.data!;
      }
    }

    // Fallback: Make an actual API call and save to cache/Hive
    final apiResponse = await callApi(uri, dioOptions, queryParameters);
    return apiResponse;
  }

  Future<Response> callApiAndSave(String uri, Options mOptions,
      Map<String, dynamic>? queryParameters) async {
    Response response = await callApi(uri, mOptions, queryParameters);
    final data = response.data is Map ? response.data : {"data": response.data};
    await hiveService.save(
        Utils.toQueryString(queryParameters ?? {},
            exclude: ["longitude", "latitude"]),
        data);
    return response;
  }

  Future<Response> callApi(String uri, Options mOptions,
      Map<String, dynamic>? queryParameters) async {
    Response response;
    try {
      response = await dio!.get(
        uri,
        options: mOptions,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      print(error);
      response = formatDioExecption(error);
    }
    return response;
  }

  //for post api calls
  Future<Response> post(
    String url,
    body, {
    bool includeHeaders = true,
    String? hostUrl,
    Map<String, dynamic>? headers,
  }) async {
    //preparing the api uri/url
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }
    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: headers != null ? headers : await getHeaders(),
          );

    Response response;
    try {
      response = await dio!.post(
        uri,
        data: body,
        options: mOptions,
      );
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for post api calls with file upload
  Future<Response> postWithFiles(
    String url,
    body, {
    bool includeHeaders = true,
    String? hostUrl,
    Map<String, dynamic>? headers,
  }) async {
    //preparing the api uri/url
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }
    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: headers != null ? headers : await getHeaders(),
          );

    Response response;
    try {
      response = await dio!.post(
        uri,
        data: body is FormData ? body : FormData.fromMap(body),
        options: mOptions,
      );
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  Future<Response> postCustomFiles(
    String url,
    body, {
    FormData? formData,
    bool includeHeaders = true,
  }) async {
    //preparing the api uri/url
    String uri = "$host$url";
    //preparing the post options if header is required
    final mOptions = !includeHeaders
        ? null
        : Options(
            headers: await getHeaders(),
          );

    Response response;

    try {
      response = await dio!.post(
        uri,
        data: formData != null ? formData : FormData.fromMap(body),
        options: mOptions,
      );
    } on DioError catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  //for patch api calls
  Future<Response> patch(
    String url,
    Map<String, dynamic> body, {
    String? hostUrl,
    Map<String, dynamic>? headers,
  }) async {
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }
    Response response;

    try {
      response = await dio!.patch(
        uri,
        data: body,
        options: Options(
          headers: headers != null ? headers : await getHeaders(),
        ),
      );
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }

    return response;
  }

  Future<Response> patchWithFiles(
    String url,
    dynamic body, {
    String? hostUrl,
    Map<String, dynamic>? headers,
  }) async {
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }
    Response response;

    try {
      response = await dio!.post(
        uri,
        data: body is FormData ? body : FormData.fromMap(body),
        options: Options(
          headers: headers != null ? headers : await getHeaders(),
        ),
      );
    } on DioException catch (error) {
      print('Lỗi: ${error.message}');
      response = formatDioExecption(error);
    }

    return response;
  }

  //for delete api calls
  Future<Response> delete(
    String url, {
    String? hostUrl,
    Map<String, dynamic>? headers,
  }) async {
    String uri;
    if (hostUrl == null) {
      uri = "$host$url";
    } else {
      uri = "$hostUrl$url";
    }

    Response response;
    try {
      response = await dio!.delete(
        uri,
        options: Options(
          headers: headers != null ? headers : await getHeaders(),
        ),
      );
      print("Future<Response> delete Call here!!!");
    } on DioException catch (error) {
      response = formatDioExecption(error);
    }
    return response;
  }

  Response formatDioExecption(DioException ex) {
    var response = Response(requestOptions: ex.requestOptions);
    print("type ==> ${ex.type}");
    response.statusCode = 400;
    String? msg = response.statusMessage;

    try {
      if (ex.type == DioExceptionType.connectionTimeout) {
        msg =
            "Connection timeout. Please check your internet connection and try again"
                .tr();
      } else if (ex.type == DioExceptionType.sendTimeout) {
        msg =
            "Timeout. Please check your internet connection and try again".tr();
      } else if (ex.type == DioExceptionType.receiveTimeout) {
        msg =
            "Timeout. Please check your internet connection and try again".tr();
      } else if (ex.type == DioExceptionType.badResponse) {
        msg =
            "Connection timeout. Please check your internet connection and try again"
                .tr();
      } else {
        msg = "Please check your internet connection and try again".tr();
      }
      response.data = {"message": msg};
    } catch (error) {
      response.statusCode = 400;
      msg = "Please check your internet connection and try again".tr();
      response.data = {"message": msg};
    }

    throw msg;
  }

  //NEUTRALS
  Future<Response> getExternal(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio!.get(
      url,
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _parser(dynamic hiveMap) {
    final jsonString = jsonEncode(hiveMap);
    return jsonDecode(jsonString);
  }
}
