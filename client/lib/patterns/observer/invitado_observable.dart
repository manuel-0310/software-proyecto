// Archivo para el patron observer de invitado observable.



import 'invitado_observer.dart';





abstract class InvitadoObservable {
  
  void suscribir(InvitadoObserver observer);

  
  void eliminar(InvitadoObserver observer);

  
  void notificar();
}
