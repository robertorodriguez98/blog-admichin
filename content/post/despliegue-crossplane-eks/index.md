---
title: "Despliegue de EKS usando CrossPlane + ArgoCD"
date: 2023-07-14T03:52:34+02:00
draft: true
---

## Objetivos que se quieren conseguir

Los objetivos que se quieren conseguir son los siguientes:
* Lograr una mayor **comprensión** de lo que es **Crossplane** y sus posibles aplicaciones.
* **Automatización**: La definición de la infraestructura como código y la automatización del proceso de implementación y gestión de la infraestructura permite a los equipos de desarrollo y operaciones centrarse en tareas más importantes y reducir los errores humanos.
* **Escalabilidad**: Otra ventaja de Kubernetes es su capacidad de escalar automáticamente, tanto hacia arriba como hacia abajo, en función de las necesidades del sistema. Al utilizar Crossplane para gestionar la infraestructura de AWS, se pueden aprovechar las capacidades de escalabilidad de AWS y de Kubernetes para garantizar que el sistema siempre tenga los recursos necesarios para funcionar correctamente.
* **Portabilidad**: Al utilizar Crossplane, se puede asegurar que la infraestructura es portátil y se puede mover fácilmente a otras nubes o proveedores de infraestructura en el futuro. Esto permite a las organizaciones evitar el bloqueo de proveedores y aprovechar las ventajas de diferentes proveedores de nube según sea necesario.
* **Costes**: La utilización de una infraestructura basada en la nube puede ser costosa, por lo que es importante asegurarse de que los recursos se utilizan de manera eficiente y se minimizan los costos innecesarios. Al utilizar Crossplane para gestionar la infraestructura de AWS, se puede optimizar el uso de los recursos y evitar pagar por recursos no utilizados.

### ¿Por qué Crossplane?

La **principal ventaja** de Crossplane es que, aún existiendo frameworks que permitan desplegar la misma infraestructura, Crossplane traslada esas interacciones a **kubernetes**, utilizando sus comandos propios y sus métodos.  Esto quiere decir que, por ejemplo, habiendo desplegado un clúster en AWS, se crean automáticamente los siguientes objetos de kubernetes enlazados a la api de AWS:

![objetos de kubernetes creados](https://i.imgur.com/A8vDXMj.png)

Además, utilizando kubectl podemos obtener aún más información acerca de estos objetos, dentro del propio clúster local:

![cluster local](https://i.imgur.com/hlc1Rae.png)

En la imagen se puede obtener toda la información referente a el objeto indicado, en este caso un nodegroup, y podemos ver, por ejemplo, el rol de nodo que tiene asignado, la región en la que se encuentra, las subredes disponibles… 

Aparte de eso, las ventajas que tiene frente el principal competidor, terraform, son:
* **Ficheros más entendibles (YAML)**: Crossplane utiliza archivos YAML para definir la infraestructura, lo que los hace más fáciles de entender y leer para los desarrolladores que pueden estar más familiarizados con el formato YAML. Terraform, por otro lado, utiliza su propio lenguaje de configuración llamado HCL (HashiCorp Configuration Language), que puede tener una curva de aprendizaje para aquellos que no están familiarizados con él.
* **Permite desplegar indistintamente en los proveedores cloud**: Crossplane se enfoca en la gestión de la infraestructura multi-nube, lo que significa que permite a los usuarios definir y gestionar recursos en múltiples proveedores de nube utilizando la misma sintaxis de Kubernetes. Terraform también soporta múltiples proveedores de nube, pero requiere la definición de cada recurso utilizando un proveedor de nube específico.
* **Metodología GitOps**: Crossplane está diseñado para trabajar en una metodología GitOps, lo que significa que todas las definiciones de recursos se almacenan en un repositorio Git y los cambios se aplican automáticamente al clúster de Kubernetes utilizando un proceso de integración y entrega continua (CI/CD). Terraform no está diseñado específicamente para trabajar con GitOps, aunque puede integrarse con sistemas de control de versiones como Git para almacenar y gestionar el código de infraestructura.

## Fundamentos teóricos y conceptos

### Kubernetes

Kubernetes o k8s para acortar, es una plataforma de sistema distribuido de código libre para la automatización del despliegue, ajuste de escala y manejo de aplicaciones. Una de las principales ventajas de Kubernetes es que ofrece una plataforma común para el desarrollo y la producción de aplicaciones. Esto significa que los equipos de desarrollo pueden crear aplicaciones en sus equipos y luego trasladarlas sin problemas a un entorno de producción utilizando las mismas herramientas y procesos. Kubernetes proporciona una capa de abstracción entre la infraestructura subyacente y las aplicaciones que se ejecutan en ella, lo que facilita la portabilidad de las aplicaciones entre diferentes plataformas y proveedores de nube. Además, Kubernetes ofrece características de autoreparación, lo que significa que las aplicaciones pueden recuperarse automáticamente de fallos en tiempo de ejecución, sin necesidad de intervención humana. 

#### Plano de control

El plano de control de Kubernetes es el conjunto de componentes que se encargan de gestionar el estado del clúster y de coordinar todas las operaciones en el mismo. Estos componentes son responsables de tomar decisiones sobre la orquestación y el escalado de los contenedores y aplicaciones en el clúster, y de garantizar que el estado deseado del clúster se mantenga en todo momento.

### GitOps

La metodología GitOps es un enfoque para la entrega continua de aplicaciones en la nube que utiliza Git como fuente de verdad para la configuración y la implementación de la infraestructura y las aplicaciones. En la metodología GitOps, todas las definiciones de la infraestructura y las aplicaciones se almacenan en un repositorio Git centralizado. Los cambios en el repositorio Git son automáticamente detectados por una herramienta de despliegue, que se encarga de implementar los cambios en la infraestructura y las aplicaciones.

La metodología GitOps se basa en los principios de la automatización, la colaboración y la transparencia. En primer lugar, la metodología GitOps 

* **Automatización** de la gestión de la infraestructura y las aplicaciones, lo que permite la implementación continua de cambios en un entorno controlado y seguro.
* **Colaboración** entre los miembros del equipo, ya que todos los cambios se realizan en el repositorio Git centralizado, lo que permite a los miembros del equipo trabajar en conjunto de manera más eficiente.
* **Transparencia**, ya que todos los cambios y versiones se registran en el repositorio Git centralizado, lo que permite a los miembros del equipo revisar y rastrear el historial de cambios.

### ArgoCD

Argo CD es una herramienta de entrega continua (Continuous Delivery) y de operaciones de infraestructura (Infrastructure Operations) que se ejecuta en Kubernetes. Permite la automatización y el control del proceso de implementación y despliegue de aplicaciones en un clúster de Kubernetes.

![ArgoCD](https://i.imgur.com/893wkC8.png)

Una de las características más destacadas de Argo CD es su capacidad para automatizar la gestión de versiones y el despliegue de aplicaciones. Permite la definición de flujos de trabajo (workflows) para la implementación de cambios, lo que garantiza que los cambios se realicen de manera controlada y segura. Argo CD también incluye características de seguridad, como el control de acceso basado en roles y la autenticación de usuarios.

### Infraestructura como código

Es una práctica que consiste en definir la infraestructura de una aplicación o sistema de forma programática utilizando un lenguaje de programación o una sintaxis específica. En lugar de configurar manualmente servidores, redes y otros recursos de infraestructura, los desarrolladores y los equipos de operaciones pueden definir la infraestructura como código y utilizar herramientas de automatización para gestionar y desplegar la infraestructura en un entorno reproducible y escalable.

### Crossplane

Crossplane es una extensión de kubernetes que transforma kubernetes en un **plano de control Universal**. Permite a los usuarios utilizar cualquier API como si fuera nativa de Kubernetes. Esto se logra mediante el uso de los recursos personalizados de Kubernetes (CRD), que permiten a los desarrolladores definir y extender los recursos de Kubernetes con sus propias definiciones. Puede crear y gestionar recursos que no son nativos de Kubernetes, como bases de datos, servicios de almacenamiento en la nube, cuentas de usuario y cualquier otra cosa que una API pueda ofrecer.

Además, Crossplane es compatible con **múltiples proveedores de nube**, lo que significa que los usuarios pueden utilizar cualquier servicio de cualquier proveedor de nube, incluidos Amazon Web Services, Google Cloud Platform y Microsoft Azure, entre otros. Esto permite a los usuarios crear **aplicaciones que utilizan servicios de varios proveedores de nube** sin tener que preocuparse por la complejidad de gestionar múltiples APIs de nube diferentes.

![Crossplane](https://i.imgur.com/fJhMKBU.png)

#### Proveedor

Un proveedor de Crossplane le permite aprovisionar una **infraestructura en un servicio externo**. se utiliza, entre otras cosas, para la autenticación, la realización de llamadas a API externas y utilizando APIs de kubernetes. 

Para utilizar un proveedor además, es necesaria una configuración. Ésta se realiza por medio del uso de **providerConfig**. Normalmente se utilizan para autenticarse con la API con la que se está comunicando, En este proyecto, se utilizan tanto con las credenciales de **AWS** como con el **clúster de EKS**.

## Escenario realizado

El escenario consiste en lo siguiente:
* Clúster local de kubernetes, en el que se han instalado las siguientes aplicaciones:
    * ArgoCD
    * Crossplane, con los proveedores de AWS y Kubernetes.
* Clúster de EKS creado y gestionado por Crossplane, en el que hay 3 nodos.

![Escenario](https://i.imgur.com/5KqPm1R.png)

### Instalaciones

Para la realización del proyecto, se necesita instalar los siguientes recursos:

#### Clúster local de kubernetes

Para desplegar un clúster local de k8s, se usará **kind**, ya que el proveedor de aws de crossplane consume muchos recursos, y kind es más liviano. Para su instalación se seguirá la documentación oficial: [Instalación kind](https://kind.sigs.k8s.io/docs/user/quick-start/). Para gestionar el clúster también es necesario kubectl, y la documentación oficial de instalación es la siguiente: [instalación kubectl](https://kubernetes.io/es/docs/tasks/tools/install-kubectl/). Es muy importante partir de un **clúster nuevo** y sin configuraciones previas.

#### ArgoCD

Para instalar ArgoCD se ejecutan los siguientes comandos:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Para acceder a la página de administración, necesito la contraseña inicial. Se obtiene con el siguiente comando; el usuario es admin:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d;echo
```

Y para acceder a la página, se realiza el siguiente port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80 --address=0.0.0.0
```

Tras eso ya está configurado ArgoCD.

#### Crossplane

Para instalar crossplane utilizamos helm

```bash
helm repo add \
crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
crossplane-stable/crossplane \
--namespace crossplane-system \
--create-namespace
```

### Configuración

#### AWS

Es necesaria una cuenta con los permisos de AWS para crear y gestionar los siguientes recursos:
* instancias EC2
* clúster de EKS
* redes VPC
* Tokens de acceso a la propia cuenta
Una vez se disponga de dicha cuenta, creamos el token en el siguiente apartado:

credenciales de seguridad > crear clave de acceso > seleccionamos el cuadro y 	crear clave de acceso > descargar archivo.csv

#### Proveedores de Crossplane

##### AWS

Ahora instalamos la última versión del provider de AWS de crossplane

```bash
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-aws:v0.39.0
EOF
```

Tras eso, creamos el fichero **aws-credentials.txt** con las claves generadas en AWS con el siguiente formato:

```bash
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Creamos un **secret** de kubernetes con las credenciales

```bash
kubectl create secret \
generic aws-creds \
-n crossplane-system \
--from-file=creds=./aws-credentials.txt
```

Finalmente, se crea un **providerconfig** con el secret que hemos creado

```bash
cat <<EOF | kubectl apply -f -
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds
EOF
```

##### kubernetes

Instalamos el proveedor con el siguiente comando:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-kubernetes
spec:
  package: crossplane/provider-kubernetes:main
EOF
```

#### Recursos gestionados

Para desplegar un clúster de aws de forma sencilla, se van a utilizar dos recursos gestionados (managed resources):

* **eks.yaml**, de tipo composition que contiene parámetros para la creación del clúster, como lo son las redes que se crearán, en qué servidores, qué tipo de máquinas pueden crearse, etc..
* **definition.yaml**, de tipo compositeResourceDefinition, contiene los parámetros que se le van a pasar con el manifiesto final, así como los recursos  a los que corresponden en composition. También contiene valores por defecto.

Ambos ficheros se encuentran en el repositorio del proyecto en la carpeta crossplane:
https://github.com/robertorodriguez98/proyecto-integrado/tree/main/crossplane

Para añadirlos, se utiliza kubectl:

```bash
kubectl apply -f eks.yaml && kubectl apply -f definition.yaml
```

#### Ngrok

Para que ArgoCD esté atento a los commits de github y siga así la metodología GitOps, al tenerlo instalado en un clúster local, es necesario instalar ngrok, exponiendo el puerto 8080:

```bash
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
```

Añadimos el token:

```bash	
ngrok config add-authtoken [TOKEN]
```

y exponemos el puerto:

```bash
ngrok http https://localhost:8080
```

#### Webhook

Para que GitHub notifique a ArgoCD en el evento de un push al repositorio, tenemos que añadirlo en la configuración del mismo. Para hacerlo, en el repositorio accedemos al apartado **Settings**; en la barra lateral seleccionamos **Webhooks** y **Add webhook**.

Dentro de la página, tenemos que rellenar los siguientes campos:
* **Payload URL**: la url generada por Ngrok, con la cadena /api/webhook añadida al final.
* **Content type**: application/json.
* **Event**: Cuando se produce un 

#### Preparación previa a la demo

Para preparar la demo, iniciaremos la aplicación de argocd **app.yaml** que se encuentra en el repositorio, ésta despliega el siguiente manifiesto:

```yaml
apiVersion: prodready.cluster/v1alpha1
kind: ClusterClaim
metadata:
  name: proyecto-eks
  labels:
    cluster-owner: robertorm
spec:
  id: proyecto-eks
  compositionSelector:
    matchLabels:
      provider: aws
      cluster: eks
  parameters:
    nodeSize: medium
    minNodeCount: 3
```

Donde podemos modificar los siguientes parámetros:

* **name**: Nombre del clúster.
* **nodesize**: tipo de máquina que se van a utilizar en los nodos. En el fichero eks.yaml se establecen los siguientes tamaños:
    * small: t2:micro
    * medium: t3.micro
    * large: t3.medium

    Los dos primeros tamaños, entran dentro de la capa gratuita de AWS.
* **minNodeCount**: mínimo de nodos que tienen que crearse en el clúster.

Tras aproximadamente **15 minutos**, el clúster estará creado junto a sus nodos. Si observamos el panel de ArgoCD de la aplicación, podemos ver todos los recursos de AWS que se han desplegado:

![ArgoCD](https://i.imgur.com/CaTYVUb.png)

## Demostraciones

### Modificación del número de nodos

El escenario final de la demo es el siguiente:

![Escenario](https://i.imgur.com/5KqPm1R.png)
