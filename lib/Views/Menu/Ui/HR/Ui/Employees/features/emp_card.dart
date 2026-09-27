import 'package:flutter/material.dart';
import 'package:zaitoonpro/Localizations/l10n/translations/app_localizations.dart';

/// A generic card widget for displaying information with avatar, title, subtitle,
/// status badge, and multiple info rows - with centered content layout.
class ZCard extends StatefulWidget {
  /// The image to display (can be network URL, asset path, or widget)
  final Widget? image;

  /// The main title text
  final String title;

  /// The subtitle text
  final String? subtitle;

  /// List of info items to display (icon + text)
  final List<InfoItem> infoItems;

  /// Status badge configuration
  final InfoStatus? status;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Whether the card is hoverable
  final bool hoverable;

  /// Border radius
  final double borderRadius;

  /// Padding inside the card
  final EdgeInsets padding;

  /// Whether to show divider between header and info items
  final bool showDivider;

  /// Custom builder for the image section
  final Widget Function(BuildContext context)? imageBuilder;

  /// Custom builder for the title section
  final Widget Function(BuildContext context)? titleBuilder;

  /// Custom builder for the info items section
  final Widget Function(BuildContext context)? infoItemsBuilder;

  /// Widget shown when there are no visible info items.
  /// Pinned to the bottom of the card.
  /// Pass [SizedBox.shrink] to hide it entirely.
  final Widget? emptyInfoWidget;

  const ZCard({
    super.key,
    this.image,
    required this.title,
    this.subtitle,
    this.infoItems = const [],
    this.status,
    this.onTap,
    this.hoverable = true,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(12),
    this.showDivider = true,
    this.imageBuilder,
    this.titleBuilder,
    this.infoItemsBuilder,
    this.emptyInfoWidget,
  });

  @override
  State<ZCard> createState() => _ZCardState();
}

/// Represents an info item (icon + text)
class InfoItem {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final TextStyle? textStyle;

  const InfoItem({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textStyle,
  });
}

/// Represents a status badge
class InfoStatus {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final TextStyle? labelStyle;

  const InfoStatus({
    required this.label,
    required this.color,
    this.backgroundColor,
    this.labelStyle,
  });
}

class _ZCardState extends State<ZCard> {
  bool _isHovering = false;

  /// Only keep info items that actually have text.
  /// This prevents an orphan icon (e.g. phone/location) from rendering
  /// when the corresponding value is null or empty.
  List<InfoItem> get _visibleInfoItems =>
      widget.infoItems.where((item) => item.text.trim().isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final visibleInfoItems = _visibleInfoItems;
    final hasInfo = visibleInfoItems.isNotEmpty;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: widget.hoverable
          ? (_) => setState(() => _isHovering = true)
          : null,
      onExit: widget.hoverable
          ? (_) => setState(() => _isHovering = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isHovering && widget.hoverable
                ? color.primary.withValues(alpha: .3)
                : color.outline.withValues(alpha: .25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovering && widget.hoverable
                  ? color.primary.withValues(alpha: .35)
                  : color.outline.withValues(alpha: .15),
              blurRadius: _isHovering ? 4 : 1,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: widget.onTap,
          child: Padding(
            padding: widget.padding,
            child: Column(
              /// Always fill the card height so the footer (info items or
              /// empty state) is pushed to the very bottom via [Spacer].
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Header (Image + Title + Status) - CENTERED
                _buildHeaderSection(context),

                /// Push the footer to the bottom of the card
                const Spacer(),

                /// Divider only shows if there is at least one visible info row
                // if (widget.showDivider && hasInfo)...[
                //   const Divider(height: 1),
                //   SizedBox(height: 5)
                // ],


                /// Footer: info pills or the empty state, always at the bottom
                if (hasInfo)
                  _buildInfoItemsSection(context, visibleInfoItems)
                else
                  _buildEmptyInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    if (widget.imageBuilder != null) {
      return widget.imageBuilder!(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Image at TOP (centered)
        if (widget.image != null) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.image!,
            ),
          ),
          const SizedBox(height: 10),
        ],

        /// Title and Status Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: widget.titleBuilder != null
                  ? widget.titleBuilder!(context)
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (widget.subtitle != null &&
                      widget.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        /// Status Badge below title (centered)
        if (widget.status != null) ...[
          const SizedBox(height: 8),
          Center(
            child: _buildStatusBadge(widget.status!),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItemsSection(
      BuildContext context,
      List<InfoItem> items,
      ) {
    if (widget.infoItemsBuilder != null) {
      return widget.infoItemsBuilder!(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(height: 6),
          _buildInfoPill(items[i], context),
        ],
      ],
    );
  }

  /// A single polished info row: tinted icon badge + text,
  /// wrapped in a subtle rounded container.
  Widget _buildInfoPill(InfoItem item, BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.iconColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: accent.withValues(alpha: .12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Small circular tinted badge behind the icon
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 12,
              color: accent,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              item.text,
              style: item.textStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact styled empty state pinned to the bottom of the card.
  Widget _buildEmptyInfo(BuildContext context) {
    if (widget.emptyInfoWidget != null) {
      return widget.emptyInfoWidget!;
    }

    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final muted = theme.hintColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.outline.withValues(alpha: .15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 13, color: muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.noData,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InfoStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.backgroundColor ?? status.color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: status.labelStyle ??
            TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
      ),
    );
  }
}