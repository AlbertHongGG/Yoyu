import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/card_face/presentation/controllers/card_face_controller.dart';
import 'package:yoyu/features/card_face/presentation/widgets/shimmer_image_card.dart';
import 'package:yoyu/features/home/presentation/controllers/card_list_controller.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:go_router/go_router.dart';

class CardFacePickerPage extends ConsumerStatefulWidget {
  final CardEntity card;
  const CardFacePickerPage({super.key, required this.card});

  @override
  ConsumerState<CardFacePickerPage> createState() => _CardFacePickerPageState();
}

class _CardFacePickerPageState extends ConsumerState<CardFacePickerPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(cardFaceProvider.notifier).loadMore();
    }
  }

  void _selectImage(String url) async {
    final updatedCard = widget.card.copyWith(cardFaceUrl: url);
    await ref.read(cardListProvider.notifier).updateCard(updatedCard);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardFaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇卡片封面'),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns for portrait, you can change to 2 for landscape
                childAspectRatio: 0.63, // Portrait ratio
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < state.loadedUrls.length) {
                    final url = state.loadedUrls[index];
                    return GestureDetector(
                      onTap: () => _selectImage(url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              url,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const ShimmerImageCard();
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.withValues(alpha: 0.2),
                                child: const Icon(Icons.error),
                              ),
                            ),
                            // Selection overlay
                            if (url == widget.card.cardFaceUrl)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                child: const Center(
                                  child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const ShimmerImageCard();
                  }
                },
                childCount: state.loadedUrls.length + (state.hasNext ? 6 : 0), // Extra 6 for shimmer
              ),
            ),
          ),
        ],
      ),
    );
  }
}
