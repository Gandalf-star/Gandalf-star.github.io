# Solución Robusta para Rastreo SOS en Segundo Plano (Pantalla bloqueada)

El comportamiento de los sistemas operativos móviles (Android/iOS) es detener las tareas en segundo plano cuando la pantalla se bloquea para ahorrar batería. Esto provoca que el rastreo de ubicación en tiempo real deje de enviar las coordenadas a Firebase, congelando el marcador en el panel de administrador.

Para evitar esto y lograr un seguimiento continuo garantizado durante una emergencia, debes implementar **Servicios en Primer Plano** (Foreground Services) en tus apps móviles (Pasajero y Conductor).

Aquí tienes los pasos exactos para implementar esta solución en tus aplicaciones móviles:

## 1. Actualizar Dependencias

Asegúrate de utilizar paquetes que soporten ejecución en background, o combina `geolocator` con `flutter_foreground_task`:

```yaml
dependencies:
  geolocator: ^13.0.0
  flutter_foreground_task: ^6.1.1
```

## 2. Configurar Permisos Nativos en Android

Edita el archivo `android/app/src/main/AndroidManifest.xml` de las apps de pasajeros y conductores para incluir los permisos de ubicación en background y el servicio:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos normales -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Permiso crítico para pantalla bloqueada/background -->
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

    <application ...>
        <!-- Declarar el servicio en primer plano -->
        <service
            android:name="com.pravera.flutter_foreground_task.services.ForegroundService"
            android:foregroundServiceType="location"
            android:exported="false" />
    ...
```

## 3. Configurar Permisos en iOS

Edita el archivo `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>La app necesita ubicación para calcular la ruta.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesaria para enviar tu ubicación crítica en un SOS de emergencia.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necesaria para seguimiento continuo en SOS.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
</array>
```

## 4. Iniciar la transmisión SOS a Firebase (Lógica de la App Móvil)

Cuando el usuario pulse el botón **SOS**, debes activar la configuración del servicio foreground. Esto generará una notificación silenciosa en el móvil que mantendrá el rastreo vivo incluso con la pantalla apagada.

Ejemplo simplificado utilizando `geolocator`:

```dart
Future<void> activarSOS() async {
  // 1. Pedir permisos
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
     permission = await Geolocator.requestPermission();
  }
  
  if (permission == LocationPermission.whileInUse) {
    // Es recomendable pedir 'always' para emergencias
  }

  // 2. Configurar la notificación para el foreground service
  late LocationSettings locationSettings;
  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 5),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Tu ubicación está siendo monitoreada por emergencia.",
        notificationTitle: "Monitoreo SOS Activo",
        enableWakeLock: true, // ¡CRÍTICO PARA PANTALLA BLOQUEADA!
      ),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.automotiveNavigation,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false, // CRÍTICO
      showBackgroundLocationIndicator: true, // CRÍTICO
    );
  }

  // 3. Empezar a escuchar y subir a Firebase
  StreamSubscription posStream = Geolocator.getPositionStream(
    locationSettings: locationSettings
  ).listen((Position position) {
    
    // Aquí actualizas a Firebase, lo que actualizará el panel admin en tiempo real
    FirebaseDatabase.instance.ref()
      .child('alertas_emergencia')
      .child(idAlertaActual)
      .update({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'ultimo_actualizado': ServerValue.timestamp, // MUY IMPORTANTE
      });
  });
}
```

## 5. Prevención en tu Panel Admin

He añadido el botón de **"Cancelar / Resolver Alerta"** en el panel lateral de detalles de alerta que solicitaste.

Para prevenir malentendidos con ubicaciones "congeladas", deberías asegurarte que en la app móvil se incluya siempre el `ultimo_actualizado`, de esta forma en el Panel podemos poner si la ubicación tiene un "*retraso de hace X minutos*".
