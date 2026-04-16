import 'package:gestparc/core/network/dio_client.dart';

class ParentService {
  final DioClient dioClient;
  ParentService(this.dioClient);

  Future<Map<String, dynamic>> getDashboardData() async => (await dioClient.dio.get('/parent/dashboard')).data;
  Future<Map<String, dynamic>> getEnfantDetails(int id) async => (await dioClient.dio.get('/parent/eleve/$id/dashboard')).data;
}
