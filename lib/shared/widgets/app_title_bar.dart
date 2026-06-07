import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppTitleBar extends StatelessWidget {
  const AppTitleBar({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {
        windowManager.startDragging();
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.only(left: 24, right: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F7FB),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            const Text(
              'Mobi Helper',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202124),
              ),
            ),
            const Spacer(),
            _TitleBarButton(
              icon: Icons.remove_rounded,
              tooltip: '최소화',
              onTap: () {
                windowManager.minimize();
              },
            ),
            const SizedBox(width: 4),
            _TitleBarButton(
              icon: Icons.close_rounded,
              tooltip: '닫기',
              isCloseButton: true,
              onTap: () {
                windowManager.close();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isCloseButton = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isCloseButton;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final iconColor = _getIconColor();

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: Container(
            width: 36,
            height: 32,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!_isHovered) {
      return Colors.transparent;
    }

    if (widget.isCloseButton) {
      return const Color(0xFFFFE4E6);
    }

    return const Color(0xFFE5E7EB);
  }

  Color _getIconColor() {
    if (!_isHovered) {
      return const Color(0xFF6B7280);
    }

    if (widget.isCloseButton) {
      return const Color(0xFFE11D48);
    }

    return const Color(0xFF374151);
  }
}
