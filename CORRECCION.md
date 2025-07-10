### Nota: 100

### ⚙️ Funcionalidad

#### 📌 Generación aleatoria del bloque a disparar
- ✅ funciona correctamente.

#### 📌 Efecto del disparo de un bloque
- ✅ funciona correctamente.

#### 📌 Avisos “Combo x N”
- ✅ funciona correctamente.

#### 📌 Avisos de nuevo bloque máximo logrado.
- ✅ funciona correctamente.

#### 📌 Limpieza de bloques retirados.
- ✅ funciona correctamente.
- ➖ luego de eliminar los bloques no se hacen las mezclas de nuevo.
    la otra posibilidad es que las mezclas se hagan pero se muestren a destiempo en el navegador.
Un caso que pueden usar para verlo es el siguiente:
init([
	512,4,8,64,32,
	4,-,-,4,16,
	512,-,-,-,2,
	-,-,-,-,16,
	-,-,-,-,2,
	-,-,-,-,-,
	-,-,-,-,-
], 5).
- ⚠️ con casos muy extremos podrian pasar cosas raras, pueden probarlo con este ejemplo.
init([
	2048,4,8,64,32,
	2048,-,-,4,16,
	2048,-,-,-,2,
	2048,-,-,-,16,
	2048,-,-,-,2,
	2048,-,-,-,-,
	-,-,-,-,-
], 5).

#### 📌 Booster Hint jugada
- ✅ funciona correctamente.

#### 📌 Booster Bloque siguiente.
- ✅ funciona correctamente.

#### 🚀 Extras
- ➕ se formatean los numeros grandes para una mejor visualizacion.
- ➕ visualmente muy bien pulido.
- ➕ las notificaciones/alertas dentro del juego son muy claras y contienen informacion adicional.

### 📚 Documentación
- ✅ la documentación es clara y completa.
- ✅ se incluyen casos de test.