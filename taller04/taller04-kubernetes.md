# Introducción a Kubernetes (K8s)
Kubernetes es una plataforma de orquestación de contenedores de código abierto que automatiza el despliegue, la escalabilidad y la gestión de aplicaciones en contenedores. Permite que los desarrolladores y los equipos de operaciones de TI puedan trabajar juntos de forma más eficiente y ágil.

## ¿Por qué usar Kubernetes?
Kubernetes simplifica el proceso de implementación y gestión de aplicaciones en contenedores, lo que significa que los equipos pueden centrarse en escribir código y no en administrar servidores y configuraciones de red. Algunas de las ventajas de utilizar Kubernetes incluyen:

Escalabilidad: Kubernetes permite que las aplicaciones se escalen automáticamente en función de la demanda, lo que significa que las aplicaciones pueden manejar más tráfico sin interrupciones.

Resiliencia: Kubernetes monitorea continuamente las aplicaciones y los contenedores y garantiza que se ejecuten correctamente. Si un contenedor falla, Kubernetes puede reiniciarlo automáticamente.

Portabilidad: Kubernetes se puede ejecutar en cualquier lugar, lo que significa que las aplicaciones se pueden mover fácilmente entre diferentes entornos, desde la nube pública hasta el centro de datos local.

## Arquitectura de Kubernetes
![k8s](./imagenes/k8s-architecture.drawio-1.png)

La arquitectura de Kubernetes consta de varios componentes principales que trabajan juntos para implementar y gestionar aplicaciones en contenedores.

Cluster: El cluster de Kubernetes es el conjunto de nodos y componentes que trabajan juntos para ejecutar aplicaciones en contenedores.

Nodo: Un nodo de Kubernetes es una máquina física o virtual que ejecuta los contenedores. Cada nodo tiene un agente llamado kubelet que se comunica con el servidor de control de Kubernetes.

Servidor de control: El servidor de control de Kubernetes es el componente principal que gestiona y coordina el cluster. Incluye componentes como el API server, el etcd y el controller manager.

API Server: El API server es el componente principal que expone la API de Kubernetes.

Etcd: Etcd es una base de datos distribuida que almacena el estado del cluster.

Controller Manager: El controller manager es el componente que gestiona los controladores de Kubernetes, como el controlador de replicación.

Pod: Un pod de Kubernetes es la unidad más pequeña que se puede implementar en el cluster. Contiene uno o varios contenedores que comparten recursos como el almacenamiento y la red.

Contenedor: Un contenedor es un paquete de software que incluye todo lo necesario para ejecutar una aplicación, como el código, las bibliotecas y las dependencias.

# Lens

Seguir los pasos para instalar Lens:

https://docs.k8slens.dev/getting-started/install-lens/


# Enlaces de Interés
https://devopscube.com/kubernetes-architecture-explained/

https://www.redhat.com/en/topics/containers/kubernetes-architecture

https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-kubectl-binary-with-curl-on-windows

https://learn.microsoft.com/es-es/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

