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
  

// Variable para invitado datasource.
  late final InvitadoDatasource _invitadoDatasource;

// Variable para proveedor datasource.
  late final ProveedorDatasource _proveedorDatasource;

// Variable para evento datasource.
  late final EventoDatasource _eventoDatasource;

  

// Variable para invitado repositorio.
  late final IInvitadoRepository _invitadoRepo;

// Variable para proveedor repositorio.
  late final IProveedorRepository _proveedorRepo;

// Variable para evento repositorio.
  late final IEventoRepository _eventoRepo;

  

// Variable para notificacion servicio.
  late final NotificacionService _notificacionService;

// Variable para invitado servicio.
  late final InvitadoService _invitadoService;

// Variable para proveedor servicio.
  late final ProveedorService _proveedorService;

// Variable para evento servicio.
  late final EventoService _eventoService;

// Variable para presupuesto servicio.
  late final PresupuestoService _presupuestoService;

  

// Variable para boda controlador.
  late final BodaController _bodaController;

// Variable para invitado controlador.
  late final InvitadoController _invitadoController;

// Variable para proveedor controlador.
  late final ProveedorController _proveedorController;

// Variable para presupuesto controlador.
  late final PresupuestoController _presupuestoController;

  

// Variable para presupuesto base.
  late final Presupuesto _presupuestoBase;

  @override
  void initState() {
    super.initState();

    
    _invitadoDatasource = InvitadoDatasource();
    _proveedorDatasource = ProveedorDatasource();
    _eventoDatasource = EventoDatasource();

    
    _invitadoRepo = InvitadoRepositoryImpl(datasource: _invitadoDatasource);
    _proveedorRepo = ProveedorRepositoryImpl(datasource: _proveedorDatasource);
    _eventoRepo = EventoRepositoryImpl(datasource: _eventoDatasource);

    
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

    


// Variable para notificacion observador.
    final notiObserver = NotificacionObserver(_notificacionService);


// Variable para presupuesto observador.
    final presupuestoObserver = PresupuestoObserver(presupuesto: _presupuestoBase);

    
    _invitadoService = InvitadoService(
      repository: _invitadoRepo,
      observadoresGlobales: [
        notiObserver,
        presupuestoObserver,
      ],
    );

    
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
