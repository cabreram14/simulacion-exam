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
docker build -t <NOMBRE DE LA IMAGEN> .
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
NOMBRE DE LA IMAGEN:latest
```
---

## Evidencia 2 - Contenedor en ejecución

### Comando para crear el contenedor

```powershell
docker run -d --name <NOMBRE CONTENEDOR> -p 3000:3000 <NOMBRE IMAGEN>
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

# Evidencia 4 - Diagnóstico e identificación de la causa


## Revisión de los registros

Comando utilizado:

```powershell
docker logs <NOMBRE CONTENEDOR>
```

## Revisión del servidor

Archivo revisado:

```text
server.js
```

Puerto identificado:

```javascript
const PORT = 8080;
```


## Revisión del Dockerfile

Archivo revisado:

```text
Dockerfile
```

Puerto expuesto:

```dockerfile
EXPOSE 3000
```

## Análisis

Se comparó la configuración del servidor con la configuración del contenedor.

| Elemento | Puerto |
|----------|--------|
| Aplicación (server.js) | 8080 |
| Dockerfile (EXPOSE) | 3000 |
| Publicación del contenedor | 3000 |

La aplicación escucha en un puerto diferente al que Docker expone y publica, lo que impide acceder al servicio desde la máquina anfitriona.


## Conclusión

Se identificó una inconsistencia en la configuración de puertos entre la aplicación y el Dockerfile. Esta diferencia provoca que las solicitudes enviadas al puerto publicado por Docker no lleguen al servicio que se ejecuta dentro del contenedor.

---

# Evidencia 5 - Corrección del Dockerfile

## Configuración inicial incorrecta

El Dockerfile declaraba:

```dockerfile
EXPOSE 3000
```

Sin embargo, la aplicación escucha internamente en el puerto `8080`.

## Corrección aplicada

Se modificó el Dockerfile para declarar el puerto correcto:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD ["node", "server.js"]
```

## Explicación

La instrucción `EXPOSE 8080` documenta que la aplicación utiliza el puerto 8080 dentro del contenedor.

`EXPOSE` no publica el puerto en la máquina anfitriona. La publicación se realiza al crear el contenedor mediante la opción `-p`.

## Eliminación del contenedor anterior

```powershell
docker stop <NOMBRE DEL CONTENEDO>
docker rm <NOMBRE DEL CONTENEDO>
```

También puede utilizarse:

```powershell
docker rm -f <NOMBRE DEL CONTENEDO>
```

El contenedor anterior debe eliminarse porque los cambios realizados en el Dockerfile no modifican contenedores existentes.

## Reconstrucción de la imagen

```powershell
docker build -t <NOMBRE DE LA IMAGEN> .
```

Se utilizó la etiqueta `corregido` para diferenciar la nueva imagen de la versión inicial defectuosa.

--- 

# Evidencia 6 - Validación de la solución

## Creación del contenedor corregido

```powershell
docker run -d --name NOMBRE DEL CONTENEDOR -p 8080:8080 NOMBRE DE LA IAMGEN
```

### Explicación

- `docker run`: crea e inicia un nuevo contenedor.
- `-d`: ejecuta el contenedor en segundo plano.
- `--name reto1-container-corregido`: asigna un nombre al nuevo contenedor.
- `-p 8080:8080`: conecta el puerto 8080 del host con el puerto 8080 del contenedor.
- `simulacion-reto-1:corregido`: utiliza la imagen reconstruida después de corregir el Dockerfile.

La publicación de puertos sigue la estructura:

```text
-p PUERTO_HOST:PUERTO_CONTENEDOR
```

## Verificación del contenedor

```powershell
docker ps
```

El contenedor debe aparecer en estado `Up` y mostrar el siguiente mapeo:

```text
0.0.0.0:8080->8080/tcp
```

## Revisión de registros

```powershell
docker logs NOMBRE CONTENEDOR
```

Los registros confirman que la aplicación inició correctamente y escucha en el puerto `8080`.

## Prueba de acceso

```powershell
curl.exe http://localhost:8080/
```

También se puede acceder desde el navegador mediante:

```text
http://localhost:8080
```

## Resultado

La aplicación responde correctamente con un contenido JSON que incluye el mensaje, el nombre y la versión de la aplicación.

## Conclusión

La solución fue exitosa porque se hizo coincidir:

| Elemento | Puerto |
|---|---:|
| Aplicación | 8080 |
| Dockerfile | 8080 |
| Puerto interno del contenedor | 8080 |
| Puerto publicado en el host | 8080 |

El problema inicial se debía a una configuración incorrecta de puertos. Después de corregir el Dockerfile, reconstruir la imagen y crear un nuevo contenedor, la aplicación quedó accesible desde la máquina anfitriona.
