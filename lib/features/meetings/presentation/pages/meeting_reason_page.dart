import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/coordinator.dart';
import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/meeting_reason_bloc.dart';
import '../widgets/meeting_card.dart';
import '../widgets/meeting_excuse_row.dart';

/// "Yig‘ilishga qatnashmadingiz" — qatnashmaslik sababini yozib yuborish
/// ekrani. Bildirishnoma (type=meeting) bosilganda ochiladi. Sabab yuborilgach
/// yig‘ilishlar sahifasiga o‘tadi va "Sabab yuborildi." toasti ko‘rsatiladi.
class MeetingReasonPage extends StatelessWidget {
  const MeetingReasonPage({super.key, required this.meetingId});

  final int meetingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeetingReasonBloc>(
      create: (_) =>
          getIt<MeetingReasonBloc>()..add(MeetingReasonLoaded(meetingId)),
      child: const _ReasonView(),
    );
  }
}

class _ReasonView extends StatefulWidget {
  const _ReasonView();

  @override
  State<_ReasonView> createState() => _ReasonViewState();
}

class _ReasonViewState extends State<_ReasonView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<MeetingReasonBloc>().add(MeetingReasonSubmitted(text));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: BlocListener<MeetingReasonBloc, MeetingReasonState>(
          listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == MeetingReasonSubmit.success) {
              // Yig‘ilishlar sahifasiga o‘tamiz va toast ko‘rsatamiz (toast
              // root overlay’da — sahifa almashsa ham qoladi).
              context.goNamed(Routes.meetings.name);
              final toastContext = rootNavigatorKey.currentContext;
              if (toastContext != null) {
                AppToast.showSuccess(
                  toastContext,
                  title: l10n.meetingReasonSentTitle,
                );
              }
            } else if (state.submitStatus == MeetingReasonSubmit.failure) {
              final message = state.failure is NetworkFailure
                  ? l10n.networkError
                  : l10n.commonError;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: colors.errorStrong,
                    content: message.s(14.sp).w(500).c(colors.textWhite),
                  ),
                );
            }
          },
          child: BlocBuilder<MeetingReasonBloc, MeetingReasonState>(
            buildWhen: (a, b) =>
                a.loadStatus != b.loadStatus || a.isOrganizer != b.isOrganizer,
            builder: (context, state) {
              // Tashkilotchi: sabab yozish o'rniga sabablarni tasdiqlash.
              if (state.isOrganizer) return const _OrganizerView();

              // Sabab allaqachon yuborilgan (yoki qatnashgan) — forma emas,
              // holat ko'rinishi. Rad etilgan bo'lsa ham qayta yozib bo'lmaydi.
              final mine = state.myAttendance;
              if (mine != null &&
                  ((mine.isAttended && mine.lateMinutes <= 5) ||
                      mine.absenceReason.trim().isNotEmpty ||
                      (!mine.canSubmitReason && mine.lateMinutes > 5))) {
                return _ReasonStatusView(
                  title: state.title,
                  date: formatMeetingDate(state.startDate),
                );
              }

              return Column(
                children: [
                  _ReasonHeader(title: l10n.meetingReasonTitle),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      child: BlocBuilder<MeetingReasonBloc, MeetingReasonState>(
                        buildWhen: (a, b) =>
                            a.title != b.title ||
                            a.startDate != b.startDate ||
                            a.myAttendance != b.myAttendance,
                        builder: (context, state) {
                          final lateMinutes =
                              state.myAttendance?.lateMinutes ?? 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: l10n.meetingReasonPrompt
                                        .s(13.sp)
                                        .w(800)
                                        .c(colors.textStrong)
                                        .copyWith(maxLines: 2),
                                  ),
                                  SizedBox(width: 12.w),
                                  _MeetingSummary(
                                    title: state.title,
                                    date: formatMeetingDate(state.startDate),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              if (lateMinutes > 5) ...[
                                l10n
                                    .meetingCallLateReason(lateMinutes)
                                    .s(12.sp)
                                    .w(600)
                                    .c(colors.errorStrong),
                                SizedBox(height: 8.h),
                              ],
                              _ReasonField(
                                controller: _controller,
                                hint: l10n.meetingReasonHint,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  _SubmitBar(controller: _controller, onSubmit: _submit),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tashkilotchi ko'rinishi: qatnashmaganlar ro'yxati — har birida sabab va
/// "Tasdiqlash" tugmasi (`is_excused=true`).
class _OrganizerView extends StatelessWidget {
  const _OrganizerView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<MeetingReasonBloc, MeetingReasonState>(
      listenWhen: (a, b) => b.approveFailed,
      listener: (context, state) =>
          AppToast.showError(context, title: l10n.commonError),
      builder: (context, state) {
        return Column(
          children: [
            _ReasonHeader(title: l10n.meetingExcuseListTitle),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: state.title
                        .s(13.sp)
                        .w(700)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 8.w),
                  formatMeetingDate(
                    state.startDate,
                  ).s(11.sp).w(500).c(colors.textSub),
                ],
              ),
            ),
            Expanded(
              child: state.rows.isEmpty
                  ? Center(
                      child: l10n.statEmpty.s(14.sp).w(500).c(colors.textSub),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      itemCount: state.rows.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemBuilder: (_, i) {
                        final row = state.rows[i];
                        return MeetingExcuseRow(
                          row: row,
                          busy: state.approvingId == row.id,
                          rejected: state.rejectedIds.contains(row.id),
                          onApprove: () =>
                              context.read<MeetingReasonBloc>().add(
                                MeetingExcuseDecided(
                                  attendanceId: row.id,
                                  approved: true,
                                ),
                              ),
                          onReject: () => context.read<MeetingReasonBloc>().add(
                            MeetingExcuseDecided(
                              attendanceId: row.id,
                              approved: false,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Sabab yozish mumkin bo'lmagan holat: qatnashgan yoki sabab allaqachon
/// yuborilgan (tasdiqlangan/rad etilgan) — faqat holat ko'rsatiladi.
class _ReasonStatusView extends StatelessWidget {
  const _ReasonStatusView({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _ReasonHeader(title: l10n.meetingReasonTitle),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: BlocBuilder<MeetingReasonBloc, MeetingReasonState>(
              builder: (context, state) {
                final mine = state.myAttendance;
                final String status;
                final Color color;
                if (mine == null || mine.isAttended) {
                  status = l10n.meetingMyAttended;
                  color = colors.successStrong;
                } else if (mine.isExcused) {
                  status = l10n.meetingExcuseAccepted;
                  color = colors.successStrong;
                } else {
                  status = l10n.meetingReasonSentLabel;
                  color = colors.textSoft;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: title
                              .s(13.sp)
                              .w(700)
                              .c(colors.textStrong)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                        SizedBox(width: 8.w),
                        date.s(11.sp).w(500).c(colors.textSub),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    if (mine != null &&
                        !mine.isAttended &&
                        mine.absenceReason.trim().isNotEmpty) ...[
                      mine.absenceReason
                          .s(13.sp)
                          .w(500)
                          .h(20 / 13)
                          .c(colors.textSub),
                      SizedBox(height: 8.h),
                    ],
                    status.s(13.sp).w(700).c(color),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReasonHeader extends StatelessWidget {
  const _ReasonHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
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
          Expanded(
            child: Center(
              child: title
                  .s(17.sp)
                  .w(800)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          SizedBox(width: 32.w),
        ],
      ),
    );
  }
}

/// Tugma uchun oddiy "check" belgisi — rangi holatga qarab o‘zgargani sabab
/// SVG emas, [CustomPaint] bilan chiziladi (kompozit `ic_check` bu yerga mos
/// emas).
class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CheckPainter(color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.74)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}

class _MeetingSummary extends StatelessWidget {
  const _MeetingSummary({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          title
              .s(13.sp)
              .w(500)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          if (date.isNotEmpty)
            date
                .s(11.sp)
                .w(500)
                .c(colors.textSub)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 9.h),
        child: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: colors.textStrong,
          ),
          cursorColor: colors.accentSub,
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colors.iconSub,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastki "Yuborish" tugmasi — matn bo‘sh bo‘lsa o‘chirilgan ko‘rinishda,
/// aks holda accent; yuborish jarayonida spinner.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
        child: BlocBuilder<MeetingReasonBloc, MeetingReasonState>(
          buildWhen: (a, b) => a.submitStatus != b.submitStatus,
          builder: (context, state) {
            final submitting = state.isSubmitting;
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final enabled = value.text.trim().isNotEmpty && !submitting;
                final bg = enabled
                    ? colors.accentStrong
                    : colors.backgroundElevation1;
                final fg = enabled ? colors.textWhite : colors.textStrong;

                return InkWell(
                  onTap: enabled ? onSubmit : null,
                  borderRadius: BorderRadius.circular(16.r),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: SizedBox(
                      height: 52.h,
                      child: Center(
                        child: submitting
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5.w,
                                  color: colors.textWhite,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _CheckMark(color: fg, size: 16.w),
                                  SizedBox(width: 8.w),
                                  l10n.meetingReasonSubmit
                                      .s(15.sp)
                                      .w(800)
                                      .c(fg),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
