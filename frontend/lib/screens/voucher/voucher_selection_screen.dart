import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../models/voucher.dart';

class VoucherSelectionScreen extends StatefulWidget {
  const VoucherSelectionScreen({super.key});

  @override
  State<VoucherSelectionScreen> createState() => _VoucherSelectionScreenState();
}

class _VoucherSelectionScreenState extends State<VoucherSelectionScreen> {
  Voucher? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().loadAvailableVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용권 선택'),
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
                      voucherProvider.loadAvailableVouchers();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final availableVouchers = voucherProvider.availableVouchers;

          if (availableVouchers.isEmpty) {
            return const Center(
              child: Text(
                '이용 가능한 이용권이 없습니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 이용권 카드들
                ...availableVouchers.map((voucher) => _buildVoucherCard(voucher)),
                const SizedBox(height: 24),

                // 선택하기 버튼
                if (_selectedVoucher != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPurchaseDialog(context, _selectedVoucher!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '선택하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final isSelected = _selectedVoucher?.id == voucher.id;
    final cardColor = _getVoucherColor(voucher.type);
    final titleColor = _getTitleColor(voucher.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedVoucher = voucher;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 (이름과 가격)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      voucher.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      '₩${voucher.price.toStringAsFixed(0)}/${voucher.period}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 기능 목록
                ...voucher.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getVoucherColor(String type) {
    switch (type) {
      case 'pro':
        return const Color(0xFFFFF3E0); // 연한 주황색 (프로)
      case 'basic':
        return Colors.white; // 흰색 (베이직)
      case 'light':
        return Colors.white; // 흰색 (라이트)
      default:
        return Colors.white;
    }
  }

  Color _getTitleColor(String type) {
    switch (type) {
      case 'pro':
        return Colors.blue; // 파란색 (프로)
      case 'basic':
        return Colors.purple; // 보라색 (베이직)
      case 'light':
        return Colors.green; // 초록색 (라이트)
      default:
        return Colors.black87;
    }
  }

  void _showPurchaseDialog(BuildContext context, Voucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${voucher.name} 이용권 구매'),
          content: Text(
            '${voucher.name} 이용권을 ₩${voucher.price.toStringAsFixed(0)}에 구매하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 구매 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${voucher.name} 이용권 구매 기능은 준비 중입니다.'),
                  ),
                );
              },
              child: const Text('구매'),
            ),
          ],
        );
      },
    );
  }
} 