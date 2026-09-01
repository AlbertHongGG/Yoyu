import 'package:flutter/material.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:intl/intl.dart';

class CardItemWidget extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onTap;
  final VoidCallback onPickImage;

  const CardItemWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Format amount with currency symbol
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Image Header
            Stack(
              children: [
                Hero(
                  tag: 'card_image_${card.cardNo}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: AspectRatio(
                      aspectLabel: 16 / 9,
                      child: Image.network(
                        card.cardFaceUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center, // Center crop for horizontal images
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? Colors.white10 : Colors.black12,
                          child: const Icon(Icons.credit_card, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onPickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Icon(
                        Icons.collections,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                if (card.isRegister)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.greenAccent, size: 12),
                          SizedBox(width: 4),
                          Text('記名', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Card Info Body
            // Card Info Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Name + Card No
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.cardName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Tight spacing to act as subtitle
                        Row(
                          children: [
                            Icon(Icons.credit_card_outlined, size: 12, color: isDark ? Colors.white54 : Colors.black38),
                            const SizedBox(width: 4),
                            Text(
                              card.cardNo.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} "), // Simple formatting
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontFamily: 'monospace',
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right side: Amount
                  Text(
                    currencyFormat.format(card.lastTranSum),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AspectRatio extends StatelessWidget {
    final Widget child;
    final double aspectLabel;

    const AspectRatio({super.key, required this.child, required this.aspectLabel});

    @override
    Widget build(BuildContext context) {
        return LayoutBuilder(
            builder: (context, constraints) {
                return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxWidth / aspectLabel,
                    child: child,
                );
            }
        );
    }
}
