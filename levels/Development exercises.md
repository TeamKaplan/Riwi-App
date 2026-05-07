## **Nivel 1: Fundamentos de Programación**

1. Multiple choice: ¿Qué tipo de dato almacena texto?
   a) int
   b) String ✅
   c) bool
   d) double

2. Completar código: Declarar variable entera con valor 10:
   ```dart
   ___ edad = ___;
   ```
   → `int edad = 10;`

3. Verdadero o Falso:
   * "bool" solo puede ser true o false. → **Verdadero**

4. Completar código: Imprimir "Hola Mundo":
   ```dart
   ___("Hola Mundo");
   ```
   → `print("Hola Mundo");`

5. Relacionar tipo de dato con ejemplo:
   * int → 42
   * String → "Hola"
   * bool → true
   * double → 3.14

6. Multiple choice: ¿Resultado de 10 % 3?
   a) 3
   b) 1 ✅
   c) 0
   d) 3.33

7. Completar código: Condición IF mayor de edad:
   ```dart
   int edad = 18;
   ___ (edad ___ 18) {
     print("Es mayor de edad");
   }
   ```
   → `if (edad >= 18)`

8. Completar palabra: Estructura que almacena múltiples valores del mismo tipo:
   A _ _ _ _ _ o → **Arreglo** (o Lista)

9. Completar espacios:
   * Una ___ almacena un valor que puede cambiar. → **variable**
   * Un ___ es un valor que no cambia. → **constante**

10. Completar código: Crear lista y agregar el 4:
    ```dart
    List<int> numeros = [1, 2, 3];
    numeros.___(4);
    ```
    → `numeros.add(4);`

---

## **Nivel 2: Control de Flujo y Funciones**

1. Completar código: Bucle FOR del 1 al 5:
   ```dart
   ___ (int i = 1; i ___ 5; i++) {
     print(i);
   }
   ```
   → `for (int i = 1; i <= 5; i++)`

2. Multiple choice: ¿Cuántas veces se ejecuta for (int i = 0; i < 3; i++)?
   a) 2 veces
   b) 3 veces ✅
   c) 4 veces
   d) Infinitas veces

3. Completar código: Función que retorna suma de dos números:
   ```dart
   int ___(int a, int b) {
     ___ a + b;
   }
   ```
   → `int sumar(int a, int b) { return a + b; }`

4. Verdadero o Falso:
   * Un bucle "while" evalúa la condición ANTES de ejecutar el código. → **Verdadero**

5. Relacionar estructura con uso:
   * if-else → Ejecutar según condición
   * for → Repetir N veces
   * while → Repetir mientras condición
   * switch → Evaluar múltiples casos

6. Completar código: WHILE que cuenta de 1 a 3:
   ```dart
   int contador = 1;
   ___ (contador <= 3) {
     print(contador);
     contador___;
   }
   ```
   → `while, ++`

7. Multiple choice: ¿Keyword para salir de un bucle?
   a) continue
   b) return
   c) break ✅
   d) exit

8. Completar código: Parámetro opcional con valor por defecto:
   ```dart
   String saludar(String nombre, {String saludo ___ "Hola"}) {
     return "$saludo, $nombre!";
   }
   ```
   → `=`

9. Completar palabra: Función que se llama a sí misma:
   R _ _ _ _ _ _ _ _ d a d → **Recursividad**

10. Completar código: Switch-case:
    ```dart
    ___ (dia) {
      ___ "lunes":
        print("Inicio de semana");
        ___;
      default:
        print("Otro día");
    }
    ```
    → `switch, case, break`

---

## **Nivel 3: Programación Orientada a Objetos**

1. Completar código: Clase Persona con constructor:
   ```dart
   ___ Persona {
     String nombre;
     int edad;
     Persona({required ___.nombre, required this.___});
   }
   ```
   → `class, this, edad`

2. Multiple choice: Pilar de POO que permite reutilizar código de una clase padre:
   a) Encapsulamiento
   b) Herencia ✅
   c) Polimorfismo
   d) Abstracción

3. Completar código: Herencia Estudiante de Persona:
   ```dart
   class Estudiante ___ Persona {
     String universidad;
     Estudiante({...})
       : ___(nombre: nombre, edad: edad);
   }
   ```
   → `extends, super`

4. Verdadero o Falso:
   * El encapsulamiento oculta detalles internos. → **Verdadero**

5. Relacionar pilares de POO:
   * Encapsulamiento → Oculta detalles internos
   * Herencia → Una clase hereda propiedades
   * Polimorfismo → Múltiples formas
   * Abstracción → Simplifica mostrando lo esencial

6. Completar código: Clase abstracta e implementación:
   ```dart
   ___ class Animal {
     void hacerSonido();
   }
   class Perro ___ Animal {
     @override
     void hacerSonido() { print("Guau!"); }
   }
   ```
   → `abstract, extends`

7. Multiple choice: Diferencia entre clase abstracta e interfaz en Dart:
   a) Clase abstracta puede tener implementaciones, interfaz solo define contrato ✅
   b) Son lo mismo
   c) Interfaces pueden tener constructores
   d) Clases abstractas no pueden tener métodos

8. Completar palabra: Atributo privado con guión bajo se llama:
   E _ _ _ _ _ _ _ _ _ _ _ _ t o → **Encapsulamiento**

9. Completar código: Getter y setter:
   ```dart
   double ___ radio => _radio;
   ___ set radio(double valor) {
     if (valor > 0) _radio = valor;
   }
   ```
   → `get, void`

10. Mini lectura: Análisis de código con Vehiculo, Carro y Moto.
    * @override → Polimorfismo
    * extends → Herencia

---

## **Nivel 4: Estructuras de Datos y Algoritmos**

1. Completar código: Crear Map y acceder a valor:
   ```dart
   Map<String, int> edades = {"Ana": 25, "Luis": 30};
   int edadAna = edades[___];
   ```
   → `"Ana"`

2. Multiple choice: Complejidad de buscar en lista no ordenada:
   a) O(1)
   b) O(log n)
   c) O(n) ✅
   d) O(n²)

3. Completar código: Búsqueda lineal:
   ```dart
   int buscar(List<int> lista, int objetivo) {
     ___ (int i = 0; i < lista.___; i++) {
       if (lista[i] == objetivo) {
         ___ i;
       }
     }
     return -1;
   }
   ```
   → `for, length, return`

4. Verdadero o Falso:
   * Un Set permite elementos duplicados. → **Falso**

5. Relacionar estructura con característica:
   * List → Colección ordenada con índices
   * Map → Pares clave-valor
   * Set → Elementos únicos sin orden
   * Queue → FIFO

6. Completar código: Filtrar números pares:
   ```dart
   List<int> pares = numeros.___((___)  => n % 2 == 0).toList();
   ```
   → `where, n`

7. Multiple choice: Estructura para "deshacer" (undo):
   a) Queue
   b) Stack ✅
   c) Set
   d) Map

8. Completar código: Bubble Sort:
   ```dart
   if (lista[j] ___ lista[j + 1]) {
     int temp = lista[j];
     lista[j] = lista[j + 1];
     lista[j + 1] = ___;
   }
   ```
   → `>, temp`

9. Completar palabra: Notación de rendimiento en peor caso:
   Notación B _ _ O → **Big O**

10. Completar código: Transformar lista con map():
    ```dart
    List<int> dobles = numeros.___((___)  => n * 2).toList();
    ```
    → `map, n`

---

## **Nivel 5: Flutter y Desarrollo Móvil**

1. Completar código: StatelessWidget básico:
   ```dart
   class MiWidget ___ StatelessWidget {
     @___
     Widget build(BuildContext context) {
       return Container();
     }
   }
   ```
   → `extends, override`

2. Multiple choice: Diferencia entre Stateless y Stateful:
   a) StatelessWidget es más rápido
   b) StatefulWidget puede cambiar su estado interno y reconstruirse ✅
   c) StatelessWidget no puede tener hijos
   d) No hay diferencia

3. Completar código: StatefulWidget con setState:
   ```dart
   State<Contador> createState() => ___();
   void _incrementar() {
     ___(() {
       ___++;
     });
   }
   ```
   → `_ContadorState, setState, _count`

4. Verdadero o Falso:
   * En Flutter, todo es un Widget. → **Verdadero**

5. Relacionar widget con función:
   * Scaffold → Estructura básica de pantalla
   * Column → Organiza verticalmente
   * ListView → Lista scrolleable
   * GestureDetector → Detecta gestos

6. Completar código: Navegación con GoRouter:
   ```dart
   GoRoute(
     ___: '/perfil',
     builder: (context, state) => const PerfilScreen(),
   ),
   context.___(___);
   ```
   → `path, push, '/perfil'`

7. Multiple choice: Patrón de Riverpod:
   a) MVC
   b) Provider con inyección de dependencias reactiva ✅
   c) Redux
   d) Singleton global

8. Completar código: Provider de Riverpod:
   ```dart
   final contadorProvider = ___<int>((ref) {
     return 0;
   });
   final count = ref.___(contadorProvider);
   ```
   → `StateProvider, watch`

9. Completar palabra: Widget que permite scroll:
   S _ _ _ _ _ V _ _ w → **SingleChildScrollView**

10. Completar código: FutureBuilder:
    ```dart
    ___<List<String>>(
      future: fetchDatos(),
      builder: (context, snapshot) {
        if (snapshot.___) {
          return CircularProgressIndicator();
        }
        return ListView(
          children: snapshot.___!.map((item) => Text(item)).toList(),
        );
      },
    )
    ```
    → `FutureBuilder, connectionState == ConnectionState.waiting, data`
