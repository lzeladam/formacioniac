## **Parte 1 - Git**

Git es un sistema de control de versiones que te permite llevar un registro completo de los cambios que realizas en tus proyectos.

## Instalar:

**Ubuntu**:

Para instalar Git en Ubuntu, sigue estos pasos:

1. Abre una terminal
2. Ejecuta el siguiente comando: **`sudo apt-get update`**
3. Luego, ejecuta este otro comando: **`sudo apt-get install git`**

**Windows:**

Para instalar Git en Windows, sigue estos pasos:

1. Descarga el instalador de Git desde **[https://git-scm.com/download/win](https://git-scm.com/download/win)**
2. Ejecuta el archivo descargado y sigue las instrucciones del instalador.

## **Autenticación**

Para poder utilizar Git, es importante que configures tu nombre y correo electrónico en la línea de comando. Esto es lo que Git usará para identificar quién realizó cada cambio en el proyecto. Para hacerlo, ejecuta los siguientes comandos, reemplazando los valores entre comillas con tus propias credenciales:

```bash
git config --global user.email "xxxxxxxx.xxxxx@gmail.com"
git config --global [user.name](http://user.name/) "lzeladam"
```

## **Los tres estados**

Git tiene tres estados: el "Working Directory", el "Staging Area" y el "Repositorio Local". Estos estados representan diferentes puntos en el proceso de guardar cambios en tu proyecto.

![Areas](imagenes/areas.png)

- **Working Directory**: Es donde haces cambios a tus archivos. Los archivos en este estado no se han agregado a la zona de preparación (staging area).
- **Staging Area**: Es una zona intermedia entre el “Working Directory” y el “Local Repository”. Cuando haces un **`git add`**, estás agregando los cambios de tu “Working Directory” a esta zona.
- **Local Repository**: Es donde Git guarda un registro completo de los cambios que has realizado. Cuando haces un **`git commit`**, estás guardando los cambios del “Staging Area” en el “Repositorio Local”, vendría a ser la carpeta “.git”.
  
  - El Local Repository está ubicado en la carpeta oculta .git
  
![Local Repository](imagenes/gitrepository.png "El Local Repository esta en la carpeta oculta .git")

  - Contenido de Local Repository
  
![Local Repository Content](imagenes/gitrepositorycontent.png)

## Comandos Basicos

1. **`git init`**: Inicializa un nuevo repositorio Git vacío en la carpeta actual.
2. **`git add`**: Añade cambios al área de preparación (staging area) para ser incluidos en el próximo commit.
3. **`git commit`**: Guarda los cambios realizados en el “Staging Area” en el repositorio.
4. **`git status`**: Muestra el estado actual del repositorio, incluyendo archivos modificados, archivos en el “Staging Area” y archivos sin seguimiento.
5. **`git diff`**: Muestra las diferencias entre los archivos en el “Staging Area” y los archivos en el repositorio.
6. **`git branch`**: Lista las ramas existentes y crea nuevas ramas.
7. **`git checkout`**: Cambia de rama o restaura un archivo a una versión anterior.
8. **`git merge`**: Combina los cambios realizados en una rama con otra rama.
9. **`git pull`**: Obtiene los cambios desde un repositorio remoto y los fusiona con el repositorio local.
10. **`git push`**: Sube los cambios realizados en el repositorio local al repositorio remoto.
11. **`git clone`**: Crea una copia local de un repositorio remoto.

## **Parte 2 - Terraform**
## Comandos Basicos

1. **`terraform init`**: Inicializa el directorio de trabajo de Terraform y descarga los proveedores de nube necesarios.
2. **`terraform plan`**: Crea un plan de ejecución que muestra los cambios que se realizarán en la infraestructura según el código de Terraform.
3. **`terraform apply`**: Aplica los cambios definidos en el código de Terraform y crea la infraestructura.
4. **`terraform destroy`**: Destruye la infraestructura creada por Terraform.
5. **`terraform validate`**: Valida la sintaxis del código de Terraform.
6. **`terraform state`**: Gestiona el estado de la infraestructura creada por Terraform.
7. **`terraform import`**: Importa recursos existentes de proveedores de nube a la configuración de Terraform.
8. **`terraform fmt`**: Reformatear el código respetando el estilo Terraform.
9. **`terraform force-unlock`**: Forzar el desbloqueo del estado en el workspace actual.
10. **`terraform plan --var-file="valores.tfvars"`**: Especificar un archivo de variables de Terraform.
11. **`terraform apply --target=aws_instance.example`**: Si deseas aplicar los cambios solo a un recurso específico, puedes utilizar la opción **`-target`** seguido del nombre del recurso.