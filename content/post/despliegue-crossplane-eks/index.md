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