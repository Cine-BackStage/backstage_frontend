import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/widgets/cards/feature_card.dart';
import '../../domain/entities/feature_info.dart';

/// Features carousel widget for login page
class FeaturesCarousel extends StatefulWidget {
  final List<FeatureInfo> features;

  const FeaturesCarousel({
    super.key,
    required this.features,
  });

  @override
  State<FeaturesCarousel> createState() => _FeaturesCarouselState();
}

class _FeaturesCarouselState extends State<FeaturesCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // TODO: Add auto-scroll functionality
    // _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.features.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final feature = widget.features[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16,
                ),
                child: FeatureCard(
                  title: feature.title,
                  description: feature.description,
                  icon: feature.icon,
                  iconColor: feature.color,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),

        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.features.length,
            (index) => _buildIndicator(index == _currentPage),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
      ),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFFD700) // Golden Reel
            : const Color(0xFF2E2E2E), // Gray Curtain
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // TODO: Implement auto-scroll
  // void _startAutoScroll() {
  //   Timer.periodic(const Duration(seconds: 4), (timer) {
  //     if (!mounted) {
  //       timer.cancel();
  //       return;
  //     }
  //     final nextPage = (_currentPage + 1) % widget.features.length;
  //     _pageController.animateToPage(
  //       nextPage,
  //       duration: const Duration(milliseconds: 400),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }
}
