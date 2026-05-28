import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:hisab_app/core/network/api_client.dart';
import '../model/invoice_model.dart';

class InvoiceService {
  Future<List<InvoiceModel>> getInvoices(int businessId) async {
    final res = await ApiClient.dio.get('/business/$businessId/invoices');
    final content = res.data['data']['content'] as List;
    return content.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceModel> createInvoice({
    required int businessId,
    required Map<String, dynamic> data,
    Uint8List? pdfBytes,
    String? pdfName,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(data)));
    if (pdfBytes != null) {
      formData.files.add(
        MapEntry('pdf', MultipartFile.fromBytes(pdfBytes, filename: pdfName)),
      );
    }
    final res = await ApiClient.dio.post(
      '/business/$businessId/invoices',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return InvoiceModel.fromJson(res.data['data']);
  }

  Future<InvoiceModel> updateStatus({
    required int businessId,
    required int invoiceId,
    required String status,
  }) async {
    final res = await ApiClient.dio.patch(
      '/business/$businessId/invoices/$invoiceId/status',
      queryParameters: {'status': status},
    );
    return InvoiceModel.fromJson(res.data['data']);
  }

  Future<InvoiceModel> recordPayment({
    required int businessId,
    required int invoiceId,
    required double amount,
  }) async {
    final res = await ApiClient.dio.patch(
      '/business/$businessId/invoices/$invoiceId/payment',
      queryParameters: {'amount': amount},
    );
    return InvoiceModel.fromJson(res.data['data']);
  }

  Future<void> deleteInvoice({
    required int businessId,
    required int invoiceId,
  }) async {
    await ApiClient.dio.delete('/business/$businessId/invoices/$invoiceId');
  }
}
