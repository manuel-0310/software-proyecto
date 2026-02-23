// Archivo para la pantalla de invitado form.



import 'package:flutter/material.dart';

import '../../../controllers/invitado_controller.dart';

class InvitadoFormScreen extends StatefulWidget {

// Variable para invitado controlador.
  final InvitadoController invitadoController;

  const InvitadoFormScreen({
    super.key,
    required this.invitadoController,
  });

  @override
  State<InvitadoFormScreen> createState() => _InvitadoFormScreenState();
}

class _InvitadoFormScreenState extends State<InvitadoFormScreen> {


// Variable para form key.
  final _formKey = GlobalKey<FormState>();



// Variable para nombre.
  final _nombre = TextEditingController();


// Variable para apellido.
  final _apellido = TextEditingController();


// Variable para correo.
  final _correo = TextEditingController();


// Variable para telefono.
  final _telefono = TextEditingController();


// Variable para mesa.
  final _mesa = TextEditingController();



// Variable para saving.
  bool _saving = false;

  InvitadoController get controller => widget.invitadoController;

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _telefono.dispose();
    _mesa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo invitado'),
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
                      controller: _apellido,
                      decoration: const InputDecoration(
                        labelText: 'Apellido *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _correo,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {


// Variable para s.
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Obligatorio';
                        if (!s.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _mesa,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mesa asignada (número)',
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

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);



// Variable para id.
    final id = DateTime.now().millisecondsSinceEpoch.toString();



// Variable para mesa parsed.
    final mesaParsed = int.tryParse(_mesa.text.trim());

    controller.agregar(
      id: id,
      nombre: _nombre.text.trim(),
      apellido: _apellido.text.trim(),
      correo: _correo.text.trim(),
      telefono: _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
      mesaAsignada: mesaParsed,
    );

    Navigator.pop(context);
  }
}
