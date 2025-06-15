# CodeLeak 🎮

**Un viaje a través de la historia de los videojuegos**

[![Processing](https://img.shields.io/badge/Processing-3.x-blue.svg)](https://processing.org/)
[![License](https://img.shields.io/badge/License-Academic%20Use%20Only-red.svg)](#licencia)
[![UOC](https://img.shields.io/badge/UOC-Programación%20Creativa-orange.svg)](https://www.uoc.edu/)

## 📋 Descripción

CodeLeak es un videojuego desarrollado como proyecto académico que rinde homenaje a la evolución de los videojuegos a través de tres eras distintas. El jugador experimenta diferentes mecánicas de juego que representan la progresión tecnológica desde los 8 bits hasta los primeros juegos 3D.

### 🎯 Concepto del Juego

El objetivo principal es **reparar grietas en el sistema** utilizando bombas especializadas mientras se evitan enemigos que intentan reabrir las grietas reparadas. Cada nivel presenta:

- **Nivel 1 (8-bit)**: Vista cenital estilo MSX/Spectrum con física básica
- **Nivel 2 (16-bit)**: Plataformas 2D con gravedad y salto
- **Nivel 3 (3D)**: Primera persona estilo Doom con raycasting

## 🎓 Contexto Académico

Este proyecto forma parte de la **Prueba de Evaluación Continua (PEC)** de la asignatura **Programación Creativa** del **Grado en Técnicas de Interacción Digital y Multimedia** de la **Universitat Oberta de Catalunya (UOC)**.

**Autor:** Jordi Hernández Vinyals  
**Asignatura:** Programación Creativa - PR  
**Institución:** Universitat Oberta de Catalunya (UOC)  
**Grado:** Técnicas de Interacción Digital y Multimedia

## 🚀 Características Principales

### 🎮 Mecánicas de Juego

- **Sistema de bombas dual**: Bombas de reparación (Z) y bombas destructoras (X)
- **Enemigos inteligentes**: Diferentes tipos de IA según el nivel
- **Sistema de salud**: Gestión de vida del jugador
- **Efectos visuales**: Partículas, ondas expansivas y efectos de pantalla
- **Sistema de ranking**: Tabla de mejores tiempos con persistencia

### 🏗️ Arquitectura Técnica

- **Patrón Strategy**: Diferentes tipos de jugador por nivel
- **Patrón Observer**: Comunicación entre entidades del juego
- **Patrón Singleton**: Gestión de audio, ranking y cronómetro
- **Patrón Factory**: Creación dinámica de sprites y entidades
- **Máquina de Estados**: Control de flujo del juego

### 🎵 Sistema Multimedia

- **Audio dinámico**: Música y efectos de sonido contextuales
- **Sprites animados**: Animaciones fluidas para personajes y efectos
- **Fuente pixel art**: Tipografía retro (PressStart2P)
- **Efectos visuales**: Glitch, shake y filtros de pantalla

## 🎯 Controles

### Controles Básicos

- **Flechas de dirección**: Movimiento del personaje
- **Z (Zip)**: Colocar bomba de reparación
- **X (eXplosion)**: Colocar bomba destructora
- **Espacio**: Avanzar en menús, cinemáticas y disparo en nivel 3
- **R**: Ver ranking desde el menú principal

### Controles Específicos por Nivel

#### Nivel 2 (Plataformas)

- **W / Flecha Arriba**: Saltar
- **A/D**: Movimiento horizontal alternativo

#### Nivel 3 (3D)

- **W/S**: Avanzar/Retroceder
- **A/D**: Rotar izquierda/derecha
- **Espacio**: Disparar proyectiles

### Atajos de Desarrollo

- **1-4**: Saltar directamente a niveles específicos (modo debug)

## 🛠️ Requisitos del Sistema

### Software Necesario

- **Processing 3.x** o superior
- **Minim Library** (para audio)
- **Java 8** o superior

### Especificaciones Mínimas

- **Resolución**: 1008x720 píxeles
- **RAM**: 512 MB disponibles
- **Almacenamiento**: 50 MB para assets
- **Audio**: Tarjeta de sonido compatible

## 📦 Instalación y Ejecución

### 1. Preparar el Entorno

```bash
# Descargar e instalar Processing desde:
# https://processing.org/download/

# Instalar la librería Minim:
# Tools > Manage Tools > Libraries > Buscar "Minim" > Install
```

### 2. Ejecutar el Juego

```bash
# Abrir Processing IDE
# File > Open > Seleccionar CodeLeak.pde
# Presionar el botón Play (▶) o Ctrl+R
```

### 3. Estructura de Archivos

```
CodeLeak/
├── CodeLeak.pde          # Archivo principal
├── *.pde                 # Módulos del juego
├── data/                 # Assets del juego
│   ├── img/             # Imágenes de pantallas
│   ├── music/           # Pistas de audio
│   ├── sfx/             # Efectos de sonido
│   ├── sprites/         # Sprites por nivel
│   └── PressStart2P.ttf # Fuente pixel art
└── DOCS/                # Documentación técnica
```

## 🎮 Cómo Jugar

### Objetivo Principal

Repara todas las **grietas del sistema** (marcadas en rojo) usando **bombas de reparación** mientras evitas que los enemigos las reabran.

### Estrategia Básica

1. **Explora** el nivel para localizar todas las grietas
2. **Coloca bombas de reparación** (Z) sobre las grietas
3. **Evita o elimina enemigos** que intentan reabrir grietas reparadas
4. **Usa bombas destructoras** (X) para crear nuevos caminos o eliminar enemigos
5. **Gestiona tu salud** evitando el contacto con enemigos

### Mecánicas Avanzadas

- **Tiles de reconfiguración** (Nivel 1): Reorganizan el mapa dinámicamente
- **Coleccionables**: Proporcionan bombas adicionales o restauran salud
- **Sistema de pánico**: Los enemigos se vuelven más agresivos tras reparaciones
- **Efectos de área**: Las bombas destructoras afectan un radio determinado

## 🏆 Sistema de Puntuación

El juego registra el **tiempo total** para completar los tres niveles:

- **Ranking persistente**: Los mejores tiempos se guardan automáticamente
- **Entrada de iniciales**: Para nuevos récords
- **Formato de tiempo**: MM:SS.CC (minutos:segundos.centésimas)

## 🔧 Arquitectura del Código

### Patrones de Diseño Implementados

#### Patrones de Creación

- **Singleton**: `AudioManager`, `RankingSystem`, `Timer`
- **Factory**: Creación de sprites, enemigos y efectos
- **Builder**: Configuración compleja de niveles y efectos

#### Patrones de Comportamiento

- **Strategy**: `TopDownPlayer`, `PlatformPlayer`, `RaycastPlayer`
- **Observer**: Sistema de eventos entre entidades
- **Command**: Gestión de input y acciones del jugador
- **State Machine**: Control de estados del juego

#### Patrones Estructurales

- **Adapter**: Compatibilidad entre diferentes sistemas de input
- **Facade**: Simplificación de sistemas complejos (Audio, Sprites)
- **Composite**: Gestión jerárquica de entidades del juego

### Estructura Modular

```
Managers/     # Gestores de nivel específicos
Players/      # Tipos de jugador (Strategy Pattern)
Entities/     # Enemigos, bombas, coleccionables
Systems/      # Audio, ranking, cronómetro (Singletons)
Utils/        # Utilidades y helpers
```

## 🐛 Problemas Conocidos

Como se menciona en el código fuente, este proyecto tiene limitaciones de tiempo que han resultado en algunos bugs conocidos:

- **Colisiones**: Ocasionalmente imprecisas en bordes de tiles
- **Audio**: Posibles fallos de carga en algunos sistemas
- **Rendimiento**: Puede experimentar drops de FPS con muchas partículas
- **Estados**: Transiciones de estado ocasionalmente inconsistentes
  
  

## 

## 📄 Licencia

### Licencia Académica Restrictiva

**Copyright © 2024 Jordi Hernández Vinyals - Universitat Oberta de Catalunya (UOC)**

Este proyecto está protegido por derechos de autor y se distribuye exclusivamente para **fines académicos y educativos**.

#### Permisos Otorgados:

- ✅ **Visualización** del código fuente para estudio
- ✅ **Ejecución** del software para evaluación académica
- ✅ **Análisis** de la arquitectura y patrones implementados
- ✅ **Referencia** en trabajos académicos (con cita apropiada)

#### Restricciones:

- ❌ **Uso comercial** de cualquier tipo
- ❌ **Redistribución** sin autorización expresa
- ❌ **Modificación** para otros proyectos académicos
- ❌ **Copia** de código para otros trabajos estudiantiles
- ❌ **Publicación** en repositorios públicos sin permiso

#### Cláusula de Integridad Académica:

Este proyecto fue desarrollado como parte de la evaluación académica de la UOC. Cualquier uso que viole las políticas de integridad académica está estrictamente prohibido.

**Para consultas sobre permisos adicionales, contactar a la institución académica correspondiente.**

---

## 🎯 Objetivos de Aprendizaje Cumplidos

Este proyecto demuestra competencias en:

### Programación Orientada a Objetos

- ✅ Herencia y polimorfismo
- ✅ Encapsulación y abstracción
- ✅ Composición y agregación

### Patrones de Diseño

- ✅ Implementación de múltiples patrones 
- ✅ Arquitectura modular y extensible
- ✅ Separación de responsabilidades

### Desarrollo de Videojuegos

- ✅ Game loops y estados
- ✅ Sistemas de física básicos
- ✅ Gestión de recursos multimedia
- ✅ Interfaces de usuario interactivas

### Programación Creativa

- ✅ Uso avanzado de Processing
- ✅ Integración de multimedia
- ✅ Efectos visuales y sonoros
- ✅ Experiencia de usuario cohesiva

---

**Desarrollado con ❤️ para la comunidad académica de la UOC**

*"Un homenaje a la historia de los videojuegos, desde los 8 bits hasta el 3D"*