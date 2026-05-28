import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hisab_app/core/network/api_client.dart';
import 'package:hisab_app/features/quotations/model/quotation_model.dart';
import 'package:hisab_app/core/network/api_endpoints.dart';

class QuotationService {
  Future<List<QuotationModel>> getQuotations(int businessId) async {
    final res = await ApiClient.dio.get(ApiEndpoints.quotations(businessId));

    // Page response se content nikalo
    final content = res.data['content'] as List;
    return content.map((e) => QuotationModel.fromJson(e)).toList();
  }

  Future<QuotationModel> createQuotation({
    required int businessId,
    required Map<String, dynamic> data,
    Uint8List? pdfBytes,
    String? pdfName,
  }) async {
    final formData = FormData();

    // backend me @RequestPart("data")
    formData.fields.add(MapEntry('data', jsonEncode(data)));

    // optional pdf upload
    if (pdfBytes != null) {
      formData.files.add(
        MapEntry('pdf', MultipartFile.fromBytes(pdfBytes, filename: pdfName)),
      );
    }

    final res = await ApiClient.dio.post(
      '/business/$businessId/quotations',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return QuotationModel.fromJson(res.data);
  }

  Future<QuotationModel> updateStatus({
    required int businessId,
    required int quotationId,
    required String status,
  }) async {
    final res = await ApiClient.dio.patch(
      '/business/$businessId/quotations/$quotationId/status',
      queryParameters: {'status': status},
    );

    return QuotationModel.fromJson(res.data);
  }

  Future<void> deleteQuotation({
    required int businessId,
    required int quotationId,
  }) async {
    await ApiClient.dio.delete('/business/$businessId/quotations/$quotationId');
  }

  Future<QuotationModel> reviseQuotation({
    required int businessId,
    required int quotationId,
    required Map<String, dynamic> data,
    Uint8List? pdfBytes,
    String? pdfName,
  }) async {
    // final formData = FormData();
    // formData.fields.add(MapEntry('data', jsonEncode(data)));

    final formData = FormData.fromMap({
      'data': jsonEncode(data),

      if (pdfBytes != null)
        'pdf': MultipartFile.fromBytes(
          pdfBytes,
          filename: pdfName ?? 'quotation.pdf',
        ),
    });

    final res = await ApiClient.dio.post(
      '/business/$businessId/quotations/$quotationId/revise',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return QuotationModel.fromJson(res.data);
  }

  Future<List<QuotationModel>> getVersionHistory({
    required int businessId,
    required int quotationId,
  }) async {
    final res = await ApiClient.dio.get(
      '/business/$businessId/quotations/$quotationId/history',
    );
    final List data = res.data['data'];
    return data.map((e) => QuotationModel.fromJson(e)).toList();
  }
}
