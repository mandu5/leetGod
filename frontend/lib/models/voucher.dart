class Voucher {
  final String id;
  final String name;
  final String type;
  final double price;
  final String period;
  final List<String> features;
  final bool isActive;

  Voucher({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.period,
    required this.features,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      price: json['price'].toDouble(),
      period: json['period'],
      features: List<String>.from(json['features']),
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'period': period,
      'features': features,
      'is_active': isActive,
    };
  }
}

class PaymentHistory {
  final String id;
  final String voucherName;
  final double amount;
  final DateTime date;
  final String status;

  PaymentHistory({
    required this.id,
    required this.voucherName,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'].toString(),
      voucherName: json['voucher_name'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucher_name': voucherName,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}

class PaymentMethod {
  final String id;
  final String cardType;
  final String cardNumber;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.cardNumber,
    required this.expiryDate,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'].toString(),
      cardType: json['card_type'],
      cardNumber: json['card_number'],
      expiryDate: json['expiry_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_type': cardType,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
    };
  }
} 