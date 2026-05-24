// Archivo para el widget de invitado card.



import 'package:flutter/material.dart';
import '../../models/invitado.dart';
import 'estado_badge.dart';

class InvitadoCard extends StatelessWidget {

// Variable para invitado.
  final Invitado invitado;

// Variable para on tap.
  final VoidCallback onTap;

  const InvitadoCard({
    super.key,
    required this.invitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
              ),
              child: const Icon(Icons.person_rounded),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitado.nombreCompleto, 
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invitado.correo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (invitado.mesaAsignada != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Mesa: ${invitado.mesaAsignada}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),
            EstadoBadge(estado: invitado.estado),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
