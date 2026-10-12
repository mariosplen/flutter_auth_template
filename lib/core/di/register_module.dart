import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'dio_factory.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => createDio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
