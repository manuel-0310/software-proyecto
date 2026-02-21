import 'package:flutter/material.dart';

import '../../../controllers/boda_controller.dart';
import '../../../utils/formateador_fecha.dart';
import '../../../models/evento.dart';
import '../../../enums/estado_evento.dart';
import 'evento_form_screen.dart';

class EventosScreen extends StatefulWidget {
  final BodaController bodaController;

  const EventosScreen({
    super.key,
    required this.bodaController,
  });

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  BodaController get controller => widget.bodaController;

  @override
  void initState() {
    super.initState();
    controller.refrescar();
  }

  @override
  Widget build(BuildContext context) {
    final boda = controller.boda;
    final eventos = boda?.eventos ?? const <Evento>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventoFormScreen(bodaController: controller),
            ),
          );
          setState(() => controller.refrescar());
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => controller.refrescar()),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (boda == null)
              _EmptyState(
                text: 'No hay boda cargada todavía.',
                onReintentar: () => setState(() => controller.refrescar()),
              )
            else if (eventos.isEmpty)
              _EmptyState(
                text: 'Aún no has creado eventos.',
                onReintentar: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventoFormScreen(bodaController: controller),
                    ),
                  );
                  setState(() => controller.refrescar());
                },
                buttonText: 'Crear evento',
              )
            else
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    for (int i = 0; i < eventos.length; i++) ...[
                      _EventoTile(
                        evento: eventos[i],
                        onEliminar: () async {
                          final ok = await _confirmarEliminar(context);
                          if (!ok) return;
                          controller.eliminarEvento(eventos[i].id);
                          setState(() {});
                        },
                      ),
                      if (i != eventos.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text('¿Seguro que quieres eliminar este evento?'),
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

class _EventoTile extends StatelessWidget {
  final Evento evento;
  final VoidCallback onEliminar;

  const _EventoTile({
    required this.evento,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
        ),
        child: Icon(_iconForEstado(evento.estado)),
      ),
      title: Text(
        evento.nombre,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${evento.lugar} • ${evento.estado.etiqueta}'),
            const SizedBox(height: 2),
            Text(
              '${FormateadorFecha.fechaYHora(evento.fechaHora)} • ${FormateadorFecha.duracion(evento.duracionMinutos)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      trailing: IconButton(
        tooltip: 'Eliminar',
        onPressed: onEliminar,
        icon: const Icon(Icons.delete_outline_rounded),
      ),
    );
  }

  static IconData _iconForEstado(EstadoEvento e) {
    switch (e) {
      case EstadoEvento.planificado:
        return Icons.event_available_rounded;
      case EstadoEvento.enCurso:
        return Icons.play_circle_outline_rounded;
      case EstadoEvento.finalizado:
        return Icons.check_circle_outline_rounded;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final VoidCallback onReintentar;
  final String buttonText;

  const _EmptyState({
    required this.text,
    required this.onReintentar,
    this.buttonText = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.event_note_outlined, size: 40),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onReintentar,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}