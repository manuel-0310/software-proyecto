import 'package:flutter/material.dart';

// Controllers
import 'controllers/boda_controller.dart';
import 'controllers/invitado_controller.dart';
import 'controllers/proveedor_controller.dart';
import 'controllers/presupuesto_controller.dart';

// Repos + impl
import 'repositories/interfaces/i_invitado_repository.dart';
import 'repositories/interfaces/i_proveedor_repository.dart';
import 'repositories/interfaces/i_evento_repository.dart';
import 'repositories/impl/invitado_repository_impl.dart';
import 'repositories/impl/proveedor_repository_impl.dart';
import 'repositories/impl/evento_repository_impl.dart';

// Datasources
import 'data/local/invitado_datasource.dart';
import 'data/local/proveedor_datasource.dart';
import 'data/local/evento_datasource.dart';

// Services
import 'services/invitado_service.dart';
import 'services/proveedor_service.dart';
import 'services/evento_service.dart';
import 'services/presupuesto_service.dart';
import 'services/notificacion_service.dart';

// Observers
import 'patterns/observer/notificacion_observer.dart';
import 'patterns/observer/presupuesto_observer.dart';

// UI screens
import 'ui/screens/home_screen.dart';
import 'ui/screens/boda/boda_screen.dart';
import 'ui/screens/invitados/invitados_screen.dart';
import 'ui/screens/proveedores/proveedores_screen.dart';
import 'ui/screens/presupuesto/presupuesto_screen.dart';
import 'ui/screens/eventos/eventos_screen.dart';

// Models (para el PresupuestoObserver)
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
  // ── Datasources
  late final InvitadoDatasource _invitadoDatasource;
  late final ProveedorDatasource _proveedorDatasource;
  late final EventoDatasource _eventoDatasource;

  // ── Repositories
  late final IInvitadoRepository _invitadoRepo;
  late final IProveedorRepository _proveedorRepo;
  late final IEventoRepository _eventoRepo;

  // ── Services
  late final NotificacionService _notificacionService;
  late final InvitadoService _invitadoService;
  late final ProveedorService _proveedorService;
  late final EventoService _eventoService;
  late final PresupuestoService _presupuestoService;

  // ── Controllers
  late final BodaController _bodaController;
  late final InvitadoController _invitadoController;
  late final ProveedorController _proveedorController;
  late final PresupuestoController _presupuestoController;

  // ── Presupuesto base (para Observer global)
  late final Presupuesto _presupuestoBase;

  @override
  void initState() {
    super.initState();

    // 1) Datasources
    _invitadoDatasource = InvitadoDatasource();
    _proveedorDatasource = ProveedorDatasource();
    _eventoDatasource = EventoDatasource();

    // 2) Repositories
    _invitadoRepo = InvitadoRepositoryImpl(datasource: _invitadoDatasource);
    _proveedorRepo = ProveedorRepositoryImpl(datasource: _proveedorDatasource);
    _eventoRepo = EventoRepositoryImpl(datasource: _eventoDatasource);

    // 3) Services base
    _notificacionService = ConsoleNotificacionService();

    _proveedorService = ProveedorService(repository: _proveedorRepo);
    _eventoService = EventoService(repository: _eventoRepo);

    // PresupuestoService requiere config
    _presupuestoService = const PresupuestoService(
      presupuestoMaximo: 20000, // ajusta a lo que quieras
      costoPorInvitadoConfirmado: 50, // ajusta a lo que quieras
    );

    // 4) Presupuesto base para Observer (se recalcula via getters)
    _presupuestoBase = Presupuesto(
      presupuestoMaximo: _presupuestoService.presupuestoMaximo,
      costoPorInvitadoConfirmado: _presupuestoService.costoPorInvitadoConfirmado,
      invitados: const [],
      proveedores: const [],
    );

    // 5) Observers globales de invitados
    final notiObserver = NotificacionObserver(_notificacionService);
    final presupuestoObserver = PresupuestoObserver(presupuesto: _presupuestoBase);

    // 6) InvitadoService (usa observadoresGlobales)
    _invitadoService = InvitadoService(
      repository: _invitadoRepo,
      observadoresGlobales: [
        notiObserver,
        presupuestoObserver,
      ],
    );

    // 7) Controllers
    _bodaController = BodaController(
      invitadoService: _invitadoService,
      proveedorService: _proveedorService,
      eventoService: _eventoService,
      presupuestoService: _presupuestoService,
    );

    _invitadoController = InvitadoController(service: _invitadoService);
    _proveedorController = ProveedorController(service: _proveedorService);

    _presupuestoController = PresupuestoController(
      presupuestoService: _presupuestoService,
      invitadoService: _invitadoService,
      proveedorService: _proveedorService,
    );

    // 8) Inicializar boda
    _bodaController.inicializar(
      id: 'boda_1',
      nombrePareja1: 'Ana',
      nombrePareja2: 'Juan',
      fechaBoda: DateTime.now().add(const Duration(days: 90)),
      lugarCeremonia: 'Iglesia Central',
      lugarRecepcion: 'Salón Los Robles',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Planner',
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