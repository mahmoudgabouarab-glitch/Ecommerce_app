import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../data/repo/genie_repo_impl.dart';
import '../view_model/genie_cubit/genie_cubit.dart';
import 'widgets/genie_bubble.dart';
import 'widgets/genie_composer.dart';

class GenieView extends StatelessWidget {
  const GenieView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GenieCubit(getIt<GenieRepoImpl>()),
      child: const _GenieScreen(),
    );
  }
}

class _GenieScreen extends StatefulWidget {
  const _GenieScreen();

  @override
  State<_GenieScreen> createState() => _GenieScreenState();
}

class _GenieScreenState extends State<_GenieScreen> {
  final _scroll = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFFB347)],
                ),
                borderRadius: BorderRadius.circular(9.r),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 17.r),
            ),
            SizedBox(width: 10.w),
            Text('genie_title'.tr()),
          ],
        ),
      ),
      body: BlocConsumer<GenieCubit, GenieState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          final cubit = context.read<GenieCubit>();
          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? _Intro(onPick: cubit.send)
                    : ListView.separated(
                        controller: _scroll,
                        padding: EdgeInsets.all(16.w),
                        itemCount:
                            state.messages.length + (state.sending ? 1 : 0),
                        separatorBuilder: (_, _) => SizedBox(height: 14.h),
                        itemBuilder: (context, i) {
                          if (i >= state.messages.length) {
                            return const _TypingBubble();
                          }
                          return GenieBubble(message: state.messages[i]);
                        },
                      ),
              ),
              GenieComposer(sending: state.sending, onSend: cubit.send),
            ],
          );
        },
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suggestions = [
      'genie_s1'.tr(),
      'genie_s2'.tr(),
      'genie_s3'.tr(),
      'genie_s4'.tr(),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Container(
            width: 74.w,
            height: 74.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22.r),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 38.r),
          ),
          SizedBox(height: 20.h),
          Text('genie_greeting'.tr(),
              textAlign: TextAlign.center, style: AppStyles.bold20),
          SizedBox(height: 10.h),
          Text(
            'genie_sub'.tr(),
            textAlign: TextAlign.center,
            style:
                AppStyles.regular14.copyWith(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: 28.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            alignment: WrapAlignment.center,
            children: suggestions
                .map((s) => GestureDetector(
                      onTap: () => onPick(s),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(s, style: AppStyles.medium14),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFFB347)],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.auto_awesome, color: Colors.white, size: 18.r),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: const _Dots(),
        ),
      ],
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots();

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_c.value + i * 0.2) % 1.0;
            final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
