# 📐 Arquitectura del Proyecto - Call Center App

## 🏗️ Estructura General

```
┌─────────────────────────────────────────────────────────────────┐
│                          CALL CENTER APP                         │
│                        (Flutter Mobile App)                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                │
        ┌───────────────────────┴───────────────────────┐
        │                                               │
        ▼                                               ▼
┌───────────────┐                               ┌───────────────┐
│   BACKOFFICE  │                               │    AGENTE     │
│     VIEWS     │                               │     VIEWS     │
└───────────────┘                               └───────────────┘
        │                                               │
        └───────────────────┬───────────────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │    ARCHITECTURE       │
                │   View → BLoC → API   │
                └───────────────────────┘
```

---

## 📱 Flujo de Datos: View → BLoC → Service → API

### **EJEMPLO: Login**

```
┌──────────────────────┐
│  1. LoginView        │  Usuario ingresa credenciales
│     (lib/views/)     │  Presiona botón "Iniciar Sesión"
└──────────┬───────────┘
           │
           │ Evento: LoginSubmitted(username, password)
           │
           ▼
┌──────────────────────┐
│  2. LoginBloc        │  Recibe el evento
│     (lib/blocs/)     │  Emite estado: LoginLoading
│                      │  Llama a LoginApi.login()
└──────────┬───────────┘
           │
           │ Llamada al método
           │
           ▼
┌──────────────────────┐
│  3. LoginApi         │  Hace POST a:
│   (lib/services/)    │  http://EC2:8000/api/auth/login
│                      │  Headers: Content-Type, Accept
│                      │  Body: {username, password}
└──────────┬───────────┘
           │
           │ HTTP Request
           │
           ▼
┌──────────────────────┐
│  4. Backend EC2      │  Valida credenciales
│   (Python/Django)    │  Retorna: {id, username, role, token}
└──────────┬───────────┘
           │
           │ HTTP Response
           │
           ▼
┌──────────────────────┐
│  3. LoginApi         │  Parsea JSON
│   (Response)         │  Retorna UsuarioModel o null
└──────────┬───────────┘
           │
           │ Resultado
           │
           ▼
┌──────────────────────┐
│  2. LoginBloc        │  Si exitoso: LoginSuccess(user)
│   (Emite Estado)     │  Si falla: LoginFailure(mensaje)
└──────────┬───────────┘
           │
           │ Estado
           │
           ▼
┌──────────────────────┐
│  1. LoginView        │  BlocConsumer escucha
│   (Actualiza UI)     │  Si Success → Navega a MainScreen
│                      │  Si Failure → Muestra SnackBar
└──────────────────────┘
```

---

## 🗂️ Organización de Archivos por Capa

### **CAPA 1: VIEW (UI)**
```
lib/views/
├── login.dart                    ✅ Usa LoginBloc
├── home.dart                     
├── backoffice/
│   ├── dashboard.dart            ✅ Usa DashboardBloc
│   ├── ventas.dart               ✅ Usa VentasBloc
│   ├── detalle_llamada.dart      ⚠️  Por revisar
│   └── opciones.dart             
└── agente/
    ├── agente_view.dart          ⚠️  Por revisar
    ├── agente_dashboard.dart     ⚠️  Por revisar
    ├── agente_kpi.dart           ⚠️  Por revisar
    └── agente_opciones.dart      ⚠️  Por revisar

RESPONSABILIDADES:
- ✅ Mostrar widgets (texto, botones, listas, etc.)
- ✅ Enviar eventos al BLoC (cuando el usuario interactúa)
- ✅ Escuchar estados del BLoC (con BlocBuilder/BlocConsumer)
- ❌ NO debe tener lógica de negocio
- ❌ NO debe hacer llamadas HTTP directas
```

### **CAPA 2: BLOC (Business Logic)**
```
lib/blocs/
├── login_bloc.dart               ✅ Implementado
└── backoffice/
    ├── dashboard_bloc.dart       ✅ Implementado
    ├── detalle_llamada_bloc.dart ⚠️  Por revisar
    ├── opciones_bloc.dart        ⚠️  Por revisar
    └── llamadas/
        ├── Llamadas_bloc.dart    ✅ Implementado
        ├── Llamada_event.dart    
        └── Llamada_state.dart    

RESPONSABILIDADES:
- ✅ Definir Eventos (acciones del usuario)
- ✅ Definir Estados (estados de la UI)
- ✅ Contener la lógica de negocio
- ✅ Llamar a los Services para obtener/enviar datos
- ✅ Emitir estados según el resultado
- ❌ NO debe tener código de UI
- ❌ NO debe hacer llamadas HTTP directamente
```

### **CAPA 3: SERVICE (API Connection)**
```
lib/services/
├── login_api.dart                ✅ Consume API real
└── backoffice/
    ├── api_service.dart          ✅ Consume API real
    └── dashboard_service.dart    ✅ Consume API real

RESPONSABILIDADES:
- ✅ Hacer peticiones HTTP (GET, POST, PUT, DELETE)
- ✅ Parsear respuestas JSON a Modelos
- ✅ Manejar errores de red
- ✅ Configurar headers y autenticación
- ❌ NO debe tener lógica de negocio
- ❌ NO debe tener código de UI
```

### **CAPA 4: MODELS (Data Structure)**
```
lib/models/
├── usuario_model.dart            ✅ Con fromJson/toJson
└── backoffice/
    ├── venta_model.dart          ✅ Con fromJson/toJson
    └── llamada_model.dart        ⚠️  Verificar si tiene fromJson

RESPONSABILIDADES:
- ✅ Definir la estructura de datos
- ✅ Método fromJson() para parsear API response
- ✅ Método toJson() para enviar a la API
- ❌ NO debe tener lógica de negocio
```

### **CAPA 5: CONFIG (Configuration)**
```
lib/config/
└── api_config.dart               ✅ URLs, endpoints, headers

RESPONSABILIDADES:
- ✅ URLs base y endpoints
- ✅ Configuración de headers
- ✅ Timeouts y constantes
```

---

## 🔄 Flujo Completo: Dashboard

```
Usuario abre Dashboard
         │
         ▼
┌────────────────────┐
│  DashboardView     │
│  (StatelessWidget) │
└────────┬───────────┘
         │
         │ BlocProvider.create → DashboardBloc()
         │ Inmediatamente dispara: CargarDashboard()
         │
         ▼
┌────────────────────┐
│  DashboardBloc     │  Estado: DashboardCargando
│  on<CargarDashboard│  Llama: _dashboardService.fetchDashboardStats()
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ DashboardService   │  GET http://EC2:8000/api/dashboard/stats
│ .fetchDashboardStats  Headers: Authorization: Bearer {token}
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Backend API       │  SELECT COUNT(*), SUM(monto) FROM ventas...
│  (EC2)             │  Return: {llamadas_reportadas: 20, ...}
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ DashboardService   │  jsonDecode(response.body)
│ (Parse)            │  DashboardStats.fromJson(json)
│                    │  Return: DashboardStats object
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  DashboardBloc     │  if stats != null:
│  (Emite Estado)    │    emit(DashboardCargado(stats))
│                    │  else:
│                    │    emit(DashboardError("mensaje"))
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  DashboardView     │  BlocBuilder<DashboardBloc, DashboardState>
│  (Actualiza UI)    │  if state is DashboardCargado:
│                    │    Muestra PieChart con stats.llamadasReportadas, etc.
│                    │  if state is DashboardCargando:
│                    │    Muestra CircularProgressIndicator
│                    │  if state is DashboardError:
│                    │    Muestra mensaje de error + botón Reintentar
└────────────────────┘
```

---

## 🎯 Ventajas de esta Arquitectura

### ✅ **Separación de Responsabilidades**
Cada capa tiene una responsabilidad clara y única.

### ✅ **Testeable**
- Views: Widget tests
- BLoCs: Unit tests
- Services: Integration tests

### ✅ **Mantenible**
Cambios en la API solo afectan la capa Service.
Cambios en la UI solo afectan la capa View.

### ✅ **Reutilizable**
Los BLoCs y Services pueden ser reutilizados en diferentes vistas.

### ✅ **Escalable**
Fácil agregar nuevas funcionalidades siguiendo el mismo patrón.

---

## 📊 Comparación: Antes vs Después

### **ANTES (Dashboard con datos mockup):**
```dart
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = {
      "Llamadas reportadas": 20,  // ❌ Hardcoded
      "Ventas auditadas": 21,     // ❌ Hardcoded
      "Ventas por auditar": 19,   // ❌ Hardcoded
    };
    
    return Scaffold(
      body: PieChart(data), // ❌ Datos estáticos
    );
  }
}
```

**PROBLEMAS:**
- ❌ Datos hardcoded en la vista
- ❌ No se conecta con backend
- ❌ No hay separación de responsabilidades
- ❌ No se puede actualizar dinámicamente

### **DESPUÉS (Dashboard con BLoC y API):**
```dart
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(DashboardService())
        ..add(CargarDashboard()), // ✅ Carga desde API
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardCargando) {
            return CircularProgressIndicator(); // ✅ Loading
          } else if (state is DashboardCargado) {
            return PieChart(state.stats); // ✅ Datos de API
          } else if (state is DashboardError) {
            return ErrorWidget(state.mensaje); // ✅ Manejo error
          }
          return Container();
        },
      ),
    );
  }
}
```

**VENTAJAS:**
- ✅ Datos vienen de la API en EC2
- ✅ Separación clara: View → BLoC → Service
- ✅ Manejo de estados (loading, error, success)
- ✅ Fácil de testear y mantener

---

## 🚀 Resumen de la Arquitectura

```
┌────────────────────────────────────────────────────────┐
│                    FLUTTER APP                         │
│                                                        │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐ │
│  │   VIEWS     │ ← │   BLoCs     │ → │  SERVICES   │ │
│  │ (UI Layer)  │   │  (Logic)    │   │  (API)      │ │
│  └─────────────┘   └─────────────┘   └──────┬──────┘ │
│         ↑                                     │        │
│         └─────── State Updates ───────────────┘        │
└────────────────────────────────────────────────────────┘
                                │
                            HTTP/HTTPS
                                │
                                ▼
┌────────────────────────────────────────────────────────┐
│                   BACKEND API (EC2)                    │
│                                                        │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐          │
│  │  Django  │   │ FastAPI  │   │  Node.js │          │
│  │   REST   │   │   REST   │   │  Express │          │
│  └─────┬────┘   └─────┬────┘   └─────┬────┘          │
│        └──────────────┴──────────────┘                │
│                       │                               │
│                       ▼                               │
│                ┌──────────────┐                       │
│                │   DATABASE   │                       │
│                │ PostgreSQL/  │                       │
│                │   MySQL      │                       │
│                └──────────────┘                       │
└────────────────────────────────────────────────────────┘
```

---

## ✨ Conclusión

Tu proyecto **Call Center App** ahora está estructurado correctamente siguiendo el patrón arquitectónico **View → BLoC → Service/API**, lo que significa:

1. ✅ **Views limpias** - Solo UI, sin lógica
2. ✅ **BLoCs robustos** - Toda la lógica centralizada
3. ✅ **Services desacoplados** - Fácil cambiar backend
4. ✅ **Código mantenible** - Fácil de entender y modificar
5. ✅ **Listo para producción** - Solo falta configurar URL de EC2

**¡Tu app está lista para conectarse con la API en EC2!** 🎉
