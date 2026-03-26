import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rickandmorty/core/widgets/app_card.dart';
import 'package:rickandmorty/core/widgets/shimmer_loader.dart';

class ShimmerCharacterCard extends StatelessWidget {
  const ShimmerCharacterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Shimmer
          Expanded(
            flex: 4,
            child: ShimmerLoader.rounded(
              height: double.infinity,
              borderRadius: 16.r,
            ),
          ),
          // Info Shimmer
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name Shimmer
                  ShimmerLoader.rounded(
                    height: 14.h,
                    width: 100.w,
                    borderRadius: 4.r,
                  ),
                  SizedBox(height: 8.h),
                  // Status/Species Shimmer
                  Row(
                    children: [
                      ShimmerLoader.circular(width: 8.w, height: 8.w),
                      SizedBox(width: 6.w),
                      ShimmerLoader.rounded(
                        height: 10.h,
                        width: 60.w,
                        borderRadius: 4.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
