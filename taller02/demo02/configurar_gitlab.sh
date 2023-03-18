#!/bin/bash

# Verificamos que se haya pasado un argumento con la dirección IP
if [ -z "$1" ]
then
  echo "Se debe proporcionar la dirección IP como argumento"
  exit 1
fi

# Conectarse al servidor remoto y modificar la configuración de GitLab
ssh -i ~/.ssh/id_rsa adminuser@"$1" '
  # Usar "sudo" para ejecutar comandos como superusuario
  sudo sed -i "
    # Reemplazar la URL externa de GitLab
    s/external_url .*/external_url \"http:\/\/'"$1"'\"/;
    # Desactivar la redirección de HTTP a HTTPS
    s/nginx['\''redirect_http_to_https'\''] = .*/nginx['\''redirect_http_to_https'\''] = false/;
    # Comentar las líneas que especifican los certificados SSL
    s/^\(nginx\['\''ssl_certificate'\''] =.*\)/#\1/;
    s/^\(nginx\['\''ssl_certificate_key'\''] =.*\)/#\1/;
  " /etc/gitlab/gitlab.rb &&
  # Volver a configurar GitLab
  sudo gitlab-ctl reconfigure
'

# Conectarse al servidor remoto y obtener la contraseña de gitlab
password=$(ssh -i ~/.ssh/id_rsa adminuser@"$1" sudo cat /home/bitnami/bitnami_credentials | grep -o "'[^']*'" | sed -n '2p' | tr -d "'")
echo "La dominio de GitLab es: http://$1"
echo "El usuario de GitLab es: root"
echo "La contraseña de GitLab es: $password"
