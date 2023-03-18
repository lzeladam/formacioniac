#!/bin/bash
# Configurar el gateway VPN
echo "Configurando el gateway VPN..."
profile=$(az network vnet-gateway vpn-client generate --resource-group GR_LABS  --name taller02-vpn-gateway --authentication-method EapTls --output json)
echo "Configuración del gateway VPN obtenida:"
echo $profile
# Descargar el archivo de configuración
echo "Descargando el archivo de configuración..."
echo curl -L "$profile" -o vpnclientconfiguration.zip
echo "Archivo de configuración descargado."
# Descomprimir el archivo de configuración
echo "Descomprimiendo el archivo de configuración..."
unzip vpnclientconfiguration.zip -d vpnconfig
echo "Archivo de configuración descomprimido."
