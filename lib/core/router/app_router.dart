import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/presentation/pages/home_page.dart';

import 'package:yoyu/features/card_face/presentation/pages/card_face_picker_page.dart';
import 'package:yoyu/features/detail/presentation/pages/card_detail_page.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pick_face',
        pageBuilder: (context, state) {
          final card = state.extra as CardEntity;
          return CupertinoPage(child: CardFacePickerPage(card: card));
        },
      ),
      GoRoute(
        path: '/detail',
        pageBuilder: (context, state) {
          final card = state.extra as CardEntity;
          return CupertinoPage(child: CardDetailPage(card: card));
        },
      ),
    ],
  );
});
