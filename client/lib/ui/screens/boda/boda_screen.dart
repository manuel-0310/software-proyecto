// Archivo para la pantalla de boda.



import 'package:flutter/material.dart';

import '../../../controllers/boda_controller.dart';
import '../../../utils/formateador_fecha.dart';
import '../../widgets/presupuesto_resumen.dart';

class BodaScreen extends StatefulWidget {

// Variable para boda controlador.
  final BodaController bodaController;

  const BodaScreen({
    super.key,
    required this.bodaController,
  });

  @override
  State<BodaScreen> createState() => _BodaScreenState();
}

class _BodaScreenState extends State<BodaScreen> {
  BodaController get controller => widget.bodaController;

  @override
  void initState() {
    super.initState();
    controller.refrescar();
  }

  @override
  Widget build(BuildContext context) {


// Variable para boda.
    final boda = controller.boda;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boda'),
        centerTitle: true,
      ),
      body: boda == null
          ? _EmptyState(onReintentar: () => setState(() => controller.refrescar()))
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => controller.refrescar());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(
                    titulo: boda.titulo,
                    fecha: FormateadorFecha.largo(boda.fechaBoda),
                    lugarCeremonia: boda.lugarCeremonia,
                    lugarRecepcion: boda.lugarRecepcion,
                  ),
                  const SizedBox(height: 16),

                  
                  
                  PresupuestoResumen(presupuesto: boda.presupuesto),

                  const SizedBox(height: 16),

                  _ResumenRapido(
                    totalInvitados: boda.totalInvitados,
                    confirmados: boda.invitadosConfirmados,
                    proveedores: boda.proveedores.length,
                    eventos: boda.eventos.length,
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {

// Variable para titulo.
  final String titulo;

// Variable para fecha.
  final String fecha;

// Variable para lugar ceremonia.
  final String lugarCeremonia;

// Variable para lugar recepcion.
  final String lugarRecepcion;

  const _InfoCard({
    required this.titulo,
    required this.fecha,
    required this.lugarCeremonia,
    required this.lugarRecepcion,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            _RowInfo(label: 'Fecha', value: fecha),
            const SizedBox(height: 6),
            _RowInfo(label: 'Ceremonia', value: lugarCeremonia),
            const SizedBox(height: 6),
            _RowInfo(label: 'Recepción', value: lugarRecepcion),
          ],
        ),
      ),
    );
  }
}

class _RowInfo extends StatelessWidget {

// Variable para label.
  final String label;

// Variable para value.
  final String value;

  const _RowInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ResumenRapido extends StatelessWidget {

// Variable para total invitados.
  final int totalInvitados;

// Variable para confirmados.
  final int confirmados;

// Variable para proveedores.
  final int proveedores;

// Variable para eventos.
  final int eventos;

  const _ResumenRapido({
    required this.totalInvitados,
    required this.confirmados,
    required this.proveedores,
    required this.eventos,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniStat(label: 'Invitados', value: '$totalInvitados'),
                _MiniStat(label: 'Confirmados', value: '$confirmados'),
                _MiniStat(label: 'Proveedores', value: '$proveedores'),
                _MiniStat(label: 'Eventos', value: '$eventos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {

// Variable para label.
  final String label;

// Variable para value.
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Container(
      width: 150,
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

class _EmptyState extends StatelessWidget {

// Variable para on reintentar.
  final VoidCallback onReintentar;

  const _EmptyState({
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 34),
            const SizedBox(height: 10),
            const Text(
              'No hay boda cargada todavía.',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Inicializa la boda con BodaController.inicializar(...) al arrancar la app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
