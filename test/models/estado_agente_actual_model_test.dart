import 'package:flutter_test/flutter_test.dart';
import 'package:call_center_application/models/estado_agente_actual_model.dart';

void main() {
  group('EstadoAgenteActualModel - Pruebas Unitarias', () {
    test('debe crear modelo desde JSON del backend correctamente', () {
      // Arrange - JSON de respuesta del backend
      final json = {
        'agente_id': '987654321',
        'agente_nombre': 'María González',
        'agente_email': 'maria.gonzalez@callcenter.com',
        'estado_id': 3,
        'estado_valor': 'AFTERCALL',
        'estado': 'AFTERCALL',
        'estado_display': 'Post Llamada - Documentación',
        'tiempo': '2025-11-20T15:45:10.000-0500',
        'ultima_actualizacion': '2025-11-20T15:45:10.000000-0500',
        'duracion_actual': 125,
        'tiempo_en_estado': 125,
        'campana_actual_id': 3,
        'acepta_llamadas': false,
        'conexion_activa': true,
        'tiene_audio': true,
        'puede_recibir_llamadas': false,
      };

      // Act
      final modelo = EstadoAgenteActualModel.fromJson(json);

      // Assert
      expect(modelo.agenteId, '987654321');
      expect(modelo.agenteNombre, 'María González');
      expect(modelo.agenteEmail, 'maria.gonzalez@callcenter.com');
      expect(modelo.estadoId, 3);
      expect(modelo.estadoValor, 'AFTERCALL');
      expect(modelo.estadoDisplay, 'Post Llamada - Documentación');
      expect(modelo.duracionActual, 125);
      expect(modelo.tiempoEnEstadoSegundos, 125); // Debe ser alias
      expect(modelo.campanaActualId, 3);
      expect(modelo.aceptaLlamadas, false);
      expect(modelo.conexionActiva, true);
      expect(modelo.tieneAudio, true);
      expect(modelo.puedeRecibirLlamadas, false);
    });

    test('debe usar duracion_actual si tiempo_en_estado no está disponible', () {
      // Arrange
      final json = {
        'agente_id': '123',
        'agente_nombre': 'Test',
        'estado_id': 1,
        'estado_valor': 'DISPONIBLE',
        'tiempo': '2025-11-20T15:45:10.000-0500',
        'ultima_actualizacion': '2025-11-20T15:45:10.000000-0500',
        'duracion_actual': 60,
        'acepta_llamadas': true,
        'conexion_activa': true,
        'tiene_audio': true,
        'puede_recibir_llamadas': true,
      };

      // Act
      final modelo = EstadoAgenteActualModel.fromJson(json);

      // Assert
      expect(modelo.duracionActual, 60);
      expect(modelo.tiempoEnEstadoSegundos, 60);
    });

    test('debe usar tiempo_en_estado si duracion_actual no está disponible', () {
      // Arrange
      final json = {
        'agente_id': '123',
        'agente_nombre': 'Test',
        'estado_id': 1,
        'estado_valor': 'DISPONIBLE',
        'tiempo': '2025-11-20T15:45:10.000-0500',
        'ultima_actualizacion': '2025-11-20T15:45:10.000000-0500',
        'tiempo_en_estado': 90,
        'acepta_llamadas': true,
        'conexion_activa': true,
        'tiene_audio': true,
        'puede_recibir_llamadas': true,
      };

      // Act
      final modelo = EstadoAgenteActualModel.fromJson(json);

      // Assert
      expect(modelo.duracionActual, 90);
      expect(modelo.tiempoEnEstadoSegundos, 90);
    });

    test('debe formatear tiempo correctamente (minutos y segundos)', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 125, // 2:05
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act & Assert
      expect(modelo.tiempoEnEstadoFormateado, '02:05');
    });

    test('debe formatear tiempo correctamente (con horas)', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 3725, // 1:02:05
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act & Assert
      expect(modelo.tiempoEnEstadoFormateado, '01:02:05');
    });

    test('debe formatear tiempo cero correctamente', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 0,
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act & Assert
      expect(modelo.tiempoEnEstadoFormateado, '00:00');
    });

    test('debe reconocer estado DISPONIBLE correctamente', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 0,
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act & Assert
      expect(modelo.isDisponible, true);
      expect(modelo.isEnLlamada, false);
      expect(modelo.isPostcall, false);
      expect(modelo.isDesconectado, false);
    });

    test('debe reconocer estado EN_LLAMADA correctamente', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 2,
        estadoValor: 'EN_LLAMADA',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 60,
        aceptaLlamadas: false,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: false,
      );

      // Act & Assert
      expect(modelo.isDisponible, false);
      expect(modelo.isEnLlamada, true);
      expect(modelo.isPostcall, false);
      expect(modelo.isDesconectado, false);
    });

    test('debe reconocer estado AFTERCALL como postcall', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 3,
        estadoValor: 'AFTERCALL',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 30,
        aceptaLlamadas: false,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: false,
      );

      // Act & Assert
      expect(modelo.isDisponible, false);
      expect(modelo.isEnLlamada, false);
      expect(modelo.isPostcall, true);
      expect(modelo.isDesconectado, false);
    });

    test('debe reconocer estado POSTCALL correctamente', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 3,
        estadoValor: 'POSTCALL',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 30,
        aceptaLlamadas: false,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: false,
      );

      // Act & Assert
      expect(modelo.isPostcall, true);
    });

    test('debe reconocer estado DESCONECTADO correctamente', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 4,
        estadoValor: 'DESCONECTADO',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 0,
        aceptaLlamadas: false,
        conexionActiva: false,
        tieneAudio: false,
        puedeRecibirLlamadas: false,
      );

      // Act & Assert
      expect(modelo.isDisponible, false);
      expect(modelo.isEnLlamada, false);
      expect(modelo.isPostcall, false);
      expect(modelo.isDesconectado, true);
    });

    test('copyWith debe crear nueva instancia con campos actualizados', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        tiempo: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        duracionActual: 60,
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act
      final nuevoModelo = modelo.copyWith(
        estadoValor: 'EN_LLAMADA',
        duracionActual: 0,
        aceptaLlamadas: false,
      );

      // Assert
      expect(nuevoModelo.estadoValor, 'EN_LLAMADA');
      expect(nuevoModelo.duracionActual, 0);
      expect(nuevoModelo.aceptaLlamadas, false);
      expect(nuevoModelo.agenteId, '123'); // No cambiado
      expect(nuevoModelo.agenteNombre, 'Test'); // No cambiado
    });

    test('toJson debe incluir todos los campos', () {
      // Arrange
      final modelo = EstadoAgenteActualModel(
        agenteId: '123',
        agenteNombre: 'Test Agent',
        agenteEmail: 'test@example.com',
        estadoId: 1,
        estadoValor: 'DISPONIBLE',
        estadoDisplay: 'Disponible',
        tiempo: DateTime(2025, 11, 20, 15, 45, 10),
        ultimaActualizacion: DateTime(2025, 11, 20, 15, 45, 10),
        duracionActual: 120,
        campanaActualId: 5,
        aceptaLlamadas: true,
        conexionActiva: true,
        tieneAudio: true,
        puedeRecibirLlamadas: true,
      );

      // Act
      final json = modelo.toJson();

      // Assert
      expect(json['agente_id'], '123');
      expect(json['agente_nombre'], 'Test Agent');
      expect(json['agente_email'], 'test@example.com');
      expect(json['estado_id'], 1);
      expect(json['estado_valor'], 'DISPONIBLE');
      expect(json['estado'], 'DISPONIBLE'); // Alias
      expect(json['estado_display'], 'Disponible');
      expect(json['duracion_actual'], 120);
      expect(json['tiempo_en_estado'], 120); // Alias
      expect(json['campana_actual_id'], 5);
      expect(json['acepta_llamadas'], true);
      expect(json['conexion_activa'], true);
      expect(json['tiene_audio'], true);
      expect(json['puede_recibir_llamadas'], true);
    });

    test('debe manejar campos opcionales como null', () {
      // Arrange
      final json = {
        'agente_id': '123',
        'agente_nombre': 'Test',
        'estado_id': 1,
        'estado_valor': 'DISPONIBLE',
        'tiempo': '2025-11-20T15:45:10.000-0500',
        'ultima_actualizacion': '2025-11-20T15:45:10.000000-0500',
        'duracion_actual': 60,
        'acepta_llamadas': true,
        'conexion_activa': true,
        'tiene_audio': true,
        'puede_recibir_llamadas': true,
        // Sin agente_email, estado_display, campana_actual_id
      };

      // Act
      final modelo = EstadoAgenteActualModel.fromJson(json);

      // Assert
      expect(modelo.agenteEmail, null);
      expect(modelo.estadoDisplay, null);
      expect(modelo.campanaActualId, null);
    });
  });
}
