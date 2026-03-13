import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/subscription_payment_controller.dart';
import 'package:jippymart_restaurant/controller/subscription_plans_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
//
// /// Small plan card: plan name + Buy now button. Tap card to see details.
// class _PlanCard extends StatelessWidget {
//   const _PlanCard({
//     required this.plan,
//     required this.onTap,
//     required this.onBuyNow,
//   });
//
//   final SubscriptionPlanModel plan;
//   final VoidCallback onTap;
//   final VoidCallback onBuyNow;
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
//     final isDark = themeChange.getThem();
//     final cardBg = isDark ? AppThemeData.grey800 : AppThemeData.grey50;
//     final surfaceColor = isDark ? AppThemeData.grey700 : AppThemeData.grey200;
//     final textPrimary = isDark ? AppThemeData.grey50 : AppThemeData.grey900;
//     final textSecondary = isDark ? AppThemeData.grey400 : AppThemeData.grey500;
//
//     const double thumbSize = 56;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Material(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(12),
//         elevation: isDark ? 0 : 1,
//         shadowColor: Colors.black.withValues(alpha: 0.06),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: plan.image != null && plan.image!.isNotEmpty
//                       ? SizedBox(
//                           width: thumbSize,
//                           height: thumbSize,
//                           child: NetworkImageWidget(
//                             imageUrl: plan.image!,
//                             fit: BoxFit.cover,
//                             width: thumbSize,
//                             height: thumbSize,
//                             errorWidget: _planThumbPlaceholder(thumbSize, surfaceColor),
//                           ),
//                         )
//                       : _planThumbPlaceholder(thumbSize, surfaceColor),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         plan.name,
//                         style: TextStyle(
//                           fontFamily: AppThemeData.semiBold,
//                           fontSize: 16,
//                           color: textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         Constant.amountShow(amount: plan.price),
//                         style: TextStyle(
//                           fontFamily: AppThemeData.regular,
//                           fontSize: 13,
//                           color: textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 _BuyNowButton(onPressed: onBuyNow),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _planThumbPlaceholder(double size, Color color) {
//     return Container(
//       width: size,
//       height: size,
//       color: color,
//       child: Icon(
//         Icons.card_membership_rounded,
//         size: 28,
//         color: AppThemeData.grey400,
//       ),
//     );
//   }
// }
//
// class _BuyNowButton extends StatelessWidget {
//   const _BuyNowButton({required this.onPressed, this.fullWidth = false});
//
//   final VoidCallback onPressed;
//   final bool fullWidth;
//
//   @override
//   Widget build(BuildContext context) {
//     final child = Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: fullWidth ? 24 : 16,
//         vertical: fullWidth ? 14 : 10,
//       ),
//       child: Center(
//         child: Text(
//           "Buy now".tr,
//           style: TextStyle(
//             fontFamily: AppThemeData.semiBold,
//             fontSize: fullWidth ? 16 : 14,
//             color: AppThemeData.grey50,
//           ),
//         ),
//       ),
//     );
//     final content = Material(
//       color: AppThemeData.secondary300,
//       borderRadius: BorderRadius.circular(fullWidth ? 12 : 8),
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(fullWidth ? 12 : 8),
//         child: child,
//       ),
//     );
//     if (fullWidth) {
//       return SizedBox(width: double.infinity, child: content);
//     }
//     return content;
//   }
// }
//
// class _PlanTypeChip extends StatelessWidget {
//   const _PlanTypeChip({required this.plan});
//
//   final SubscriptionPlanModel plan;
//
//   @override
//   Widget build(BuildContext context) {
//     final isCommission = plan.isCommission;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: isCommission
//             ? AppThemeData.info600.withValues(alpha: 0.95)
//             : AppThemeData.success600.withValues(alpha: 0.95),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         plan.planType == 'commission' ? 'Commission'.tr : 'Subscription'.tr,
//         style: const TextStyle(
//           fontFamily: AppThemeData.semiBold,
//           fontSize: 12,
//           color: AppThemeData.grey50,
//         ),
//       ),
//     );
//   }
// }
//
// /// Full-screen detail view for a single subscription plan.
// class SubscriptionPlanDetailScreen extends StatelessWidget {
//   const SubscriptionPlanDetailScreen({super.key, required this.plan});
//
//   final SubscriptionPlanModel plan;
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
//     final isDark = themeChange.getThem();
//     final bgColor = isDark ? AppThemeData.grey900 : AppThemeData.grey100;
//     final cardBg = isDark ? AppThemeData.grey800 : AppThemeData.grey50;
//     final textPrimary = isDark ? AppThemeData.grey50 : AppThemeData.grey900;
//     final textSecondary = isDark ? AppThemeData.grey400 : AppThemeData.grey500;
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 220,
//             pinned: true,
//             backgroundColor: AppThemeData.secondary300,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_rounded, color: AppThemeData.grey50),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               background: plan.image != null && plan.image!.isNotEmpty
//                   ? Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         NetworkImageWidget(
//                           imageUrl: plan.image!,
//                           fit: BoxFit.cover,
//                           errorWidget: _detailImagePlaceholder(),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.transparent,
//                                 AppThemeData.grey900.withValues(alpha: 0.7),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : _detailImagePlaceholder(),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           plan.name,
//                           style: TextStyle(
//                             fontFamily: AppThemeData.semiBold,
//                             fontSize: 24,
//                             color: textPrimary,
//                           ),
//                         ),
//                       ),
//                       _PlanTypeChip(plan: plan),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     Constant.amountShow(amount: plan.price),
//                     style: const TextStyle(
//                       fontFamily: AppThemeData.semiBold,
//                       fontSize: 26,
//                       color: AppThemeData.secondary400,
//                     ),
//                   ),
//                   if (plan.expiryDay.isNotEmpty && plan.expiryDay != '0') ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       "Valid for ${plan.expiryDay} days".tr,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.regular,
//                         fontSize: 14,
//                         color: textSecondary,
//                       ),
//                     ),
//                   ],
//                   if (plan.description.isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     Text(
//                       "About this plan".tr,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.semiBold,
//                         fontSize: 16,
//                         color: textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       plan.description,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.regular,
//                         fontSize: 15,
//                         color: textSecondary,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 24),
//                   Text(
//                     "Plan details".tr,
//                     style: TextStyle(
//                       fontFamily: AppThemeData.semiBold,
//                       fontSize: 16,
//                       color: textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _DetailCard(
//                     cardBg: cardBg,
//                     textPrimary: textPrimary,
//                     textSecondary: textSecondary,
//                     children: [
//                       _DetailRow(
//                         label: "Plan type".tr,
//                         value: plan.planType == 'commission'
//                             ? 'Commission'.tr
//                             : 'Subscription'.tr,
//                         textPrimary: textPrimary,
//                         textSecondary: textSecondary,
//                         showDivider: false,
//                       ),
//                       if (plan.expiryDay.isNotEmpty)
//                         _DetailRow(
//                           label: "Validity".tr,
//                           value: plan.expiryDay == '0'
//                               ? "Unlimited".tr
//                               : "${plan.expiryDay} days",
//                           textPrimary: textPrimary,
//                           textSecondary: textSecondary,
//                         ),
//                       if (plan.itemLimit.isNotEmpty && plan.itemLimit != 'null')
//                         _DetailRow(
//                           label: "Item limit".tr,
//                           value: plan.itemLimit == '0'
//                               ? "Unlimited".tr
//                               : plan.itemLimit,
//                           textPrimary: textPrimary,
//                           textSecondary: textSecondary,
//                         ),
//                       if (plan.orderLimit.isNotEmpty && plan.orderLimit != 'null')
//                         _DetailRow(
//                           label: "Order limit".tr,
//                           value: plan.orderLimit == '0'
//                               ? "Unlimited".tr
//                               : plan.orderLimit,
//                           textPrimary: textPrimary,
//                           textSecondary: textSecondary,
//                         ),
//                       if (plan.place.isNotEmpty && plan.place != '0')
//                         _DetailRow(
//                           label: "Place".tr,
//                           value: plan.place,
//                           textPrimary: textPrimary,
//                           textSecondary: textSecondary,
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   _BuyNowButton(
//                     fullWidth: true,
//                     onPressed: () {
//                       // TODO: Wire to payment / subscribe API
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _detailImagePlaceholder() {
//     return Container(
//       color: AppThemeData.grey800,
//       child: Center(
//         child: Icon(
//           Icons.card_membership_rounded,
//           size: 72,
//           color: AppThemeData.grey500,
//         ),
//       ),
//     );
//   }
// }
//
// class _DetailCard extends StatelessWidget {
//   const _DetailCard({
//     required this.cardBg,
//     required this.textPrimary,
//     required this.textSecondary,
//     required this.children,
//   });
//
//   final Color cardBg;
//   final Color textPrimary;
//   final Color textSecondary;
//   final List<Widget> children;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: AppThemeData.grey300.withValues(alpha: 0.5),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }
// }
//
// class _DetailRow extends StatelessWidget {
//   const _DetailRow({
//     required this.label,
//     required this.value,
//     required this.textPrimary,
//     required this.textSecondary,
//     this.showDivider = true,
//   });
//
//   final String label;
//   final String value;
//   final Color textPrimary;
//   final Color textSecondary;
//   final bool showDivider;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (showDivider)
//           Divider(
//             height: 1,
//             thickness: 1,
//             color: AppThemeData.grey300.withValues(alpha: 0.4),
//           ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontFamily: AppThemeData.regular,
//                     fontSize: 14,
//                     color: textSecondary,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Flexible(
//                 child: Text(
//                   value,
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     fontFamily: AppThemeData.semiBold,
//                     fontSize: 14,
//                     color: textPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   const _ErrorView({required this.message, required this.onRetry});
//
//   final String message;
//   final VoidCallback onRetry;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               size: 56,
//               color: AppThemeData.danger300,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontFamily: AppThemeData.medium,
//                 fontSize: 16,
//                 color: AppThemeData.grey600,
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextButton.icon(
//               onPressed: onRetry,
//               icon: Icon(Icons.refresh_rounded, color: AppThemeData.secondary300),
//               label: Text("Retry".tr),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppThemeData.secondary400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyView extends StatelessWidget {
//   const _EmptyView({required this.onRetry});
//
//   final VoidCallback onRetry;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.inbox_rounded,
//               size: 56,
//               color: AppThemeData.grey400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               "No subscription plans available.".tr,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontFamily: AppThemeData.medium,
//                 fontSize: 16,
//                 color: AppThemeData.grey500,
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextButton.icon(
//               onPressed: onRetry,
//               icon: Icon(Icons.refresh_rounded, color: AppThemeData.secondary300),
//               label: Text("Refresh".tr),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppThemeData.secondary400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _Tok {
  // Spacing
  static const double s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,
      s14 = 14, s16 = 16, s20 = 20, s24 = 24, s28 = 28, s32 = 32, s48 = 48;

  // Border radii
  static const double r8 = 8, r12 = 12, r16 = 16, r20 = 20, r24 = 24, r99 = 99;

  // Font sizes
  static const double f11 = 11, f12 = 12, f13 = 13, f14 = 14, f15 = 15,
      f16 = 16, f18 = 18, f22 = 22, f26 = 26, f28 = 28;

  // Icon sizes
  static const double i18 = 18, i22 = 22, i28 = 28, i32 = 32, i48 = 48, i64 = 64;

  // Gradients
  static const LinearGradient heroGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3C), Color(0xFF2D3561)],
  );
  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
  );
  static const LinearGradient commissionGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
  );
  static const LinearGradient subGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure payment controller exists for Buy Now actions.
    final SubscriptionPaymentController paymentController =
        Get.put(SubscriptionPaymentController());
    return GetBuilder<SubscriptionPlansController>(
      init: SubscriptionPlansController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: _bg(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp green
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF25D366).withValues(alpha: 0.45),
                ),
                onPressed: () async {
                  const String phoneNumber = '+918106625666';
                  const String message =
                      "I'm interested in more information about your subscription plans";
                  final Uri whatsappUrl = Uri.parse(
                    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
                  );
                  try {
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                    } else {
                      final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                      if (await canLaunchUrl(phoneUrl)) {
                        await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
                      }
                    }
                  } catch (e) {
                    debugPrint('Error launching WhatsApp: $e');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // WhatsApp SVG Icon
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: SvgPicture.string(
                        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
                <path d="M12 0C5.373 0 0 5.373 0 12c0 2.135.563 4.14 1.54 5.875L0 24l6.31-1.516A11.944 11.944 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.006-1.371l-.36-.214-3.727.896.933-3.625-.234-.373A9.818 9.818 0 1112 21.818z"/>
              </svg>''',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'Need more info about plans? Chat on WhatsApp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),          body: Obx(() {
            if (controller.isLoading.value && controller.plans.isEmpty) {
              return const _LoadingView();
            }
            if (controller.hasError && controller.plans.isEmpty) {
              return _ErrorView(
                message: controller.errorMessage.value,
                onRetry: controller.fetchPlans,
              );
            }
            if (!controller.hasPlans) {
              return _EmptyView(onRetry: controller.fetchPlans);
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _PlansAppBar(planCount: controller.plans.length),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      _Tok.s16, _Tok.s20, _Tok.s16, _Tok.s48),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final plan = controller.plans[index];
                        return _PlanCard(
                          plan: plan,
                          index: index,
                          onTap: () => _openDetail(context, plan),
                          onBuyNow: () =>
                              paymentController.startRazorpayPayment(plan),
                        );
                      },
                      childCount: controller.plans.length,
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _openDetail(BuildContext context, SubscriptionPlanModel plan) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) =>
            FadeTransition(
              opacity: animation,
              child: SubscriptionPlanDetailScreen(plan: plan),
            ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static Color _bg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
  }
}

// ─────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────
class _PlansAppBar extends StatelessWidget {
  const _PlansAppBar({required this.planCount});
  final int planCount;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppThemeData.secondary300,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppThemeData.grey50, size: _Tok.i22),
      ),
      title: Text(
        "Subscription Plans".tr,
        style: const TextStyle(
          fontFamily: AppThemeData.semiBold,
          fontSize: _Tok.f18,
          color: AppThemeData.grey50,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: _Tok.s16),
          padding: const EdgeInsets.symmetric(
              horizontal: _Tok.s12, vertical: _Tok.s6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(_Tok.r99),
          ),
          child: Text(
            "$planCount plans",
            style: const TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PLAN CARD
// ─────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    this.index,
    required this.onTap,
    this.onBuyNow,
  });

  final SubscriptionPlanModel plan;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onBuyNow;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDark = themeChange.getThem();
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSub = isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);
    final isCommission = plan.isCommission;
    final planGrad = isCommission ? _Tok.commissionGrad : _Tok.subGrad;

    // Fixed card height — single row layout
    const double cardH = 88.0;
    const double imgSize = 58.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: _Tok.s10),
      child: SizedBox(
        height: cardH,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_Tok.r16),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(_Tok.r16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: _Tok.s12, vertical: _Tok.s12),
              child: Row(
                children: [
                  // ── left: small square image ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_Tok.r12),
                    child: SizedBox(
                      width: imgSize,
                      height: imgSize,
                      child: plan.image != null && plan.image!.isNotEmpty
                          ? NetworkImageWidget(
                        imageUrl: plan.image!,
                        fit: BoxFit.cover,
                        width: imgSize,
                        height: imgSize,
                        errorWidget: _SmallPlaceholder(
                            grad: planGrad, size: imgSize),
                      )
                          : _SmallPlaceholder(grad: planGrad, size: imgSize),
                    ),
                  ),
                  const SizedBox(width: _Tok.s12),

                  // ── middle: name + meta ──
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: _Tok.f15,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: _Tok.s4),
                        Text(
                          Constant.amountShow(amount: plan.price),
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: _Tok.f14,
                            color: AppThemeData.secondary300,
                          ),
                        ),
                        const SizedBox(height: _Tok.s2),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11, color: textSub),
                            const SizedBox(width: 3),
                            Text(
                              plan.expiryDay.isEmpty || plan.expiryDay == '0'
                                  ? "Unlimited"
                                  : "${plan.expiryDay} days",
                              style: TextStyle(
                                fontFamily: AppThemeData.regular,
                                fontSize: _Tok.f11,
                                color: textSub,
                              ),
                            ),
                            const SizedBox(width: _Tok.s8),
                            _TypeBadgeInline(isCommission: isCommission),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: _Tok.s10),

                  // ── right: buy button ──
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    onPressed: onBuyNow ?? onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}

// ─────────────────────────────────────────────
// PILL BUTTON
// ─────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.fullWidth = false,
  });
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_Tok.r99),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 0 : _Tok.s20,
            vertical: fullWidth ? _Tok.s16 : _Tok.s10,
          ),
          alignment: fullWidth ? Alignment.center : null,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(_Tok.r99),
            boxShadow: [
              BoxShadow(
                color: _gradFirstColor(gradient).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: fullWidth ? _Tok.f16 : _Tok.f13,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: inner);
    }
    return inner;
  }

  Color _gradFirstColor(Gradient g) {
    if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.first;
    return AppThemeData.secondary300;
  }
}

// ─────────────────────────────────────────────
// TYPE BADGE
// ─────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _Tok.s10, vertical: _Tok.s4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(_Tok.r99),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommission ? Icons.percent_rounded : Icons.star_rounded,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isCommission ? 'Commission'.tr : 'Subscription'.tr,
            style: const TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// // ─────────────────────────────────────────────
// // PLACEHOLDER
// // ─────────────────────────────────────────────
// class _PlanIconPlaceholder extends StatelessWidget {
//   const _PlanIconPlaceholder({required this.grad});
//   final LinearGradient grad;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(gradient: grad),
//       child: const Center(
//         child: Icon(
//           Icons.card_membership_rounded,
//           size: _Tok.i48,
//           color: Colors.white54,
//         ),
//       ),
//     );
//   }
// }

class _SmallPlaceholder extends StatelessWidget {
  const _SmallPlaceholder({required this.grad, required this.size});
  final LinearGradient grad;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: grad),
      child: const Center(
        child: Icon(Icons.card_membership_rounded,
            size: 24, color: Colors.white60),
      ),
    );
  }
}

/// Tiny inline badge used inside the horizontal card row
class _TypeBadgeInline extends StatelessWidget {
  const _TypeBadgeInline({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCommission
            ? const Color(0xFF4776E6).withValues(alpha: 0.12)
            : const Color(0xFF11998E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_Tok.r99),
      ),
      child: Text(
        isCommission ? 'Commission'.tr : 'Subscription'.tr,
        style: TextStyle(
          fontFamily: AppThemeData.semiBold,
          fontSize: 9,
          color: isCommission
              ? const Color(0xFF4776E6)
              : const Color(0xFF11998E),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DOT PATTERN PAINTER
// ─────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 14.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}

// ─────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlanDetailScreen extends StatelessWidget {
  const SubscriptionPlanDetailScreen({super.key, required this.plan});
  final SubscriptionPlanModel plan;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDark = themeChange.getThem();
    final bgColor = isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSub = isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);
    final divider = isDark ? const Color(0xFF2A2F50) : const Color(0xFFE8EDF5);
    final isCommission = plan.isCommission;
    final planGrad = isCommission ? _Tok.commissionGrad : _Tok.subGrad;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── hero app bar ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: _Tok.s8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(_Tok.s8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(_Tok.r12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: _Tok.i22),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // base gradient
                  Container(decoration: BoxDecoration(gradient: planGrad)),
                  // dot pattern
                  Opacity(
                    opacity: 0.06,
                    child: CustomPaint(painter: _DotPatternPainter()),
                  ),
                  // plan image
                  if (plan.image != null && plan.image!.isNotEmpty)
                    NetworkImageWidget(
                      imageUrl: plan.image!,
                      fit: BoxFit.cover,
                      errorWidget: const SizedBox.shrink(),
                    ),
                  // bottom scrim
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                        colors: [
                          Colors.transparent,
                          bgColor,
                        ],
                      ),
                    ),
                  ),
                  // bottom content
                  Positioned(
                    left: _Tok.s20,
                    right: _Tok.s20,
                    bottom: _Tok.s20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TypeBadge(isCommission: isCommission),
                        const SizedBox(height: _Tok.s8),
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: _Tok.f26,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(blurRadius: 12, color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  _Tok.s16, _Tok.s4, _Tok.s16, _Tok.s48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // price + validity row
                  _PriceCard(
                    plan: plan,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSub: textSub,
                    planGrad: planGrad,
                    divider: divider,
                  ),
                  const SizedBox(height: _Tok.s16),

                  // description
                  if (plan.description.isNotEmpty) ...[
                    _SectionLabel(label: "About this plan".tr, textColor: textPrimary),
                    const SizedBox(height: _Tok.s8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(_Tok.s16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(_Tok.r16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        plan.description,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          fontSize: _Tok.f15,
                          color: textSub,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: _Tok.s20),
                  ],

                  // details
                  _SectionLabel(label: "Plan details".tr, textColor: textPrimary),
                  const SizedBox(height: _Tok.s8),
                  _DetailCard(
                    cardBg: cardBg,
                    divider: divider,
                    rows: _buildRows(plan, textPrimary, textSub),
                  ),

                  const SizedBox(height: _Tok.s28),

                  // CTA
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    fullWidth: true,
                    onPressed: () {
                      final ctrl =
                          Get.find<SubscriptionPaymentController>();
                      ctrl.startRazorpayPayment(plan);
                    },
                  ),

                  const SizedBox(height: _Tok.s12),
                  Center(
                    child: Text(
                      "Secure payment · Cancel anytime",
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: _Tok.f12,
                        color: textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_RowData> _buildRows(
      SubscriptionPlanModel p, Color primary, Color sub) {
    final rows = <_RowData>[];
    rows.add(_RowData(
      icon: Icons.category_rounded,
      label: "Plan type".tr,
      value: p.planType == 'commission' ? 'Commission'.tr : 'Subscription'.tr,
    ));
    if (p.expiryDay.isNotEmpty) {
      rows.add(_RowData(
        icon: Icons.calendar_today_rounded,
        label: "Validity".tr,
        value: p.expiryDay == '0' ? "Unlimited".tr : "${p.expiryDay} days",
      ));
    }
    if (p.itemLimit.isNotEmpty && p.itemLimit != 'null') {
      rows.add(_RowData(
        icon: Icons.inventory_2_rounded,
        label: "Item limit".tr,
        value: p.itemLimit == '0' ? "Unlimited".tr : p.itemLimit,
      ));
    }
    // if (p.orderLimit.isNotEmpty && p.orderLimit != 'null') {
    //   rows.add(_RowData(
    //     icon: Icons.receipt_long_rounded,
    //     label: "Order limit".tr,
    //     value: p.orderLimit == '0' ? "Unlimited".tr : p.orderLimit,
    //   ));
    // }
    if (p.place.isNotEmpty && p.place != '0') {
      rows.add(_RowData(
        icon: Icons.percent,
        label: "commission".tr,
        value: p.place,
      ));
    }
    return rows;
  }
}

class _RowData {
  const _RowData({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}

// ─────────────────────────────────────────────
// PRICE CARD
// ─────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.plan,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
    required this.planGrad,
    required this.divider,
  });
  final SubscriptionPlanModel plan;
  final Color cardBg, textPrimary, textSub, divider;
  final LinearGradient planGrad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_Tok.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    fontFamily: AppThemeData.regular,
                    fontSize: _Tok.f12,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      planGrad.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    Constant.amountShow(amount: plan.price),
                    style: const TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // divider
          Container(width: 1, height: 48, color: divider),
          const SizedBox(width: _Tok.s20),
          // validity
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Validity",
                style: TextStyle(
                  fontFamily: AppThemeData.regular,
                  fontSize: _Tok.f12,
                  color: textSub,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 16, color: textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    plan.expiryDay.isEmpty || plan.expiryDay == '0'
                        ? "Unlimited"
                        : "${plan.expiryDay} days",
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f18,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textColor});
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppThemeData.semiBold,
        fontSize: _Tok.f16,
        color: textColor,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL CARD
// ─────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.cardBg,
    required this.divider,
    required this.rows,
  });
  final Color cardBg, divider;
  final List<_RowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: divider, indent: 48, endIndent: 16),
        itemBuilder: (_, i) {
          final row = rows[i];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _Tok.s16, vertical: _Tok.s14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppThemeData.secondary300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_Tok.r8),
                  ),
                  child: Icon(row.icon,
                      size: 16, color: AppThemeData.secondary300),
                ),
                const SizedBox(width: _Tok.s12),
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontFamily: AppThemeData.regular,
                      fontSize: _Tok.f14,
                      color: AppThemeData.grey500,
                    ),
                  ),
                ),
                Text(
                  row.value,
                  style: const TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f14,
                    color: AppThemeData.grey900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOADING VIEW
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeData.secondary300,
              ),
            ),
          ),
          const SizedBox(height: _Tok.s16),
          Text(
            "Loading plans…",
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: _Tok.f14,
              color: AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: _Tok.i48, color: Color(0xFFFF4757)),
            ),
            const SizedBox(height: _Tok.s20),
            Text(
              "Something went wrong",
              style: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f18,
                color: AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Retry".tr,
              gradient: _Tok.accentGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY VIEW
// ─────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: _Tok.heroGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3561).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.card_membership_rounded,
                  size: _Tok.i48, color: Colors.white),
            ),
            const SizedBox(height: _Tok.s24),
            const Text(
              "No plans yet",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f22,
                color: AppThemeData.grey900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              "No subscription plans available for your zone right now.".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Refresh".tr,
              gradient: _Tok.heroGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}


