// Archivo para el punto de entrada y configuracion principal de la app.

import 'package:flutter/material.dart';

import 'controllers/boda_controller.dart';
import 'controllers/invitado_controller.dart';
import 'controllers/proveedor_controller.dart';
import 'controllers/presupuesto_controller.dart';

import 'repositories/interfaces/i_invitado_repository.dart';
import 'repositories/interfaces/i_proveedor_repository.dart';
import 'repositories/interfaces/i_evento_repository.dart';
import 'repositories/impl/invitado_repository_impl.dart';
import 'repositories/impl/proveedor_repository_impl.dart';
import 'repositories/impl/evento_repository_impl.dart';

import 'data/local/invitado_datasource.dart';
import 'data/local/proveedor_datasource.dart';
import 'data/local/evento_datasource.dart';

// Datasources remotos — Servicio Consumidor (HTTP → Weddy API)
import 'data/remote/invitado_remote_datasource.dart';
import 'data/remote/presupuesto_remote_datasource.dart';

import 'services/invitado_service.dart';
import 'services/proveedor_service.dart';
import 'services/evento_service.dart';
import 'services/presupuesto_service.dart';
import 'services/notificacion_service.dart';

import 'patterns/observer/notificacion_observer.dart';
import 'patterns/observer/presupuesto_observer.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/boda/boda_screen.dart';
import 'ui/screens/invitados/invitados_screen.dart';
import 'ui/screens/proveedores/proveedores_screen.dart';
import 'ui/screens/presupuesto/presupuesto_screen.dart';
import 'ui/screens/eventos/eventos_screen.dart';

import 'models/presupuesto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

// Datasources locales (caché en memoria, compartida con BodaController).
  late final InvitadoDatasource _invitadoDatasource;
  late final ProveedorDatasource _proveedorDatasource;
  late final EventoDatasource _eventoDatasource;

// Datasources remotos (HTTP → Weddy API).
// TODO(JWT): Tras el login, llama ApiClient.setToken(token) antes de las escrituras.
  late final InvitadoRemoteDatasource _invitadoRemoto;
  late final PresupuestoRemoteDatasource _presupuestoRemoto;

// Repositorios locales.
  late final IInvitadoRepository _invitadoRepo;
  late final IProveedorRepository _proveedorRepo;
  late final IEventoRepository _eventoRepo;

// Servicios.
  late final NotificacionService _notificacionService;
  late final InvitadoService _invitadoService;
  late final ProveedorService _proveedorService;
  late final EventoService _eventoService;
  late final PresupuestoService _presupuestoService;

// Controladores.
  late final BodaController _bodaController;
  late final InvitadoController _invitadoController;
  late final ProveedorController _proveedorController;
  late final PresupuestoController _presupuestoController;

// Variable para presupuesto base.
  late final Presupuesto _presupuestoBase;

  @override
  void initState() {
    super.initState();

    // ── Datasources locales ──────────────────────────────────────────────
    _invitadoDatasource = InvitadoDatasource();
    _proveedorDatasource = ProveedorDatasource();
    _eventoDatasource = EventoDatasource();

    // ── Datasources remotos (Servicio Consumidor) ────────────────────────
    _invitadoRemoto = InvitadoRemoteDatasource();
    _presupuestoRemoto = PresupuestoRemoteDatasource();

    // ── Repositorios locales ─────────────────────────────────────────────
    _invitadoRepo = InvitadoRepositoryImpl(datasource: _invitadoDatasource);
    _proveedorRepo = ProveedorRepositoryImpl(datasource: _proveedorDatasource);
    _eventoRepo = EventoRepositoryImpl(datasource: _eventoDatasource);

    // ── Servicios ────────────────────────────────────────────────────────
    _notificacionService = ConsoleNotificacionService();
    _proveedorService = ProveedorService(repository: _proveedorRepo);
    _eventoService = EventoService(repository: _eventoRepo);
    _presupuestoService = const PresupuestoService(
      presupuestoMaximo: 20000,
      costoPorInvitadoConfirmado: 50,
    );

    _presupuestoBase = Presupuesto(
      presupuestoMaximo: _presupuestoService.presupuestoMaximo,
      costoPorInvitadoConfirmado: _presupuestoService.costoPorInvitadoConfirmado,
      invitados: const [],
      proveedores: const [],
    );

    final notiObserver = NotificacionObserver(_notificacionService);
    final presupuestoObserver = PresupuestoObserver(presupuesto: _presupuestoBase);

    _invitadoService = InvitadoService(
      repository: _invitadoRepo,
      observadoresGlobales: [notiObserver, presupuestoObserver],
    );

    // ── Controladores ────────────────────────────────────────────────────
    _bodaController = BodaController(
      invitadoService: _invitadoService,
      proveedorService: _proveedorService,
      eventoService: _eventoService,
      presupuestoService: _presupuestoService,
    );

    // InvitadoController = Servicio Consumidor: HTTP vía _invitadoRemoto + caché local.
    _invitadoController = InvitadoController(
      service: _invitadoService,
      remote: _invitadoRemoto,
    );

    _proveedorController = ProveedorController(service: _proveedorService);

    // PresupuestoController consulta GET /presupuesto/ al backend.
    _presupuestoController = PresupuestoController(
      presupuestoRemoto: _presupuestoRemoto,
      invitadoService: _invitadoService,
      proveedorService: _proveedorService,
    );

    // ── Inicialización ───────────────────────────────────────────────────
    _bodaController.inicializar(
      id: 'boda_1',
      nombrePareja1: 'Ana',
      nombrePareja2: 'Juan',
      fechaBoda: DateTime.now().add(const Duration(days: 90)),
      lugarCeremonia: 'Iglesia Central',
      lugarRecepcion: 'Salón Los Robles',
    );

    // Carga inicial asíncrona de invitados desde la Weddy API.
    _invitadoController.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEDDY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home: HomeScreen(bodaController: _bodaController),

      routes: {
        '/boda': (_) => BodaScreen(bodaController: _bodaController),
        '/invitados': (_) => InvitadosScreen(invitadoController: _invitadoController),
        '/proveedores': (_) => ProveedoresScreen(proveedorController: _proveedorController),
        '/presupuesto': (_) => PresupuestoScreen(presupuestoController: _presupuestoController),
        '/eventos': (_) => EventosScreen(bodaController: _bodaController),
      },
    );
  }
}
