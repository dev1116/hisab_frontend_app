import 'package:flutter/material.dart';

class InvoiceModel {
  final int id;
  final int businessId;
  final int? customerId;
  final String? customerName;
  final String invoiceNumber;
  final String? billNumber;
  final String? billDate;
  final String title;
  final String? description;
  final double amount;
  final double? taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final String? pdfUrl;
  final String? pdfOriginalName;
  final String issueDate;
  final String? dueDate;
  final String? addressLine1;
  final String? addressLine2;
  final String? pincode;
  final String? city;
  final String? state;
  final String? country;
  final String? notes;
  final int? quotationId;
  final String createdAt;

  InvoiceModel({
    required this.id,
    required this.businessId,
    this.customerId,
    this.customerName,
    required this.invoiceNumber,
    this.billNumber,
    this.billDate,
    required this.title,
    this.description,
    required this.amount,
    this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    this.pdfUrl,
    this.pdfOriginalName,
    required this.issueDate,
    this.dueDate,
    this.addressLine1,
    this.addressLine2,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.notes,
    this.quotationId,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
    id: j['id'],
    businessId: j['businessId'],
    customerId: j['customerId'],
    customerName: j['customerName'],
    invoiceNumber: j['invoiceNumber'],
    billNumber: j['billNumber'],
    billDate: j['billDate'],
    title: j['title'],
    description: j['description'],
    amount: (j['amount'] as num).toDouble(),
    taxAmount: j['taxAmount'] != null
        ? (j['taxAmount'] as num).toDouble()
        : null,
    totalAmount: (j['totalAmount'] as num).toDouble(),
    paidAmount: (j['paidAmount'] as num).toDouble(),
    remainingAmount: (j['remainingAmount'] as num).toDouble(),
    status: j['status'],
    pdfUrl: j['pdfUrl'],
    pdfOriginalName: j['pdfOriginalName'],
    issueDate: j['issueDate'],
    dueDate: j['dueDate'],
    addressLine1: j['addressLine1'],
    addressLine2: j['addressLine2'],
    pincode: j['pincode'],
    city: j['city'],
    state: j['state'],
    country: j['country'],
    notes: j['notes'],
    quotationId: j['quotationId'],
    createdAt: j['createdAt'],
  );

  Color get statusColor {
    switch (status) {
      case 'PAID':
        return const Color(0xFF10B981);
      case 'PARTIAL':
        return const Color(0xFF3B82F6);
      case 'OVERDUE':
        return const Color(0xFFEF4444);
      case 'CANCELLED':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B); // UNPAID
    }
  }

  bool get isOverdue =>
      status == 'OVERDUE' ||
      (dueDate != null &&
          DateTime.tryParse(dueDate!)?.isBefore(DateTime.now()) == true &&
          status != 'PAID' &&
          status != 'CANCELLED');
}
