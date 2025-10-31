# 🔧 Diagnóstico: Error "SyntaxError: Unexpected token <!DOCTYPE>"

## 🎯 Problema Identificado

El error **"SyntaxError: Unexpected token <!DOCTYPE> is not valid JSON"** ocurre cuando el backend está devolviendo **HTML en lugar de JSON**.

## 🔍 Causa Raíz

El código intenta hacer `json.decode()` de una respuesta HTML, causando el error.

### Respuesta Esperada (JSON):
```json
{
  "documento_id": "12345678",
  "email": "agente@example.com",
  "full_name": "Juan Pérez",
  "role": "AGENTE"
}
```

### Respuesta Real (HTML):
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Error 404</title>
  </head>
  ...
</html>
```

---

## 🛠️ Soluciones

### ✅ Solución 0: Agregar Header para Ngrok (⭐ MÁS COMÚN)

**Este es el problema más frecuente:** Ngrok muestra una página de advertencia HTML con el mensaje:
```
You are about to visit [tu-url].ngrok-free.dev...
This website is served for free through ngrok.com
(ERR_NGROK_6024)
```

**Solución Implementada:**

Se agregó el header `ngrok-skip-browser-warning: true` en `api_config.dart`:

```dart
// lib/config/api_config.dart
static Map<String, String> headers({String? token}) {
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true', // ← ESTO SOLUCIONA EL PROBLEMA
  };
  
  if (token != null && token.isNotEmpty) {
    defaultHeaders['Authorization'] = 'Bearer $token';
  }
  
  return defaultHeaders;
}
```

**¿Por qué funciona?**

Ngrok muestra una página de advertencia HTML para proteger a los usuarios de enlaces maliciosos. Al agregar este header, le indicas a ngrok que confías en la fuente y permites que las peticiones HTTP pasen directamente al backend sin mostrar la advertencia.

**✅ SOLUCIÓN APLICADA - Reinicia la app con Hot Restart (`r` en la terminal de Flutter)**

---

### ✅ Solución 1: Verificar URL de Ngrok

Ngrok genera URLs temporales que expiran. Necesitas verificar la URL actual.

**Pasos:**

1. **En la terminal donde está corriendo el backend**, busca la URL de ngrok:
```bash
# Deberías ver algo como:
Forwarding    https://[nombre-aleatorio].ngrok-free.app -> http://localhost:8000
```

2. **Actualiza `api_config.dart`** con la nueva URL:
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://[TU-NUEVA-URL-NGROK].ngrok-free.app/api';
  //                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                              ACTUALIZA ESTO
}
```

3. **Reinicia la app** (Hot restart, no hot reload):
```bash
# En la terminal de Flutter
r  # Restart
```

---

### ✅ Solución 2: Verificar que el Backend Esté Corriendo

**Verifica que Django esté activo:**

```bash
# En la terminal del backend
python manage.py runserver 0.0.0.0:8000
```

**Deberías ver:**
```
Starting development server at http://0.0.0.0:8000/
Quit the server with CTRL-BREAK.
```

---

### ✅ Solución 3: Probar el Endpoint Manualmente

**Usa un cliente HTTP para verificar el endpoint:**

#### Opción A: Con curl
```bash
curl -H "Authorization: Bearer TU_TOKEN" \
     https://unegregious-unscintillating-kingsley.ngrok-free.dev/api/users/me/
```

#### Opción B: Con Postman
1. Crea una request GET
2. URL: `https://[TU-URL-NGROK]/api/users/me/`
3. Headers:
   - `Authorization: Bearer [TU_TOKEN]`
   - `Content-Type: application/json`
4. Envía la request

**Resultado Esperado:**
- Status 200
- Body en formato JSON con datos del usuario

**Si recibes HTML:**
- Status 404 → El endpoint no existe
- Status 500 → Error en el backend
- Página de Ngrok → URL incorrecta o ngrok requiere autenticación

---

### ✅ Solución 4: Revisar Logs del Backend

**En la terminal del backend**, busca errores:

```bash
# Logs normales (exitosos)
[30/Oct/2025 10:30:45] "GET /api/users/me/ HTTP/1.1" 200 245

# Error 404 (endpoint no existe)
[30/Oct/2025 10:30:45] "GET /api/users/me/ HTTP/1.1" 404 1234

# Error 500 (error en el servidor)
[30/Oct/2025 10:30:45] "GET /api/users/me/ HTTP/1.1" 500 5678
Internal Server Error: /api/users/me/
Traceback (most recent call last):
  ...
```

---

### ✅ Solución 5: Verificar Configuración de Ngrok

Si usas Ngrok, puede que tengas restricciones.

**Archivo de configuración de ngrok (`ngrok.yml`):**
```yaml
version: "2"
authtoken: TU_AUTH_TOKEN
tunnels:
  backend:
    proto: http
    addr: 8000
    # NO agregues restricciones HTML
```

**Inicia ngrok correctamente:**
```bash
ngrok http 8000
```

---

## 🔬 Mejoras Implementadas en el Código

### 1. **Detección de Content-Type**

El código ahora verifica que la respuesta sea JSON:

```dart
final contentType = response.headers['content-type'] ?? '';
if (!contentType.contains('application/json')) {
  throw Exception('El servidor devolvió HTML en lugar de JSON');
}
```

### 2. **Logging Mejorado**

```dart
AppLogger.info('📍 URL: ${ApiConfig.userMeEndpoint}');
AppLogger.info('📊 Status Code: ${response.statusCode}');
AppLogger.info('📄 Content-Type: ${response.headers['content-type']}');
AppLogger.error('🔍 Primeros 200 caracteres: ${response.body.substring(0, 200)}');
```

### 3. **Mensaje de Error Detallado en UI**

```dart
if (e.toString().contains('HTML') || e.toString().contains('DOCTYPE')) {
  errorMsg = 'Error de configuración del servidor.\n\n'
      '⚠️ El backend está devolviendo HTML en lugar de JSON.\n\n'
      'Posibles causas:\n'
      '• URL del backend incorrecta\n'
      '• El endpoint /api/users/me/ no existe\n'
      '• Ngrok requiere autenticación\n'
      '• Backend no está corriendo';
}
```

---

## 📋 Checklist de Verificación

Marca cada item cuando lo hayas verificado:

- [ ] **Backend corriendo**: `python manage.py runserver`
- [ ] **Ngrok activo**: URL visible en la terminal
- [ ] **URL actualizada**: `api_config.dart` tiene la URL correcta de ngrok
- [ ] **Endpoint existe**: `/api/users/me/` responde en Postman
- [ ] **Token válido**: El usuario ha iniciado sesión
- [ ] **Content-Type correcto**: Backend devuelve `application/json`
- [ ] **App reiniciada**: Hot restart ejecutado
- [ ] **Logs revisados**: No hay errores 500 en el backend

---

## 🎓 Para Desarrolladores

### Cómo Probar Localmente sin Ngrok

Si estás en desarrollo local:

```dart
// lib/config/api_config.dart
class ApiConfig {
  // Para desarrollo local (Android emulator)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Para desarrollo local (iOS simulator)
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // Para dispositivo físico en la misma red
  // static const String baseUrl = 'http://192.168.1.X:8000/api';
}
```

### Cómo Agregar Logging de Red

Para ver todas las requests HTTP:

```bash
# En la terminal de Flutter, habilita logging verbose
flutter run --verbose
```

---

## 🚀 Resultado Esperado

Después de aplicar las soluciones, deberías ver en los logs:

```
I/flutter: === Iniciando carga de dashboard ===
I/flutter: 👤 Obteniendo perfil actual...
I/flutter: 📍 URL: https://tu-url.ngrok-free.app/api/users/me/
I/flutter: 📊 Status Code: 200
I/flutter: 📄 Content-Type: application/json; charset=utf-8
I/flutter: ✅ Perfil obtenido: Juan Pérez
I/flutter: === Dashboard cargado exitosamente ===
```

Y la interfaz mostrará:
- ✅ Header con avatar y nombre del agente
- ✅ Estado actual con color
- ✅ 6 cards de métricas

---

## 📞 Si el Problema Persiste

**Proporciona esta información:**

1. **Logs de Flutter** (con el error completo)
2. **URL del backend** que estás usando
3. **Respuesta del endpoint** (prueba con curl o Postman)
4. **Logs del backend** (Django)
5. **Status code de la respuesta**

Con esa información se puede diagnosticar el problema exacto.
