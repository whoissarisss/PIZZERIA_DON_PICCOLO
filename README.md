<img width="1053" height="525" alt="image" src="https://github.com/user-attachments/assets/0b8012b0-83a5-4c52-a8ab-a194bda907e5" />

### 🍕 Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios

Sistema de gestión de base de datos desarrollado en **MySQL** para digitalizar y organizar las operaciones de la **Pizzería Don Piccolo**.

El proyecto permite administrar de manera estructurada la información relacionada con **clientes, pizzas, ingredientes, pedidos, domicilios, repartidores y pagos**, además de incorporar funciones, procedimientos almacenados, triggers, vistas y consultas SQL para facilitar el control y análisis de la información.

---

## 🎯 Objetivo

Diseñar e implementar una base de datos relacional que permita gestionar de manera eficiente los procesos principales de la pizzería, incluyendo:

* 👤 Registro y administración de clientes.
* 🍕 Gestión del menú de pizzas.
* 🧂 Control de ingredientes e inventario.
* 🛒 Registro y seguimiento de pedidos.
* 🛵 Administración de repartidores.
* 📍 Gestión de zonas de reparto.
* 🚚 Control de domicilios.
* 💳 Registro de pagos.
* 📊 Generación de reportes mediante vistas y consultas.
* ⚙️ Automatización de procesos mediante funciones, procedimientos y triggers.

---

## 🛠️ Tecnologías utilizadas

| Tecnología          | Uso                                                |
| ------------------- | -------------------------------------------------- |
| **MySQL**           | Sistema gestor de base de datos                    |
| **SQL**             | Creación, consulta y manipulación de datos         |
| **MySQL Workbench** | Desarrollo y ejecución de scripts                  |
| **Git / GitHub**    | Control de versiones y almacenamiento del proyecto |

---

## 📁 Estructura del proyecto

```text
/pizzeria-don-piccolo/
│
├── database.sql          # Creación de la base de datos y tablas
├── datos_prueba.sql      # Datos de prueba
├── funciones.sql         # Funciones y procedimiento almacenado
├── triggers.sql          # Triggers de automatización
├── vistas.sql            # Vistas para reportes
├── consultas.sql         # Consultas SQL requeridas
└── README.md             # Documentación del proyecto
```

---

## 🗄️ Modelo de datos

La base de datos está compuesta por las siguientes tablas:

| Tabla                | Descripción                                    | Relación principal                      |
| -------------------- | ---------------------------------------------- | --------------------------------------- |
| `persona`            | Almacena los datos comunes de las personas.    | Tabla padre                             |
| `clientes`           | Información específica de los clientes.        | `id_cliente → persona.id_persona`       |
| `repartidores`       | Información de los repartidores y su estado.   | `id_repartidor → persona.id_persona`    |
| `zonas`              | Zonas disponibles para realizar domicilios.    | —                                       |
| `ingredientes`       | Inventario de ingredientes y control de stock. | —                                       |
| `pizzas`             | Menú de pizzas disponibles.                    | —                                       |
| `pizza_ingredientes` | Relaciona pizzas con sus ingredientes.         | N:M                                     |
| `pedidos`            | Información general de cada pedido.            | `id_cliente → clientes.id_cliente`      |
| `detalle_pedido`     | Pizzas incluidas en cada pedido.               | `id_pedido`, `id_pizza`                 |
| `domicilios`         | Información relacionada con la entrega.        | `id_pedido`, `id_repartidor`, `id_zona` |
| `pagos`              | Información del pago de cada pedido.           | `id_pedido → pedidos.id_pedido`         |

---

## 🔗 Relaciones principales

El modelo utiliza diferentes tipos de relaciones:

### Persona → Clientes

`persona` funciona como tabla padre para almacenar los datos comunes.

```text
persona
   │
   ├── clientes
   │
   └── repartidores
```

Tanto `clientes` como `repartidores` utilizan su propia clave primaria como clave foránea hacia `persona`.

Para registrar un nuevo cliente se debe:

1. Insertar sus datos en `persona`.
2. Obtener el `id_persona` generado.
3. Utilizar ese mismo ID para insertar el registro correspondiente en `clientes`.

### Pizzas ↔ Ingredientes

Existe una relación **muchos a muchos (N:M)** mediante la tabla intermedia:

```text
pizzas
   │
   └── pizza_ingredientes ── ingredientes
```

Esto permite definir qué ingredientes necesita cada pizza y qué cantidad se utiliza de cada uno.

### Pedidos → Detalles

Un pedido puede contener varias pizzas:

```text
pedidos
   │
   └── detalle_pedido ── pizzas
```

### Pedidos → Domicilios

Cada pedido puede tener un registro de domicilio asociado.

### Pedidos → Pagos

Cada pedido tiene un registro de pago asociado.

---

## 🧠 Consideraciones de diseño

### 👤 Herencia mediante `persona`

La tabla `persona` evita repetir información como:

* Nombre.
* Apellido.
* Dirección.
* Correo.

Los clientes y repartidores reutilizan esta información mediante una relación **1:1**.

### 💰 Costo del domicilio

El costo del domicilio se determina mediante:

```text
zonas.costo_domicilio
```

El campo `domicilios.distancia_km` es únicamente informativo y logístico.

**La distancia no modifica el costo del domicilio.**

### 🧂 Costo de los ingredientes

`ingredientes.costo_unitario` representa el **costo de un gramo** del ingrediente.

El costo utilizado para calcular una pizza depende de:

```text
costo_unitario × cantidad_requerida
```

Por esta razón, los valores almacenados en `costo_unitario` pueden ser pequeños.

### 📋 Historial de precios

El proyecto **no incluye una tabla `historial_precios` ni un trigger de auditoría de precios**, ya que este componente fue descartado para mantener un alcance adecuado al proyecto.

---

# ⚙️ Funciones y procedimiento almacenado

El archivo `funciones.sql` contiene las funciones y procedimientos utilizados para automatizar cálculos y operaciones.

### `fn_total_pedido(id_pedido)`

Calcula el valor total de un pedido considerando:

* Valor de las pizzas.
* Costo del domicilio.
* IVA del **19 % aplicado sobre el valor de las pizzas**.

Conceptualmente:

```text
Total = pizzas + domicilio + IVA
```

---

### `fn_ganancia_neta_diaria(fecha)`

Calcula la ganancia neta de un día determinado.

Se obtiene mediante:

```text
Ventas de pedidos entregados
-
Costo de los ingredientes utilizados
```

---

### `sp_registrar_entrega(id_pedido, hora_entrega)`

Permite registrar la entrega de un pedido en una sola operación.

El procedimiento:

1. Registra la hora de entrega.
2. Cambia automáticamente el estado del pedido a `entregado`.

---

# ⚡ Triggers

El archivo `triggers.sql` contiene triggers encargados de automatizar determinados procesos.

### `trg_descontar_stock`

Se ejecuta cuando se agrega una pizza a un pedido.

Su función es descontar automáticamente del inventario los ingredientes necesarios de acuerdo con la receta de la pizza.

```text
Nuevo detalle del pedido
        ↓
Identificar pizza
        ↓
Consultar ingredientes
        ↓
Calcular cantidad utilizada
        ↓
Descontar stock
```

---

### `trg_repartidor_disponible`

Cuando un domicilio registra una `hora_entrega`, el repartidor asignado vuelve automáticamente a estado:

```text
disponible
```

Esto permite mantener actualizado el estado de disponibilidad de los repartidores.

---

# 👀 Vistas

El archivo `vistas.sql` contiene vistas diseñadas para facilitar la consulta de información y generar reportes.

### `v_resumen_pedidos_cliente`

Muestra información relacionada con los pedidos y el total gastado por cada cliente.

Incluye una columna con el valor formateado en pesos colombianos, por ejemplo:

```text
$95.440 COP
```

---

### `v_desempeno_repartidores`

Permite consultar información sobre el desempeño de los repartidores, incluyendo:

* Número de entregas.
* Tiempo promedio de entrega.
* Zona asignada.

---

### `v_stock_bajo_minimo`

Muestra los ingredientes cuyo stock actual se encuentra por debajo del stock mínimo establecido.

Esta vista permite identificar rápidamente los productos que requieren reposición.

---

# 🔍 Consultas SQL

El archivo `consultas.sql` contiene diferentes consultas utilizadas para analizar la información de la pizzería.

Entre ellas se incluyen consultas con:

* `SELECT`
* `JOIN`
* `LEFT JOIN`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `BETWEEN`
* `AVG`
* `LIKE`
* Subconsultas
* Funciones de agregación

### 🍕 Pizzas más vendidas

Ejemplo:

```sql
SELECT 
    pz.nombre, 
    SUM(dp.cantidad) AS unidades_vendidas
FROM detalle_pedido dp
JOIN pizzas pz 
    ON pz.id_pizza = dp.id_pizza
JOIN pedidos p 
    ON p.id_pedido = dp.id_pedido
WHERE p.estado <> 'cancelado'
GROUP BY pz.id_pizza, pz.nombre
ORDER BY unidades_vendidas DESC;
```

### 👥 Clientes frecuentes

Permite identificar clientes que realizaron más de cinco pedidos durante un mismo mes:

```sql
SELECT 
    per.nombre, 
    per.apellido
FROM clientes c
JOIN persona per 
    ON per.id_persona = c.id_cliente
WHERE c.id_cliente IN (
    SELECT p.id_cliente
    FROM pedidos p
    GROUP BY 
        p.id_cliente,
        YEAR(p.fecha_hora),
        MONTH(p.fecha_hora)
    HAVING COUNT(*) > 5
);
```

---

# 🚀 Instalación y ejecución

## 1. Requisitos

Antes de ejecutar el proyecto se necesita tener instalado:

* MySQL Server.
* MySQL Workbench (opcional, pero recomendado).
* Un usuario con permisos para crear bases de datos y tablas.

---

## 2. Clonar el repositorio

```bash
git clone URL_DEL_REPOSITORIO
cd pizzeria-don-piccolo
```

> Reemplaza `URL_DEL_REPOSITORIO` por la URL correspondiente al repositorio de GitHub.

---

## 3. Ejecutar los scripts

Los archivos deben ejecutarse **en el siguiente orden**, ya que cada uno depende de los objetos creados anteriormente:

```text
1. database.sql
2. datos_prueba.sql
3. funciones.sql
4. triggers.sql
5. vistas.sql
6. consultas.sql
```

### Desde la terminal

```bash
mysql -u tu_usuario -p < database.sql
mysql -u tu_usuario -p < datos_prueba.sql
mysql -u tu_usuario -p < funciones.sql
mysql -u tu_usuario -p < triggers.sql
mysql -u tu_usuario -p < vistas.sql
mysql -u tu_usuario -p < consultas.sql
```

El sistema solicitará la contraseña del usuario de MySQL.

---

## 🖥️ Ejecución mediante MySQL Workbench

Si se utiliza MySQL Workbench:

1. Abrir MySQL Workbench.
2. Conectarse al servidor MySQL.
3. Seleccionar **File → Open SQL Script**.
4. Abrir `database.sql`.
5. Ejecutar el script completo.
6. Repetir el proceso siguiendo el orden establecido.

Es importante mantener el mismo orden de ejecución.

---

# 🧪 Pruebas rápidas

Después de ejecutar todos los archivos, se pueden realizar las siguientes pruebas:

```sql
USE pizzeria_don_piccolo_sariss;
```

### Probar el total de un pedido

```sql
SELECT fn_total_pedido(1);
```

### Probar la ganancia diaria

```sql
SELECT fn_ganancia_neta_diaria('2026-08-25');
```

### Consultar el resumen de clientes

```sql
SELECT * 
FROM v_resumen_pedidos_cliente;
```

### Consultar ingredientes con stock bajo

```sql
SELECT * 
FROM v_stock_bajo_minimo;
```

---

# 📊 Flujo general del sistema

```text
                 ┌──────────────┐
                 │   CLIENTES   │
                 └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │   PEDIDOS    │
                 └──────┬───────┘
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
     ┌─────────────────┐   ┌──────────────┐
     │ DETALLE_PEDIDO  │   │  DOMICILIOS  │
     └────────┬────────┘   └──────┬───────┘
              │                   │
              ▼                   ▼
         ┌─────────┐        ┌─────────────┐
         │ PIZZAS  │        │ REPARTIDORES│
         └────┬────┘        └──────┬──────┘
              │                    │
              ▼                    ▼
   ┌────────────────────┐      ┌───────┐
   │ PIZZA_INGREDIENTES │      │ ZONAS │
   └─────────┬──────────┘      └───────┘
             │
             ▼
      ┌──────────────┐
      │ INGREDIENTES │
      └──────────────┘
```

---

# 🔐 Integridad y automatización

El diseño utiliza **llaves primarias y foráneas** para mantener la integridad referencial entre las tablas.

Además, los triggers permiten automatizar procesos importantes como:

* Actualización del inventario.
* Actualización del estado de los repartidores.

Las funciones y procedimientos almacenados permiten centralizar operaciones y cálculos directamente en la base de datos.

Las vistas facilitan la generación de reportes sin necesidad de repetir consultas complejas.

---

# 📚 Componentes del proyecto

| Componente         | Función                              |
| ------------------ | ------------------------------------ |
| `database.sql`     | Estructura de la base de datos       |
| `datos_prueba.sql` | Información inicial para pruebas     |
| `funciones.sql`    | Funciones y procedimiento almacenado |
| `triggers.sql`     | Automatización de procesos           |
| `vistas.sql`       | Reportes y consultas reutilizables   |
| `consultas.sql`    | Consultas SQL de análisis            |
| `README.md`        | Documentación del proyecto           |

---

# 👩‍💻 Proyecto académico

**Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios**

Proyecto desarrollado como ejercicio académico para aplicar conceptos de:

* Modelado relacional.
* Bases de datos MySQL.
* Llaves primarias y foráneas.
* Relaciones 1:1, 1:N y N:M.
* Consultas SQL.
* Funciones almacenadas.
* Procedimientos almacenados.
* Triggers.
* Vistas.
* Integridad referencial.
* Manipulación y análisis de datos.

---

## ⭐ Estado del proyecto

**Estado:** ✅ Funcional

El proyecto incluye la estructura de la base de datos, datos de prueba, funciones, procedimientos, triggers, vistas y consultas necesarias para demostrar el funcionamiento del sistema de gestión de la Pizzería Don Piccolo.
