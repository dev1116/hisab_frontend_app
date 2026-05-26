import 'package:flutter/animation.dart';

class QuotationModel {
  final int id;
  final int businessId;
  final int? customerId;
  final String? customerName;
  final String quoteNumber;
  final String title;
  final String? description;
  final double amount;
  final double? taxAmount;
  final double totalAmount;
  final String status;
  final String? pdfUrl;
  final String? pdfOriginalName;
  final String? validUntil;
  final String issueDate;
  final int version;
  final int? parentId;
  final bool isLatest;
  final String? notes;
  final String createdAt;
  final String? addressLine1;
  final String? addressLine2;
  final String? pincode;
  final String? city;
  final String? state;
  final String? country;

  QuotationModel({
    required this.id,
    required this.businessId,
    this.customerId,
    this.customerName,
    required this.quoteNumber,
    required this.title,
    this.description,
    required this.amount,
    this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.pdfUrl,
    this.pdfOriginalName,
    this.validUntil,
    required this.issueDate,
    required this.version,
    this.parentId,
    required this.isLatest,
    this.notes,
    required this.createdAt,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,

    this.pincode,
    this.state,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> j) => QuotationModel(
    id: j['id'],
    businessId: j['businessId'],
    customerId: j['customerId'],
    customerName: j['customerName'],
    quoteNumber: j['quoteNumber'],
    title: j['title'],
    description: j['description'],
    amount: (j['amount'] as num).toDouble(),
    taxAmount: j['taxAmount'] != null
        ? (j['taxAmount'] as num).toDouble()
        : null,
    totalAmount: (j['totalAmount'] as num).toDouble(),
    status: j['status'],
    pdfUrl: j['pdfUrl'] as String?,
    pdfOriginalName: j['pdfOriginalName'],
    validUntil: j['validUntil'],
    issueDate: j['issueDate'],
    version: j['version'],
    parentId: j['parentId'],
    isLatest: j['isLatest'],
    notes: j['notes'],
    createdAt: j['createdAt'],
    addressLine1: j['addressLine1'],
    addressLine2: j['addressLine2'],
    pincode: j['pincode'],
    city: j['city'],
    state: j['state'],
    country: j['country'],
  );

  Color get statusColor {
    switch (status) {
      case 'ACCEPTED':
        return const Color(0xFF10B981);
      case 'REJECTED':
        return const Color(0xFFEF4444);
      case 'SENT':
        return const Color(0xFF3B82F6);
      case 'EXPIRED':
        return const Color(0xFFF59E0B);
      case 'REVISED':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF8BA8A5); // DRAFT
    }
  }
}
