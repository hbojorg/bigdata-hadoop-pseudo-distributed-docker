# bigdata-hadoop-pseudo-distributed-docker
AUTHOR: **JORGE HUANCA BORGES**

Entorno completo de Big Data en modo Pseudo-Distribuido (Single Node) en Docker: corriendo sobre Ubuntu 24.04 LTS | Hadoop 3.4.1 | Spark 3.5.7 | Hive 3.1.3 | Pig 0.18.0 | MySQL 8.0 | OpenJDK 8

# 🐘 Big Data Pseudo-Distributed Stack (Docker)

Este repositorio contiene un entorno completo de Big Data en modo **Pseudo-Distribuido** (Single Node) corriendo sobre **Ubuntu 24.04 LTS**.

Está diseñado para desarrollo local, pruebas de concepto y aprendizaje de tecnologías de ingeniería de datos y Big Data sin la complejidad de configurar un clúster físico.

## 🚀 Componentes y Versiones

El stack incluye las siguientes tecnologías configuradas y listas para usar:

| Componente | Versión | Notas |
|------------|---------|-------|
| **OS** | Ubuntu 24.04 (Noble) | Base image |
| **Java** | OpenJDK 8 | Requisito para compatibilidad Hadoop/Spark |
| **Hadoop** | 3.4.1 | HDFS & YARN configurados |
| **Spark** | 3.5.7 | Soporte para Scala y PySpark (Python 3.12) |
| **Hive** | 3.1.3 | Con Metastore sobre MySQL 8 |
| **Pig** | 0.18.0 | Scripting para MapReduce |
| **MySQL** | 8.0 | Backend para Hive Metastore |

## ✨ Características Principales

* **Todo en Uno:** Un solo contenedor Docker maneja todos los servicios.
* **Usuarios Configurados:** Gestión de permisos con usuarios `root`, `docker` y grupos `hadoop`/`hive`.
* **SSH Ready:** Configuración de claves RSA para comunicación sin contraseña (necesario para Hadoop).
* **Persistencia:** Scripts listos para montar volúmenes de datos.
* **PySpark Ready:** Configurado para funcionar con Python 3.12 nativo de Ubuntu 24.04.

## 🛠️ Pre-requisitos

* Docker Desktop o Docker Engine.
* Git.

## 📦 Instalación y Uso

### 1. Clonar el repositorio
```bash
git clone git@github.com:hbojorg/bigdata-hadoop-pseudo-distributed-docker.git
