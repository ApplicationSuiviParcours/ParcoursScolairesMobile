import 'package:gestparc/core/network/dio_client.dart';

class NotificationService {
  final DioClient dioClient;

  NotificationService(this.dioClient);

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await dioClient.dio.get('notifications');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des notifications');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await dioClient.dio.post('notifications/$id/read');
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la notification');
    }
  }
}
