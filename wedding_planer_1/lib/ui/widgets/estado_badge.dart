import 'package:flutter/material.dart';
import '../../enums/estado_invitado.dart';

class EstadoBadge extends StatelessWidget {
  final EstadoInvitado estado;

  const EstadoBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg;
    Color border;
    String text;
    IconData icon;

    switch (estado) {
      case EstadoInvitado.confirmado:
        bg = theme.colorScheme.primaryContainer.withOpacity(0.45);
        border = theme.colorScheme.primary.withOpacity(0.45);
        text = 'Confirmado';
        icon = Icons.verified_rounded;
        break;
      case EstadoInvitado.pendiente:
        bg = theme.colorScheme.tertiaryContainer.withOpacity(0.45);
        border = theme.colorScheme.tertiary.withOpacity(0.45);
        text = 'Pendiente';
        icon = Icons.hourglass_bottom_rounded;
        break;
      case EstadoInvitado.rechazado:
        bg = theme.colorScheme.errorContainer.withOpacity(0.45);
        border = theme.colorScheme.error.withOpacity(0.45);
        text = 'Rechazado';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}