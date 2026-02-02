# Documentación del Proyecto - Trapito Simulator

## 1. Introducción

Este documento detalla la arquitectura y el funcionamiento interno del código del videojuego. Está diseñado para que nuevos desarrolladores puedan entender rápidamente la estructura del proyecto, los sistemas clave y cómo interactúan entre sí.

El juego es un simulador donde el jugador, un "trapito", gestiona un área de estacionamiento. El objetivo es atender a los clientes (autos), completar minijuegos para ellos y ganar dinero, mientras se gestionan estadísticas como la estamina y el carisma.

---

## 2. Estructura del Proyecto

El proyecto se organiza en las siguientes carpetas principales:

- **/assets**: Contiene todos los recursos artísticos, como texturas, personajes, fuentes y sonidos.
- **/economy**: Scripts relacionados con la gestión del dinero.
- **/minigames**: Escenas y scripts para cada uno de los minijuegos (Limpieza, Estacionamiento, etc.).
- **/resources**: Recursos de Godot (`.tres`), como tipos de autos y máscaras.
- **/scenes**: Escenas principales del juego (actualmente, la mayoría están en la raíz).
- **/systems**: Scripts de sistemas globales, como el guardado, menú principal y gestión de máscaras.
- **/time**: Scripts relacionados con el manejo del tiempo y el ciclo día/noche.
- **/UI**: Recursos y escenas relacionadas con la interfaz de usuario.

---

## 3. Sistemas Principales (Singletons/Autoloads)

Estos scripts están configurados como "autoload" en Godot, lo que significa que una única instancia de cada uno está disponible globalmente en todo momento. Son el núcleo de la gestión del estado del juego.

### `StatsManager.gd`
Gestiona las estadísticas vitales del jugador.

- **Atributos Clave:**
  - `vida`, `estamina`, `carisma`: Valores actuales del jugador.
  - `vida_max`, `estamina_max`, `carisma_max`: Valores máximos para las estadísticas.

- **Funcionalidad:**
  - `iniciar_stats()`: Se llama al comenzar una nueva partida. Inicializa la vida y la estamina a su máximo, y el **carisma a 50**.
  - `iniciar_dia()`: Se llama al comienzo de cada día. **Regenera la estamina** al máximo. La vida y el carisma persisten.
  - Ofrece funciones para modificar las estadísticas, como `perder_vida()`, `gastar_estamina()`, `ganar_carisma()`, etc. Estas deben ser llamadas por otros sistemas (el jugador, minijuegos) para afectar al estado.

### `DayManager.gd`
Controla el ciclo de día y noche, y el progreso del tiempo en el juego.

- **Atributos Clave:**
  - `dia_actual`, `hora_actual`: Llevan la cuenta del día y la hora.
  - `duracion_dia_real`: Variable (en segundos) que define cuánto dura un día completo en el juego.
  - `dia_activo`: Un booleano que indica si el ciclo del día está en progreso.

- **Funcionalidad:**
  - `_ready()`: Llama a `iniciar_dia()` para empezar el primer día.
  - `iniciar_dia()`: Resetea la hora, activa el día y llama a las funciones correspondientes en `StatsManager` y `MoneyManager`.
  - `finalizar_dia()`: Se activa cuando `hora_actual` llega al final. Emite la señal `dia_finalizado` a la que otros nodos (como la UI de fin de día) pueden reaccionar.
  - `_process()`: Avanza el tiempo del juego (`hora_actual`) basado en el tiempo real transcurrido (`delta`).

### `MoneyManager.gd`
Maneja toda la lógica económica del juego.

- **Atributos Clave:**
  - `dinero_total`: El dinero total que posee el jugador. Persiste entre días.
  - `dinero_del_dia`: Dinero ganado durante la jornada actual. Se resetea cada día.

- **Funcionalidad:**
  - `iniciar_dia()`: Resetea `dinero_del_dia` a cero.
  - `agregar_dinero(monto)`: Añade dinero tanto al total como al del día.
  - `gastar_dinero(monto)`: Intenta restar dinero del `dinero_total`. Devuelve `true` si la transacción es exitosa y `false` si no hay fondos suficientes.

### `SaveManager.gd`
Gestiona el guardado y la carga del progreso del juego.

- **Funcionalidad:**
  - `guardar()`: Recopila datos clave de otros managers (`DayManager`, `MoneyManager`, `MaskManager`) y los guarda en un archivo JSON en `user://savegame.json`.
  - `cargar()`: Lee el archivo JSON y restaura el estado del juego, actualizando los valores en los managers correspondientes.
  - `hay_partida()`: Comprueba si el archivo de guardado existe.

### `MaskManager.gd`
Administra la compra, carga y equipamiento de las máscaras que el jugador puede usar.

- **Funcionalidad:**
  - `_ready()`: Carga todas las máscaras disponibles desde los archivos `.tres` definidos en `MASK_PATHS`.
  - `comprar_mascara(mask)`: Procesa la compra de una máscara si el jugador tiene suficiente dinero.
  - `equipar_mascara(mask)`: Asigna una máscara comprada como la activa. También desbloquea el minijuego asociado si lo tiene.
  - `cargar_desde_save(...)`: Restaura las máscaras compradas y equipadas a partir de los datos de una partida guardada.

### `QueueManager.gd`
Organiza los autos que esperan ser atendidos.

- **Funcionalidad:**
  - Gestiona una serie de `slots` (posiciones físicas) donde los autos pueden esperar.
  - `hay_espacio()`: Devuelve `true` si hay menos autos activos que el `max_autos` permitido.
  - `asignar_slot(auto)`: Busca un slot libre y se lo asigna a un auto, diciéndole que se mueva a esa posición.
  - `registrar_auto(auto)` y `remover_auto(auto)`: Llevan la cuenta de los autos activos en la escena.

### `CameraManager.gd`
Un gestor simple para controlar la cámara principal del juego.

- **Funcionalidad:**
  - Permite que una cámara se registre a sí misma (`register_camera`).
  - Proporciona funciones para activar diferentes comportamientos de la cámara (reactiva, de evento, de minijuego), que están implementados en el script de la propia cámara.

### `MiniGameManager.gd`
Lleva un registro de los minijuegos que el jugador ha desbloqueado.

- **Funcionalidad:**
  - `desbloquear(id)`: Añade el ID de un minijuego a la lista `minijuegos_desbloqueados`.
  - `esta_desbloqueado(id)`: Comprueba si un minijuego específico ya ha sido desbloqueado. Es utilizado por `auto.gd` para decidir qué tareas puede solicitar un cliente.

---

## 4. Actores y Escenas Clave

### `player.gd` (El Trapito)
Controla al personaje del jugador.

- **Movimiento:**
  - Se mueve de izquierda a derecha usando `Input.get_axis("left", "right")`.
  - Puede correr si se presiona "run" y hay estamina. Al correr, la estamina disminuye (`_physics_process`).
  - La estamina se regenera automáticamente si el jugador permanece quieto por un tiempo (`tiempo_para_regenerar`).
- **Interacción:**
  - Muestra la máscara equipada (`_process`), obteniendo la información de `MaskManager`.
  - Gestiona las animaciones ("walk", "run", "idle", "pegar").
  - Reproduce sonidos de pasos y golpes.

### `auto.gd` (Los Clientes)
El script más complejo, que define el comportamiento de los autos/clientes.

- **Máquina de Estados:**
  - Funciona con una máquina de estados (`enum Estado`) que define su comportamiento actual: `ESPERANDO`, `LIMPIANDO`, `YENDOSE`, etc.
  - También tiene una `enum Tarea` para definir qué servicio requiere: `LIMPIAR`, `ESTACIONAR`, `MESSI`.
- **Lógica Principal:**
  - Al llegar a un slot, activa un temporizador de `paciencia`. Si la paciencia llega a cero, se va enojado.
  - Muestra un icono sobre el auto indicando la tarea requerida.
  - Si el jugador está cerca (`_on_interaction_area_body_entered`) y presiona "interactuar", se inicia el minijuego correspondiente.
  - `iniciar_limpieza()`, `iniciar_estacionamiento()`, `iniciar_messi_minijuego()`: Pausan el juego principal y añaden la escena del minijuego como un hijo de la escena actual.
  - Se conecta a las señales de "terminado" de los minijuegos para saber el resultado.
  - Si el minijuego es exitoso (`tarea_completada`), el auto entra en estado `ESPERANDO_COBRO`.
  - `cobrar()`: El jugador interactúa de nuevo para recibir el dinero. `MoneyManager.agregar_dinero()` es llamado y se gana un poco de carisma en `StatsManager`. Después, el auto se va.

### `main.gd` (Escena Principal)
Es el nodo raíz de la escena principal del juego.

- **Funcionalidad:**
  - Inicia la música del juego con un fundido de entrada (`fade_in_musica`).
  - Llama a `DayManager.iniciar_dia()` al empezar, lo que pone en marcha todo el ciclo de juego.

---

## 5. Flujo del Juego (Game Flow)

1.  **Inicio y Menú:** El juego comienza en `start_screen.tscn`. Desde aquí, el jugador puede iniciar una nueva partida o cargar una existente (usando `SaveManager`). Esto lleva a la escena principal `main.tscn`.

2.  **Ciclo del Día:**
    - `main.gd` llama a `DayManager.iniciar_dia()`.
    - `DayManager` avanza la hora en su `_process()`. La `day_ui.gd` lee esta hora y la muestra en el reloj.
    - Durante el día, el `spawn_point.gd` (no detallado arriba, pero presente en el proyecto) genera nuevos autos (`auto.gd`).

3.  **Interacción con Autos:**
    - Un auto llega y `QueueManager` le asigna un slot.
    - El auto se mueve a su slot y espera al jugador, mientras su `paciencia` disminuye.
    - El jugador se acerca e interactúa, lo que pausa el juego y lanza un minijuego.

4.  **Minijuegos:**
    - El minijuego se ejecuta. Al finalizar, emite una señal con el resultado (`exito: bool`).
    - `auto.gd` recibe esta señal. Si hubo éxito, espera el cobro. Si no, el auto puede irse o simplemente perder más paciencia.

5.  **Final del Día:**
    - Cuando `DayManager` llega al final del día, emite la señal `dia_finalizado`.
    - La `end_day_ui.gd` (UI de fin de día) se activa, mostrando un resumen de las ganancias (`MoneyManager.dinero_del_dia`).
    - El jugador pasa al siguiente día, y el ciclo se repite. `DayManager` llama a `iniciar_dia()` de nuevo.
