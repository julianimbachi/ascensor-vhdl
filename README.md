# Proyecto: Ascensor Controlado por FSM en VHDL

Este proyecto consiste en el diseño e implementación de un **ascensor digital** utilizando **máquinas de estados finitas (FSM)** en el lenguaje de descripción de hardware **VHDL**, orientado a una **FPGA Cyclone III**.

## 📌 Objetivo

Desarrollar un sistema de control para un ascensor de 5 pisos, con capacidad para 10 personas, cumpliendo con múltiples requerimientos de seguridad y operatividad, como detección de anomalías, sobrecarga, control de puertas, luces y motores.

## 🧩 Estructura del Proyecto

El diseño se divide en **módulos independientes**, cada uno desarrollado y probado como un bloque funcional:

### 1. FSM Puertas (`fsm_puerta.vhd`)
Controla la apertura y cierre de puertas con temporización de 10 y 45 segundos. También activa señales visuales y sonoras en los eventos de apertura/cierre.

### 2. Control Motor DC (FSM)
Controla la dirección del movimiento del ascensor (subir o bajar) y la activación del motor.

### 3. FSM Principal (`ascensorfsm1.vhd`)
Gestiona la lógica de control de alto nivel del ascensor: atención a llamados externos, ingreso de destino, detección de anomalías, control de luces y tránsito entre estados.

### 4. FIFO de Solicitudes (`fifo_ascensor.vhd`)
Maneja las solicitudes de pisos en orden de llegada, sin repetir llamados, usando una estructura FIFO con control de lectura y escritura.

---

## ⚠️ Problema Actual

Aunque cada módulo individual (FSM de puertas, control de motor, FIFO) **funciona correctamente por separado**, la **integración de estos componentes en un sistema superior** genera **comportamientos no deseados**, tales como:

- Conflictos entre la activación del motor y el estado de las puertas.
- Desincronización entre el ciclo de atención de solicitudes y la lógica de transición de estados.
- Problemas en el tiempo de habilitación de señales entre FSMs.

Estas inconsistencias reflejan la necesidad de:
- Una mejor coordinación entre estados de los módulos.
- Un reloj o controlador central más robusto.
- Tal vez rediseñar el FSM principal como entidad coordinadora.

---

## 📷 Requisitos del Proyecto

El sistema debe:

- Controlar un ascensor de 5 pisos y 10 personas.
- Indicar anomalías mediante señales sonoras y visuales.
- Atender solicitudes desde fuera (botones por piso) y dentro del ascensor.
- Mantener puertas cerradas ante anomalías.
- Encender/apagar luces según actividad.
- Visualizar el piso actual dentro y fuera del ascensor.

---

## 🛠️ Estado del Proyecto

- ✅ Módulo FSM de puertas: probado y funcional.
- ✅ Control de motor: probado individualmente.
- ✅ FIFO para solicitudes: funcional.
- ⚠️ Integración de módulos: requiere revisión y sincronización.

---

## 🚀 Futuras Mejoras

- Diseñar una **FSM superior** que actúe como controlador maestro.
- Establecer señales de sincronización estrictas entre módulos.
- Añadir un módulo de visualización para piso actual y estado del sistema.

---

## 📄 Licencia

Este proyecto está desarrollado con fines académicos en la Universidad del Cauca. Libre para fines educativos y mejoras.

