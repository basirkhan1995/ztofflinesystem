import 'package:flutter/material.dart';
import 'package:zaitoonpro/Features/Other/responsive.dart';

class SubscriptionRenewalView extends StatelessWidget {
  const SubscriptionRenewalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile:  const _Content(),
      tablet:  const _Content(),
      desktop: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Icon ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    size: 56,
                    color: scheme.error,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                Text(
                  'Subscription Expired',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Message ──
                Text(
                  'Your subscription is not active. Please contact your '
                      'system administrator to reactivate it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Contact card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _row(Icons.business_rounded, 'Zaitoon Technology', scheme),
                      const SizedBox(height: 10),
                      _row(Icons.email_outlined, 'info@zaitoonsoft.com', scheme),
                      const SizedBox(height: 10),
                      _row(Icons.phone_outlined, '+93 792 496 200', scheme),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to Login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text, ColorScheme scheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            text,
            style: const TextStyle(fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}