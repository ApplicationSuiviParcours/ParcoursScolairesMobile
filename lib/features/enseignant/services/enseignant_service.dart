import 'package:gestparc/core/network/dio_client.dart';

class EnseignantService {
  final DioClient dioClient;
  EnseignantService(this.dioClient);

  Future<Map<String, dynamic>> getDashboardData() async => (await dioClient.dio.get('/enseignant/dashboard')).data;
  Future<Map<String, dynamic>> getClasses() async => (await dioClient.dio.get('/enseignant/classes')).data;
  Future<Map<String, dynamic>> getEvaluations() async => (await dioClient.dio.get('/enseignant/evaluations')).data;
}
