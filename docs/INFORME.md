# **Informe de Implementación – Proyecto Prolog + React**

## Participantes

**Materia:** Lógica para Cs. de la Computación – 2025

**Comisión:** 15

**Integrantes:**

- Bruno Ariel Parisi (@brunitoa10)
- Nombre Apellido(usuario GitHub)
- Nombre Apellido (usuario GitHub)

## 1. Introducción

Este informe documenta el desarrollo del sistema basado en **Prolog** para la lógica principal, complementado con una interfaz construida en **React**. El objetivo principal fue resolver los requerimientos funcionales definidos para el sistema, garantizando claridad, completitud y una interfaz amigable para el usuario.

## 2. Implementación en Prolog

### 2.1. Enfoque general

La lógica del juego/sistema fue modelada en Prolog aprovechando sus capacidades declarativas para el manejo de conocimiento, reglas y resolución de casos. Se diseñó una base de hechos y reglas que permiten:

- Representar el estado del juego.
- Consultar el estado y tomar decisiones.
- Validar movimientos o acciones del usuario.
- Generar respuestas o sugerencias automáticas según la situación actual.

Para lograr una implementación clara y modular, se estructuró el código Prolog en distintos archivos, agrupando responsabilidades específicas en cada uno:

### 🧩 Estructura modular del sistema

| Archivo | Propósito |
| --- | --- |
| `grid_gravity.pl` | Aplica la **gravedad** en la grilla, haciendo que los bloques caigan cuando hay espacios vacíos. |
| `grid_indexing.pl` | Proporciona funciones de **indexado** para acceder o modificar celdas por coordenadas. |
| `grid_merge.pl` | Implementa la **fusión de bloques** adyacentes con condiciones específicas. |
| `grid_utils.pl` | Contiene **utilitarios** generales para operaciones sobre la grilla. |
| `block_factory.pl` | Genera bloques con características específicas, siguiendo un patrón **Factory**. |
| `app.pl` | Punto de entrada principal para consultas externas; expone las funcionalidades clave. |
| `init.pl` | Inicializa el sistema y define configuraciones iniciales o estados por defecto. |
| `proylcc.pl` | Archivo raíz que agrupa e importa todos los módulos del sistema. |

Esta modularización favoreció el desarrollo incremental, el testeo individual de componentes, y la escalabilidmensualesad del sistema.

---

### 2.2. Resolución de requerimientos funcionales

| Requerimiento | Estrategia Prolog |
| --- | --- |
| **Generación aleatoria del bloque** | `randomBlock/2` usa `random_between/3` acotado por el valor máximo actual en la grilla. Se consulta el máximo y se calcula el rango correspondiente dinámicamente. |
| **Disparo y caída de bloques** | `shoot/5` determina la posición de impacto, aplica la inserción, evalúa fusiones en cadena, y luego aplica gravedad inversa sobre la grilla resultante. |
| **Fusión en cadena (efecto cascada)** | `grid_merge.pl` contiene reglas recursivas que detectan bloques iguales adyacentes y los fusionan, generando combos múltiples cuando es necesario. |
| **Avisos de Combo x N** | La cantidad de fusiones consecutivas generadas en un solo disparo se devuelve como parámetro a la UI para su visualización. |
| **Nuevo bloque máximo alcanzado** | Se detecta cuando aparece un nuevo máximo en la grilla, se actualiza el rango de generación y se marca un mensaje para la UI. |
| **Limpieza de bloques retirados** | Si un bloque es eliminado del rango, se eliminan todas sus ocurrencias de la grilla (reconstrucción de grilla sin ese valor). |
| **Booster Hint** | Se simula un disparo en cada columna y se devuelven los efectos simulados (nuevo valor, combo estimado). No se modifica el estado real. |
| **Booster siguiente bloque** | El backend devuelve no solo el bloque actual, sino también el siguiente en cola, actualizado tras cada jugada. |

> ⚠️ Reglas auxiliares o triviales no se documentan por claridad (por ejemplo, operaciones sobre listas, validación de índices, etc.)
> 

---

### 2.3. Desafíos enfrentados

- **Cadena de fusiones complejas**
    
    Fue necesario modelar una lógica que permita detectar múltiples fusiones consecutivas, alternando entre fusiones y caídas. Se aplicó un enfoque recursivo con control de estado intermedio.
    
- **Manejo de rangos dinámicos de generación**
    
    Se creó un mapeo declarativo entre los valores máximos en la grilla y el rango de generación permitido, con control sobre la eliminación de valores obsoletos.
    
- **Comunicación React ↔ Prolog**
    
    Vino dada por la catedra
    

---

## 3. Casos de test

A continuación se presentan algunos casos representativos con capturas de pantalla:

### 🟦 Caso 1 – Disparo con combo x3

![image](https://github.com/user-attachments/assets/0d022544-78bc-4d4e-afeb-5a52dead3fd7)

### 🟩 Caso 2 – Logro de nuevo bloque máximo

*(Captura con el mensaje “New Block 1024 added”, y otro con “Eliminated Block 4”)*

### 🟨 Caso 3 – Activación del Booster Hint

![image](https://github.com/user-attachments/assets/6f50a211-831d-4efb-b928-1d0e45a294b4)


### 🟥 Caso 4 – Activación del Booster siguiente bloque

![image](https://github.com/user-attachments/assets/d844c5f2-d007-46c1-a6d9-8b00095d10c7)

### 🟫 Caso 5 – Limpieza automática del bloque retirado

*(Captura antes y después de la limpieza de todos los bloques "4" luego de alcanzar 2048)*

---

## 4. Conclusión

La implementación logró cumplir todos los requerimientos funcionales del juego **M2 Blocks**, replicando fielmente el comportamiento de la versión móvil. Se desarrolló una lógica sólida en Prolog para gestionar el motor del juego y una interfaz moderna y reactiva en React.

**Aspectos destacados**:

- Uso efectivo del paradigma lógico para representar reglas complejas.
- Modularización clara de la lógica Prolog y componentes React.
- Interfaz intuitiva, con feedback visual progresivo.
- Excelente sincronización entre capas lógica y visual.

---

## 5. Instrucciones de ejecución

### Backend – Prolog

```bash
cd pengines_server
swipl run.pl
```

### Frontend – React

```bash
npm run start

```
