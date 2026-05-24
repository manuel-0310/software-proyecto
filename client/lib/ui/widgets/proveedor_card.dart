// Archivo para el widget de proveedor card.



import 'package:flutter/material.dart';
import '../../models/proveedor.dart';

class ProveedorCard extends StatelessWidget {

// Variable para proveedor.
  final Proveedor proveedor;

// Variable para on tap.
  final VoidCallback onTap;

  const ProveedorCard({
    super.key,
    required this.proveedor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);


// Variable para costo.
    final costo = proveedor.calcularCostoFinal();

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
              child: Icon(_iconoPorTipo(proveedor.tipo)),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proveedor.nombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proveedor.tipo.nombre,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proveedor.contacto,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            Text(
              _money(costo),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  static String _money(num value) => '\$${value.toStringAsFixed(0)}';

  static IconData _iconoPorTipo(dynamic tipo) {


// Variable para name.
    final name = tipo.toString().toLowerCase();
    if (name.contains('dj')) return Icons.music_note_rounded;
    if (name.contains('catering')) return Icons.restaurant_rounded;
    if (name.contains('fotografia')) return Icons.photo_camera_rounded;
    return Icons.storefront_rounded;
  }
}
