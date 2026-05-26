import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../model/business_model.dart';

class BusinessService {
  Future<BusinessResponse> createBusiness(String name, String type) async {
    try {
      final response = await ApiClient.dio.post(
        '/business',
        data: {'businessName': name, 'businessType': type},
      );
      return BusinessResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Failed to create business';
      throw Exception(message);
    }
  }

  Future<List<BusinessResponse>> getMyBusinesses() async {
    try {
      final response = await ApiClient.dio.get('/business/my');
      final List data = response.data['data'];
      return data.map((e) => BusinessResponse.fromJson({'data': e})).toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Failed to fetch businesses';
      throw Exception(message);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getBusinessTypes() async {
    try {
      final response = await ApiClient.dio.get('/business/types');
      final Map<String, dynamic> data = response.data['data'];
      return data.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => e as Map<String, dynamic>).toList(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Failed to load business types');
    }
  }
}
