<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Riverpod-00B4D8?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Groq_AI-F55036?style=for-the-badge&logo=openai&logoColor=white" alt="Groq AI"/>
  <img src="https://img.shields.io/badge/Material_3-6B5BFC?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material 3"/>
</p>

# 🚀 RIWI App — Plataforma Educativa Gamificada

**RIWI App** es una aplicación móvil educativa gamificada desarrollada en Flutter, diseñada para potenciar el aprendizaje en tres áreas clave: **Inglés**, **Desarrollo de Software** y **Soft Skills**. Incluye un **Tutor IA** con reconocimiento de voz, un sistema de niveles tipo Duolingo con mapa zigzag, ligas competitivas y tabla de clasificación.

---

## 📑 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Tecnologías](#-tecnologías)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Tracks de Aprendizaje](#-tracks-de-aprendizaje)
- [Tutor IA](#-tutor-ia)
- [Tipos de Ejercicios](#-tipos-de-ejercicios)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Variables de Entorno](#-variables-de-entorno)
- [Equipo](#-equipo)

---

## ✨ Características Principales

| Característica | Descripción |
|---|---|
| 🗺️ **Mapa de niveles** | Mapa zigzag interactivo estilo Duolingo con nodos animados, cofres de recompensa y conectores curvos |
| 🤖 **Tutor IA** | Asistente inteligente con voz: graba audio → transcribe con Whisper → responde con Llama 3 → lee la respuesta con TTS |
| 🎓 **3 Tracks de aprendizaje** | Inglés (A1→B1), Desarrollo de Software y Soft Skills |
| 🏆 **Ligas y Leaderboard** | Sistema de competición social con clasificación y ligas |
| 🌙 **Tema Oscuro/Claro** | Soporte completo de temas con Material 3 |
| 🌐 **Bilingüe** | Interfaz en Español e Inglés |
| 🔥 **Rachas y XP** | Sistema de gamificación con puntos de experiencia y rachas diarias |
| 🎨 **Aurora Borealis UI** | Efectos visuales premium con animaciones de aurora boreal en el Tutor IA |

---

## 🛠 Tecnologías

### Core
| Tecnología | Versión | Uso |
|---|---|---|
| **Flutter** | SDK ^3.11.5 | Framework principal de desarrollo multiplataforma |
| **Dart** | ^3.11.5 | Lenguaje de programación |
| **Material 3** | — | Sistema de diseño moderno con temas dinámicos |

### State Management & Navigation
| Paquete | Versión | Uso |
|---|---|---|
| **flutter_riverpod** | ^2.5.1 | Gestión de estado reactiva e inyección de dependencias |
| **go_router** | ^13.2.0 | Navegación declarativa con rutas anidadas (ShellRoute) |

### Inteligencia Artificial
| Paquete / Servicio | Versión | Uso |
|---|---|---|
| **Groq API** | — | Backend de IA (Whisper + Llama 3) |
| **Whisper Large V3 Turbo** | — | Transcripción de voz a texto (Speech-to-Text) |
| **Llama 3 8B** | — | Modelo de lenguaje para respuestas del Tutor IA |
| **flutter_tts** | ^4.2.5 | Text-to-Speech para lectura de respuestas |
| **record** | ^6.2.0 | Grabación de audio del micrófono |

### Utilidades
| Paquete | Versión | Uso |
|---|---|---|
| **flutter_animate** | ^4.5.0 | Animaciones declarativas y fluidas |
| **http** | ^1.6.0 | Cliente HTTP para llamadas a APIs |
| **path_provider** | ^2.1.5 | Acceso a directorios del sistema |
| **flutter_dotenv** | ^6.0.1 | Gestión de variables de entorno |

---

## 🏗 Arquitectura

El proyecto sigue una **arquitectura modular por features** con separación clara de responsabilidades:

```
┌─────────────────────────────────────────────┐
│                   UI Layer                  │
│         (Screens / Widgets / Painters)      │
├─────────────────────────────────────────────┤
│              State Management               │
│           (Riverpod Providers)              │
├─────────────────────────────────────────────┤
│               Services Layer                │
│         (GroqService / TtsService)          │
├─────────────────────────────────────────────┤
│                Data Layer                   │
│         (Models / Levels / Router)          │
├─────────────────────────────────────────────┤
│              External APIs                  │
│      (Groq Whisper / Groq Llama 3)         │
└─────────────────────────────────────────────┘
```

### Patrones utilizados
- **Feature-first architecture**: Cada funcionalidad en su propio directorio
- **Provider Pattern**: Gestión de estado reactiva con Riverpod
- **Service Pattern**: Lógica de negocio encapsulada en servicios
- **Declarative UI**: Interfaz completamente declarativa con Flutter

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── router.dart                    # GoRouter con ShellRoute
│   ├── providers/
│   │   ├── auth_provider.dart         # Autenticación
│   │   ├── locale_provider.dart       # Idioma (ES/EN)
│   │   ├── theme_provider.dart        # Tema oscuro/claro
│   │   ├── sound_provider.dart        # Configuración de sonido
│   │   └── notifications_provider.dart # Notificaciones
│   └── services/
│       ├── groq_service.dart          # API Groq (Whisper + Llama 3)
│       └── tts_service.dart           # Text-to-Speech
├── features/
│   ├── home/                          # Mapa de niveles zigzag
│   ├── learning/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── question_model.dart # Modelo de preguntas (12 tipos)
│   │   │   │   └── level_model.dart    # Modelo de niveles
│   │   │   └── levels/
│   │   │       ├── english_levels.dart      # 10+ niveles A1→B1
│   │   │       ├── development_levels.dart  # 5 niveles programación
│   │   │       └── soft_skills_levels.dart  # 5 niveles habilidades
│   │   └── presentation/
│   │       └── lesson_screen.dart     # Pantalla de ejercicios
│   ├── ai_tutor/                      # Tutor IA con orbe animado
│   ├── leaderboard/                   # Tabla de clasificación
│   ├── leagues/                       # Sistema de ligas
│   ├── profile/                       # Perfil, sonido, notificaciones
│   └── main_layout/                   # Layout con Bottom Navigation
└── shared/
    └── widgets/
        ├── level_node.dart            # Nodo del mapa de niveles
        ├── level_connector_painter.dart # Conector curvo entre nodos
        └── aurora_fab.dart            # FAB con efecto aurora
```

---

## 🎓 Tracks de Aprendizaje

### 🟢 Inglés — 10+ Niveles (A1 → B1)
| Nivel | Tema | Dificultad | XP |
|---|---|---|---|
| 1-5 | Greetings, Family, Routines, Abilities, Places | A1 | 100 |
| 6-9 | Past Simple, Shopping, Future Plans, Jobs | A2 | 120 |
| 10 | A1 Review | A1 | 150 |
| 11+ | Present Perfect, Present Perfect Continuous... | B1 | 120+ |

### 🟣 Desarrollo de Software — 5 Niveles
| Nivel | Tema | Dificultad | XP |
|---|---|---|---|
| 1 | Fundamentos: variables, tipos, operadores | Básico | 100 |
| 2 | Control de flujo: for, while, funciones, recursión | Básico | 120 |
| 3 | POO: clases, herencia, polimorfismo, abstracción | Intermedio | 150 |
| 4 | Estructuras de datos: List, Map, Set, algoritmos, Big O | Intermedio | 160 |
| 5 | Flutter: widgets, estado, Riverpod, GoRouter, FutureBuilder | Avanzado | 200 |

### 🟠 Soft Skills — 5 Niveles
| Nivel | Tema | Dificultad | XP |
|---|---|---|---|
| 1 | Comunicación Efectiva y asertividad | Básico | 100 |
| 2 | Trabajo en Equipo y metodologías ágiles | Básico | 120 |
| 3 | Liderazgo y Gestión del Tiempo (Eisenhower, Pomodoro) | Intermedio | 140 |
| 4 | Inteligencia Emocional (Goleman, Mindfulness) | Intermedio | 150 |
| 5 | Resolución de Conflictos y Negociación (CNV, BATNA) | Avanzado | 180 |

---

## 🤖 Tutor IA

El Tutor IA ofrece una experiencia conversacional inmersiva con un **orbe animado estilo Gemini**:

```
┌──────────────────────────────────┐
│  1. Usuario presiona el orbe     │
│  2. Graba audio (record)         │
│  3. Envía a Groq Whisper (STT)   │
│  4. Texto → Groq Llama 3 (LLM)  │
│  5. Respuesta → flutter_tts      │
│  6. App habla la respuesta       │
└──────────────────────────────────┘
```

**Efectos visuales del orbe:**
- 7 capas de animación concéntrica
- Gradientes sweep con rotación
- Ondas de sonido (ripples) al escuchar
- Efecto de respiración (breathe)
- Aurora boreal interior y exterior

---

## 📝 Tipos de Ejercicios

La app soporta **12 tipos de preguntas** diferentes:

| Tipo | Descripción | Tracks |
|---|---|---|
| `multipleChoice` | Selección múltiple con 3-4 opciones | Todos |
| `fillInTheBlanks` | Completar espacios en blanco | Todos |
| `trueFalse` | Verdadero o Falso | Todos |
| `matching` | Relacionar columnas (drag & match) | Todos |
| `orderWords` | Ordenar palabras o pasos | Todos |
| `miniReading` | Lectura comprensiva con preguntas | Todos |
| `completeCode` | **Completar fragmentos de código** (con syntax highlighting) | Desarrollo |
| `completeWord` | Completar una palabra/concepto clave | Soft Skills, Dev |
| `errorCorrection` | Encontrar y corregir errores | Inglés |
| `completeDialogue` | Completar un diálogo | Inglés |
| `chooseCorrect` | Elegir la opción correcta | Inglés |
| `shortWriting` | Escritura libre guiada | Inglés |

---

## ⚙️ Instalación y Configuración

### Prerequisitos
- Flutter SDK ^3.11.5
- Dart ^3.11.5
- Android Studio / VS Code
- Cuenta en [Groq](https://console.groq.com/) para la API key

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/TeamKaplan/Riwi-App.git
cd Riwi-App

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env con tu API key de Groq

# 4. Ejecutar en modo debug
flutter run
```

---

## 🔐 Variables de Entorno

Crear un archivo `.env` en la raíz del proyecto:

```env
GROQ_API_KEY=tu_api_key_de_groq
```

> ⚠️ **Importante**: Nunca subas el archivo `.env` al repositorio. Ya está incluido en `.gitignore`.

---

## 👥 Equipo

**Team Kaplan** — Desarrollado como parte del programa de formación **RIWI** (Rutas de Innovación y Aprendizaje).

---

<p align="center">
  <sub>Hecho con ❤️ por Team Kaplan | RIWI 2026</sub>
</p>
