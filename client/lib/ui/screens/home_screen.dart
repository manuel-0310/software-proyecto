// Archivo para la pantalla de home.



import 'package:flutter/material.dart';

import '../../controllers/boda_controller.dart';
import '../../utils/formateador_fecha.dart';

class HomeScreen extends StatefulWidget {

// Variable para boda controlador.
  final BodaController bodaController;

  const HomeScreen({
    super.key,
    required this.bodaController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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



// Variable para titulo.
    final titulo = controller.titulo;


// Variable para total invitados.
    final totalInvitados = controller.totalInvitados;


// Variable para confirmados.
    final confirmados = controller.confirmados;

    final cuentaRegresiva = (boda == null)
        ? 'Boda no inicializada'
        : FormateadorFecha.cuentaRegresiva(boda.fechaBoda);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WEDDY'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => controller.refrescar());
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(
              titulo: titulo,
              cuentaRegresiva: cuentaRegresiva,
              totalInvitados: totalInvitados,
              confirmados: confirmados,
              onVerDetalleBoda: () {
                Navigator.pushNamed(context, '/boda');
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Módulos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            _QuickAccessTile(
              icon: Icons.people_alt_rounded,
              titulo: 'Invitados',
              subtitulo: '$confirmados confirmados • $totalInvitados total',
              onTap: () => Navigator.pushNamed(context, '/invitados'),
            ),
            const Divider(height: 1),

            _QuickAccessTile(
              icon: Icons.storefront_rounded,
              titulo: 'Proveedores',
              subtitulo: 'DJ, Catering, Fotografía…',
              onTap: () => Navigator.pushNamed(context, '/proveedores'),
            ),
            const Divider(height: 1),

            _QuickAccessTile(
              icon: Icons.paid_rounded,
              titulo: 'Presupuesto',
              subtitulo: 'Resumen de costos y saldo',
              onTap: () => Navigator.pushNamed(context, '/presupuesto'),
            ),
            const Divider(height: 1),

            _QuickAccessTile(
              icon: Icons.event_available_rounded,
              titulo: 'Eventos',
              subtitulo: 'Ceremonia, recepción, cronograma',
              onTap: () => Navigator.pushNamed(context, '/eventos'),
            ),

            const SizedBox(height: 24),

            if (boda == null)
              _WarningBox(
                texto:
                    'No encuentro una boda inicializada en el controller.\n'
                    'Inicialízala una vez al arrancar la app usando '
                    'BodaController.inicializar(...) y luego vuelve aquí.',
                onReintentar: () => setState(() => controller.refrescar()),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {

// Variable para titulo.
  final String titulo;

// Variable para cuenta regresiva.
  final String cuentaRegresiva;

// Variable para total invitados.
  final int totalInvitados;

// Variable para confirmados.
  final int confirmados;

// Variable para on ver detalle boda.
  final VoidCallback onVerDetalleBoda;

  const _HeaderCard({
    required this.titulo,
    required this.cuentaRegresiva,
    required this.totalInvitados,
    required this.confirmados,
    required this.onVerDetalleBoda,
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
            const SizedBox(height: 6),
            Text(
              cuentaRegresiva,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Invitados',
                    value: '$totalInvitados',
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: 'Confirmados',
                    value: '$confirmados',
                    icon: Icons.verified_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onVerDetalleBoda,
                child: const Text('Ver boda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {

// Variable para label.
  final String label;

// Variable para value.
  final String value;

// Variable para icon.
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
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
          ),
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {

// Variable para icon.
  final IconData icon;

// Variable para titulo.
  final String titulo;

// Variable para subtitulo.
  final String subtitulo;

// Variable para on tap.
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
        ),
        child: Icon(icon),
      ),
      title: Text(
        titulo,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _WarningBox extends StatelessWidget {

// Variable para texto.
  final String texto;

// Variable para on reintentar.
  final VoidCallback onReintentar;

  const _WarningBox({
    required this.texto,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {


// Variable para theme.
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.errorContainer.withOpacity(0.25),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atención',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(texto),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}
