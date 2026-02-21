import 'package:flutter/material.dart';

import '../../../controllers/invitado_controller.dart';
import '../../../enums/estado_invitado.dart';
import '../../../models/invitado.dart';
import '../../widgets/invitado_card.dart';
import 'invitado_detalle_screen.dart';
import 'invitado_form_screen.dart';

enum _FiltroInvitados { todos, confirmados, pendientes, rechazados }

class InvitadosScreen extends StatefulWidget {
  final InvitadoController invitadoController;

  const InvitadosScreen({
    super.key,
    required this.invitadoController,
  });

  @override
  State<InvitadosScreen> createState() => _InvitadosScreenState();
}

class _InvitadosScreenState extends State<InvitadosScreen> {
  InvitadoController get controller => widget.invitadoController;
  _FiltroInvitados filtro = _FiltroInvitados.todos;

  @override
  Widget build(BuildContext context) {
    final resumen = controller.resumenPorEstado;
    final total = controller.total;

    final invitados = _filtrar(controller.invitados, filtro);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitados'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvitadoFormScreen(invitadoController: controller),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Filtros(
            total: total,
            confirmados: resumen[EstadoInvitado.confirmado] ?? 0,
            pendientes: resumen[EstadoInvitado.pendiente] ?? 0,
            rechazados: resumen[EstadoInvitado.rechazado] ?? 0,
            filtro: filtro,
            onChanged: (f) => setState(() => filtro = f),
          ),
          const SizedBox(height: 12),

          if (invitados.isEmpty)
            _EmptyList(
              filtro: filtro,
              onAgregar: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvitadoFormScreen(invitadoController: controller),
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
                  for (int i = 0; i < invitados.length; i++) ...[
                    InvitadoCard(
                      invitado: invitados[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvitadoDetalleScreen(
                              invitadoController: controller,
                              invitadoId: invitados[i].id,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    if (i != invitados.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Invitado> _filtrar(List<Invitado> list, _FiltroInvitados f) {
    switch (f) {
      case _FiltroInvitados.todos:
        return list;
      case _FiltroInvitados.confirmados:
        return list.where((i) => i.estado == EstadoInvitado.confirmado).toList();
      case _FiltroInvitados.pendientes:
        return list.where((i) => i.estado == EstadoInvitado.pendiente).toList();
      case _FiltroInvitados.rechazados:
        return list.where((i) => i.estado == EstadoInvitado.rechazado).toList();
    }
  }
}

class _Filtros extends StatelessWidget {
  final int total;
  final int confirmados;
  final int pendientes;
  final int rechazados;

  final _FiltroInvitados filtro;
  final ValueChanged<_FiltroInvitados> onChanged;

  const _Filtros({
    required this.total,
    required this.confirmados,
    required this.pendientes,
    required this.rechazados,
    required this.filtro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Chip(
          text: 'Todos ($total)',
          selected: filtro == _FiltroInvitados.todos,
          onTap: () => onChanged(_FiltroInvitados.todos),
        ),
        _Chip(
          text: 'Confirmados ($confirmados)',
          selected: filtro == _FiltroInvitados.confirmados,
          onTap: () => onChanged(_FiltroInvitados.confirmados),
        ),
        _Chip(
          text: 'Pendientes ($pendientes)',
          selected: filtro == _FiltroInvitados.pendientes,
          onTap: () => onChanged(_FiltroInvitados.pendientes),
        ),
        _Chip(
          text: 'Rechazados ($rechazados)',
          selected: filtro == _FiltroInvitados.rechazados,
          onTap: () => onChanged(_FiltroInvitados.rechazados),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final _FiltroInvitados filtro;
  final VoidCallback onAgregar;

  const _EmptyList({
    required this.filtro,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final text = switch (filtro) {
      _FiltroInvitados.todos => 'Aún no tienes invitados.',
      _FiltroInvitados.confirmados => 'No hay invitados confirmados.',
      _FiltroInvitados.pendientes => 'No hay invitados pendientes.',
      _FiltroInvitados.rechazados => 'No hay invitados rechazados.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.people_outline_rounded, size: 40),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar invitado'),
            ),
          ],
        ),
      ),
    );
  }
}