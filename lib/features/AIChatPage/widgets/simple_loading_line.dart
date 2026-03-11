import 'package:flutter/material.dart';

class SimpleLoadingLine extends StatelessWidget {
  const SimpleLoadingLine({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 3, // thin flat line — try 2 if 3 feels visible too much
      child: LinearProgressIndicator(
        minHeight: 3,
        backgroundColor: Colors.transparent, // no track = super clean/modern
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primary.withOpacity(
              0.9), // app's accent color, slight opacity for subtlety
        ),
        borderRadius:
            const BorderRadius.all(Radius.circular(2)), // gentle rounding
      ),
    );
  }
}
