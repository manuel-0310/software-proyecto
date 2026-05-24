// Archivo para el widget de presupuesto resumen.



import 'package:flutter/material.dart';
import '../../models/presupuesto.dart';

class PresupuestoResumen extends StatelessWidget {

// Variable para presupuesto.
  final Presupuesto presupuesto;

  const PresupuestoResumen({
    super.key,
    required this.presupuesto,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);



// Variable para maximo.
    final maximo = presupuesto.presupuestoMaximo;


// Variable para total.
    final total = presupuesto.costoTotal;


// Variable para restante.
    final restante = presupuesto.saldoRestante;

    
    final porcentaje01 =
        maximo > 0 ? (total / maximo).clamp(0.0, 1.0) : 0.0;



// Variable para excedido.
    final excedido = !presupuesto.dentroDelPresupuesto;


// Variable para cerca del limite.
    final cercaDelLimite = !excedido && presupuesto.porcentajeUtilizado >= 85;

    final estadoTexto = excedido
        ? 'Presupuesto excedido'
        : (cercaDelLimite ? 'Cerca del límite' : 'En control');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presupuesto',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: maximo <= 0 ? null : porcentaje01,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MoneyItem(
                    label: 'Total',
                    value: _money(total),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MoneyItem(
                    label: 'Límite',
                    value: maximo <= 0 ? '—' : _money(maximo),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MoneyItem(
                    label: 'Restante',
                    value: maximo <= 0 ? '—' : _money(restante),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusPill(
                    text: estadoTexto,
                    tone: excedido
                        ? _Tone.danger
                        : (cercaDelLimite ? _Tone.warning : _Tone.ok),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              '${presupuesto.porcentajeUtilizado.toStringAsFixed(0)}% utilizado',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _money(num value) {


// Variable para abs.
    final abs = value.abs().toStringAsFixed(0);
    
    return value < 0 ? '-\$$abs' : '\$$abs';
  }
}

class _MoneyItem extends StatelessWidget {

// Variable para label.
  final String label;

// Variable para value.
  final String value;

  const _MoneyItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Tone { ok, warning, danger }

class _StatusPill extends StatelessWidget {

// Variable para text.
  final String text;

// Variable para tone.
  final _Tone tone;

  const _StatusPill({
    required this.text,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);


// Variable para bg.
    Color bg;

// Variable para border.
    Color border;

    switch (tone) {
      case _Tone.ok:
        bg = theme.colorScheme.primaryContainer.withOpacity(0.35);
        border = theme.colorScheme.primary.withOpacity(0.35);
        break;
      case _Tone.warning:
        bg = theme.colorScheme.tertiaryContainer.withOpacity(0.35);
        border = theme.colorScheme.tertiary.withOpacity(0.35);
        break;
      case _Tone.danger:
        bg = theme.colorScheme.errorContainer.withOpacity(0.35);
        border = theme.colorScheme.error.withOpacity(0.35);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
