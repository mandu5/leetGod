import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../models/voucher.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().loadPaymentMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 수단'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, voucherProvider, child) {
          if (voucherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (voucherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: ${voucherProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      voucherProvider.clearError();
                      voucherProvider.loadPaymentMethod();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final paymentMethod = voucherProvider.paymentMethod;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 현재 결제 수단
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 결제 수단',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (paymentMethod != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paymentMethod.cardType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  paymentMethod.cardNumber,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '만료일: ${paymentMethod.expiryDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _showChangePaymentMethodDialog(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('변경하기'),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            '등록된 결제 수단이 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _showAddPaymentMethodDialog(context);
                              },
                              child: const Text('결제 수단 등록'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 해지하기 버튼
                if (paymentMethod != null)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _showCancelVoucherDialog(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('해지하기'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangePaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('결제 수단 변경'),
          content: const Text('결제 수단을 변경하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 결제 수단 변경 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('결제 수단 변경 기능은 준비 중입니다.')),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('결제 수단 등록'),
          content: const Text('결제 수단을 등록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 결제 수단 등록 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('결제 수단 등록 기능은 준비 중입니다.')),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelVoucherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이용권 해지'),
          content: const Text(
            '이용권을 해지하면 이용하신 모든 컨텐츠는 삭제되며, 다시 이용권을 구매하더라도 이전 컨텐츠는 이용하실 수 없습니다.\n\n이용권을 해지하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 이용권 해지 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이용권 해지 기능은 준비 중입니다.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
} 