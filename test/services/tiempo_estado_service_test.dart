import 'package:flutter_test/flutter_test.dart';
import 'package:call_center_application/services/tiempo_estado_service.dart';

void main() {
  late TiempoEstadoService service;

  setUp(() {
    service = TiempoEstadoService();
  });

  tearDown(() {
    service.dispose();
  });

  group('TiempoEstadoService - Pruebas Unitarias', () {
    test('debe iniciar el servicio con segundos base', () {
      // Arrange
      const segundosBase = 120;
      int? segundosRecibidos;
      String? formateadoRecibido;

      service.onTiempoActualizado = (segundos, formateado) {
        segundosRecibidos = segundos;
        formateadoRecibido = formateado;
      };

      // Act
      service.iniciar(segundosBase);

      // Assert
      expect(service.estaActivo, true);
      expect(segundosRecibidos, segundosBase);
      expect(formateadoRecibido, '02:00');
    });

    test('debe formatear tiempo correctamente (minutos y segundos)', () {
      // Arrange
      const segundos = 125; // 2:05
      String? formateadoRecibido;

      service.onTiempoActualizado = (s, formateado) {
        formateadoRecibido = formateado;
      };

      // Act
      service.iniciar(segundos);

      // Assert
      expect(formateadoRecibido, '02:05');
    });

    test('debe formatear tiempo correctamente (con horas)', () {
      // Arrange
      const segundos = 3725; // 1:02:05
      String? formateadoRecibido;

      service.onTiempoActualizado = (s, formateado) {
        formateadoRecibido = formateado;
      };

      // Act
      service.iniciar(segundos);

      // Assert
      expect(formateadoRecibido, '01:02:05');
    });

    test('debe obtener tiempo actual sin esperar al tick del timer', () {
      // Arrange
      const segundosBase = 100;
      service.iniciar(segundosBase);

      // Act
      final resultado = service.obtenerTiempoActual();

      // Assert
      expect(resultado['segundos'], greaterThanOrEqualTo(segundosBase));
      expect(resultado['formateado'], isNotNull);
      expect(resultado['formateado'], isA<String>());
    });

    test('debe detener el servicio correctamente', () {
      // Arrange
      service.iniciar(100);
      expect(service.estaActivo, true);

      // Act
      service.detener();

      // Assert
      expect(service.estaActivo, false);
    });

    test('debe sincronizar tiempo cuando la diferencia es pequeña', () {
      // Arrange
      service.iniciar(100);
      final tiempoAntes = service.obtenerTiempoActual()['segundos'] as int;

      // Act - Sincronizar con una diferencia menor a 2 segundos
      service.sincronizar(tiempoAntes + 1);
      final tiempoDespues = service.obtenerTiempoActual()['segundos'] as int;

      // Assert - El tiempo debe continuar incrementándose desde la base original
      expect(tiempoDespues, greaterThanOrEqualTo(tiempoAntes));
    });

    test('debe resincronizar cuando la diferencia es mayor a 2 segundos', () async {
      // Arrange
      service.iniciar(100);
      
      // Esperar un poco para que el tiempo local avance
      await Future.delayed(const Duration(milliseconds: 100));
      
      const nuevoTiempoServidor = 200; // Diferencia significativa

      // Act
      service.sincronizar(nuevoTiempoServidor);
      
      // Assert
      final tiempoActual = service.obtenerTiempoActual()['segundos'] as int;
      expect(tiempoActual, greaterThanOrEqualTo(nuevoTiempoServidor));
      expect(tiempoActual, lessThan(nuevoTiempoServidor + 5)); // Margen de error
    });

    test('debe llamar callback cada segundo después de iniciar', () async {
      // Arrange
      int contadorLlamadas = 0;
      service.onTiempoActualizado = (segundos, formateado) {
        contadorLlamadas++;
      };

      // Act
      service.iniciar(0);
      await Future.delayed(const Duration(milliseconds: 2500));

      // Assert - Debe haber llamado al menos 2 veces (inicial + 2 segundos)
      expect(contadorLlamadas, greaterThanOrEqualTo(2));
    });

    test('debe manejar sincronización cuando el servicio no está iniciado', () {
      // Arrange
      const segundosDelServidor = 100;

      // Act - Sincronizar sin iniciar primero
      service.sincronizar(segundosDelServidor);

      // Assert - Debe iniciar automáticamente
      expect(service.estaActivo, true);
      final tiempo = service.obtenerTiempoActual();
      expect(tiempo['segundos'], greaterThanOrEqualTo(segundosDelServidor));
    });
  });
}
