---
title: "Carga del fichero preseed.cfg desde red"
date: 2022-10-06T08:21:57+02:00
draft: False
tags: ["Debian","preseed"]
---

## Configuración del servidor
Para la instalación desatendida cargando el `preseed` desde red, es necesario una máquina que haga el rol de servidor, teniendo un servidor `apache2` instalado. Para preparar dicha máquina seguimos los siguientes pasos: 

1. Instalamos el servidor apache en la máquina:
```bash
$ apt upgrade && apt install apache2
```
2. copiamos el fichero `preseed.cfg` previamente configurado al directorio `/var/www/html`

Tras este paso, el servidor ya está configurado y ofreciendo la configuración a la red.

## Utilización desde el cliente

Para aplicar la configuración del fichero `preseed`, iniciamos la instalación de una imagen de debian sin modificar. Para utilizarla tenemos dos opciones:
1. Utilizando línea de comandos:
    1. Pulsamos la tecla ESC para abrir la línea de comandos
    2. Introducimos el siguiente comando para acceder al fichero, donde `IP servidor` es la ip de la máquina que tiene el servidor apache:
```bash
boot: auto url=[IP servidor]/preseed.cfg
```
2. Utilizando las opciones avanzadas:
    1. Accedemos a opciones avanzadas en el menú, seguido de instalación automatizada. 
    2. Introducimos la ip del servidor con apache de la siguiente manera:
```
http://[IP servidor]/preseed.cfg
```
Tras esto, la instalación desatendida comenzará.
	
