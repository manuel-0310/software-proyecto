import 'package:flutter/material.dart';

import '../../../controllers/boda_controller.dart';
import '../../../utils/formateador_fecha.dart';

class EventoFormScreen extends StatefulWidget {
  final BodaController bodaController;

  const EventoFormScreen({
    super.key,
    required this.bodaController,
  });

  @override
  State<EventoFormScreen> createState() => _EventoFormScreenState();
}

class _EventoFormScreenState extends State<EventoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _lugar = TextEditingController();
  final _duracion = TextEditingController(text: '60');
  final _descripcion = TextEditingController();

  DateTime _fechaHora = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  BodaController get controller => widget.bodaController;

  @override
  void dispose() {
    _nombre.dispose();
    _lugar.dispose();
    _duracion.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = FormateadorFecha.fechaYHora(_fechaHora);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo evento'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _lugar,
                      decoration: const InputDecoration(
                        labelText: 'Lugar *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _pickFechaHora,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha y hora',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(fechaTexto)),
                            const Icon(Icons.calendar_month_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _duracion,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duración (minutos) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) return 'Número inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descripcion,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _guardar,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFechaHora() async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 10),
      initialDate: _fechaHora,
    );
    if (fecha == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (hora == null) return;

    setState(() {
      _fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dur = int.parse(_duracion.text.trim());

    controller.crearEvento(
      id: id,
      nombre: _nombre.text.trim(),
      lugar: _lugar.text.trim(),
      fechaHora: _fechaHora,
      duracionMinutos: dur,
      descripcion: _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
    );

    Navigator.pop(context);
  }
}