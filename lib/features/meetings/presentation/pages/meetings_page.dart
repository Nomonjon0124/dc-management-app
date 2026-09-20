import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../app/bloc/session_bloc.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/meeting_filter.dart';
import '../bloc/meetings_bloc.dart';
import '../widgets/meeting_card.dart';

/// Yig‘ilishlar ro‘yxati ekrani (`GET /meetings/`).
class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MeetingsBloc>(
          create: (_) => getIt<MeetingsBloc>()..add(const MeetingsRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
      ],
      child: const _MeetingsView(),
    );
  }
}

class _MeetingsView extends StatelessWidget {
  const _MeetingsView();

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<MeetingsBloc>();
    bloc.add(const MeetingsRequested());
    return bloc.stream.firstWhere((s) => s.status != MeetingsStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final activeRole = context.select<SessionBloc, RoleType>(
      (bloc) => bloc.state.roleType,
    );
    final currentUserId = context.select<ProfileBloc, int>(
      (bloc) => bloc.state.profile?.id ?? 0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              tooltip: AppLocalizations.of(context).meetingAdd,
              backgroundColor: colors.accentStrong,
              onPressed: () => context.pushNamed(Routes.meetingCreate.name),
              child: Assets.icons.icPlus.svg(
                width: 22.w,
                height: 22.w,
                colorFilter: ColorFilter.mode(
                  colors.textWhite,
                  BlendMode.srcIn,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const _MeetingsHeader(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: () => _onRefresh(context),
                child: BlocBuilder<MeetingsBloc, MeetingsState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case MeetingsStatus.loading:
                      case MeetingsStatus.initial:
                        return const _CenteredScrollable(
                          child: CircularProgressIndicator(),
                        );
                      case MeetingsStatus.failure:
                        return _CenteredScrollable(
                          child: _ErrorState(
                            failure: state.failure,
                            onRetry: () => context.read<MeetingsBloc>().add(
                              const MeetingsRequested(),
                            ),
                          ),
                        );
                      case MeetingsStatus.success:
                        if (state.items.isEmpty) {
                          return _CenteredScrollable(
                            child: AppLocalizations.of(
                              context,
                            ).meetingsEmpty.s(14.sp).w(500).c(colors.textSub),
                          );
                        }
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (_, i) {
                            final meeting = state.items[i];
                            final canManage =
                                activeRole != RoleType.employee ||
                                meeting.organizerId == currentUserId;
                            return MeetingCard(
                              meeting: meeting,
                              // Detail'da yig'ilish yakunlansa pop(true)
                              // qaytadi — ro'yxat qayta yuklanadi.
                              onTap: () async {
                                final bloc = context.read<MeetingsBloc>();
                                final changed = await context.pushNamed<bool>(
                                  Routes.meetingDetail.name,
                                  pathParameters: {'id': '${meeting.id}'},
                                  extra: meeting,
                                );
                                if (changed == true) {
                                  bloc.add(const MeetingsRequested());
                                }
                              },
                              onEdit: canManage
                                  ? () async {
                                      final bloc = context.read<MeetingsBloc>();
                                      final updated = await context
                                          .pushNamed<bool>(
                                            Routes.meetingEdit.name,
                                            pathParameters: {
                                              'id': '${meeting.id}',
                                            },
                                            extra: meeting,
                                          );
                                      if (updated == true) {
                                        bloc.add(const MeetingsRequested());
                                      }
                                    }
                                  : null,
                              onDelete: canManage
                                  ? () => context.read<MeetingsBloc>().add(
                                      MeetingsMeetingDeleted(meeting.id),
                                    )
                                  : null,
                            );
                          },
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ikki qatorli sarlavha: (1) orqaga + "Yig‘ilish qo‘shish" + bildirishnoma,
/// (2) "Yig‘ilishlar" + qidiruv + filtr. Qo‘shish/qidiruv/filtr — hozircha
/// stub (tegishli oqim dizayni yo‘q).
class _MeetingsHeader extends StatelessWidget {
  const _MeetingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Assets.icons.icArrowLeftLarge.svg(
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _AddMeetingButton(
                onTap: () async {
                  final bloc = context.read<MeetingsBloc>();
                  final created = await context.pushNamed<bool>(
                    Routes.meetingCreate.name,
                  );
                  if (created == true) bloc.add(const MeetingsRequested());
                },
              ),
              SizedBox(width: 12.w),
              _SquareIconButton(
                icon: Assets.icons.icProfileNotification,
                background: colors.backgroundElevation1,
                borderColor: colors.strokeSub,
                onTap: () => context.pushNamed(Routes.notifications.name),
              ),
            ],
          ),
        ),
        const _SearchFilterRow(),
      ],
    );
  }
}

class _SearchFilterRow extends StatefulWidget {
  const _SearchFilterRow();

  @override
  State<_SearchFilterRow> createState() => _SearchFilterRowState();
}

class _SearchFilterRowState extends State<_SearchFilterRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _closeSearch() {
    _debounce?.cancel();
    final hadText = _controller.text.isNotEmpty;
    _controller.clear();
    _focus.unfocus();
    setState(() => _searching = false);
    if (hadText) {
      context.read<MeetingsBloc>().add(const MeetingsSearchChanged(''));
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<MeetingsBloc>().add(MeetingsSearchChanged(value.trim()));
      }
    });
  }

  Future<void> _openFilter() async {
    final bloc = context.read<MeetingsBloc>();
    final result = await context.pushNamed<Object?>(
      Routes.meetingFilter.name,
      extra: bloc.state.filter,
    );
    if (result is MeetingFilter) {
      bloc.add(MeetingsFilterChanged(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _searching
            ? _SearchBar(
                key: const ValueKey('search'),
                controller: _controller,
                focus: _focus,
                onChanged: _onChanged,
                onClose: _closeSearch,
              )
            : _TitleBar(
                key: const ValueKey('title'),
                onSearch: _openSearch,
                onFilter: _openFilter,
              ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.onSearch, required this.onFilter, super.key});

  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: l10n.meetingsTitle
              .s(17.sp)
              .w(800)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 12.w),
        _SquareIconButton(
          icon: Assets.icons.icSearch,
          background: colors.backgroundElevation1,
          size: 40,
          iconSize: 16,
          onTap: onSearch,
        ),
        SizedBox(width: 12.w),
        BlocBuilder<MeetingsBloc, MeetingsState>(
          buildWhen: (p, c) =>
              p.filter.hasActiveFilters != c.filter.hasActiveFilters,
          builder: (context, state) => _SquareIconButton(
            icon: Assets.icons.icFilter,
            background: colors.backgroundElevation1,
            size: 40,
            iconSize: 16,
            showDot: state.filter.hasActiveFilters,
            onTap: onFilter,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onClose,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: colors.textStrong,
    );

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.strokeSub, width: 1.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SizedBox(
                height: 40.h,
                child: Row(
                  children: [
                    Assets.icons.icSearch.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focus,
                        onChanged: onChanged,
                        textInputAction: TextInputAction.search,
                        style: style,
                        cursorColor: colors.accentSub,
                        decoration: InputDecoration.collapsed(
                          hintText: l10n.taskSearchHint,
                          hintStyle: style.copyWith(color: colors.textSub),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                controller.clear();
                                onChanged('');
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Assets.icons.icClose.svg(
                                  width: 14.w,
                                  height: 14.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.iconSub,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: l10n.taskSearchClose.s(13.sp).w(700).c(colors.textSub),
          ),
        ),
      ],
    );
  }
}

class _AddMeetingButton extends StatelessWidget {
  const _AddMeetingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accentStrong,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SizedBox(
            height: 20.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.icons.icShareNodes.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                l10n.meetingAdd.s(13.sp).w(800).c(colors.textWhite),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.background,
    required this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.borderColor,
    this.showDot = false,
  });

  final SvgGenImage icon;
  final Color background;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? borderColor;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget square = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor ?? colors.strokeSoft, width: 1.w),
      ),
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: Center(
          child: icon.svg(
            width: iconSize.w,
            height: iconSize.w,
            colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
          ),
        ),
      ),
    );

    if (showDot) {
      square = Stack(
        clipBehavior: Clip.none,
        children: [
          square,
          Positioned(
            top: -2.h,
            right: -2.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentSub,
                shape: BoxShape.circle,
                border: Border.all(color: colors.backgroundBase, width: 2.w),
              ),
              child: SizedBox(width: 10.w, height: 10.w),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: square,
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final message = failure is NetworkFailure
        ? l10n.networkError
        : l10n.commonError;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          message.s(14.sp).w(500).c(colors.textSub).a(TextAlign.center),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
          ),
        ],
      ),
    );
  }
}
