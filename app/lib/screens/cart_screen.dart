import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // 임시 장바구니 데이터
  List<Map<String, dynamic>> cartItems = [
    {
      'id': '1',
      'name': '베이직 화이트 티셔츠',
      'brand': 'UNIQLO',
      'price': 19900,
      'size': 'M',
      'color': '화이트',
      'quantity': 1,
      'image': 'assets/images/tshirt.jpg',
      'isSelected': true,
    },
    {
      'id': '2',
      'name': '데님 청바지',
      'brand': 'ZARA',
      'price': 89000,
      'size': 'L',
      'color': '네이비',
      'quantity': 1,
      'image': 'assets/images/jeans.jpg',
      'isSelected': true,
    },
    {
      'id': '3',
      'name': '커버넛 스니커즈',
      'brand': 'NIKE',
      'price': 129000,
      'size': '280',
      'color': '화이트',
      'quantity': 1,
      'image': 'assets/images/sneakers.jpg',
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedItems = cartItems.where((item) => item['isSelected']).toList();
    final totalPrice = selectedItems.fold<int>(0, (sum, item) => 
        sum + ((item['price'] as int) * (item['quantity'] as int)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '장바구니',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showDeleteAllDialog();
            },
            child: const Text(
              '전체 삭제',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 장바구니 통계
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedItems.length}개 상품 선택됨',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '총 ${totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
                          (Match m) => '${m[1]},'
                        )}원',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 장바구니 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(item, index);
              },
            ),
          ),

          // 하단 구매 버튼
          if (selectedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 결제금액',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
                          (Match m) => '${m[1]},'
                        )}원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPurchaseDialog(selectedItems, totalPrice);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '구매하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 선택 체크박스
            Checkbox(
              value: item['isSelected'],
              onChanged: (value) {
                setState(() {
                  cartItems[index]['isSelected'] = value!;
                });
              },
              activeColor: Colors.black,
            ),
            
            const SizedBox(width: 12),
            
            // 상품 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.checkroom,
                size: 40,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['brand']} • ${item['size']} • ${item['color']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['price'].toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
                          (Match m) => '${m[1]},'
                        )}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      // 수량 조절
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                            if ((item['quantity'] as int) > 1) {
                              setState(() {
                                cartItems[index]['quantity'] = (item['quantity'] as int) - 1;
                              });
                            }
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${item['quantity']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                cartItems[index]['quantity'] = (item['quantity'] as int) + 1;
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 삭제 버튼
            IconButton(
              onPressed: () {
                _showDeleteDialog(index);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('${cartItems[index]['name']}을(를) 장바구니에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cartItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('장바구니의 모든 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cartItems.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(List<Map<String, dynamic>> selectedItems, int totalPrice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구매 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('선택한 상품을 구매하시겠습니까?'),
            const SizedBox(height: 12),
            ...selectedItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${item['name']} (${item['quantity']}개)',
                style: const TextStyle(fontSize: 12),
              ),
            )),
            const SizedBox(height: 12),
            Text(
              '총 결제금액: ${totalPrice.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
                (Match m) => '${m[1]},'
              )}원',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('구매하기'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('구매 완료'),
          ],
        ),
        content: const Text('구매가 완료되었습니다!\n빠른 시일 내에 배송해드리겠습니다.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
