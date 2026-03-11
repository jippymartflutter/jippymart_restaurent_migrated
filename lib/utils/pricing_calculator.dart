/// Pricing logic from Add Product API doc: commission vs subscription, GST.
class PricingCalculator {
  /// [hasSubscription] – vendor has active subscription.
  /// [planType] – "commission" or "subscription".
  /// [applyPercentage] – platform commission % (e.g. 30).
  /// [gstAgreed] – true = platform absorbs GST; false = GST added to customer price.
  static double calculateOnlinePrice({
    required double merchantPrice,
    bool hasSubscription = false,
    String planType = 'commission',
    int applyPercentage = 30,
    bool gstAgreed = false,
  }) {
    if (merchantPrice <= 0) return 0;

    final isSubscription = hasSubscription && planType == 'subscription';

    if (isSubscription) {
      if (gstAgreed) return merchantPrice;
      final gstAmount = merchantPrice * 0.05;
      return merchantPrice + gstAmount;
    }

    // Commission-based
    final commission = merchantPrice * (applyPercentage / 100);
    final priceBeforeGst = merchantPrice + commission;
    if (gstAgreed) return priceBeforeGst;
    final gstAmount = merchantPrice * 0.05;
    return priceBeforeGst + gstAmount;
  }
}
