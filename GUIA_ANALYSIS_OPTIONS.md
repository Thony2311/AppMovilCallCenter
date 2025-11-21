# Guía de Configuración: analysis_options.yaml

Este documento explica cada regla y configuración del archivo `analysis_options.yaml` que controla el análisis estático de código en el proyecto Flutter.

---

## 📋 Tabla de Contenidos
- [Configuración del Analizador](#configuración-del-analizador)
- [Reglas Críticas de Corrección](#reglas-críticas-de-corrección)
- [Seguridad y Mejores Prácticas](#seguridad-y-mejores-prácticas)
- [Nombres y Convenciones](#nombres-y-convenciones)
- [Flutter Específico](#flutter-específico)
- [Mantenibilidad Básica](#mantenibilidad-básica)
- [Limpieza de Código](#limpieza-de-código)
- [Rendimiento](#rendimiento)

---

## 📦 Include

```yaml
include: package:flutter_lints/flutter.yaml
```

**¿Qué hace?** Incluye el conjunto de reglas recomendadas por el equipo de Flutter. Es el punto de partida estándar que ya contiene muchas buenas prácticas.

---

## ⚙️ Configuración del Analizador

### Exclusiones

```yaml
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
  - "**/generated/**"
  - "build/**"
```

**¿Qué hace?** Excluye archivos generados automáticamente del análisis porque:
- `**/*.g.dart`: Archivos generados por generadores de código (json_serializable, etc.)
- `**/*.freezed.dart`: Archivos generados por el paquete Freezed
- `**/generated/**`: Cualquier carpeta llamada "generated"
- `build/**`: Directorio de construcción de Flutter

**Razón:** No tiene sentido analizar código que no escribimos manualmente.

### Configuración de Lenguaje

```yaml
language:
  strict-casts: true
  strict-inference: false
  strict-raw-types: false
```

#### `strict-casts: true`
**¿Qué hace?** Obliga a hacer conversiones de tipos explícitas en lugar de implícitas.

**Ejemplo:**
```dart
// ❌ Error con strict-casts: true
dynamic valor = 5;
int numero = valor; // Conversión implícita no permitida

// ✅ Correcto
dynamic valor = 5;
int numero = valor as int; // Conversión explícita
```

#### `strict-inference: false`
**¿Qué hace?** Permite que Dart infiera tipos automáticamente sin forzar anotaciones explícitas.

**Ejemplo:**
```dart
// ✅ Permitido con strict-inference: false
var lista = [1, 2, 3]; // Dart infiere List<int>

// Con strict-inference: true, requerirías:
List<int> lista = [1, 2, 3];
```

#### `strict-raw-types: false`
**¿Qué hace?** Permite usar tipos genéricos sin especificar el tipo del parámetro.

**Ejemplo:**
```dart
// ✅ Permitido con strict-raw-types: false
List miLista = []; // Sin especificar <tipo>

// Con strict-raw-types: true, requerirías:
List<dynamic> miLista = [];
```

### Configuración de Severidad de Errores

```yaml
errors:
  invalid_annotation_target: ignore
  todo: ignore
  deprecated_member_use: warning
  missing_required_param: error
  missing_return: error
  avoid_print: error
  dead_code: warning
  unused_import: warning
  unused_local_variable: info
  unused_element: info
```

#### `invalid_annotation_target: ignore`
**¿Qué hace?** Ignora cuando una anotación se aplica a un target inválido.
**Razón:** Algunas librerías generan código con anotaciones especiales que pueden causar esta advertencia.

#### `todo: ignore`
**¿Qué hace?** Ignora comentarios `// TODO:` en el código.
**Razón:** Los TODOs son útiles durante el desarrollo y no deberían bloquear la compilación.

#### `deprecated_member_use: warning`
**¿Qué hace?** Advierte cuando usas código marcado como obsoleto.
**Razón:** Te alerta para que migres a alternativas modernas, pero no bloquea el desarrollo.

#### `missing_required_param: error`
**¿Qué hace?** Error si falta un parámetro requerido.
**Ejemplo:**
```dart
void saludar({required String nombre}) { }

// ❌ Error
saludar(); // Falta el parámetro 'nombre'

// ✅ Correcto
saludar(nombre: 'Juan');
```

#### `missing_return: error`
**¿Qué hace?** Error si una función que debe retornar un valor no lo hace.
**Ejemplo:**
```dart
// ❌ Error
int sumar(int a, int b) {
  if (a > 0) {
    return a + b;
  }
  // Falta return en el else
}

// ✅ Correcto
int sumar(int a, int b) {
  return a + b;
}
```

#### `avoid_print: error`
**¿Qué hace?** Prohíbe el uso de `print()` en el código.
**Razón:** En producción deberías usar un sistema de logging apropiado como `logger` o `debugPrint`.
**Ejemplo:**
```dart
// ❌ Error
print('Debug info'); 

// ✅ Correcto
debugPrint('Debug info');
// o usar AppLogger.info('Debug info');
```

#### `dead_code: warning`
**¿Qué hace?** Advierte sobre código que nunca se ejecuta.
**Ejemplo:**
```dart
// ⚠️ Warning
void ejemplo() {
  return;
  print('Esto nunca se ejecuta'); // Código muerto
}
```

#### `unused_import: warning`
**¿Qué hace?** Advierte sobre imports que no se usan.

#### `unused_local_variable: info`
**¿Qué hace?** Info sobre variables locales declaradas pero no usadas.

#### `unused_element: info`
**¿Qué hace?** Info sobre métodos/propiedades privadas no usadas en la clase.

---

## 🛡️ Reglas Críticas de Corrección

### Prevenir Errores y Bugs

#### `avoid_empty_else`
**¿Qué hace?** Evita bloques `else` vacíos.
```dart
// ❌ Malo
if (condicion) {
  hacerAlgo();
} else {
  // Vacío
}

// ✅ Mejor - eliminar el else
if (condicion) {
  hacerAlgo();
}
```

#### `avoid_print`
**¿Qué hace?** Ya explicado arriba - usar logging apropiado.

#### `avoid_relative_lib_imports`
**¿Qué hace?** Evita imports relativos desde `lib/`.
```dart
// ❌ Malo
import '../../../models/usuario.dart';

// ✅ Bueno
import 'package:mi_app/models/usuario.dart';
```

#### `avoid_returning_null_for_void`
**¿Qué hace?** Una función `void` no debe retornar `null`.
```dart
// ❌ Malo
void procesar() {
  return null;
}

// ✅ Bueno
void procesar() {
  return;
}
```

#### `avoid_types_as_parameter_names`
**¿Qué hace?** Evita usar nombres de tipos como nombres de parámetros.
```dart
// ❌ Malo
void procesar(int int) { }

// ✅ Bueno
void procesar(int numero) { }
```

#### `cancel_subscriptions`
**¿Qué hace?** Verifica que los `StreamSubscription` se cancelen.
```dart
// ❌ Malo - fuga de memoria
StreamSubscription sub = stream.listen((data) { });

// ✅ Bueno
StreamSubscription sub = stream.listen((data) { });
@override
void dispose() {
  sub.cancel();
  super.dispose();
}
```

#### `close_sinks`
**¿Qué hace?** Verifica que los `StreamController` se cierren.
```dart
// ❌ Malo - fuga de memoria
final controller = StreamController();

// ✅ Bueno
final controller = StreamController();
@override
void dispose() {
  controller.close();
  super.dispose();
}
```

#### `control_flow_in_finally`
**¿Qué hace?** Evita `return`, `break`, `continue` en bloques `finally`.
```dart
// ❌ Malo
try {
  procesarDatos();
} finally {
  return; // No permitido
}
```

#### `empty_catches`
**¿Qué hace?** Advierte sobre bloques `catch` vacíos.
```dart
// ❌ Malo - oculta errores
try {
  operacionRiesgosa();
} catch (e) {
  // Vacío - error silencioso
}

// ✅ Bueno
try {
  operacionRiesgosa();
} catch (e) {
  logger.error('Error en operación', e);
}
```

#### `empty_statements`
**¿Qué hace?** Evita statements vacíos (`;` solo).
```dart
// ❌ Malo
if (condicion); // Statement vacío accidental
  hacerAlgo();
```

#### `hash_and_equals`
**¿Qué hace?** Si implementas `==` también debes implementar `hashCode`.
```dart
// ❌ Malo
class Persona {
  final String nombre;
  Persona(this.nombre);
  
  @override
  bool operator ==(Object other) => 
      other is Persona && other.nombre == nombre;
  // Falta hashCode
}

// ✅ Bueno
class Persona {
  final String nombre;
  Persona(this.nombre);
  
  @override
  bool operator ==(Object other) => 
      other is Persona && other.nombre == nombre;
  
  @override
  int get hashCode => nombre.hashCode;
}
```

#### `no_duplicate_case_values`
**¿Qué hace?** Evita valores duplicados en `switch`.
```dart
// ❌ Malo
switch (valor) {
  case 1:
    print('Uno');
    break;
  case 1: // Duplicado
    print('Uno de nuevo');
    break;
}
```

#### `throw_in_finally`
**¿Qué hace?** Evita lanzar excepciones en bloques `finally`.

#### `unrelated_type_equality_checks`
**¿Qué hace?** Advierte cuando comparas tipos incompatibles.
```dart
// ❌ Malo - siempre será false
if ('texto' == 42) { }

// ✅ Bueno
if ('texto' == '42') { }
```

#### `valid_regexps`
**¿Qué hace?** Valida que las expresiones regulares sean sintácticamente correctas.

#### `always_require_non_null_named_parameters`
**¿Qué hace?** Parámetros nombrados sin valor por defecto deben ser `required`.
```dart
// ❌ Malo - puede ser null sin control
void procesar({String? nombre}) { }

// ✅ Bueno
void procesar({required String nombre}) { }
// o
void procesar({String nombre = 'sin nombre'}) { }
```

---

## 🔒 Seguridad y Mejores Prácticas

#### `use_build_context_synchronously`
**¿Qué hace?** Verifica que el `BuildContext` sigue válido después de operaciones asíncronas.
```dart
// ❌ Malo - context puede estar desmontado
Future<void> cargarDatos() async {
  await Future.delayed(Duration(seconds: 2));
  Navigator.of(context).pop(); // ⚠️ Peligroso
}

// ✅ Bueno
Future<void> cargarDatos() async {
  await Future.delayed(Duration(seconds: 2));
  if (mounted && context.mounted) {
    Navigator.of(context).pop();
  }
}
```

#### `avoid_init_to_null`
**¿Qué hace?** No inicialices variables explícitamente a `null` (es el valor por defecto).
```dart
// ❌ Malo - redundante
String? nombre = null;

// ✅ Bueno
String? nombre;
```

#### `prefer_is_empty` / `prefer_is_not_empty`
**¿Qué hace?** Usa `.isEmpty` y `.isNotEmpty` en lugar de comparar con `.length`.
```dart
// ❌ Malo
if (lista.length == 0) { }
if (lista.length > 0) { }

// ✅ Bueno
if (lista.isEmpty) { }
if (lista.isNotEmpty) { }
```

#### `await_only_futures`
**¿Qué hace?** Solo usa `await` con `Future`.
```dart
// ❌ Malo
await 42; // No es un Future

// ✅ Bueno
await Future.value(42);
```

#### `unawaited_futures`
**¿Qué hace?** Advierte cuando ignoras un `Future` sin esperar.
```dart
// ⚠️ Warning - Future ignorado
Future<void> guardarDatos() async {
  api.guardar(datos); // Sin await
}

// ✅ Bueno
Future<void> guardarDatos() async {
  await api.guardar(datos);
}
// o si intencionalmente no quieres esperar:
Future<void> guardarDatos() async {
  unawaited(api.guardar(datos));
}
```

---

## 📝 Nombres y Convenciones

#### `camel_case_types`
**¿Qué hace?** Nombres de clases deben usar UpperCamelCase.
```dart
// ❌ Malo
class mi_clase { }

// ✅ Bueno
class MiClase { }
```

#### `file_names`
**¿Qué hace?** Nombres de archivos deben usar snake_case.
```dart
// ❌ Malo
MiClase.dart
MiClase-Model.dart

// ✅ Bueno
mi_clase.dart
mi_clase_model.dart
```

#### `non_constant_identifier_names`
**¿Qué hace?** Variables y parámetros deben usar lowerCamelCase.
```dart
// ❌ Malo
String mi_nombre;
void Procesar() { }

// ✅ Bueno
String miNombre;
void procesar() { }
```

#### `constant_identifier_names`
**¿Qué hace?** Constantes deben usar lowerCamelCase.
```dart
// ❌ Malo
const int MAX_VALUE = 100;

// ✅ Bueno
const int maxValue = 100;
```

#### `library_names` / `library_prefixes`
**¿Qué hace?** Nombres de librerías y prefijos deben seguir convenciones.

---

## 📱 Flutter Específico

#### `avoid_unnecessary_containers`
**¿Qué hace?** Evita `Container` cuando otro widget es más apropiado.
```dart
// ❌ Malo - Container innecesario
return Container(
  child: Text('Hola'),
);

// ✅ Bueno
return Text('Hola');

// Pero está bien si Container tiene propósito:
return Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(color: Colors.blue),
  child: Text('Hola'),
);
```

#### `sized_box_for_whitespace`
**¿Qué hace?** Usa `SizedBox` en lugar de `Container` solo para espacio.
```dart
// ❌ Malo
return Container(
  width: 10,
  height: 10,
);

// ✅ Bueno
return SizedBox(
  width: 10,
  height: 10,
);
```

#### `use_key_in_widget_constructors`
**¿Qué hace?** Permite pasar `Key` en constructores de widgets.
```dart
// ❌ Malo
class MiWidget extends StatelessWidget {
  MiWidget();
}

// ✅ Bueno
class MiWidget extends StatelessWidget {
  const MiWidget({super.key});
}
```

#### `sort_child_properties_last`
**¿Qué hace?** Propiedades `child` y `children` deben ir al final.
```dart
// ❌ Malo
Container(
  child: Text('Hola'),
  padding: EdgeInsets.all(8),
  color: Colors.blue,
);

// ✅ Bueno
Container(
  padding: EdgeInsets.all(8),
  color: Colors.blue,
  child: Text('Hola'),
);
```

#### `use_full_hex_values_for_flutter_colors`
**¿Qué hace?** Usa valores hex completos (6 u 8 dígitos) para colores.
```dart
// ❌ Malo
Color(0x00F); // Ambiguo

// ✅ Bueno
Color(0xFF0000FF); // 8 dígitos (AARRGGBB)
Color(0x0000FF);   // 6 dígitos (RRGGBB)
```

---

## 🔧 Mantenibilidad Básica

#### `annotate_overrides`
**¿Qué hace?** Usa `@override` cuando sobrescribes métodos.
```dart
class Hijo extends Padre {
  // ❌ Malo - falta @override
  void metodo() { }
  
  // ✅ Bueno
  @override
  void metodo() { }
}
```

#### `avoid_null_checks_in_equality_operators`
**¿Qué hace?** No necesitas verificar `null` en `==` (Dart lo hace automáticamente).
```dart
// ❌ Malo - redundante
@override
bool operator ==(Object other) {
  if (other == null) return false; // Innecesario
  return other is MiClase && ...;
}

// ✅ Bueno
@override
bool operator ==(Object other) {
  return other is MiClase && ...;
}
```

#### `avoid_shadowing_type_parameters`
**¿Qué hace?** No reutilices nombres de parámetros de tipo.
```dart
// ❌ Malo
class Contenedor<T> {
  void procesar<T>(T valor) { } // T sombrea el T de la clase
}

// ✅ Bueno
class Contenedor<T> {
  void procesar<U>(U valor) { }
}
```

#### `curly_braces_in_flow_control_structures`
**¿Qué hace?** Siempre usa llaves `{}` en if/for/while.
```dart
// ❌ Malo
if (condicion)
  hacerAlgo();

// ✅ Bueno
if (condicion) {
  hacerAlgo();
}
```

#### `empty_constructor_bodies`
**¿Qué hace?** Constructores vacíos deben ser `{}` en lugar de `{ }`.
```dart
// ❌ Malo
MiClase() { }

// ✅ Bueno
MiClase();
```

#### `prefer_collection_literals`
**¿Qué hace?** Usa literales `[]` y `{}` en lugar de constructores.
```dart
// ❌ Malo
var lista = List();
var mapa = Map();

// ✅ Bueno
var lista = [];
var mapa = {};
```

#### `prefer_conditional_assignment`
**¿Qué hace?** Usa `??=` para asignación condicional.
```dart
// ❌ Malo
if (nombre == null) {
  nombre = 'sin nombre';
}

// ✅ Bueno
nombre ??= 'sin nombre';
```

#### `prefer_const_constructors`
**¿Qué hace?** Usa `const` cuando sea posible para mejorar rendimiento.
```dart
// ❌ Malo
return Text('Hola');

// ✅ Bueno
return const Text('Hola');
```

#### `prefer_const_constructors_in_immutables`
**¿Qué hace?** Clases inmutables deben tener constructor `const`.
```dart
// ❌ Malo
class Punto {
  final int x, y;
  Punto(this.x, this.y);
}

// ✅ Bueno
class Punto {
  final int x, y;
  const Punto(this.x, this.y);
}
```

#### `prefer_const_declarations`
**¿Qué hace?** Usa `const` en lugar de `final` para valores constantes.
```dart
// ❌ Malo
final pi = 3.14159;

// ✅ Bueno
const pi = 3.14159;
```

#### `prefer_final_fields`
**¿Qué hace?** Marca campos como `final` si no cambian.
```dart
// ❌ Malo
class Usuario {
  String _nombre; // Nunca cambia después de asignación
  Usuario(this._nombre);
}

// ✅ Bueno
class Usuario {
  final String _nombre;
  Usuario(this._nombre);
}
```

#### `prefer_if_null_operators`
**¿Qué hace?** Usa `??` en lugar de verificaciones explícitas.
```dart
// ❌ Malo
String nombre = usuario != null ? usuario : 'invitado';

// ✅ Bueno
String nombre = usuario ?? 'invitado';
```

#### `prefer_null_aware_operators`
**¿Qué hace?** Usa `?.` para acceso seguro a propiedades.
```dart
// ❌ Malo
String? nombre = usuario != null ? usuario.nombre : null;

// ✅ Bueno
String? nombre = usuario?.nombre;
```

#### `unnecessary_null_in_if_null_operators`
**¿Qué hace?** No uses `?? null` (es redundante).
```dart
// ❌ Malo
String? nombre = usuario.nombre ?? null;

// ✅ Bueno
String? nombre = usuario.nombre;
```

#### `unnecessary_this`
**¿Qué hace?** No uses `this.` a menos que sea necesario.
```dart
// ❌ Malo (si no hay conflicto de nombres)
class Usuario {
  String nombre;
  void saludar() {
    print(this.nombre); // this. innecesario
  }
}

// ✅ Bueno
class Usuario {
  String nombre;
  void saludar() {
    print(nombre);
  }
}
```

#### `use_super_parameters`
**¿Qué hace?** Usa `super.parametro` en constructores (Dart 2.17+).
```dart
// ❌ Malo (estilo antiguo)
class Hijo extends Padre {
  Hijo(String nombre) : super(nombre);
}

// ✅ Bueno (estilo moderno)
class Hijo extends Padre {
  Hijo(super.nombre);
}
```

---

## 🧹 Limpieza de Código

#### `unnecessary_brace_in_string_interps`
**¿Qué hace?** No uses `${}` para variables simples.
```dart
// ❌ Malo
String saludo = 'Hola ${nombre}';

// ✅ Bueno
String saludo = 'Hola $nombre';

// Pero usa {} para expresiones:
String saludo = 'Hola ${nombre.toUpperCase()}';
```

#### `unnecessary_const` / `unnecessary_new`
**¿Qué hace?** No uses `const` o `new` redundantes.
```dart
// ❌ Malo
const widget = const Text('Hola');
var lista = new List();

// ✅ Bueno
const widget = Text('Hola');
var lista = List();
```

#### `unnecessary_null_aware_assignments`
**¿Qué hace?** No uses `??=` si ya sabes que no es null.
```dart
// ❌ Malo
String nombre = 'Juan';
nombre ??= 'Pedro'; // Siempre será Juan

// ✅ Bueno
String? nombre;
nombre ??= 'Pedro'; // Solo si es null
```

#### `unnecessary_overrides`
**¿Qué hace?** No sobrescribas métodos si solo llamas a `super`.
```dart
// ❌ Malo
@override
void metodo() {
  super.metodo(); // Solo llama a super, innecesario
}

// ✅ Bueno - eliminar el método
```

#### `unnecessary_parenthesis`
**¿Qué hace?** Evita paréntesis innecesarios.
```dart
// ❌ Malo
if ((a > b)) { }
return (valor + 10);

// ✅ Bueno
if (a > b) { }
return valor + 10;
```

#### `unnecessary_statements`
**¿Qué hace?** Evita statements que no hacen nada.
```dart
// ❌ Malo
void procesar() {
  42; // Statement sin efecto
}
```

---

## ⚡ Rendimiento

#### `prefer_const_literals_to_create_immutables`
**¿Qué hace?** Usa `const` para listas/mapas inmutables.
```dart
// ❌ Malo
final colores = [Colors.red, Colors.blue];

// ✅ Bueno
const colores = [Colors.red, Colors.blue];
```

#### `prefer_spread_collections`
**¿Qué hace?** Usa spread operator `...` en lugar de `.addAll()`.
```dart
// ❌ Malo
var lista = [1, 2];
lista.addAll([3, 4]);

// ✅ Bueno
var lista = [1, 2, ...[3, 4]];
```

#### `prefer_inlined_adds`
**¿Qué hace?** Agregar elementos durante la creación de la lista.
```dart
// ❌ Malo
var lista = <int>[];
lista.add(1);
lista.add(2);

// ✅ Bueno
var lista = [1, 2];
```

---

## 🚫 Reglas Deshabilitadas

El archivo NO incluye estas reglas para mayor flexibilidad:

- **`prefer_single_quotes`**: Permite usar comillas dobles (`"`) o simples (`'`)
- **`lines_longer_than_80_chars`**: Permite líneas más largas de 80 caracteres
- **`prefer_expression_function_bodies`**: Permite ambos estilos de funciones
- **`sort_constructors_first`**: No fuerza orden estricto de constructores
- **`require_trailing_commas`**: No requiere comas finales
- **`directives_ordering`**: No fuerza orden específico de imports
- **`omit_local_variable_types`**: Permite tipos explícitos en variables

---

## 📊 Resumen de Severidades

| Nivel | Qué significa | Ejemplos |
|-------|---------------|----------|
| **error** | Bloqueará la compilación | `missing_required_param`, `avoid_print`, `missing_return` |
| **warning** | Advertencia importante | `deprecated_member_use`, `dead_code`, `unused_import` |
| **info** | Información, no bloquea | `unused_local_variable`, `unused_element` |
| **ignore** | Se ignora completamente | `todo`, `invalid_annotation_target` |

---

## 🎯 Comandos Útiles

```bash
# Analizar el proyecto
flutter analyze

# Aplicar correcciones automáticas
dart fix --apply

# Ver qué se puede corregir sin aplicar
dart fix --dry-run

# Analizar archivo específico
flutter analyze lib/main.dart
```

---

## 📚 Recursos Adicionales

- [Dart Lints](https://dart.dev/lints)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**Última actualización:** Noviembre 2025
