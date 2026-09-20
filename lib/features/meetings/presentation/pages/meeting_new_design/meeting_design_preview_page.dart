import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/entity/routes.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';
import '../../../../../core/widgets/app_date_picker.dart';
import '../../../../../core/widgets/app_filter_components.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../injection_container.dart';
import '../../bloc/meeting_new_design/meeting_design_preview_bloc.dart';
import '../../bloc/meeting_new_design/meeting_design_preview_event.dart';
import '../../bloc/meeting_new_design/meeting_design_preview_state.dart';
import 'widgets/form/meeting_preview_actions.dart';
import 'widgets/form/meeting_preview_field.dart';
import 'widgets/form/meeting_preview_header.dart';
import 'widgets/form/meeting_preview_participants_field.dart';
import 'widgets/form/meeting_preview_select_field.dart';
import 'widgets/form/meeting_preview_text_area.dart';

enum MeetingPreviewMode { create, details }

/// Figma UI preview. Network/BLoC intentionally absent until backend contract
/// is finalized; local interactions keep both empty and filled states usable.
class MeetingDesignPreviewPage extends StatelessWidget {
  const MeetingDesignPreviewPage({super.key, required this.mode});

  final MeetingPreviewMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final details = mode == MeetingPreviewMode.details;
        return getIt.isRegistered<MeetingDesignPreviewBloc>()
            ? getIt<MeetingDesignPreviewBloc>()
            : MeetingDesignPreviewBloc(requiresApproval: details);
      },
      child: _MeetingDesignPreviewView(mode: mode),
    );
  }
}

class _MeetingDesignPreviewView extends StatefulWidget {
  const _MeetingDesignPreviewView({required this.mode});

  final MeetingPreviewMode mode;

  @override
  State<_MeetingDesignPreviewView> createState() =>
      _MeetingDesignPreviewViewState();
}

class _MeetingDesignPreviewViewState extends State<_MeetingDesignPreviewView> {
  late final MeetingDesignPreviewBloc _bloc;
  late final TextEditingController _nameController;
  late final TextEditingController _penaltyController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;

  DateTime _date = DateTime(2026, 1, 1);
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 0);
  bool _initialized = false;

  bool get _isDetails => widget.mode == MeetingPreviewMode.details;
  MeetingDesignPreviewState get _previewState => _bloc.state;
  String? get _project => _previewState.project;
  bool get _requiresApproval => _previewState.requiresApproval;
  Set<String> get _participants => _previewState.participants;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<MeetingDesignPreviewBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final l10n = AppLocalizations.of(context);
    _nameController = TextEditingController(
      text: _isDetails ? l10n.meetingPreviewName : '',
    );
    _penaltyController = TextEditingController(
      text: _isDetails ? l10n.meetingPreviewPenalty : '',
    );
    _descriptionController = TextEditingController(
      text: _isDetails ? l10n.meetingPreviewDescription : '',
    );
    _durationController = TextEditingController();
    _time = _isDetails
        ? const TimeOfDay(hour: 21, minute: 0)
        : const TimeOfDay(hour: 0, minute: 0);
    if (_isDetails) {
      _bloc.add(const MeetingDesignApprovalChanged(true));
      _bloc.add(MeetingDesignProjectSelected(l10n.meetingPreviewProject));
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _penaltyController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingDesignPreviewBloc, MeetingDesignPreviewState>(
      builder: (context, state) {
        final colors = AppColors.of(context);
        final l10n = AppLocalizations.of(context);
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isDetails) ...[
              const _PreviewStatusPill(),
              SizedBox(height: 12.h),
            ],
            MeetingPreviewSelectField(
              label: l10n.taskCreateFieldProject,
              value: _project,
              hint: l10n.taskCreateProjectHint,
              onTap: _selectProject,
            ),
            SizedBox(height: 12.h),
            MeetingPreviewField(
              label: l10n.taskCreateFieldName,
              hint: l10n.meetingCreateNameHint,
              controller: _nameController,
              readOnly: _isDetails,
            ),
            SizedBox(height: 12.h),
            MeetingPreviewField(
              label: l10n.taskCreateFieldPenalty,
              hint: l10n.meetingCreatePenaltyHint,
              controller: _penaltyController,
              readOnly: _isDetails,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 12.h),
            _PreviewApprovalCard(
              enabled: _requiresApproval,
              onChanged: _isDetails
                  ? null
                  : (value) => _bloc.add(MeetingDesignApprovalChanged(value)),
            ),
            SizedBox(height: 12.h),
            MeetingPreviewTextArea(
              label: l10n.taskCreateFieldDescription,
              hint: l10n.meetingCreateDescriptionHint,
              controller: _descriptionController,
              readOnly: _isDetails,
            ),
            SizedBox(height: 12.h),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 360.w
                  ? Column(
                      children: [
                        MeetingPreviewSelectField(
                          label: l10n.meetingCreateStartDate,
                          value: _formatDate(_date),
                          icon: Assets.icons.icCalendar,
                          onTap: _pickDate,
                        ),
                        SizedBox(height: 12.h),
                        MeetingPreviewSelectField(
                          label: l10n.taskCreateFieldTime,
                          value: _formatTime(_time),
                          icon: Assets.icons.icTuilconTime,
                          onTap: _pickTime,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: MeetingPreviewSelectField(
                            label: l10n.meetingCreateStartDate,
                            value: _formatDate(_date),
                            icon: Assets.icons.icCalendar,
                            onTap: _pickDate,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: MeetingPreviewSelectField(
                            label: l10n.taskCreateFieldTime,
                            value: _formatTime(_time),
                            icon: Assets.icons.icTuilconTime,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 12.h),
            if (_isDetails)
              AppFilterFieldLabel(l10n.meetingCreateDuration)
            else ...[
              MeetingPreviewField(
                label: l10n.meetingCreateDuration,
                hint: l10n.meetingCreateDurationHint,
                readOnly: false,
                controller: _durationController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              MeetingPreviewParticipantsField(
                label: l10n.meetingCreateParticipantsLabel,
                selected: _participants,
                onTap: _selectParticipants,
              ),
            ],
            SizedBox(height: 12.h),
            if (_isDetails)
              MeetingPreviewActions(
                primaryLabel: l10n.meetingPreviewJoin,
                secondaryLabel: l10n.meetingPreviewSave,
                onPrimary: () =>
                    context.pushNamed(Routes.meetingCallPreview.name),
                onSecondary: () {},
              )
            else
              _PreviewPrimaryButton(
                label: l10n.meetingAdd,
                icon: Assets.icons.icTuilconCheck,
                onTap: () => context.pushNamed(
                  Routes.meetingUiPreview.name,
                  queryParameters: const {'mode': 'details'},
                ),
              ),
          ],
        );

        return Scaffold(
          backgroundColor: colors.backgroundBase,
          body: SafeArea(
            child: Column(
              children: [
                MeetingPreviewHeader(
                  title: _isDetails
                      ? l10n.meetingPreviewDetailsTitle
                      : l10n.meetingAdd,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth > 720.w
                                ? 680.w
                                : double.infinity,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectProject() async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.of(context).backgroundBase,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            12.h + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              l10n.taskCreateFieldProject
                  .s(17.sp)
                  .w(800)
                  .c(AppColors.of(context).textStrong),
              SizedBox(height: 12.h),
              for (final project in [
                l10n.meetingPreviewProject,
                l10n.meetingPreviewProjectSecond,
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: project
                      .s(13.sp)
                      .w(600)
                      .c(AppColors.of(context).textStrong)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: project == _project
                      ? Assets.icons.icTuilconCheck.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.of(context).accentSub,
                            BlendMode.srcIn,
                          ),
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(project),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      _bloc.add(MeetingDesignProjectSelected(selected));
    }
  }

  Future<void> _selectParticipants() async {
    final l10n = AppLocalizations.of(context);
    final selected = {..._participants};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.of(context).backgroundBase,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              12.h + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                l10n.meetingCreateParticipantsTitle
                    .s(17.sp)
                    .w(800)
                    .c(AppColors.of(context).textStrong),
                SizedBox(height: 8.h),
                for (final person in [
                  l10n.meetingPreviewParticipantOne,
                  l10n.meetingPreviewParticipantTwo,
                ])
                  CheckboxListTile(
                    value: selected.contains(person),
                    contentPadding: EdgeInsets.zero,
                    title: person
                        .s(13.sp)
                        .w(600)
                        .c(AppColors.of(context).textStrong)
                        .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                    activeColor: AppColors.of(context).accentStrong,
                    onChanged: (value) => setSheetState(
                      () => value == true
                          ? selected.add(person)
                          : selected.remove(person),
                    ),
                  ),
                SizedBox(height: 8.h),
                _PreviewPrimaryButton(
                  label: l10n.profileSave,
                  onTap: () {
                    _bloc.add(MeetingDesignParticipantsChanged(selected));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }
}

class _PreviewStatusPill extends StatelessWidget {
  const _PreviewStatusPill();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2Alt,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 5.h, 12.w, 5.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.successPrimary,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 8.w, height: 8.w),
            ),
            SizedBox(width: 6.w),
            AppLocalizations.of(
              context,
            ).meetingPreviewActive.s(13.sp).w(800).c(colors.textStrong),
          ],
        ),
      ),
    );
  }
}

class _PreviewApprovalCard extends StatelessWidget {
  const _PreviewApprovalCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  l10n.meetingPreviewApprovalTitle
                      .s(13.sp)
                      .w(800)
                      .h(20 / 13)
                      .c(colors.textStrong),
                  SizedBox(height: 2.h),
                  l10n.meetingPreviewApprovalDescription
                      .s(11.sp)
                      .w(500)
                      .h(16 / 11)
                      .c(colors.textSub)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            _PreviewSwitch(value: enabled, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _PreviewSwitch extends StatelessWidget {
  const _PreviewSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(999.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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

class _PreviewPrimaryButton extends StatelessWidget {
  const _PreviewPrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final SvgGenImage? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accentStrong,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              label.s(15.sp).w(800).h(24 / 15).c(colors.textWhite),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}

String _formatTime(TimeOfDay time) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}';
}
