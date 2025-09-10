import 'package:flutter/material.dart';
import 'package:leet_god/services/api_service.dart';
import 'package:leet_god/models/voucher.dart';

class VoucherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Voucher? _currentVoucher;
  List<PaymentHistory> _paymentHistory = [];
  PaymentMethod? _paymentMethod;
  List<Voucher> _availableVouchers = [];
  bool _isLoading = false;
  String? _error;

  Voucher? get currentVoucher => _currentVoucher;
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  PaymentMethod? get paymentMethod => _paymentMethod;
  List<Voucher> get availableVouchers => _availableVouchers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVoucherInfo() async {
    _setLoading(true);
    try {
      final data = await _apiService.getVoucherInfo();
      if (data['voucher'] != null) {
        _currentVoucher = Voucher.fromJson(data['voucher']);
      } else {
        _currentVoucher = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPaymentHistory() async {
    _setLoading(true);
    try {
      final data = await _apiService.getPaymentHistory();
      _paymentHistory = data.map((json) => PaymentHistory.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPaymentMethod() async {
    _setLoading(true);
    try {
      final data = await _apiService.getPaymentMethod();
      if (data['payment_method'] != null) {
        _paymentMethod = PaymentMethod.fromJson(data['payment_method']);
      } else {
        _paymentMethod = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAvailableVouchers() async {
    _setLoading(true);
    try {
      final data = await _apiService.getAvailableVouchers();
      _availableVouchers = data.map((json) => Voucher.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 