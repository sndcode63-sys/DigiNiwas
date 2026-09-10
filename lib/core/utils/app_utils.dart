String formatPrice(dynamic priceValue) {
  if (priceValue == null) return 'N/A';

  // Agar price pehle se string hai aur usme 'L' ya '₹' hai toh waise hi return kar do
  String priceStr = priceValue.toString().trim();
  if (priceStr.contains('L') || priceStr.contains('Cr') || priceStr.contains('₹')) {
    return priceStr;
  }

  // Number mein convert karke Lakh / Crore mein format karna
  double? price = double.tryParse(priceStr);
  if (price == null) return priceStr;

  if (price >= 10000000) {
    double cr = price / 10000000;
    return '₹ ${cr % 1 == 0 ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
  } else if (price >= 100000) {
    double lakh = price / 100000;
    return '₹ ${lakh % 1 == 0 ? lakh.toInt() : lakh.toStringAsFixed(1)} L';
  } else if (price >= 1000) {
    double thousand = price / 1000;
    return '₹ ${thousand % 1 == 0 ? thousand.toInt() : thousand.toStringAsFixed(1)} K';
  }

  return '₹ $priceStr';
}
