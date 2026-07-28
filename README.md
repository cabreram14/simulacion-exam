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

--- 
# Reto 2 - Kubernetes: Pods listos, Service sin tráfico

# Preparación del entorno

## 1. Ubicarse en la carpeta del proyecto

```powershell
cd "C:\Users\Sebas\Downloads\app-ejemplo-evaluacion\app-ejemplo-evaluacion"
```

Verificar la ubicación actual:

```powershell
pwd
```

---

## 2. Verificar que Minikube esté ejecutándose

```powershell
minikube status
```

Resultado esperado:

```text
host: Running
kubelet: Running
apiserver: Running
```

---

## 3. Verificar la conexión con Kubernetes

```powershell
kubectl get nodes
```

Resultado esperado:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   ...
```

Esto confirma que el clúster está disponible para recibir recursos.

---

## 4. Verificar la imagen Docker

La aplicación construida en el Reto 1 debe existir localmente.

```powershell
docker images
```

Resultado esperado:

```text
simulacion-reto-1    corregido
```

---

## 5. Etiquetar la imagen

El manifiesto utilizará la siguiente imagen:

```text
app-ejemplo-evaluacion:latest
```

Por ello se crea una nueva etiqueta:

```powershell
docker tag simulacion-reto-1:corregido app-ejemplo-evaluacion:latest
```

Verificar:

```powershell
docker images
```

---

## 6. Cargar la imagen en Minikube

```powershell
minikube image load app-ejemplo-evaluacion:latest
```

Verificar:

```powershell
minikube image ls | Select-String "app-ejemplo-evaluacion"
```

La imagen debe aparecer dentro del entorno de Minikube.

---

# Creación del manifiesto

## Crear el archivo

```powershell
New-Item kubernetes-reto2.yaml
```

Abrir en Visual Studio Code:

```powershell
code kubernetes-reto2.yaml
```

---

## Contenido del manifiesto inicial

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: app-ejemplo-evaluacion:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

> **Importante:** El separador `---` es obligatorio para definir más de un recurso dentro del mismo archivo YAML.

---

# Validación del manifiesto

Antes de aplicarlo, validar la sintaxis:

```powershell
kubectl apply --dry-run=client -f kubernetes-reto2.yaml
```

Resultado esperado:

```text
deployment.apps/web-deployment created (dry run)
service/web-service configured (dry run)
```

---

# Aplicación del manifiesto

```powershell
kubectl apply -f kubernetes-reto2.yaml
```

Resultado esperado:

```text
deployment.apps/web-deployment created
service/web-service created
```

---

# Evidencia 1

Aplicación correcta del manifiesto inicial.

**Captura requerida:**

- `kubectl apply -f kubernetes-reto2.yaml`

---

# Evidencia 2

Verificar los Pods creados.

```powershell
kubectl get pods
```

o

```powershell
kubectl get pods -l app=web
```

Resultado esperado:

```text
READY   STATUS
1/1     Running
1/1     Running
```

En esta etapa los Pods deben encontrarse en estado **Running**.

**Captura requerida:**

- `kubectl get pods`

---

# Evidencia 3

Verificar el Service.

```powershell
kubectl get svc
```

Consultar los Endpoints:

```powershell
kubectl get endpoints web-service
```

o

```powershell
kubectl describe service web-service
```

En este punto el Service no tendrá Endpoints válidos debido a que busca Pods con la etiqueta:

```yaml
app: webapp
```

mientras que los Pods poseen:

```yaml
app: web
```

Este será el diagnóstico del problema.

---

# Evidencia 4 - Corrección del selector del Service

## Configuración incorrecta

Los Pods fueron creados con la etiqueta:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: webapp
  ports:
    - port: 80
      targetPort: 8080
```

Sin embargo, el Service buscaba Pods con:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
    # app: webapp
  ports:
    - port: 80
      targetPort: 8080
```

Debido a esta diferencia, el Service no podía asociarse con los Pods y no tenía endpoints disponibles.

## Corrección aplicada

Se modificó el selector del Service:

```yaml
spec:
  selector:
    app: web
```

Ahora el selector coincide con la etiqueta de los Pods.

## Validación del manifiesto

```powershell
kubectl apply --dry-run=client -f .\kubernetes-reto2.yaml
```

## Aplicación de la corrección

```powershell
kubectl apply -f .\kubernetes-reto2.yaml
```

Resultado esperado:

```text
deployment.apps/web-deployment unchanged
service/web-service configured
```
---

# Evidencia 5 - Service con endpoints válidos


## Comando ejecutado

```powershell
kubectl get endpoints web-service
```

También se utilizó:

```powershell
kubectl describe service web-service
```

## Resultado esperado

El Service debe mostrar las direcciones IP de los dos Pods en el puerto 8080:

```text
web-service   10.244.x.x:8080,10.244.x.x:8080
```

## Explicación

Kubernetes compara el selector del Service con las etiquetas de los Pods.

Después de corregir el selector a:

```yaml
app: web
```

el Service encontró los Pods que tienen la misma etiqueta y creó los endpoints correspondientes.

## Evidencia

Captura de:

```powershell
kubectl get endpoints web-service
```

mostrando dos endpoints válidos.

--- 

# Evidencia 6 - Petición exitosa mediante el Service

## Creación del acceso temporal

```powershell
kubectl port-forward service/web-service 8081:80
```

### Explicación

Este comando conecta temporalmente:

```text
Puerto 8081 del equipo → Puerto 80 del Service
```

El Service recibe la solicitud en el puerto 80 y la envía al puerto 8080 de uno de los Pods mediante `targetPort`.

## Prueba desde otra terminal

```powershell
curl.exe http://localhost:8081/
```

También puede utilizarse el navegador:

```text
http://localhost:8081
```

## Resultado esperado

La aplicación debe responder con un contenido JSON que incluya su mensaje, nombre y versión.

## Flujo de comunicación

```text
Cliente
  ↓ localhost:8081
Port-forward
  ↓
Service web-service:80
  ↓
Pods:8080
```

## Conclusión

La aplicación respondió correctamente mediante el Service de Kubernetes. Esto confirma que:

- Los Pods están en ejecución.
- El selector del Service coincide con las etiquetas de los Pods.
- El Service tiene endpoints válidos.
- El puerto 80 del Service dirige el tráfico al puerto 8080 de los contenedores.

--- 
# Reto 3 - CI/CD: despliegue ejecutado aunque las pruebas fallen

## Objetivo

Asegurar que el despliegue solo pueda ejecutarse cuando el proceso de instalación, construcción y pruebas termine exitosamente.

El pipeline inicial presenta un defecto: el trabajo de despliegue no depende del trabajo que ejecuta las pruebas. Por lo tanto, ambos trabajos pueden ejecutarse independientemente.

---

## 1. Creación de la carpeta de GitHub Actions

Desde la raíz del proyecto se creó la carpeta utilizada por GitHub para almacenar los workflows:

```powershell
New-Item -ItemType Directory -Force .github\workflows
```

Se verificó su creación mediante:

```powershell
Get-ChildItem .github\workflows
```

GitHub reconoce automáticamente los archivos YAML que se encuentran dentro de:

```text
.github/workflows/
```

---

## 2. Creación del archivo del pipeline

Se creó el archivo:

```powershell
New-Item -ItemType File -Force .github\workflows\ci-cd.yml
```

Posteriormente se abrió con Visual Studio Code:

```powershell
code .github\workflows\ci-cd.yml
```

---

## 3. Pipeline inicial

Se agregó el siguiente workflow:

```yaml
name: ci-cd

on:
  push:
    branches:
      - main

jobs:
  build-test:
    runs-on: ubuntu-latest

    steps:
      - name: Descargar repositorio
        uses: actions/checkout@v4

      - name: Configurar Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Instalar dependencias
        run: npm ci

      - name: Ejecutar pruebas
        run: npm test

  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Descargar repositorio
        uses: actions/checkout@v4

      - name: Simular construcción de imagen
        run: echo "Construyendo imagen app:${{ github.sha }}"

      - name: Simular publicación de imagen
        run: echo "Publicando imagen registry/app:${{ github.sha }}"

      - name: Simular despliegue
        run: echo "Desplegando registry/app:${{ github.sha }} en Kubernetes"
```

---

## 4. Explicación del pipeline inicial

El workflow se ejecuta cuando se realiza un `push` sobre la rama:

```yaml
branches:
  - main
```

El job `build-test` realiza las siguientes actividades:

1. Descarga el código del repositorio.
2. Configura Node.js.
3. Instala las dependencias con `npm ci`.
4. Ejecuta las pruebas mediante `npm test`.

El job `deploy` simula:

1. La construcción de la imagen.
2. La publicación de la imagen.
3. El despliegue en Kubernetes.

En la versión inicial no existe una dependencia entre ambos jobs. Por esta razón, GitHub Actions puede ejecutar `build-test` y `deploy` de manera independiente.

La estructura inicial es:

```text
Push
 ├── build-test
 └── deploy
```

Este comportamiento será utilizado para demostrar el defecto solicitado en el reto.

---

## 5. Registro del pipeline en Git

Se verificaron los cambios:

```powershell
git status
```

Se agregó el archivo del workflow:

```powershell
git add .github/workflows/ci-cd.yml
```

Se creó el commit:

```powershell
git commit -m "Reto 3 - Agregar pipeline CI CD inicial defectuoso"
```

Finalmente, se publicó el cambio en GitHub:

```powershell
git push
```

---
# Reto 3 - CI/CD: despliegue ejecutado aunque las pruebas fallen

## Objetivo

Asegurar que el despliegue solo pueda ejecutarse cuando el proceso de instalación, construcción y pruebas termine exitosamente.

El pipeline inicial presenta un defecto: el trabajo de despliegue no depende del trabajo que ejecuta las pruebas. Por lo tanto, ambos trabajos pueden ejecutarse independientemente.

---

## 1. Creación de la carpeta de GitHub Actions

Desde la raíz del proyecto se creó la carpeta utilizada por GitHub para almacenar los workflows:

```powershell
New-Item -ItemType Directory -Force .github\workflows
```

Se verificó su creación mediante:

```powershell
Get-ChildItem .github\workflows
```

GitHub reconoce automáticamente los archivos YAML que se encuentran dentro de:

```text
.github/workflows/
```

---

## 2. Creación del archivo del pipeline

Se creó el archivo:

```powershell
New-Item -ItemType File -Force .github\workflows\ci-cd.yml
```

Posteriormente se abrió con Visual Studio Code:

```powershell
code .github\workflows\ci-cd.yml
```

---

## 3. Pipeline inicial

Se agregó el siguiente workflow:

```yaml
name: ci-cd

on:
  push:
    branches:
      - main

jobs:
  build-test:
    runs-on: ubuntu-latest

    steps:
      - name: Descargar repositorio
        uses: actions/checkout@v4

      - name: Configurar Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Instalar dependencias
        run: npm ci

      - name: Ejecutar pruebas
        run: npm test

  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Descargar repositorio
        uses: actions/checkout@v4

      - name: Simular construcción de imagen
        run: echo "Construyendo imagen app:${{ github.sha }}"

      - name: Simular publicación de imagen
        run: echo "Publicando imagen registry/app:${{ github.sha }}"

      - name: Simular despliegue
        run: echo "Desplegando registry/app:${{ github.sha }} en Kubernetes"
```

---

## 4. Explicación del pipeline inicial

El workflow se ejecuta cuando se realiza un `push` sobre la rama:

```yaml
branches:
  - main
```

El job `build-test` realiza las siguientes actividades:

1. Descarga el código del repositorio.
2. Configura Node.js.
3. Instala las dependencias con `npm ci`.
4. Ejecuta las pruebas mediante `npm test`.

El job `deploy` simula:

1. La construcción de la imagen.
2. La publicación de la imagen.
3. El despliegue en Kubernetes.

En la versión inicial no existe una dependencia entre ambos jobs. Por esta razón, GitHub Actions puede ejecutar `build-test` y `deploy` de manera independiente.

La estructura inicial es:

```text
Push
 ├── build-test
 └── deploy
```

Este comportamiento será utilizado para demostrar el defecto solicitado en el reto.

---

## 5. Registro del pipeline en Git

Se verificaron los cambios:

```powershell
git status
```

Se agregó el archivo del workflow:

```powershell
git add .github/workflows/ci-cd.yml
```

Se creó el commit:

```powershell
git commit -m "Reto 3 - Agregar pipeline CI CD inicial defectuoso"
```

Finalmente, se publicó el cambio en GitHub:

```powershell
git push
```

---

## Evidencia 1 - Pipeline inicial

Después del `push`, GitHub Actions ejecutó automáticamente el workflow denominado:

```text
ci-cd
```

En la primera ejecución se observaron los dos trabajos:

```text
build-test
deploy
```

Esta ejecución representa el estado inicial del pipeline antes de provocar intencionalmente una prueba fallida.

--- 
## Evidencia 2 - Prueba fallida provocada intencionalmente


### Modificación realizada

En el archivo de pruebas se modificó intencionalmente una validación.

La prueba originalmente esperaba que el endpoint respondiera con el código HTTP:

```javascript
assert.equal(response.statusCode, 200);
```

Se cambió temporalmente por:

```javascript
assert.equal(response.statusCode, 500);
```

La aplicación continuó respondiendo correctamente con el código `200`, pero la prueba esperaba incorrectamente un código `500`.

### Ejecución local

Se ejecutó:

```powershell
npm test
```

El resultado mostró una prueba fallida:

```text
tests 2
pass 1
fail 1
```

La falla fue intencional y controlada. No se modificó el código funcional de la aplicación.

### Registro en Git

```powershell
git status
git add .
git commit -m "Reto 3 - Provocar falla intencional en las pruebas"
git push
```

El `push` activó automáticamente el workflow de GitHub Actions.

### Evidencia requerida

Captura de la terminal mostrando el resultado fallido de `npm test`.

---

## Evidencia 3 - Comportamiento defectuoso del pipeline inicial


### Resultado observado

Después de subir la prueba defectuosa, GitHub Actions ejecutó los dos jobs del pipeline:

```text
build-test
deploy
```

El job `build-test` falló durante el comando:

```powershell
npm test
```

Sin embargo, el job `deploy` se ejecutó exitosamente.

La ejecución presentó el siguiente estado:

```text
build-test ❌
deploy     ✅
```

### Causa del problema

El job `deploy` no tenía una dependencia explícita respecto al job `build-test`.

La estructura inicial era:

```text
Push
 ├── build-test
 └── deploy
```

Ambos jobs podían ejecutarse de manera independiente y en paralelo.

Por esta razón, el fallo de las pruebas no impedía que se ejecutara el despliegue.

--- 

## Evidencia 4 - Workflow corregido



### Problema identificado

En el workflow inicial, los trabajos `build-test` y `deploy` no tenían una dependencia explícita:

```text
Push
 ├── build-test
 └── deploy
```

Por esta razón, ambos podían ejecutarse de manera independiente.

### Corrección aplicada

Se agregó la propiedad `needs` al job `deploy`:

```yaml
deploy:
  needs: build-test
  runs-on: ubuntu-latest
```

La nueva estructura del pipeline es:

```text
Push
  ↓
build-test
  ↓
deploy
```

La instrucción:

```yaml
needs: build-test
```

obliga al job `deploy` a esperar la finalización del job `build-test`.

Si `build-test` falla, GitHub Actions no ejecutará el despliegue.

### Verificación del cambio

```powershell
git diff
```

También se revisó el archivo completo mediante:

```powershell
Get-Content .github\workflows\ci-cd.yml
```

### Registro en Git

```powershell
git add .github/workflows/ci-cd.yml
git commit -m "Reto 3 - Condicionar despliegue al resultado de las pruebas"
git push
```
--- 

## Evidencia 5 - Pruebas fallidas y despliegue bloqueado

### Objetivo

Comprobar que el despliegue no se ejecuta cuando las pruebas automatizadas fallan.

### Condición utilizada

La prueba continuaba modificada intencionalmente para esperar un código HTTP incorrecto:

```javascript
assert.equal(response.statusCode, 500);
```

Sin embargo, la aplicación respondía correctamente con:

```text
200
```

Esto provocó que el job `build-test` fallara durante:

```powershell
npm test
```

### Resultado del pipeline corregido

Después de agregar:

```yaml
needs: build-test
```

el pipeline presentó el siguiente resultado:

```text
build-test ❌
deploy     ⏭️ Skipped
```

### Interpretación

El trabajo `deploy` reconoció que su dependencia `build-test` no terminó exitosamente.

Por ello, GitHub Actions omitió completamente la etapa de despliegue.

La estructura observada fue:

```text
build-test ❌
     ↓
deploy omitido
```

Este comportamiento evita publicar o desplegar una versión cuyo código no ha superado las pruebas automatizadas.

--- 

## Evidencia 6 - Pruebas aprobadas y despliegue ejecutado

### Restauración de la prueba

Se devolvió la expectativa de la prueba a su valor correcto:

```javascript
assert.equal(response.statusCode, 200);
```

### Validación local

Se ejecutó:

```powershell
npm test
```

El resultado fue:

```text
tests 2
pass 2
fail 0
```

Esto confirmó que el código superaba nuevamente todas las pruebas.

### Registro del cambio

```powershell
git add .
git commit -m "Reto 3 - Restaurar pruebas y validar pipeline corregido"
git push
```

### Resultado final del pipeline

GitHub Actions ejecutó primero el job `build-test`.

Como las pruebas terminaron exitosamente, se permitió la ejecución del job `deploy`:

```text
build-test ✅
     ↓
deploy ✅
```

Los pasos del despliegue fueron ejecutados correctamente:

```text
Simular construcción de imagen
Simular publicación de imagen
Simular despliegue
```

### Conclusión

La corrección mediante:

```yaml
needs: build-test
```

garantiza que el despliegue solo se ejecute cuando la instalación y las pruebas terminan exitosamente.

El comportamiento final cumple el objetivo del reto:

- Con pruebas fallidas, el despliegue es omitido.
- Con pruebas aprobadas, el despliegue se ejecuta.
- El orden entre las etapas queda explícitamente definido.

### Evidencias requeridas

- Captura de `npm test` con todas las pruebas aprobadas.
- Captura de GitHub Actions con `build-test` exitoso.
- Captura del job `deploy` ejecutado después de `build-test`.

---

# Evidencia 1 - Estado inicial del Deployment

## Verificación del Deployment

```powershell
kubectl get deployment
```

Posteriormente se consultó la información detallada:

```powershell
kubectl describe deployment web-deployment
```

## Verificación de Pods

```powershell
kubectl get pods -o wide
```

## Información obtenida

Se verificó:

- Número de réplicas.
- Pods disponibles.
- Estado del Deployment.
- Estrategia de actualización configurada.

## Evidencia requerida

Captura de:

- `kubectl get deployment`
- `kubectl describe deployment`
- `kubectl get pods`

---

# Evidencia 2 - Escalamiento del Deployment


## Escalamiento

```powershell
kubectl scale deployment web-deployment --replicas=5
```

## Verificación

```powershell
kubectl get deployment

kubectl get pods
```

## Explicación

El Deployment incrementó el número de réplicas de la aplicación.

Kubernetes creó automáticamente nuevos Pods para distribuir la carga de trabajo.

## Evidencia requerida

Captura de:

- `kubectl scale`
- `kubectl get deployment`
- `kubectl get pods`

---

# Evidencia 3 - Estrategia de despliegue

## Configuración aplicada

```yaml
spec:
  replicas: 5

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

## Aplicación

```powershell
kubectl apply -f kubernetes-reto2.yaml
```

## Verificación

```powershell
kubectl describe deployment web-deployment
```

La estrategia Rolling Update permite reemplazar gradualmente los Pods antiguos por nuevos, manteniendo la disponibilidad del servicio.

## Evidencia requerida

Captura de `kubectl describe deployment web-deployment` mostrando la estrategia configurada.

---

# Evidencia 4 - Tráfico durante el despliegue

## Generación de tráfico

```powershell
kubectl port-forward service/web-service 8081:80
```

En otra terminal:

```powershell
while ($true) {
    curl.exe http://localhost:8081/
    Start-Sleep -Seconds 1
}
```

## Reinicio del Deployment

```powershell
kubectl rollout restart deployment web-deployment
```

## Monitoreo

```powershell
kubectl get pods -w
```

## Resultado esperado

Durante el reinicio, Kubernetes reemplaza los Pods uno por uno, mientras la aplicación continúa respondiendo a las solicitudes.

## Evidencia requerida

Capturas del tráfico continuo y del reemplazo de Pods.

---

# Evidencia 5 - Disponibilidad del servicio


## Verificación del despliegue

```powershell
kubectl rollout status deployment web-deployment
```

Resultado esperado:

```text
deployment "web-deployment" successfully rolled out
```

## Estado final

```powershell
kubectl get pods
```

Todos los Pods deben encontrarse en estado `Running`.

## Prueba final

```powershell
curl.exe http://localhost:8081/
```

La aplicación respondió correctamente después del despliegue.

## Conclusión

Gracias a la estrategia Rolling Update, Kubernetes reemplazó los Pods gradualmente, manteniendo la disponibilidad del servicio durante todo el proceso.

## Evidencia requerida

- Captura de `kubectl rollout status`.
- Captura de `kubectl get pods`.
- Captura de la respuesta final de la aplicación.