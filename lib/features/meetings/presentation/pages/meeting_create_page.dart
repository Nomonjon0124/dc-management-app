import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/entities/meeting_form.dart';
import '../bloc/meeting_create_bloc.dart';
import '../widgets/meeting_excuse_row.dart';
import 'meeting_new_design/widgets/common/meeting_preview_button.dart';
import 'meeting_new_design/widgets/form/meeting_preview_field.dart';
import 'meeting_new_design/widgets/form/meeting_preview_header.dart';
import 'meeting_new_design/widgets/form/meeting_preview_participants_field.dart';
import 'meeting_new_design/widgets/form/meeting_preview_select_field.dart';
import 'meeting_new_design/widgets/form/meeting_preview_text_area.dart';

enum _Field { none, project }

/// Yig'ilish qo'shish/tahrirlash formasi. [initial] berilsa tahrirlash
/// rejimi: maydonlar ro'yxatdagi [Meeting]dan to'ldiriladi, saqlash `PUT`
/// yuboradi (toggle yoqilsa va yig'ilish ochiq bo'lsa keyin yopiladi).
/// [readOnly] — tafsilotlar rejimi: forma o'zgartirib bo'lmaydi, saqlash
/// paneli yashirin, havola bosilganda tashqi brauzerda ochiladi.
class MeetingCreatePage extends StatelessWidget {
  const MeetingCreatePage({
    super.key,
    this.initial,
    this.meetingId,
    this.readOnly = false,
    this.newDesign = false,
  });

  final Meeting? initial;

  /// Detail rejimida `GET /meetings/{id}/` uchun (path param; extra bo'lmasa
  /// ham ishlaydi).
  final int? meetingId;

  final bool readOnly;

  /// Production routes use the Figma form while the old implementation stays
  /// available for comparison and safe rollback.
  final bool newDesign;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeetingCreateBloc>(
      create: (_) {
        final bloc = getIt<MeetingCreateBloc>()
          ..add(const MeetingCreateOptionsRequested());
        final id = meetingId ?? initial?.id;
        if (readOnly && id != null) {
          bloc.add(MeetingDetailRequested(id));
          // Detail: joriy foydalanuvchining qatnashuv holati.
          final userId = _cachedUserId();
          if (userId != null) {
            bloc.add(
              MeetingMyAttendanceRequested(meetingId: id, userId: userId),
            );
          }
        }
        return bloc;
      },
      child: _MeetingCreateView(
        initial: initial,
        readOnly: readOnly,
        newDesign: newDesign,
      ),
    );
  }
}

class _MeetingCreateView extends StatefulWidget {
  const _MeetingCreateView({
    this.initial,
    this.readOnly = false,
    this.newDesign = false,
  });

  final Meeting? initial;
  final bool readOnly;
  final bool newDesign;

  @override
  State<_MeetingCreateView> createState() => _MeetingCreateViewState();
}

class _MeetingCreateViewState extends State<_MeetingCreateView> {
  final _nameCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _portalCtrl = OverlayPortalController();
  final _projectLink = LayerLink();

  _Field _open = _Field.none;
  ProjectShort? _project;
  DateTime? _date;
  TimeOfDay? _time;
  bool _completed = false;
  bool _requiresApproval = false;
  final Set<int> _participantIds = {};

  bool get _isEdit => widget.initial != null;

  /// Forma to'ldiriladigan manba: avval ro'yxatdan kelgan extra, detail
  /// rejimida `GET /meetings/{id}/` javobi bilan yangilanadi.
  Meeting? _meeting;

  /// Keshlangan login javobidagi (`cached_user`) joriy foydalanuvchi id'si.
  late final int? _currentUserId = _cachedUserId();

  /// Yakunlash faqat detail rejimida, ochiq yig'ilishda va joriy foydalanuvchi
  /// tashkilotchi bo'lib `participants_info`da ham bor bo'lsa ko'rinadi.
  bool get _canClose {
    final m = _meeting;
    if (!widget.readOnly || m == null || m.isCompleted) return false;
    final organizerId = m.organizerId;
    if (organizerId == null || organizerId != _currentUserId) return false;
    return m.participantsInfo.any((p) => p.id == organizerId);
  }

  @override
  void initState() {
    super.initState();
    // Tahrirlash: ro'yxatdagi Meeting'da forma maydonlari to'liq bor —
    // alohida detal so'rovi shart emas. Loyiha (ProjectShort) esa options
    // yuklangach id bo'yicha moslanadi (build'dagi BlocListener).
    _meeting = widget.initial;
    final m = _meeting;
    if (m != null) _applyMeeting(m);
  }

  void _applyMeeting(Meeting m) {
    _nameCtrl.text = m.title;
    _linkCtrl.text = m.link;
    _descCtrl.text = m.description;
    _penaltyCtrl.text = _intPart(m.penaltyPercentage ?? '');
    _durationCtrl.text = m.durationMinutes?.toString() ?? '';
    _completed = m.isCompleted;
    _requiresApproval = m.requiresApproval ?? false;
    _participantIds
      ..clear()
      ..addAll(m.participantIds);
    final start = m.startDate;
    if (start != null) {
      _date = start;
      _time = TimeOfDay.fromDateTime(start);
    }
  }

  /// Tanlanmagan loyihani yig'ilishning `projectId`si bo'yicha
  /// `project-shorts` ro'yxatidan topadi (ishtirokchilar ro'yxati
  /// ham yuklanadi, tanlovlar tozalanmaydi).
  void _syncProjectFromInitial(List<ProjectShort> projects) {
    final m = _meeting;
    if (_project != null || m == null || m.projectId == null) return;
    for (final p in projects) {
      if (p.id == m.projectId) {
        _project = p;
        context.read<MeetingCreateBloc>().add(
          MeetingCreateProjectSelected(p.id),
        );
        return;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _linkCtrl.dispose();
    _descCtrl.dispose();
    _penaltyCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _toggle(_Field field) {
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == field ? _Field.none : field);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _selectProject(ProjectShort project) {
    setState(() {
      _project = project;
      _participantIds.clear();
      _open = _Field.none;
    });
    _portalCtrl.hide();
    context.read<MeetingCreateBloc>().add(
      MeetingCreateProjectSelected(project.id),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _openParticipants(MeetingCreateState state) async {
    final l10n = AppLocalizations.of(context);
    if (_project == null) {
      AppToast.showError(context, title: l10n.taskCreateSelectProjectFirst);
      return;
    }
    if (state.membersLoading) return;
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: l10n.meetingCreateParticipantsTitle,
        items: [
          for (final member in state.members)
            MultiSelectItem(
              id: member.id,
              initial: member.username,
              title: member.username,
              subtitle: member.position,
              avatarUrl: member.avatar,
            ),
        ],
        selected: _participantIds,
      ),
    );
    if (result is Set<int>) {
      setState(() {
        _participantIds
          ..clear()
          ..addAll(result);
      });
    }
  }

  /// Tafsilotlar rejimida maydonni o'zgartirishdan to'sadi.
  Widget _ro(Widget child) =>
      widget.readOnly ? AbsorbPointer(child: child) : child;

  /// Havolani tashqi brauzerda ochadi (sxema yo'q bo'lsa `https://` qo'shiladi).
  Future<void> _openLink() async {
    var url = _linkCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    var launched = false;
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Object {
        launched = false;
      }
    }
    if (!launched && mounted) {
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).commonError,
      );
    }
  }

  /// Yakunlash sheet'i: qatnashganlar belgilanadi, tasdiqda bloc'ga yuboriladi.
  Future<void> _openCloseSheet() async {
    final m = _meeting;
    if (m == null) return;
    final bloc = context.read<MeetingCreateBloc>();
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).backgroundBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _CloseMeetingSheet(meeting: m),
    );
    if (result != null && mounted) {
      bloc.add(
        MeetingCloseWithAttendanceSubmitted(
          meetingId: m.id,
          attendedUserIds: result,
        ),
      );
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final duration = int.tryParse(_durationCtrl.text.trim());
    // Tahrirlashda loyiha ixtiyoriy (schema: project nullable) — moslanmagan
    // bo'lsa null ketadi.
    if ((_project == null && !_isEdit) ||
        _nameCtrl.text.trim().isEmpty ||
        _linkCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _date == null ||
        duration == null) {
      AppToast.showError(context, title: l10n.meetingCreateRequiredError);
      return;
    }

    final time = _time ?? const TimeOfDay(hour: 0, minute: 0);
    final date = _date!;
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final penalty = _penaltyCtrl.text.trim();

    final form = MeetingForm(
      project: _project?.id,
      title: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      penaltyPercentage: penalty.isEmpty ? null : penalty,
      startTime: startTime,
      durationMinutes: duration,
      participants: _participantIds.toList(),
      requiresApproval: _requiresApproval,
    );

    final initial = widget.initial;
    context.read<MeetingCreateBloc>().add(
      initial == null
          ? MeetingCreateSubmitted(form: form, closeAfterCreate: _completed)
          : MeetingUpdateSubmitted(
              id: initial.id,
              form: form,
              // Yopishni faqat endi yoqilgan bo'lsa chaqiramiz (ochish API'si yo'q).
              closeAfterUpdate: _completed && !initial.isCompleted,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<MeetingCreateBloc, MeetingCreateState>(
          listenWhen: (p, c) => p.submitStatus != c.submitStatus,
          listener: (context, state) {
            switch (state.submitStatus) {
              case MeetingCreateSubmitStatus.success:
                AppToast.showSuccess(
                  context,
                  title: _isEdit
                      ? l10n.meetingUpdateSuccess
                      : l10n.meetingCreateSuccess,
                );
                final submitted = state.submittedMeeting;
                if (widget.newDesign && !_isEdit && submitted != null) {
                  context.pushReplacementNamed(
                    Routes.meetingDetail.name,
                    pathParameters: {'id': '${submitted.id}'},
                    extra: submitted,
                  );
                } else {
                  Navigator.of(context).maybePop(true);
                }
              case MeetingCreateSubmitStatus.failure:
                AppToast.showError(
                  context,
                  title: l10n.commonError,
                  message: state.submitFailure?.message,
                );
              case MeetingCreateSubmitStatus.idle:
              case MeetingCreateSubmitStatus.submitting:
                break;
            }
          },
        ),
        // Tahrirlash: loyihalar ro'yxati kelganda loyihani moslashtiramiz.
        BlocListener<MeetingCreateBloc, MeetingCreateState>(
          listenWhen: (p, c) => p.projects != c.projects,
          listener: (context, state) =>
              setState(() => _syncProjectFromInitial(state.projects)),
        ),
        // Detail: `GET /meetings/{id}/` javobi kelganda forma yangilanadi.
        BlocListener<MeetingCreateBloc, MeetingCreateState>(
          listenWhen: (p, c) => p.detail != c.detail && c.detail != null,
          listener: (context, state) => setState(() {
            _meeting = state.detail;
            _applyMeeting(state.detail!);
            _syncProjectFromInitial(state.projects);
          }),
        ),
        // Sabab qarori xatosi (detail'dagi tasdiqlash/rad etish).
        BlocListener<MeetingCreateBloc, MeetingCreateState>(
          listenWhen: (p, c) => c.excuseActionFailed,
          listener: (context, state) =>
              AppToast.showError(context, title: l10n.commonError),
        ),
        // Yakunlash oqimi natijasi (davomat PATCH + close).
        BlocListener<MeetingCreateBloc, MeetingCreateState>(
          listenWhen: (p, c) => p.closeStatus != c.closeStatus,
          listener: (context, state) {
            switch (state.closeStatus) {
              case MeetingCreateSubmitStatus.success:
                AppToast.showSuccess(context, title: l10n.meetingCloseSuccess);
                Navigator.of(context).maybePop(true);
              case MeetingCreateSubmitStatus.failure:
                AppToast.showError(
                  context,
                  title: l10n.commonError,
                  message: state.submitFailure?.message,
                );
              case MeetingCreateSubmitStatus.idle:
              case MeetingCreateSubmitStatus.submitting:
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: widget.newDesign
            ? _buildNewDesignBody(context, colors, l10n)
            : SafeArea(
                child: OverlayPortal(
                  controller: _portalCtrl,
                  overlayChildBuilder: _buildOverlay,
                  child: Column(
                    children: [
                      _Header(
                        title: widget.readOnly
                            ? l10n.meetingDetailTitle
                            : _isEdit
                            ? l10n.meetingEditTitle
                            : l10n.meetingAdd,
                      ),
                      Expanded(
                        child: BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                          builder: (context, state) => SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              12.h,
                              20.w,
                              24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12.h,
                              children: [
                                _ro(
                                  AppFilterFieldBox(
                                    label: l10n.taskCreateFieldProject,
                                    value: _project?.title,
                                    placeholder: l10n.taskCreateProjectHint,
                                    link: _projectLink,
                                    showClear: !widget.readOnly,
                                    onTap: () => _toggle(_Field.project),
                                    onClear: () => setState(() {
                                      _project = null;
                                      _participantIds.clear();
                                    }),
                                  ),
                                ),
                                _ro(
                                  _InputField(
                                    label: l10n.taskCreateFieldName,
                                    hint: l10n.meetingCreateNameHint,
                                    controller: _nameCtrl,
                                  ),
                                ),
                                _ro(
                                  _InputField(
                                    label: l10n.taskCreateFieldPenalty,
                                    hint: l10n.meetingCreatePenaltyHint,
                                    controller: _penaltyCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [_MaxValueFormatter(100)],
                                  ),
                                ),
                                // Tafsilotlar rejimida havola bosilganda ochiladi.
                                GestureDetector(
                                  onTap: widget.readOnly ? _openLink : null,
                                  child: AbsorbPointer(
                                    absorbing: widget.readOnly,
                                    child: _InputField(
                                      label: l10n.meetingCreateLink,
                                      hint: l10n.meetingCreateLinkHint,
                                      controller: _linkCtrl,
                                      keyboardType: TextInputType.url,
                                    ),
                                  ),
                                ),
                                _ro(
                                  _TextAreaField(
                                    label: l10n.taskCreateFieldDescription,
                                    hint: l10n.meetingCreateDescriptionHint,
                                    controller: _descCtrl,
                                  ),
                                ),
                                _ro(
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppFilterPickerBox(
                                          value: _fmtDate(_date),
                                          placeholder: l10n.taskFilterDateHint,
                                          icon: Assets.icons.icCalendar,
                                          onTap: _pickDate,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: AppFilterPickerBox(
                                          value: _fmtTime(_time),
                                          placeholder: '00:00',
                                          icon: Assets.icons.icTuilconTime,
                                          onTap: _pickTime,
                                        ),
                                      ),
                                    ],
                                  ).withLabels(
                                    context,
                                    left: l10n.meetingCreateStartDate,
                                    right: l10n.taskCreateFieldTime,
                                  ),
                                ),
                                _ro(
                                  _InputField(
                                    label: l10n.meetingCreateDuration,
                                    hint: l10n.meetingCreateDurationHint,
                                    controller: _durationCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                _ro(
                                  _ParticipantsField(
                                    label: widget.readOnly
                                        ? l10n.meetingDetailParticipantsLabel
                                        : l10n.meetingCreateParticipantsLabel,
                                    readOnly: widget.readOnly,
                                    // Detail: qatnashchilar javobdagi participants_info'dan
                                    // (loyiha a'zolari yuklanishiga bog'liq emas).
                                    selected: widget.readOnly
                                        ? (_meeting?.participantsInfo ??
                                              const [])
                                        : _selectedMembers(state.members),
                                    loading: state.membersLoading,
                                    onPick: () => _openParticipants(state),
                                    onRemove: (id) => setState(
                                      () => _participantIds.remove(id),
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.cardSurface,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              l10n.meetingPreviewApprovalTitle
                                                  .s(14.sp)
                                                  .w(700)
                                                  .c(colors.textStrong),
                                              SizedBox(height: 3.h),
                                              l10n.meetingPreviewApprovalDescription
                                                  .s(11.sp)
                                                  .w(500)
                                                  .c(colors.textSub)
                                                  .copyWith(
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        _SmallSwitch(
                                          value: _requiresApproval,
                                          enabled: !widget.readOnly,
                                          onChanged: (value) => setState(
                                            () => _requiresApproval = value,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Detail: joriy foydalanuvchining qatnashuv holati
                                // (yakunlangan yig'ilishda).
                                if (widget.readOnly &&
                                    (_meeting?.isCompleted ?? false) &&
                                    state.myAttendance != null)
                                  _MyAttendanceSection(
                                    attendance: state.myAttendance!,
                                    onSendReason: () {
                                      final id = _meeting?.id;
                                      if (id != null) {
                                        context.pushNamed(
                                          Routes.meetingReason.name,
                                          pathParameters: {'id': '$id'},
                                        );
                                      }
                                    },
                                  ),
                                // Detail: tashkilotchi qatnashmaganlar sabablarini
                                // tasdiqlaydi/rad etadi.
                                if (widget.readOnly &&
                                    (_meeting?.isCompleted ?? false) &&
                                    _meeting?.organizerId != null &&
                                    _meeting?.organizerId == _currentUserId &&
                                    state.attendanceRows.any(
                                      (r) => !r.isAttended,
                                    )) ...[
                                  AppFilterFieldLabel(
                                    l10n.meetingExcuseListTitle,
                                  ),
                                  for (final row in state.attendanceRows)
                                    if (!row.isAttended)
                                      MeetingExcuseRow(
                                        row: row,
                                        busy: state.excuseBusyId == row.id,
                                        rejected: state.rejectedExcuseIds
                                            .contains(row.id),
                                        onApprove: () => context
                                            .read<MeetingCreateBloc>()
                                            .add(
                                              MeetingDetailExcuseDecided(
                                                attendanceId: row.id,
                                                approved: true,
                                              ),
                                            ),
                                        onReject: () => context
                                            .read<MeetingCreateBloc>()
                                            .add(
                                              MeetingDetailExcuseDecided(
                                                attendanceId: row.id,
                                                approved: false,
                                              ),
                                            ),
                                      ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Detail: tashkilotchi ochiq yig'ilishni yakunlay oladi.
                      if (widget.readOnly && _canClose)
                        BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                          buildWhen: (p, c) => p.closeStatus != c.closeStatus,
                          builder: (context, state) => _CloseBar(
                            label: l10n.meetingCloseAction,
                            loading:
                                state.closeStatus ==
                                MeetingCreateSubmitStatus.submitting,
                            onTap: _openCloseSheet,
                          ),
                        ),
                      if (widget.readOnly &&
                          _meeting?.id != null &&
                          !(_meeting?.isCompleted ?? true))
                        _JoinBar(
                          label: l10n.meetingCallJoin,
                          onTap: () => context.pushNamed(
                            Routes.meetingRoom.name,
                            pathParameters: {'id': '${_meeting!.id}'},
                          ),
                        ),
                      if (!widget.readOnly)
                        BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                          buildWhen: (p, c) => p.submitStatus != c.submitStatus,
                          builder: (context, state) => _SubmitBar(
                            label: _isEdit
                                ? l10n.taskEditSave
                                : l10n.meetingAdd,
                            completed: _completed,
                            loading:
                                state.submitStatus ==
                                MeetingCreateSubmitStatus.submitting,
                            onCompletedChanged: (value) =>
                                setState(() => _completed = value),
                            onSubmit: _submit,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNewDesignBody(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      child: Column(
        children: [
          MeetingPreviewHeader(
            title: widget.readOnly
                ? l10n.meetingDetailTitle
                : _isEdit
                ? l10n.meetingEditTitle
                : l10n.meetingAdd,
          ),
          Expanded(
            child: BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
              builder: (context, state) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 720.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MeetingPreviewSelectField(
                          label: l10n.taskCreateFieldProject,
                          value: _project?.title,
                          hint: l10n.taskCreateProjectHint,
                          onTap: widget.readOnly
                              ? () {}
                              : () => _openNewProjectPicker(state),
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewField(
                          label: l10n.taskCreateFieldName,
                          hint: l10n.meetingCreateNameHint,
                          controller: _nameCtrl,
                          readOnly: widget.readOnly,
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: widget.readOnly ? _openLink : null,
                          child: AbsorbPointer(
                            absorbing: widget.readOnly,
                            child: MeetingPreviewField(
                              label: l10n.meetingCreateLink,
                              hint: l10n.meetingCreateLinkHint,
                              controller: _linkCtrl,
                              readOnly: widget.readOnly,
                              keyboardType: TextInputType.url,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewTextArea(
                          label: l10n.taskCreateFieldDescription,
                          hint: l10n.meetingCreateDescriptionHint,
                          controller: _descCtrl,
                          readOnly: widget.readOnly,
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewField(
                          label: l10n.taskCreateFieldPenalty,
                          hint: l10n.meetingCreatePenaltyHint,
                          controller: _penaltyCtrl,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_MaxValueFormatter(100)],
                        ),
                        SizedBox(height: 12.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final date = MeetingPreviewSelectField(
                              label: l10n.meetingCreateStartDate,
                              value: _fmtDate(_date),
                              hint: l10n.taskFilterDateHint,
                              icon: Assets.icons.icCalendar,
                              onTap: widget.readOnly ? () {} : _pickDate,
                            );
                            final time = MeetingPreviewSelectField(
                              label: l10n.taskCreateFieldTime,
                              value: _fmtTime(_time),
                              hint: '00:00',
                              icon: Assets.icons.icTuilconTime,
                              onTap: widget.readOnly ? () {} : _pickTime,
                            );
                            if (constraints.maxWidth < 360.w) {
                              return Column(
                                children: [
                                  date,
                                  SizedBox(height: 12.h),
                                  time,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: date),
                                SizedBox(width: 12.w),
                                Expanded(child: time),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewField(
                          label: l10n.meetingCreateDuration,
                          hint: l10n.meetingCreateDurationHint,
                          controller: _durationCtrl,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _NewApprovalCard(
                          enabled: _requiresApproval,
                          readOnly: widget.readOnly,
                          onChanged: (value) =>
                              setState(() => _requiresApproval = value),
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewParticipantsField(
                          label: widget.readOnly
                              ? l10n.meetingDetailParticipantsLabel
                              : l10n.meetingCreateParticipantsLabel,
                          selected: {
                            for (final member
                                in widget.readOnly
                                    ? (_meeting?.participantsInfo ?? const [])
                                    : _selectedMembers(state.members))
                              member.username,
                          },
                          onTap: widget.readOnly
                              ? () {}
                              : () => _openParticipants(state),
                        ),
                        if (!widget.readOnly) ...[
                          SizedBox(height: 12.h),
                          _NewCompletionCard(
                            completed: _completed,
                            onChanged: (value) =>
                                setState(() => _completed = value),
                          ),
                        ],
                        if (widget.readOnly &&
                            (_meeting?.isCompleted ?? false) &&
                            state.myAttendance != null) ...[
                          SizedBox(height: 16.h),
                          _MyAttendanceSection(
                            attendance: state.myAttendance!,
                            onSendReason: () {
                              final id = _meeting?.id;
                              if (id != null) {
                                context.pushNamed(
                                  Routes.meetingReason.name,
                                  pathParameters: {'id': '$id'},
                                );
                              }
                            },
                          ),
                        ],
                        if (widget.readOnly &&
                            (_meeting?.isCompleted ?? false) &&
                            _meeting?.organizerId == _currentUserId &&
                            state.attendanceRows.any(
                              (row) => !row.isAttended,
                            )) ...[
                          SizedBox(height: 16.h),
                          AppFilterFieldLabel(l10n.meetingExcuseListTitle),
                          SizedBox(height: 8.h),
                          for (final row in state.attendanceRows)
                            if (!row.isAttended)
                              MeetingExcuseRow(
                                row: row,
                                busy: state.excuseBusyId == row.id,
                                rejected: state.rejectedExcuseIds.contains(
                                  row.id,
                                ),
                                onApprove: () =>
                                    context.read<MeetingCreateBloc>().add(
                                      MeetingDetailExcuseDecided(
                                        attendanceId: row.id,
                                        approved: true,
                                      ),
                                    ),
                                onReject: () =>
                                    context.read<MeetingCreateBloc>().add(
                                      MeetingDetailExcuseDecided(
                                        attendanceId: row.id,
                                        approved: false,
                                      ),
                                    ),
                              ),
                        ],
                        SizedBox(height: 20.h),
                        if (widget.readOnly &&
                            _meeting?.id != null &&
                            !(_meeting?.isCompleted ?? true))
                          MeetingPreviewButton(
                            label: l10n.meetingCallJoin,
                            background: colors.accentStrong,
                            foreground: colors.textWhite,
                            icon: Assets.icons.icPersonalInformationIcon,
                            onTap: () => context.pushNamed(
                              Routes.meetingRoom.name,
                              pathParameters: {'id': '${_meeting!.id}'},
                            ),
                          ),
                        if (widget.readOnly && _canClose) ...[
                          if (_meeting?.id != null &&
                              !(_meeting?.isCompleted ?? true))
                            SizedBox(height: 12.h),
                          BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                            buildWhen: (p, c) => p.closeStatus != c.closeStatus,
                            builder: (context, state) => MeetingPreviewButton(
                              label: l10n.meetingCloseAction,
                              background:
                                  state.closeStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? colors.controlBgDisabled
                                  : colors.errorStrong,
                              foreground:
                                  state.closeStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? colors.controlTextDisabled
                                  : colors.textWhite,
                              icon: Assets.icons.icTuilconCheck,
                              onTap:
                                  state.closeStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? () {}
                                  : _openCloseSheet,
                            ),
                          ),
                        ],
                        if (!widget.readOnly)
                          BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                            buildWhen: (p, c) =>
                                p.submitStatus != c.submitStatus,
                            builder: (context, state) => MeetingPreviewButton(
                              label: _isEdit
                                  ? l10n.taskEditSave
                                  : l10n.meetingAdd,
                              background:
                                  state.submitStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? colors.controlBgDisabled
                                  : colors.accentStrong,
                              foreground:
                                  state.submitStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? colors.controlTextDisabled
                                  : colors.textWhite,
                              icon: Assets.icons.icTuilconCheck,
                              onTap:
                                  state.submitStatus ==
                                      MeetingCreateSubmitStatus.submitting
                                  ? () {}
                                  : _submit,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNewProjectPicker(MeetingCreateState state) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<ProjectShort>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).backgroundBase,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 0.8.sh),
          child: state.projects.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    l10n.taskCreateProjectHint,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.of(context).textSub,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20.w),
                  itemCount: state.projects.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(project),
                      borderRadius: BorderRadius.circular(12.r),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.of(context).backgroundElevation1,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Text(
                            project.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.of(context).textStrong,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
    if (selected != null && mounted) _selectProject(selected);
  }

  List<ProjectMember> _selectedMembers(List<ProjectMember> members) => [
    for (final member in members)
      if (_participantIds.contains(member.id)) member,
  ];

  Widget _buildOverlay(BuildContext context) {
    if (_open == _Field.none) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _projectLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 40.w,
            child: BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
              builder: (context, state) => AppFilterDropdownBox(
                emptyText: AppLocalizations.of(context).statEmpty,
                children: [
                  for (final project in state.projects)
                    AppFilterDropdownItem(
                      selected: project == _project,
                      verticalPadding: 6,
                      onTap: () => _selectProject(project),
                      child: _ProjectOption(project: project),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themedPicker(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    final isDark = colors.backgroundBase.computeLuminance() < 0.5;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    );

    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: colors.accentSub,
          onPrimary: colors.textWhite,
          surface: colors.backgroundBase,
          onSurface: colors.textStrong,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: colors.backgroundBase,
          shape: shape,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colors.accentSub),
        ),
      ),
      child: child,
    );
  }
}

class _NewApprovalCard extends StatelessWidget {
  const _NewApprovalCard({
    required this.enabled,
    required this.readOnly,
    required this.onChanged,
  });

  final bool enabled;
  final bool readOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  l10n.meetingPreviewApprovalTitle
                      .s(14.sp)
                      .w(700)
                      .c(colors.textStrong),
                  SizedBox(height: 3.h),
                  l10n.meetingPreviewApprovalDescription
                      .s(11.sp)
                      .w(500)
                      .c(colors.textSub)
                      .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _SmallSwitch(
              value: enabled,
              enabled: !readOnly,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCompletionCard extends StatelessWidget {
  const _NewCompletionCard({required this.completed, required this.onChanged});

  final bool completed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: AppLocalizations.of(
                context,
              ).meetingCreateCompleted.s(14.sp).w(700).c(colors.textStrong),
            ),
            _SmallSwitch(value: completed, enabled: true, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

extension _LabelRow on Widget {
  Widget withLabels(
    BuildContext context, {
    required String left,
    required String right,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: AppFilterFieldLabel(left)),
            SizedBox(width: 16.w),
            Expanded(child: AppFilterFieldLabel(right)),
          ],
        ),
        this,
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(width: 24.w),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .h(28 / 17)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Assets.icons.icClose.svg(
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: colors.textStrong,
      height: 20 / 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: SizedBox(
              height: 44.h,
              child: Center(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: style,
                  cursorColor: colors.accentSub,
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: style.copyWith(color: colors.textSub),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextAreaField extends StatelessWidget {
  const _TextAreaField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: colors.textStrong,
      height: 20 / 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 9.h),
            child: SizedBox(
              height: 60.h,
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: style,
                cursorColor: colors.accentSub,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: style.copyWith(color: colors.textSub),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectOption extends StatelessWidget {
  const _ProjectOption({required this.project});

  final ProjectShort project;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              project.title
                  .s(13.sp)
                  .w(700)
                  .h(20 / 13)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (project.description.isNotEmpty)
                project.description
                    .s(11.sp)
                    .w(500)
                    .h(16 / 11)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (project.deadline != null) ...[
          SizedBox(width: 12.w),
          _fmtDate(
            project.deadline,
          ).s(11.sp).w(500).h(16 / 11).c(colors.iconSub),
        ],
      ],
    );
  }
}

class _ParticipantsField extends StatelessWidget {
  const _ParticipantsField({
    required this.label,
    required this.selected,
    required this.loading,
    required this.onPick,
    required this.onRemove,
    this.readOnly = false,
  });

  final String label;
  final List<ProjectMember> selected;
  final bool loading;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  /// Detail rejimi: bo'sh holatda "qo'shish" tugmasi o'rniga chiziqcha.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    if (readOnly && selected.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFilterFieldLabel(label),
          DecoratedBox(
            decoration: appFilterFieldDecoration(colors),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: '—'.s(13.sp).w(500).h(20 / 13).c(colors.textSub),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: appFilterFieldDecoration(colors),
            child: selected.isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          l10n.meetingCreateParticipantsHelp
                              .s(11.sp)
                              .w(500)
                              .h(16 / 11)
                              .c(colors.textSub)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          SizedBox(height: 8.h),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.backgroundElevation3,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: colors.strokeSub,
                                width: 1.w,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (loading)
                                    SizedBox(
                                      width: 12.w,
                                      height: 12.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5.w,
                                        color: colors.iconStrong,
                                      ),
                                    )
                                  else
                                    Assets.icons.icPlus.svg(
                                      width: 11.w,
                                      height: 16.w,
                                      colorFilter: ColorFilter.mode(
                                        colors.iconStrong,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  SizedBox(width: 2.w),
                                  l10n.meetingCreateParticipantsAdd
                                      .s(11.sp)
                                      .w(500)
                                      .h(16 / 11)
                                      .c(colors.textStrong),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 6.h, 8.w, 6.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          for (final member in selected)
                            _ParticipantChip(
                              member: member,
                              onRemove: readOnly
                                  ? null
                                  : () => onRemove(member.id),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({required this.member, this.onRemove});

  final ProjectMember member;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = member.position.isEmpty
        ? member.username
        : '${member.username} | ${member.position}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.w, right: 4.w, top: 4.h, bottom: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TuiAvatar(
              initial: member.username,
              avatarUrl: member.avatar,
              size: 20,
            ),
            SizedBox(width: 4.w),
            // Wrap chip'ga o'z maxWidth'ini beradi — Flexible matnni avatar/X
            // egallagan joydan qolganiga siqadi (qat'iy maxWidth toshib ketardi).
            Flexible(
              child: label
                  .s(13.sp)
                  .w(500)
                  .h(16 / 13)
                  .c(colors.iconSub)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (onRemove != null) ...[
              SizedBox(width: 4.w),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8.r),
                child: Assets.icons.icClose.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconSub,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.label,
    required this.completed,
    required this.loading,
    required this.onCompletedChanged,
    required this.onSubmit,
  });

  final String label;
  final bool completed;
  final bool loading;
  final ValueChanged<bool> onCompletedChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.backgroundBase),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: l10n.meetingCreateCompleted
                        .s(15.sp)
                        .w(800)
                        .h(24 / 15)
                        .c(colors.textStrong),
                  ),
                  _SmallSwitch(
                    value: completed,
                    enabled: !loading,
                    onChanged: onCompletedChanged,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              InkWell(
                onTap: loading ? null : onSubmit,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentStrong,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Center(
                      child: loading
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: colors.textWhite,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.icTuilconCheck.svg(
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.textWhite,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                label
                                    .s(15.sp)
                                    .w(800)
                                    .h(24 / 15)
                                    .c(colors.textWhite),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail: joriy foydalanuvchining qatnashuv holati — qatnashgan/qatnashmagan,
/// qatnashmagan bo'lsa sabab yuborish tugmasi yoki yuborilgan sabab holati.
class _MyAttendanceSection extends StatelessWidget {
  const _MyAttendanceSection({
    required this.attendance,
    required this.onSendReason,
  });

  final MeetingAttendance attendance;
  final VoidCallback onSendReason;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final hasReason = attendance.absenceReason.trim().isNotEmpty;

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (attendance.isAttended
                      ? l10n.meetingMyAttended
                      : l10n.meetingMyNotAttended)
                  .s(13.sp)
                  .w(700)
                  .h(20 / 13)
                  .c(
                    attendance.isAttended
                        ? colors.successStrong
                        : colors.errorStrong,
                  ),
              if (!attendance.isAttended) ...[
                if (hasReason) ...[
                  SizedBox(height: 4.h),
                  attendance.absenceReason
                      .s(13.sp)
                      .w(500)
                      .h(20 / 13)
                      .c(colors.textSub)
                      .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  (attendance.isExcused
                          ? l10n.meetingExcuseAccepted
                          : l10n.meetingReasonSentLabel)
                      .s(11.sp)
                      .w(700)
                      .c(
                        attendance.isExcused
                            ? colors.successStrong
                            : colors.textSoft,
                      ),
                ] else ...[
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: onSendReason,
                    borderRadius: BorderRadius.circular(12.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accentStrong,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: SizedBox(
                        height: 40.h,
                        width: double.infinity,
                        child: Center(
                          child: l10n.meetingSendReason
                              .s(13.sp)
                              .w(800)
                              .c(colors.textWhite),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail rejimidagi pastki "Yig'ilishni yakunlash" tugmasi.
class _CloseBar extends StatelessWidget {
  const _CloseBar({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.accentStrong,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              height: 52.h,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: colors.textWhite,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.icons.icTuilconCheck.svg(
                            width: 16.w,
                            height: 16.w,
                            colorFilter: ColorFilter.mode(
                              colors.textWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          label.s(15.sp).w(800).h(24 / 15).c(colors.textWhite),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinBar extends StatelessWidget {
  const _JoinBar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.accentStrong,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              height: 52.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.meetingJoin.svg(
                    width: 18.w,
                    height: 18.w,
                    colorFilter: ColorFilter.mode(
                      colors.textWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  label.s(15.sp).w(800).h(24 / 15).c(colors.textWhite),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yakunlash bottom sheet'i: yig'ilish sarlavhasi + qatnashganlarni belgilash.
/// Tasdiqda tanlangan foydalanuvchi id to'plamini `pop` bilan qaytaradi.
class _CloseMeetingSheet extends StatefulWidget {
  const _CloseMeetingSheet({required this.meeting});

  final Meeting meeting;

  @override
  State<_CloseMeetingSheet> createState() => _CloseMeetingSheetState();
}

class _CloseMeetingSheetState extends State<_CloseMeetingSheet> {
  // Web'dagi kabi hammasi belgilangan holda ochiladi.
  late final Set<int> _selected = {
    for (final p in widget.meeting.participantsInfo) p.id,
  };

  void _toggle(int id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final m = widget.meeting;
    final start = m.startDate;
    final when = start == null
        ? ''
        : '${_fmtDate(start)} ${_fmtTime(TimeOfDay.fromDateTime(start))}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            l10n.meetingCloseSheetTitle
                .s(17.sp)
                .w(800)
                .h(28 / 17)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (m.uid.isNotEmpty)
                        m.uid.s(11.sp).w(500).h(16 / 11).c(colors.textSoft),
                      m.title
                          .s(13.sp)
                          .w(700)
                          .h(20 / 13)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ),
                ),
                if (when.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  when.s(11.sp).w(500).h(16 / 11).c(colors.textSub),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            l10n.meetingCloseSheetSubtitle
                .s(13.sp)
                .w(700)
                .h(20 / 13)
                .c(colors.textStrong),
            SizedBox(height: 8.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: m.participantsInfo.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (_, i) {
                  final member = m.participantsInfo[i];
                  return _AttendanceRow(
                    member: member,
                    checked: _selected.contains(member.id),
                    onTap: () => _toggle(member.id),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            InkWell(
              onTap: () => Navigator.of(context).pop(_selected),
              borderRadius: BorderRadius.circular(16.r),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.accentStrong,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: SizedBox(
                  height: 52.h,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.icons.icTuilconCheck.svg(
                        width: 16.w,
                        height: 16.w,
                        colorFilter: ColorFilter.mode(
                          colors.textWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      l10n.meetingCloseConfirm
                          .s(15.sp)
                          .w(800)
                          .h(24 / 15)
                          .c(colors.textWhite),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet'dagi bitta qatnashchi qatori: checkbox + avatar + ism/lavozim.
class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.member,
    required this.checked,
    required this.onTap,
  });

  final ProjectMember member;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: checked
                      ? colors.accentStrong
                      : colors.backgroundElevation3,
                  borderRadius: BorderRadius.circular(6.r),
                  border: checked
                      ? null
                      : Border.all(color: colors.strokeStrong, width: 1.w),
                ),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: checked
                      ? Center(
                          child: Assets.icons.icTuilconCheck.svg(
                            width: 12.w,
                            height: 12.w,
                            colorFilter: ColorFilter.mode(
                              colors.textWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              TuiAvatar(
                initial: member.username,
                avatarUrl: member.avatar,
                size: 24,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    member.username
                        .s(13.sp)
                        .w(700)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (member.position.isNotEmpty)
                      member.position
                          .s(11.sp)
                          .w(500)
                          .c(colors.textSoft)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallSwitch extends StatelessWidget {
  const _SmallSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 40.w,
        height: 21.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value ? colors.accentStrong : colors.backgroundElevation3,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.textWhite,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 17.w, height: 17.w),
          ),
        ),
      ),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  _MaxValueFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null || parsed > max) return oldValue;
    return newValue;
  }
}

/// Keshlangan login javobidagi (`cached_user`) joriy foydalanuvchi id'si.
int? _cachedUserId() {
  final raw = getIt<StorageService>().getString(StorageKeys.cachedUser);
  if (raw == null || raw.isEmpty) return null;
  try {
    final map = jsonDecode(raw);
    if (map is Map) return (map['id'] as num?)?.toInt();
  } on Object {
    // Buzuq kesh — foydalanuvchiga bog'liq bo'limlar ko'rsatilmaydi.
  }
  return null;
}

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

/// Decimal string'ning butun qismi ("20.00" → "20") — prefill uchun.
String _intPart(String s) =>
    s.split('.').first.replaceAll(RegExp('[^0-9]'), '');

String _fmtTime(TimeOfDay? t) {
  if (t == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}
