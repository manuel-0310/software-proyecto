// Archivo para la pantalla de proveedor form.



import 'package:flutter/material.dart';

import '../../../controllers/proveedor_controller.dart';
import '../../../enums/tipo_proveedor.dart';

class ProveedorFormScreen extends StatefulWidget {

// Variable para proveedor controlador.
  final ProveedorController proveedorController;

  const ProveedorFormScreen({
    super.key,
    required this.proveedorController,
  });

  @override
  State<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {


// Variable para form key.
  final _formKey = GlobalKey<FormState>();



// Variable para nombre.
  final _nombre = TextEditingController();


// Variable para contacto.
  final _contacto = TextEditingController();


// Variable para costo base.
  final _costoBase = TextEditingController();

  


// Variable para horas dj.
  final _horasDj = TextEditingController(text: '4');



// Variable para platillos.
  final _platillos = TextEditingController(text: '50');


// Variable para costo por platillo.
  final _costoPorPlatillo = TextEditingController(text: '25');



// Variable para horas foto.
  final _horasFoto = TextEditingController(text: '6');


// Variable para incluye video.
  bool _incluyeVideo = false;



// Variable para tipo.
  TipoProveedor _tipo = TipoProveedor.dj;


// Variable para saving.
  bool _saving = false;

  ProveedorController get controller => widget.proveedorController;

  @override
  void dispose() {
    _nombre.dispose();
    _contacto.dispose();
    _costoBase.dispose();
    _horasDj.dispose();
    _platillos.dispose();
    _costoPorPlatillo.dispose();
    _horasFoto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratar proveedor'),
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
                    DropdownButtonFormField<TipoProveedor>(
                      value: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de proveedor',
                        border: OutlineInputBorder(),
                      ),
                      items: TipoProveedor.values
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.nombre),
                              ))
                          .toList(),
                      onChanged: (t) {
                        if (t == null) return;
                        setState(() => _tipo = t);
                      },
                    ),
                    const SizedBox(height: 12),

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
                      controller: _contacto,
                      decoration: const InputDecoration(
                        labelText: 'Contacto *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _costoBase,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Costo base *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {


// Variable para n.
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) return 'Ingresa un número válido';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    _ExtrasPorTipo(tipo: _tipo),

                    const SizedBox(height: 12),
                    _extrasForm(),

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

  Widget _extrasForm() {
    switch (_tipo) {
      case TipoProveedor.dj:
        return TextFormField(
          controller: _horasDj,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Horas de servicio (DJ)',
            border: OutlineInputBorder(),
          ),
          validator: (v) {


// Variable para n.
            final n = int.tryParse((v ?? '').trim());
            if (n == null || n <= 0) return 'Número inválido';
            return null;
          },
        );

      case TipoProveedor.catering:
        return Column(
          children: [
            TextFormField(
              controller: _platillos,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de platillos',
                border: OutlineInputBorder(),
              ),
              validator: (v) {


// Variable para n.
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costoPorPlatillo,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo por platillo',
                border: OutlineInputBorder(),
              ),
              validator: (v) {


// Variable para n.
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Número inválido';
                return null;
              },
            ),
          ],
        );

      case TipoProveedor.fotografia:
        return Column(
          children: [
            TextFormField(
              controller: _horasFoto,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Horas de cobertura',
                border: OutlineInputBorder(),
              ),
              validator: (v) {


// Variable para n.
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _incluyeVideo,
              onChanged: (v) => setState(() => _incluyeVideo = v),
              title: const Text('Incluye video'),
            ),
          ],
        );
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);



// Variable para id.
    final id = DateTime.now().millisecondsSinceEpoch.toString();


// Variable para costo base.
    final costoBase = double.parse(_costoBase.text.trim());



// Variable para extras.
    final extras = <String, dynamic>{};

    switch (_tipo) {
      case TipoProveedor.dj:
        extras['horasDeServicio'] = int.parse(_horasDj.text.trim());
        break;
      case TipoProveedor.catering:
        extras['numeroDePlatillos'] = int.parse(_platillos.text.trim());
        extras['costoPorPlatillo'] = double.parse(_costoPorPlatillo.text.trim());
        break;
      case TipoProveedor.fotografia:
        extras['horasCobertura'] = int.parse(_horasFoto.text.trim());
        extras['incluyeVideo'] = _incluyeVideo;
        break;
    }

    controller.contratar(
      id: id,
      nombre: _nombre.text.trim(),
      contacto: _contacto.text.trim(),
      costoBase: costoBase,
      tipo: _tipo,
      extras: extras,
    );

    Navigator.pop(context);
  }
}

class _ExtrasPorTipo extends StatelessWidget {

// Variable para tipo.
  final TipoProveedor tipo;

  const _ExtrasPorTipo({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final text = switch (tipo) {
      TipoProveedor.dj => 'Campos extra para DJ',
      TipoProveedor.catering => 'Campos extra para Catering',
      TipoProveedor.fotografia => 'Campos extra para Fotografía',
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
