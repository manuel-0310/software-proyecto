import 'package:flutter/material.dart';

import '../../../controllers/invitado_controller.dart';
import '../../../enums/estado_invitado.dart';
import '../../widgets/estado_badge.dart';

class InvitadoDetalleScreen extends StatefulWidget {
  final InvitadoController invitadoController;
  final String invitadoId;

  const InvitadoDetalleScreen({
    super.key,
    required this.invitadoController,
    required this.invitadoId,
  });

  @override
  State<InvitadoDetalleScreen> createState() => _InvitadoDetalleScreenState();
}

class _InvitadoDetalleScreenState extends State<InvitadoDetalleScreen> {
  InvitadoController get controller => widget.invitadoController;

  @override
  Widget build(BuildContext context) {
    final invitado = controller.invitados.firstWhere((i) => i.id == widget.invitadoId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: () async {
              final ok = await _confirmarEliminar(context);
              if (!ok) return;

              controller.eliminar(invitado.id);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitado.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      EstadoBadge(estado: invitado.estado),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<EstadoInvitado>(
                          value: invitado.estado,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: EstadoInvitado.values
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(_labelEstado(e)),
                                  ))
                              .toList(),
                          onChanged: (nuevo) {
                            if (nuevo == null) return;
                            controller.cambiarEstado(invitado.id, nuevo);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _RowInfo(label: 'Correo', value: invitado.correo),
                  const SizedBox(height: 8),

                  _RowInfo(label: 'Teléfono', value: invitado.telefono ?? '—'),
                  const SizedBox(height: 8),

                  _RowInfo(
                    label: 'Mesa',
                    value: invitado.mesaAsignada?.toString() ?? '—',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _labelEstado(EstadoInvitado e) {
    switch (e) {
      case EstadoInvitado.pendiente:
        return 'Pendiente';
      case EstadoInvitado.confirmado:
        return 'Confirmado';
      case EstadoInvitado.rechazado:
        return 'Rechazado';
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar invitado'),
        content: const Text('¿Seguro que quieres eliminar este invitado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

class _RowInfo extends StatelessWidget {
  final String label;
  final String value;

  const _RowInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}