import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaitoonpro/Features/Other/responsive.dart';
import 'package:zaitoonpro/Features/Other/toast.dart';
import 'package:zaitoonpro/Features/Widgets/outline_button.dart';
import 'package:zaitoonpro/Features/Widgets/textfield_entitled.dart';
import 'package:zaitoonpro/Localizations/l10n/translations/app_localizations.dart';
import 'package:zaitoonpro/Views/Auth/Subscription/bloc/subscription_bloc.dart';
import 'package:zaitoonpro/Views/Auth/Subscription/model/sub_model.dart';
import '../../../../Features/Date/gregorian_date_picker.dart';
import '../../../../Features/Other/z_dialog.dart';
import '../../bloc/auth_bloc.dart';
import 'no_subscription.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoadedState) {
          final subscriptions = state.subs;
          if (subscriptions.isEmpty) return const NoSubscriptionView();
          final currentSub = subscriptions.first;

          return ResponsiveLayout(
            mobile:  _MobileContent(subscription: currentSub),
            tablet:  _TabletContent(subscription: currentSub),
            desktop: _DesktopContent(subscription: currentSub),
          );
        } else if (state is SubscriptionLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is SubscriptionErrorState) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 20),
                  ZOutlineButton(
                    label: const Text('Retry'),
                    onPressed: () {
                      context
                          .read<SubscriptionBloc>()
                          .add(LoadSubscriptionEvent());
                    },
                    icon: Icons.refresh,
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// =============================================================
// Mobile / Tablet / Desktop wrappers
// =============================================================
class _MobileContent extends StatelessWidget {
  final SubscriptionModel subscription;
  const _MobileContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _SubscriptionDetails(subscription: subscription),
      ),
    );
  }
}

class _TabletContent extends StatelessWidget {
  final SubscriptionModel subscription;
  const _TabletContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _SubscriptionDetails(subscription: subscription),
      ),
    );
  }
}

class _DesktopContent extends StatelessWidget {
  final SubscriptionModel subscription;
  const _DesktopContent({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _SubscriptionDetails(subscription: subscription),
      ),
    );
  }
}

// =============================================================
// Subscription Details — main content
// =============================================================
class _SubscriptionDetails extends StatelessWidget {
  final SubscriptionModel subscription;
  const _SubscriptionDetails({required this.subscription});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _getDaysRemaining() {
    if (subscription.subExpireDate == null) return 0;
    return subscription.subExpireDate!.difference(DateTime.now()).inDays;
  }

  bool get _isExpired {
    if (subscription.subExpireDate == null) return false;
    return subscription.subExpireDate!.isBefore(DateTime.now());
  }

  Color _getStatusColor(BuildContext context) {
    if (_isExpired) return Theme.of(context).colorScheme.error;
    final daysRemaining = _getDaysRemaining();
    if (daysRemaining <= 7) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  void _showGenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenerateKeyDialog(),
    );
  }

  Future<void> _copyKey(BuildContext context, String key) async {
    await Clipboard.setData(ClipboardData(text: key));
    if (!context.mounted) return;
    ToastManager.show(
      context: context,
      title: 'Copied',
      message: 'Key copied to clipboard',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpired = _isExpired;
    final daysRemaining = _getDaysRemaining();
    final expireDate = _formatDate(subscription.subExpireDate);
    final entryDate = _formatDate(subscription.subEntryDate);
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthenticatedState) return const SizedBox();

    final login = state.loginData;
    final statusColor = _getStatusColor(context);
    final isSuper = login.usrRole == "Super";
    final hasKey = subscription.subKey != null &&
        subscription.subKey!.isNotEmpty &&
        subscription.subKey != 'Expired';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .subscriptionTitle
                          .toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.manageSubMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // Generate button — SUPER ONLY
              if (isSuper)
                ZOutlineButton(
                  label: const Text('GENERATE NEW KEY'),
                  icon: Icons.vpn_key_rounded,
                  height: 40,
                  onPressed: () => _showGenerateDialog(context),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Status badges ──
          Row(
            children: [
              _statusBadge(statusColor, isExpired),
              const SizedBox(width: 12),
              if (!isExpired) _daysBadge(colorScheme, daysRemaining),
            ],
          ),

          const SizedBox(height: 30),

          // ── Key section ──
          if (isSuper && hasKey)
            _keyCardForAdmin(
              context, theme, colorScheme, subscription.subKey!,
            )
          else if (isSuper)
            _expiredKeyCard(colorScheme)
          else
            _maskedKeyCard(colorScheme),

          const SizedBox(height: 20),

          // ── Date cards ──
          Row(
            children: [
              Expanded(
                child: _buildDateCard(
                  context,
                  icon: Icons.calendar_today,
                  label: "Expiry Date",
                  value: expireDate,
                  isExpired: isExpired,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateCard(
                  context,
                  icon: Icons.date_range,
                  label: "Entry Date",
                  value: entryDate,
                ),
              ),
            ],
          ),

          // ── Warning ──
          if (isExpired || (!isExpired && daysRemaining <= 7))
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _warningBanner(
                colorScheme,
                isExpired,
                daysRemaining,
                isSuper,
              ),
            ),
        ],
      ),
    );
  }

  // ── Status badge ──
  Widget _statusBadge(Color statusColor, bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: statusColor.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.error_outline : Icons.check_circle_outline,
            color: statusColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isExpired ? "Expired" : "Active",
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _daysBadge(ColorScheme colorScheme, int daysRemaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.primary.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: colorScheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            daysRemaining <= 0
                ? "Expires today"
                : "$daysRemaining days remaining",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Key cards ──
  Widget _keyCardForAdmin(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      String key,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Subscription Key",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  key,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copyKey(context, key),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expiredKeyCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No active subscription key. Click "Generate New Key" to create one.',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _maskedKeyCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: colorScheme.outline,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Contact your system administrator to view or change the '
                  'subscription key.',
              style: TextStyle(
                color: colorScheme.outline,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningBanner(
      ColorScheme colorScheme,
      bool isExpired,
      int daysRemaining,
      bool isSuper,
      ) {
    final accent = isExpired ? colorScheme.error : Colors.orange;
    final msg = isExpired
        ? (isSuper
        ? "Your subscription has expired. Click \"Generate New Key\" to renew it."
        : "Your subscription has expired. Please contact your system administrator.")
        : "Your subscription will expire in $daysRemaining days. Consider renewing it soon.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.warning : Icons.info,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: isExpired ? colorScheme.error : Colors.orange.shade800,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        bool isExpired = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isExpired ? colorScheme.error : colorScheme.primary)
                  .withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isExpired ? colorScheme.error : colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpired ? colorScheme.error : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Generate Key Dialog (Super Admin only) — simplified
// =============================================================
class _GenerateKeyDialog extends StatefulWidget {
  const _GenerateKeyDialog();

  @override
  State<_GenerateKeyDialog> createState() => _GenerateKeyDialogState();
}

class _GenerateKeyDialogState extends State<_GenerateKeyDialog> {
  final _expireDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _expireDateController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final initial = _expireDateController.text.isNotEmpty
        ? DateTime.tryParse(_expireDateController.text) ??
        DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 365));

    await showDialog(
      context: context,
      builder: (_) => GregorianDatePicker(
        initialDate: initial,
        onDateSelected: (d) {
          setState(() => _expireDateController.text = _fmt(d));
        },
        minYear: DateTime.now().year,
        maxYear: DateTime.now().year + 10,
        disablePastDates: true,
      ),
    );
  }

  void _generate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<SubscriptionBloc>().add(
      GenerateSubscriptionEvent(_expireDateController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionGeneratedState) {
          // Auto-close + toast — no key display, no copy button
          Navigator.pop(context);
          ToastManager.show(
            context: context,
            title: 'Success',
            message: 'Subscription reactivated successfully.',
            type: ToastType.success,
          );
          context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
        } else if (state is SubscriptionErrorState) {
          ToastManager.show(
            context: context,
            title: 'Error',
            message: state.message,
            type: ToastType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SubscriptionLoadingState;

        return ZFormDialog(
          title: 'Reactivate Subscription',
          onAction: _generate,
          actionLabel: isLoading
              ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              color: scheme.surface,
              strokeWidth: 2,
            ),
          )
              : const Text('Reactivate'),
          padding: const EdgeInsets.all(24),
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select the new expiry date for the subscription.',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.outline,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: isLoading ? null : _pickDate,
                  child: AbsorbPointer(
                    child: ZTextFieldEntitled(
                      title: 'Expiry Date',
                      hint: 'Tap to select date',
                      controller: _expireDateController,
                      icon: Icons.calendar_today,
                      isRequired: true,
                      readOnly: true,
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
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
}