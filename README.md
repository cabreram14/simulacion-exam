# Evaluación Práctica - Guía de Estudio

# Evidencias Iniciales

Antes de modificar cualquier archivo relacionado con Docker, Kubernetes o CI/CD, es necesario verificar que la aplicación funciona correctamente de manera local. Esto permite asegurar que cualquier error posterior proviene de la infraestructura y no del código de la aplicación.

---

# Evidencia 1 - Instalación de dependencias

## Objetivo

Instalar todas las dependencias definidas por el proyecto y verificar que no existan problemas antes de comenzar la evaluación.

## Comando

```powershell
npm install
```

## ¿Qué hace este comando?

- Lee el archivo `package.json`.
- Descarga las dependencias necesarias del proyecto.
- Crea (o actualiza) la carpeta `node_modules`.
- Realiza una auditoría básica de seguridad de los paquetes instalados.

## Resultado esperado

```text
up to date, audited 1 package

found 0 vulnerabilities
```

## Explicación

- **up to date:** Todas las dependencias ya estaban instaladas.
- **audited:** npm revisó las dependencias buscando vulnerabilidades conocidas.
- **0 vulnerabilities:** No se encontraron problemas de seguridad.

---

# Evidencia 2 - Pruebas automatizadas

## Objetivo

Verificar que la aplicación funciona correctamente antes de modificar Docker o Kubernetes.

## Comando

```powershell
npm test
```

## Resultado esperado

```text
✔ GET / responde 200 con un mensaje y una versión
✔ una ruta inexistente responde 404

tests 2
pass 2
fail 0
```

## ¿Qué valida esta prueba?

### Primera prueba

Comprueba que la ruta principal (`GET /`) responda correctamente con:

- Código HTTP 200
- Mensaje de la aplicación
- Versión

### Segunda prueba

Comprueba que una ruta inexistente responda correctamente con un código HTTP 404.

## Explicación

Antes de trabajar con Docker es importante demostrar que la aplicación funciona correctamente de forma local. Si las pruebas fallaran en este punto, el problema pertenecería al código de la aplicación y no a Docker o Kubernetes.

---

# Evidencia 3 - Aplicación funcionando localmente

## Objetivo

Comprobar que la aplicación puede ejecutarse fuera de Docker y responder correctamente mediante HTTP.

## Iniciar la aplicación

```powershell
node server.js
```

## Probar desde otra terminal

```powershell
curl.exe http://localhost:8080/
```

O abrir en el navegador:

```
http://localhost:8080
```

## Resultado esperado

La aplicación debe responder con un mensaje similar al siguiente:

```json
{
  "message": "...",
  "app": "app-ejemplo-evaluacion",
  "version": "1.0.0"
}
```

## Explicación

Esta evidencia confirma que:

- La aplicación inicia correctamente.
- Escucha en el puerto esperado.
- Responde correctamente a las solicitudes HTTP.

Con esta verificación se garantiza que cualquier problema encontrado posteriormente pertenece a Docker o Kubernetes y no a la aplicación.

--- 

# RETO 1

## Evidencia 1 - Construcción de la imagen

### Comando ejecutado

```powershell
docker build -t simulacion-reto-1 .
```

### Explicación

Este comando construye una imagen Docker utilizando el `Dockerfile` ubicado en el directorio actual.

- `docker build`: inicia la construcción de la imagen.
- `-t simulacion-reto-1`: asigna un nombre a la imagen.
- `.`: indica que el contexto de construcción es la carpeta actual.

Durante el proceso Docker ejecuta las instrucciones del Dockerfile (`FROM`, `WORKDIR`, `COPY`, `RUN`, etc.) hasta generar una imagen lista para crear contenedores.

### Resultado esperado

La construcción debe finalizar correctamente y registrar la imagen con el nombre:

```text
simulacion-reto-1:latest
```
---

## Evidencia 2 - Contenedor en ejecución

### Comando para crear el contenedor

```powershell
docker run -d --name reto1-container -p 3000:3000 simulacion-reto-1
```

### Explicación

- `docker run`: crea e inicia un contenedor.
- `-d`: ejecuta el contenedor en segundo plano.
- `--name reto1-container`: asigna un nombre al contenedor.
- `-p 3000:3000`: conecta el puerto 3000 del equipo anfitrión con el puerto 3000 del contenedor.
- `simulacion-reto-1`: imagen utilizada.

### Verificación

```powershell
docker ps
```

El resultado muestra que el contenedor está en estado `Up` y que el puerto 3000 está publicado.

Sin embargo, que el contenedor esté activo no garantiza que la aplicación esté escuchando en ese puerto.

---
# Evidencia 3 - Intento fallido de acceso a la aplicación

## Prueba de acceso

Ejecutar el siguiente comando:

```powershell
curl.exe http://localhost:3000/
```

También se puede realizar la prueba ingresando desde un navegador a:

```
http://localhost:3000
```

## Resultado esperado

La aplicación **no responde correctamente**, aun cuando el contenedor aparece en estado `Up`.

Dependiendo del entorno, puede ocurrir alguno de los siguientes casos:

- La conexión permanece esperando respuesta.
- Se obtiene un mensaje de error como:

```text
curl: (7) Failed to connect to localhost port 3000
```

o

```text
ERR_EMPTY_RESPONSE
```

o cualquier otro error indicando que no fue posible establecer la conexión.'

---

