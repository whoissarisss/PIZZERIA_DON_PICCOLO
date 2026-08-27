<img width="1053" height="525" alt="image" src="https://github.com/user-attachments/assets/0b8012b0-83a5-4c52-a8ab-a194bda907e5" />

# 🍕 Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios

Base de datos relacional en MySQL para digitalizar la operación de la
pizzería: clientes, menú, ingredientes, pedidos, repartidores, domicilios
y pagos. Incluye funciones, un procedimiento almacenado, triggers, vistas
y consultas para apoyar el control diario del negocio.

## 📁 Estructura del proyecto

```
/pizzeria-don-piccolo/
 ├── script.sql        # Base de datos, tablas, ajustes de tipo y datos de prueba
 ├── functions.sql     # Funciones: total_pedido, ganancia_neta_diaria
 ├── procedures.sql    # Procedimiento: registrar_entrega
 ├── triggers.sql      # Triggers: descontar_stock, repartidor_disponible
 ├── views.sql          # Vistas de reportes
 ├── consultas.sql      # Consultas SQL requeridas (JOIN, subconsultas, etc.)
 └── README.md
```

## 🧩 Tablas y relaciones

| Tabla | Descripción | Relación |
|---|---|---|
| `persona` | Tabla padre con los datos comunes: nombre, apellido, dirección, correo | — |
| `clientes` | Extiende a `persona` (1:1). Su PK (`id_cliente`) **es también** FK hacia `persona.id_persona` | `id_cliente` → `persona.id_persona` |
| `repartidores` | Extiende a `persona` (1:1), igual que `clientes`. Tiene además `telefono`, `id_zona` y `estado` | `id_repartidor` → `persona.id_persona`; `id_zona` → `zonas.id_zona` |
| `zonas` | Zonas de reparto con su costo fijo de domicilio | — |
| `ingredientes` | Inventario: stock actual, stock mínimo, costo por gramo | — |
| `pizzas` | Menú: nombre, tamaño, precio de venta, tipo | — |
| `pizza_ingredientes` | Receta de cada pizza (relación N:M entre `pizzas` e `ingredientes`) | `id_pizza` → `pizzas`; `id_ingrediente` → `ingredientes` |
| `pedidos` | Cabecera del pedido: cliente, fecha, método de pago, estado, total | `id_cliente` → `clientes` |
| `detalle_pedido` | Pizzas de cada pedido (1 pedido → N pizzas) | `id_pedido` → `pedidos`; `id_pizza` → `pizzas` |
| `domicilios` | Datos del envío (1:1 con `pedidos`): repartidor, zona, horas, costo | `id_pedido` → `pedidos`; `id_repartidor` → `repartidores`; `id_zona` → `zonas` |
| `pagos` | Pago asociado a cada pedido (1:1) | `id_pedido` → `pedidos` |

**Notas de diseño:**
- `persona` es la tabla "padre" de `clientes` y `repartidores`: comparten llave primaria con `persona` en vez de repetir columnas (patrón de herencia de tablas). Para crear un cliente nuevo: primero `INSERT INTO persona`, y con el `id_persona` generado se hace `INSERT INTO clientes (id_cliente, ...)`.
- El costo del domicilio se define por `zonas.costo_domicilio` (precio fijo por zona), no por distancia.
- `ingredientes.costo_unitario` es el precio de **un gramo** de ese ingrediente, no del paquete completo. El costo real de una pizza sale de multiplicar por `pizza_ingredientes.cantidad_requerida`.
- Todas las columnas de dinero y de cantidades en gramos son `INT` (no `DECIMAL`), para que ningún valor salga con `.00` al mostrarlo. `script.sql` crea las tablas y de una vez deja esas columnas en `INT` (columnas como `stock_actual`/`stock_minimo` de `ingredientes` nacen en `DECIMAL(10,2)` y el mismo script las pasa a `INT` con `ALTER TABLE` más abajo, antes de insertar los datos de prueba).

## ⚙️ Funciones (`functions.sql`)

- `total_pedido(id_pedido)` → total del pedido = pizzas + costo de envío + 19% de IVA (sobre las pizzas).
- `ganancia_neta_diaria(fecha)` → ventas del día (pedidos entregados) menos el costo de los ingredientes usados ese día.

## 🔧 Procedimiento (`procedures.sql`)

- `registrar_entrega(id_pedido, hora_entrega)` → registra la hora de entrega del domicilio y cambia el pedido a `'entregado'` en un solo paso.

## ⚡ Triggers (`triggers.sql`)

- `descontar_stock` → al agregar una pizza a un pedido, descuenta automáticamente el stock de cada ingrediente de su receta.
- `repartidor_disponible` → cuando se registra `hora_entrega` en un domicilio, el repartidor asignado vuelve a `'disponible'` automáticamente.

## 👀 Vistas (`views.sql`)

- `view_resumen_pedidos_cliente` → pedidos y total gastado por cliente (incluye `total_gastado_formato`, con el precio ya formateado estilo `$95.440 COP`).
- `view_stock_bajo_minimo` → ingredientes cuyo stock actual ya está por debajo del mínimo permitido.

> ⚠️ **Pendiente:** la guía original también pedía una vista de **desempeño de
> repartidores** (número de entregas, tiempo promedio, zona) — en esta
> versión de `views.sql` no está creada, aunque sí aparece mencionada en el
> comentario de ejemplos al final del archivo. Si tu entrega la exige,
> dime y te la agrego.

## 🔍 Consultas (`consultas.sql`)

Las 7 consultas que pedía la guía: `BETWEEN`, `GROUP BY`/`COUNT`, `JOIN`,
`AVG`, `HAVING`, `LIKE` y la subconsulta de clientes frecuentes (más de 5
pedidos en un mismo mes). Todas están comentadas dentro del archivo.


