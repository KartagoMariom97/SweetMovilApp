# Sweet Mobile App

Frontend móvil del marketplace **Sweet** — conecta clientes con jornalistas del servicio verificados, poniendo la confianza en el centro de cada pantalla.

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.22+ (Dart) — iOS & Android |
| Estado | Riverpod 2.x |
| Navegación | GoRouter 14 — guards por rol |
| HTTP | Dio 5 — interceptor JWT + refresh silencioso |
| WebSocket | web_socket_channel — chat en tiempo real |
| Storage seguro | flutter_secure_storage — tokens JWT |
| Storage local | shared_preferences — configuraciones |
| UI | Material 3 + Sweet Design System (dark) |
| Animaciones | flutter_animate |

---

## Requisitos previos

- Flutter SDK >= 3.22 ([flutter.dev/docs/get-started](https://flutter.dev/docs/get-started))
- Dart SDK >= 3.2 (incluido con Flutter)
- Android Studio / Xcode (para emuladores)
- sweet-api corriendo en local (ver [../sweet-api/README.md](../sweet-api/README.md))

---

## Setup local

### 1. Crear proyecto Flutter + instalar dependencias

```bash
# Abrir terminal en esta carpeta
cd "D:\PROYECTO SWEET\sweet-mobile-app"

# Genera android/, ios/, web/ preservando lib/ ya existente
flutter create . --org com.sweetapp --project-name sweet_mobile_app

# Instalar dependencias
flutter pub get
```

### 2. Configurar el backend

Por defecto la app apunta a `http://10.0.2.2:3000/api/v1` (emulador Android → localhost).

Para dispositivo físico o iOS, editar `lib/core/config/app_config.dart`:

```dart
// development — iOS Simulator
return 'http://localhost:3000/api/v1';

// development — dispositivo físico
return 'http://192.168.X.X:3000/api/v1'; // IP local de tu máquina
```

### 3. Correr la app

```bash
# Listar dispositivos disponibles
flutter devices

# Correr en emulador/dispositivo
flutter run

# Correr especificando dispositivo
flutter run -d emulator-5554

# Correr en modo release (sin hot-reload)
flutter run --release
```

---

## Ambientes

El ambiente se controla con `--dart-define` en tiempo de compilación:

| Ambiente | Comando | API URL |
|----------|---------|---------|
| Development | `flutter run` | `http://10.0.2.2:3000/api/v1` |
| Staging | `flutter run --dart-define=ENV=staging` | `https://staging-api.sweetapp.com/api/v1` |
| Production | `flutter build apk --dart-define=ENV=production` | `https://api.sweetapp.com/api/v1` |

---

## Scripts disponibles

| Comando | Descripción |
|---------|-------------|
| `flutter run` | Correr en modo debug |
| `flutter run --release` | Correr en modo release |
| `flutter build apk` | Compilar APK Android |
| `flutter build ios` | Compilar iOS (requiere Mac) |
| `flutter pub get` | Instalar dependencias |
| `flutter pub run build_runner build` | Generar código (freezed, json_serializable, riverpod_generator) |
| `flutter pub run build_runner watch` | Generación de código en modo watch |
| `flutter analyze` | Análisis estático |
| `flutter test` | Tests unitarios y de widget |
| `flutter test --coverage` | Tests con cobertura |

---

## Estructura del proyecto

```
lib/
├── main.dart                      # Bootstrap — ProviderScope, SharedPreferences, SystemUI
├── app.dart                       # MaterialApp.router + SweetTheme
│
├── core/
│   ├── config/
│   │   └── app_config.dart        # URLs por ambiente, timeouts
│   ├── di/
│   │   └── providers.dart         # Providers globales — DioClient, Storage, AuthState
│   ├── error/
│   │   └── failures.dart          # Sealed class: NetworkFailure, AuthFailure, ServerFailure...
│   ├── network/
│   │   ├── dio_client.dart        # Dio con helpers get/post/patch/delete + mapeo de errores
│   │   └── auth_interceptor.dart  # JWT auto-inject + refresh silencioso en 401
│   ├── router/
│   │   ├── app_router.dart        # GoRouter — guards por auth + bifurcación por rol
│   │   └── route_names.dart       # Constantes de paths y nombres de rutas
│   ├── storage/
│   │   ├── secure_storage.dart    # flutter_secure_storage — access/refresh token
│   │   └── local_storage.dart     # shared_preferences — onboarding, locale
│   └── theme/
│       ├── app_colors.dart        # Design tokens Sweet (dark palette)
│       └── app_theme.dart         # ThemeData Material 3 completo
│
├── features/
│   ├── auth/                      # Login, Register, Splash, Onboarding
│   │   ├── data/
│   │   │   ├── datasources/       # AuthRemoteDataSource — llamadas API
│   │   │   ├── models/            # AuthResponseModel — mapeo JSON → entidad
│   │   │   └── repositories/      # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          # AuthUser — entidad de dominio
│   │   │   └── repositories/      # AuthRepository — interfaz (contrato)
│   │   └── presentation/
│   │       ├── pages/             # SplashPage, OnboardingPage, LoginPage, RegisterPage
│   │       ├── providers/         # AuthNotifier + authNotifierProvider
│   │       └── widgets/           # AuthTextField
│   ├── home/                      # Home del cliente — cards jornalistas
│   ├── search/                    # Búsqueda por chips de categoría
│   ├── bookings/                  # Reservas — lista + detalle + estado coloreado
│   ├── chat/                      # Chat WebSocket + filtro de datos de contacto
│   ├── provider_profile/          # Perfil público del jornalista
│   ├── provider_dashboard/        # Dashboard, Servicios, Solicitudes (PROVIDER)
│   ├── notifications/             # Alertas del sistema
│   └── profile/                   # Perfil propio — editar datos
│
└── shared/
    ├── extensions/
    │   └── context_extensions.dart  # BuildContext.theme, .colors, .showSnack
    ├── utils/
    │   └── validators.dart          # AppValidators — email, password, phone
    └── widgets/
        ├── main_shell.dart          # BottomNavigationBar por rol (CLIENT / PROVIDER)
        ├── sweet_button.dart        # Primary, Secondary, Outlined, Ghost
        ├── sweet_card.dart          # Card con Sweet styling + ripple
        └── sweet_avatar.dart        # Avatar circular con fallback de iniciales + badge online
```

---

## Arquitectura por feature (Clean Architecture)

Cada feature sigue tres capas independientes:

```
feature/
├── data/           → Implementaciones concretas: API, modelos JSON, repositorios
├── domain/         → Lógica pura: entidades, interfaces, casos de uso
└── presentation/   → UI: pages, widgets, providers Riverpod
```

**Regla:** los widgets nunca llaman directo a la API. Todo pasa por un `Notifier` de Riverpod que usa el repositorio del dominio.

---

## Design System — Sweet Dark Theme

| Token | Color | Uso |
|-------|-------|-----|
| `primary` | `#7C3AED` | Botones, seleccionado, focus |
| `secondary` | `#4A9EED` | Acciones secundarias, links |
| `success` | `#15803D` | Reserva completada, verificado |
| `warning` | `#F59E0B` | Reserva pendiente, badge |
| `error` | `#EF4444` | Errores, reportes, disputas |
| `surface` | `#1A1A2E` | Fondo de tarjetas y sheets |
| `background` | `#0D0D1A` | Fondo base de la app |
| `onSurface` | `#E5E5E5` | Texto primario |
| `onSurfaceVariant` | `#A0A0A0` | Texto secundario, placeholders |

---

## Flujos y navegación

### Router — bifurcación por rol

```
/ (Splash) → revisa token en SecureStorage
    ├── Token válido → rol CLIENT  → /home  (ShellRoute con BottomNav)
    ├── Token válido → rol PROVIDER → /provider-home  (ShellRoute con BottomNav)
    └── Sin token → /onboarding → /login
```

### Tabs por rol

**Cliente:**
`Inicio` · `Buscar` · `Reservas` · `Alertas` · `Perfil`

**Jornalista:**
`Dashboard` · `Solicitudes` · `Servicios` · `Chat` · `Perfil`

---

## Auth — funcionamiento

1. `LoginPage` / `RegisterPage` llaman a `AuthNotifier`
2. `AuthNotifier` usa `AuthRepository` → `AuthRemoteDataSource` → `DioClient`
3. En éxito: tokens se guardan en `flutter_secure_storage`, `AuthState.setLoggedIn()` notifica a GoRouter
4. GoRouter detecta el cambio vía `refreshListenable` y redirige automáticamente
5. En cada request, `AuthInterceptor` agrega el Bearer token
6. Si el servidor retorna 401, el interceptor intenta renovar el token silenciosamente con el refresh token
7. Si el refresh falla, limpia la sesión y GoRouter redirige al login

---

## Estados de reserva

| Estado | Color | Significado |
|--------|-------|-------------|
| `PENDING` | Amber | Esperando confirmación del jornalista |
| `CONFIRMED` | Azul | Jornalista aceptó — cita agendada |
| `IN_PROGRESS` | Violeta | Servicio en curso |
| `COMPLETED` | Verde | Servicio finalizado — habilita reseña |
| `CANCELLED` | Gris | Cancelado por cualquiera de las partes |
| `DISPUTED` | Rojo | En revisión por el equipo Sweet |

---

## Seguridad

- Tokens JWT almacenados en **flutter_secure_storage** (Keychain iOS / EncryptedSharedPreferences Android)
- Refresh token silencioso — el usuario nunca ve un error de sesión si el refresh es exitoso
- Compilación con `--obfuscate` en release para ofuscación de código
- Sin logs de datos sensibles en ningún entorno

---

## Roadmap de fases

| Fase | Estado | Descripción |
|------|--------|-------------|
| 10 | ✅ Completada | Setup Flutter — core, theme, router, DI, design system |
| 11 | ✅ Completada | Auth feature — Login, Register, AuthNotifier, Clean Architecture |
| 12 | ✅ Completada | Flujo cliente — Home, Búsqueda, Perfil jornalista, Reserva, Chat WebSocket |
| 13 | Pendiente | Flujo jornalista — Dashboard, Servicios, Solicitudes, Chat |
| 14 | Pendiente | Admin panel (web) |
| 15 | Pendiente | Integration & QA |
