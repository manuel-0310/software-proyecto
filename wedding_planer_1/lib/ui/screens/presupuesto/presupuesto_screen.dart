import 'package:flutter/material.dart';

import '../../../controllers/presupuesto_controller.dart';
import '../../../models/presupuesto.dart';
import '../../widgets/presupuesto_resumen.dart';

class PresupuestoScreen extends StatefulWidget {
  final PresupuestoController presupuestoController;

  const PresupuestoScreen({
    super.key,
    required this.presupuestoController,
  });

  @override
  State<PresupuestoScreen> createState() => _PresupuestoScreenState();
}

class _PresupuestoScreenState extends State<PresupuestoScreen> {
  PresupuestoController get controller => widget.presupuestoController;

  @override
  void initState() {
    super.initState();
    controller.recalcular();
  }

  @override
  Widget build(BuildContext context) {
    final Presupuesto? p = controller.presupuesto;

    final total = controller.costoTotal;
    final restante = controller.saldoRestante;
    final porcentaje = controller.porcentajeUtilizado; // 0–100+
    final excedido = controller.estaExcedido;
    final cerca = controller.cercaDelLimite;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => controller.recalcular()),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (p == null) ...[
              _EmptyBudget(
                onReintentar: () => setState(() => controller.recalcular()),
              ),
            ] else ...[
              // ✅ Widget reutilizable
              PresupuestoResumen(presupuesto: p),
              const SizedBox(height: 14),

              // ✅ Alertas cerca/excedido
              if (excedido || cerca)
                _AlertCard(
                  type: excedido ? _AlertType.danger : _AlertType.warning,
                  title: excedido ? 'Presupuesto excedido' : 'Cerca del límite',
                  message: controller.resumenTexto,
                ),

              const SizedBox(height: 14),

              // ✅ Desglose invitados vs proveedores (sale del modelo Presupuesto)
              _BreakdownCard(
                costoInvitados: p.costoInvitados,
                costoProveedores: p.costoProveedores,
                total: total,
              ),

              const SizedBox(height: 14),

              // ✅ KPIs adicionales (saldo y %)
              _KpiRow(
                saldoRestante: restante,
                porcentajeUtilizado: porcentaje,
              ),

              const SizedBox(height: 14),

              // ✅ Texto resumen del service (lo que pide tu tabla)
              _ResumenTexto(texto: controller.resumenTexto),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyBudget extends StatelessWidget {
  final VoidCallback onReintentar;

  const _EmptyBudget({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.paid_outlined, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Sin datos de presupuesto.',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Agrega invitados confirmados o contrata proveedores para ver el cálculo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onReintentar,
              child: const Text('Recalcular'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AlertType { warning, danger }

class _AlertCard extends StatelessWidget {
  final _AlertType type;
  final String title;
  final String message;

  const _AlertCard({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = type == _AlertType.danger
        ? theme.colorScheme.errorContainer.withOpacity(0.25)
        : theme.colorScheme.tertiaryContainer.withOpacity(0.25);

    final border = type == _AlertType.danger
        ? theme.colorScheme.error.withOpacity(0.35)
        : theme.colorScheme.tertiary.withOpacity(0.35);

    final icon = type == _AlertType.danger
        ? Icons.warning_amber_rounded
        : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double costoInvitados;
  final double costoProveedores;
  final double total;

  const _BreakdownCard({
    required this.costoInvitados,
    required this.costoProveedores,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final invPct = total <= 0 ? 0.0 : (costoInvitados / total).clamp(0.0, 1.0);
    final provPct = total <= 0 ? 0.0 : (costoProveedores / total).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desglose',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            _LineItem(
              label: 'Invitados',
              value: _money(costoInvitados),
              percent: invPct,
            ),
            const SizedBox(height: 10),
            _LineItem(
              label: 'Proveedores',
              value: _money(costoProveedores),
              percent: provPct,
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  _money(total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _money(num value) => '\$${value.toStringAsFixed(0)}';
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  final double percent;

  const _LineItem({
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          minHeight: 8,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  final double saldoRestante;
  final double porcentajeUtilizado; // 0–100+

  const _KpiRow({
    required this.saldoRestante,
    required this.porcentajeUtilizado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Saldo restante',
            value: _money(saldoRestante),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            title: '% utilizado',
            value: '${porcentajeUtilizado.toStringAsFixed(0)}%',
            icon: Icons.percent_rounded,
          ),
        ),
      ],
    );
  }

  static String _money(num value) {
    final abs = value.abs().toStringAsFixed(0);
    return value < 0 ? '-\$$abs' : '\$$abs';
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenTexto extends StatelessWidget {
  final String texto;

  const _ResumenTexto({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          texto,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}