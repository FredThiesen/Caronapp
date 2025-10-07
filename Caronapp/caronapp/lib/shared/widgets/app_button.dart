import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final isDisabled = onPressed == null;
    final button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? AppColors.orange : AppColors.white,
            foregroundColor: isPrimary ? AppColors.white : AppColors.orange,
            elevation: isPrimary ? 2 : 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: isPrimary
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.orange, width: 1.5),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ).copyWith(
            backgroundColor: isDisabled
                ? MaterialStateProperty.all(
                    (isPrimary ? AppColors.orange : AppColors.white)
                        .withOpacity(0.5),
                  )
                : null,
            foregroundColor: isDisabled
                ? MaterialStateProperty.all(
                    (isPrimary ? AppColors.white : AppColors.orange)
                        .withOpacity(0.5),
                  )
                : null,
          ),
      child: Text(label),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
