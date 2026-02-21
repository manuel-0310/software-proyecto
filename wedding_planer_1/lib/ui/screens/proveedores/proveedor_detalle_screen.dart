import 'package:flutter/material.dart';

import '../../../controllers/proveedor_controller.dart';

class ProveedorDetalleScreen extends StatefulWidget {
  final ProveedorController proveedorController;
  final String proveedorId;

  const ProveedorDetalleScreen({
    super.key,
    required this.proveedorController,
    required this.proveedorId,
  });

  @override
  State<ProveedorDetalleScreen> createState() => _ProveedorDetalleScreenState();
}

class _ProveedorDetalleScreenState extends State<ProveedorDetalleScreen> {
  ProveedorController get controller => widget.proveedorController;

  @override
  Widget build(BuildContext context) {
    final proveedor =
        controller.proveedores.firstWhere((p) => p.id == widget.proveedorId);

    final costoFinal = proveedor.calcularCostoFinal();
    final descripcion = proveedor.descripcionServicio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cancelar contrato',
            onPressed: () async {
              final ok = await _confirmarCancelar(context);
              if (!ok) return;

              controller.cancelar(proveedor.id);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel_outlined),
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
                    proveedor.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    proveedor.tipo.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  _Row(label: 'Contacto', value: proveedor.contacto),
                  const SizedBox(height: 8),
                  _Row(label: 'Costo base', value: '\$${proveedor.costoBase.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _Row(label: 'Costo final', value: '\$${costoFinal.toStringAsFixed(0)}'),

                  const SizedBox(height: 14),
                  const Text(
                    'Servicio',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(descripcion),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarCancelar(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar contrato'),
        content: const Text('¿Seguro que quieres cancelar este proveedor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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