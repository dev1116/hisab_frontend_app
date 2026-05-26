class BusinessResponse {
  final int id;
  final String businessName;
  final String businessCode;
  final String businessType;

  BusinessResponse({
    required this.id,
    required this.businessName,
    required this.businessCode,
    required this.businessType,
  });

  factory BusinessResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return BusinessResponse(
      id: data['id'],
      businessName: data['businessName'],
      businessCode: data['businessCode'],
      businessType: data['businessType'],
    );
  }
}
