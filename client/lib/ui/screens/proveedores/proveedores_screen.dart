// Archivo para la pantalla de proveedores.



import 'package:flutter/material.dart';

import '../../../controllers/proveedor_controller.dart';
import '../../../enums/tipo_proveedor.dart';
import '../../../models/proveedor.dart';
import '../../widgets/proveedor_card.dart';
import 'proveedor_detalle_screen.dart';
import 'proveedor_form_screen.dart';

class ProveedoresScreen extends StatefulWidget {

// Variable para proveedor controlador.
  final ProveedorController proveedorController;

  const ProveedoresScreen({
    super.key,
    required this.proveedorController,
  });

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  ProveedorController get controller => widget.proveedorController;


// Variable para filtro tipo.
  TipoProveedor? filtroTipo; 

  @override
  Widget build(BuildContext context) {
    final proveedores = (filtroTipo == null)
        ? controller.proveedores
        : controller.porTipo(filtroTipo!);



// Variable para total.
    final total = controller.costoTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProveedorFormScreen(proveedorController: controller),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Contratar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FiltrosTipo(
            filtroActual: filtroTipo,
            onChanged: (t) => setState(() => filtroTipo = t),
          ),
          const SizedBox(height: 12),

          if (proveedores.isEmpty)
            _EmptyProveedores(
              filtroTipo: filtroTipo,
              onContratar: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProveedorFormScreen(proveedorController: controller),
                  ),
                );
                setState(() {});
              },
            )
          else
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  for (int i = 0; i < proveedores.length; i++) ...[
                    ProveedorCard(
                      proveedor: proveedores[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProveedorDetalleScreen(
                              proveedorController: controller,
                              proveedorId: proveedores[i].id,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    if (i != proveedores.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 12),
          _TotalFooter(total: total),
        ],
      ),
    );
  }
}

class _FiltrosTipo extends StatelessWidget {

// Variable para filtro actual.
  final TipoProveedor? filtroActual;

// Variable para on changed.
  final ValueChanged<TipoProveedor?> onChanged;

  const _FiltrosTipo({
    required this.filtroActual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: filtroActual == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final t in TipoProveedor.values)
          ChoiceChip(
            label: Text(t.nombre),
            selected: filtroActual == t,
            onSelected: (_) => onChanged(t),
          ),
      ],
    );
  }
}

class _TotalFooter extends StatelessWidget {

// Variable para total.
  final double total;

  const _TotalFooter({required this.total});

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              'Costo total',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '\$${total.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProveedores extends StatelessWidget {

// Variable para filtro tipo.
  final TipoProveedor? filtroTipo;

// Variable para on contratar.
  final VoidCallback onContratar;

  const _EmptyProveedores({
    required this.filtroTipo,
    required this.onContratar,
  });

  @override
  Widget build(BuildContext context) {
    final texto = (filtroTipo == null)
        ? 'Aún no has contratado proveedores.'
        : 'No hay proveedores del tipo ${filtroTipo!.nombre}.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.storefront_outlined, size: 40),
            const SizedBox(height: 10),
            Text(
              texto,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onContratar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Contratar proveedor'),
            ),
          ],
        ),
      ),
    );
  }
}
