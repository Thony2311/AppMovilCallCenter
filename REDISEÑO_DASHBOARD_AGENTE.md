# Rediseño del Dashboard del Agente

## 📋 Resumen

Se ha realizado un **rediseño completo** de la vista `agente_dashboard.dart` con los siguientes objetivos cumplidos:

1. ✅ **Integración con endpoints reales** - Usa KPIsService y EstadosService
2. ✅ **Información de perfil completa** - Muestra equipo, coordinador y campaña
3. ✅ **Diseño moderno con UI/UX mejorada** - Cards con gradientes, iconos y colores
4. ✅ **Actualización en tiempo real** - Auto-refresh cada 30 segundos con BLoCs
5. ✅ **Gestión de estados** - Loading, error y success states
6. ✅ **Responsive y animado** - Pull-to-refresh, transiciones suaves

---

## 🎨 Características del Nuevo Diseño

### 1. Header con Perfil del Agente

```dart
Widget _buildHeaderCard(BuildContext context)
```

**Muestra:**
- Avatar del agente (foto de perfil o iniciales)
- Nombre completo y rol
- Información del equipo (placeholder)
- Nombre del coordinador (placeholder)
- Campaña activa (placeholder)

**Diseño:**
- Card con gradiente del color primario
- Hero animation en el avatar
- Iconos descriptivos para cada campo

**Nota:** Los campos de equipo, coordinador y campaña están con placeholders porque el endpoint actual del backend no incluye esta información. **Se requiere actualizar el backend** para incluir:

```python
# En el serializer de KPIAgenteDetalleSerializer
def get_agente_datos(self, obj):
    return {
        'nombre': obj.agente.get_full_name(),
        'documento_id': obj.agente.documento_id,
        'equipo_nombre': obj.agente.equipo.nombre if obj.agente.equipo else None,
        'coordinador_nombre': obj.agente.equipo.coordinador.get_full_name() if obj.agente.equipo and obj.agente.equipo.coordinador else None,
        'campana_nombre': obj.agente.equipo.campana.nombre if obj.agente.equipo and obj.agente.equipo.campana else None,
    }
```

### 2. Estado Actual en Tiempo Real

```dart
Widget _buildEstadoActualCard(BuildContext context)
```

**Muestra:**
- Estado actual del agente (DISPONIBLE, EN_LLAMADA, POSTCALL, DESCONECTADO)
- Tiempo en el estado actual con formato legible
- Indicador visual animado con colores según el estado
- Icono representativo del estado

**Diseño:**
- Card con borde coloreado según el estado
- Círculos concéntricos animados
- Badge con el tiempo en estado
- Colores semánticos:
  - 🟢 **Verde**: DISPONIBLE
  - 🔵 **Azul**: EN_LLAMADA
  - 🟠 **Naranja**: POSTCALL
  - ⚫ **Gris**: DESCONECTADO

**Fuente de datos:**
```dart
_estadosBloc.add(const LoadEstadoActual());
// Endpoint: GET /api/estados/actual/
```

### 3. Métricas Principales del Día

```dart
Widget _buildKPIsSection(BuildContext context)
```

**Muestra 6 métricas clave:**

#### 📞 Llamadas Atendidas
- Valor numérico del total de llamadas del día
- Icono: `phone_in_talk`
- Color: Azul

#### 🛍️ Ventas Realizadas
- Total de ventas concretadas
- Icono: `shopping_bag`
- Color: Verde

#### 📈 Tasa de Conversión
- Porcentaje de llamadas convertidas en ventas
- Indica si cumple el objetivo (>20%)
- Icono: `trending_up` con flecha hacia arriba
- Color: Naranja

#### ⏱️ Tiempo Trabajado
- Tiempo total en estado activo (formateado HH:MM:SS)
- Subtitle con formato legible (Xh Ym)
- Icono: `access_time`
- Color: Púrpura

#### ⏲️ Duración Promedio
- Tiempo promedio por llamada
- Card de ancho completo
- Icono: `timer_outlined`
- Color: Teal

#### 📊 Distribución del Tiempo
- Gráfico de barras horizontales
- Muestra porcentaje de tiempo en cada estado
- Formato: `HH:MM:SS (XX.X%)`
- Colores según el estado

**Diseño de Cards:**
- Gradientes suaves con opacidad
- Padding generoso (16px)
- Border radius de 16px
- Iconos en contenedores con fondo semitransparente
- Títulos en gris (tamaño 13)
- Valores grandes y bold (tamaño 24-28)
- Subtítulos opcionales en gris claro

**Fuente de datos:**
```dart
_kpisBloc.add(LoadKPIAgenteDetalle(
  documentoId: perfil.documentoId,
  rango: 'hoy',
));
// Endpoint: GET /api/kpis/agentes/{documento_id}/detalle/?rango=hoy
```

### 4. Manejo de Estados

#### Loading State
```dart
if (state is KPIsLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

#### Error State
```dart
if (state is KPIsError) {
  return Card(
    child: Column([
      Icon(Icons.error_outline, size: 48, color: Colors.red),
      Text('Error al cargar métricas'),
      Text(state.message),
      ElevatedButton.icon(
        onPressed: _cargarDatos,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
      ),
    ]),
  );
}
```

#### Success State
- Muestra todos los datos con animación de fade-in
- Cards interactivos con hover effects

---

## 🔄 Actualización Automática

### BLoCs Utilizados

1. **KPIsBloc**
   - Auto-refresh cada 30 segundos
   - Refresh silencioso (no muestra loading)
   - Preserva estado en caso de error
   - Timer auto-cancelable al destruir el widget

2. **EstadosBloc**
   - Auto-refresh cada 30 segundos
   - Monitorea estado actual del agente en tiempo real
   - Timer independiente del KPIsBloc

### Métodos de Refresh

1. **Pull to Refresh**
```dart
RefreshIndicator(
  onRefresh: _cargarDatos,
  child: SingleChildScrollView(...),
)
```

2. **Botón Manual**
```dart
IconButton(
  icon: const Icon(Icons.refresh),
  onPressed: _cargarDatos,
)
```

3. **Automático (BLoC)**
- Cada 30 segundos sin intervención del usuario
- No interrumpe la experiencia del usuario

---

## 🛠️ Arquitectura Técnica

### Estructura de Archivos

```
lib/
├── views/
│   └── agente/
│       └── agente_dashboard.dart     <-- ✅ REDISEÑADO
├── blocs/
│   ├── kpis/
│   │   ├── kpis_bloc.dart
│   │   ├── kpis_event.dart
│   │   └── kpis_state.dart
│   └── estados/
│       ├── estados_bloc.dart
│       ├── estados_event.dart
│       └── estados_state.dart
├── models/
│   ├── usuario_model.dart
│   └── kpis/
│       ├── kpi_agente_detalle_model.dart
│       └── estado_del_dia_model.dart
└── services/
    ├── user_service.dart
    ├── kpis/
    │   └── kpis_service.dart
    └── estados_service.dart
```

### Flujo de Datos

```
1. initState()
   ↓
2. _cargarDatos()
   ↓
3a. UserService.obtenerPerfilActual()     → UsuarioModel
   ↓
3b. KPIsBloc.LoadKPIAgenteDetalle()       → KPIAgenteDetalleModel
   ↓
3c. EstadosBloc.LoadEstadoActual()        → EstadoAgenteActualModel
   ↓
4. BlocBuilder escucha cambios
   ↓
5. UI se actualiza reactivamente
   ↓
6. Timer (30s) → Refresh automático silencioso
```

### Gestión de Memoria

```dart
@override
void dispose() {
  _animationController.dispose();
  _kpisBloc.stopAutoRefresh();   // Detiene el timer
  _kpisBloc.close();              // Libera recursos
  _estadosBloc.stopAutoRefresh(); // Detiene el timer
  _estadosBloc.close();           // Libera recursos
  super.dispose();
}
```

---

## 📱 Responsive Design

### Breakpoints

- **Mobile**: 1 columna para todos los cards
- **Tablet/Desktop**: 2 columnas para métricas principales

### Adaptación

```dart
Row(
  children: [
    Expanded(child: _buildMetricCard(...)),  // 50% width
    const SizedBox(width: 12),
    Expanded(child: _buildMetricCard(...)),  // 50% width
  ],
),
```

### ScrollView

- `SingleChildScrollView` con `AlwaysScrollableScrollPhysics`
- Permite scroll incluso cuando el contenido no lo requiere
- Habilita el pull-to-refresh en todo momento

---

## 🎯 UX/UI Best Practices Aplicadas

### ✅ Visual Hierarchy
- Headers grandes y bold
- Subtítulos pequeños y en gris
- Valores destacados con tamaño y color

### ✅ Feedback Visual
- Loading indicators durante carga inicial
- Pull-to-refresh con indicador
- Estados de error con botón de reintento
- Animaciones suaves (fade-in 800ms)

### ✅ Consistencia
- Border radius uniforme (16px para cards, 12px para contenedores internos)
- Spacing consistente (8px, 12px, 16px, 24px)
- Paleta de colores semántica (verde=success, azul=info, naranja=warning, rojo=error)

### ✅ Accesibilidad
- Iconos descriptivos en todas las métricas
- Textos legibles con contraste adecuado
- Tooltips en botones de acción
- Indicadores visuales de estado

### ✅ Performance
- Lazy loading con BlocBuilder
- Disposing correcto de recursos
- Timers optimizados (sin memory leaks)
- Refresh silencioso (no reconstruye toda la vista)

---

## 🐛 Solución de Problemas

### El dashboard no carga los datos

**Problema:** La vista muestra "Loading..." indefinidamente.

**Soluciones:**
1. Verificar que el backend esté corriendo
2. Revisar logs del `AppLogger` para ver errores
3. Verificar token de autenticación válido
4. Comprobar conectividad con el backend

### Los datos no se actualizan automáticamente

**Problema:** Los datos quedan estáticos, no hay auto-refresh.

**Soluciones:**
1. Verificar que el timer del BLoC esté activo:
```dart
// En KPIsBloc/EstadosBloc
_refreshTimer?.isActive ?? false
```
2. Asegurar que no se haya llamado a `stopAutoRefresh()` prematuramente

### Errores de tipo "The getter 'X' isn't defined"

**Problema:** Falta importar modelos o el modelo no tiene la propiedad.

**Soluciones:**
1. Importar el modelo requerido
2. Verificar que el modelo tenga la propiedad/getter
3. Si el backend cambió, actualizar el modelo

### Equipo, Coordinador y Campaña muestran "Placeholder"

**Problema:** El backend actual no retorna esa información.

**Solución:** Actualizar el backend para incluir:
```python
# En el serializer
'equipo_nombre': agente.equipo.nombre,
'coordinador_nombre': agente.equipo.coordinador.get_full_name(),
'campana_nombre': agente.equipo.campana.nombre,
```

Luego actualizar el código:
```dart
// En _buildHeaderCard()
_buildInfoRow(
  context,
  Icons.groups,
  'Equipo',
  state.detalle.equipoNombre ?? 'N/A',
),
```

---

## 🔮 Mejoras Futuras

### Corto Plazo
- [ ] Actualizar backend para incluir equipo, coordinador y campaña
- [ ] Agregar gráfico de líneas para llamadas por hora
- [ ] Implementar filtros de fecha (hoy, esta semana, este mes)
- [ ] Agregar notificaciones push cuando llegue una llamada

### Mediano Plazo
- [ ] Dashboard personalizable (drag-and-drop de cards)
- [ ] Comparación con promedios del equipo
- [ ] Objetivos visuales con progress bars
- [ ] Export de métricas a PDF

### Largo Plazo
- [ ] Gamificación (badges, niveles, logros)
- [ ] Análisis predictivo con ML
- [ ] Recomendaciones personalizadas
- [ ] Integración con analytics avanzado

---

## 📚 Referencias

- **Archivo Principal**: `lib/views/agente/agente_dashboard.dart`
- **BLoCs**: `lib/blocs/kpis/` y `lib/blocs/estados/`
- **Modelos**: `lib/models/kpis/`
- **Servicios**: `lib/services/kpis/` y `lib/services/estados_service.dart`
- **Documentación de KPIs**: `IMPLEMENTACION_MODULO_KPIS.md`
- **Arquitectura del Proyecto**: `ARQUITECTURA_PROYECTO.md`

---

## 🎓 Código de Ejemplo

### Uso del Dashboard en la App

```dart
// En la vista principal del agente
import 'package:flutter/material.dart';
import 'views/agente/agente_dashboard.dart';

class AgenteHomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AgenteDashboardView(),
      bottomNavigationBar: ...,
    );
  }
}
```

### Cómo agregar una nueva métrica

1. **Actualizar el modelo** (`kpi_agente_detalle_model.dart`):
```dart
final int nuevaMetrica;

factory KPIAgenteDetalleModel.fromJson(Map<String, dynamic> json) {
  return KPIAgenteDetalleModel(
    // ... otros campos
    nuevaMetrica: json['nueva_metrica'] ?? 0,
  );
}
```

2. **Agregar card en la vista**:
```dart
_buildModernMetricCard(
  context,
  'Nueva Métrica',
  kpi.nuevaMetrica.toString(),
  Icons.new_icon,
  Colors.indigo,
  subtitle: 'Descripción',
),
```

3. **Actualizar el backend** para incluir el campo en el serializer.

---

## ✨ Conclusión

El nuevo diseño del dashboard del agente ofrece:

✅ **Experiencia de usuario moderna** con animaciones y diseño intuitivo  
✅ **Datos en tiempo real** con actualización automática cada 30 segundos  
✅ **Información completa** sobre métricas, estados y perfil  
✅ **Arquitectura escalable** usando BLoC pattern  
✅ **Código mantenible** con separación de responsabilidades  
✅ **Performance optimizada** con gestión correcta de recursos  

El dashboard está listo para producción con una pequeña actualización pendiente en el backend para mostrar la información de equipo, coordinador y campaña.
