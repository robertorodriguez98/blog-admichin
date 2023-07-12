---
title: "Instalación basada en preseed/PXE/TFTP"
date: 2022-10-06T11:14:21+02:00
draft: false
tags: ["Debian","preseed"]
---

Para esta instalación, al igual que la anterior, es necesario que una máquina haga el rol de servidor, además en este caso tiene que tener un servidor DHCP. Para configurarla vamos a seguir los siguientes pasos. La máquina tiene que tener una red aislada sin DHCP en la que se va a conectar con los clientes

## Instalación de dnsmasq

1. Instalamos el paquete dnsmasq, encargado tanto del DHCP como del servidor TFTP
```shell
$ apt install dnsmasq
```
2. configuramos el contenido del fichero /etc/dnsmasq.conf/:
```shell
dhcp-range=192.168.100.50,192.168.100.150,255.255.255.0,12h
dhcp-boot=pxelinux.0
enable-tftp
tftp-root=/srv/tftp
```
3. En el paso anterior especificamos que se utilizara el directorio /srv/tftp/ como raíz para la transmisión por pxe; vamos a crearlo:
```shell
$ mkdir /srv/tftp/
```
4. Reiniciamos el servicio para que los cambios tengan efecto
```shell
$ systemctl restart dnsmasq
```

## Descarga de la imagen

Para instalar utilizando PXE/TFTP tenemos que utilizar una imagen de debian especial llamada netboot. Esta imagen se encuentra en la siguiente dirección: http://ftp.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/netboot.tar.gz.

1. Nos desplazamos al directorio /srv/tftp/, descargamos la imagen y la descomprimimos:
```shell
$ wget http://ftp.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/netboot.tar.gz
$ tar -zxf netboot.tar.gz && rm netboot.tar.gz
```

Tras este paso, el servidor ya está ofreciendo la imagen de debian a la red.

## Reglas nftables

dado que el cliente solo está conectado al servidor, no tiene ninguna conexión a internet. Por lo que el servidor, además, tiene que hacer SNAT. Para ello vamos a activar el bit de forwarding y a aplicar las siguientes reglas de nftables:
```shell
$ nft add table nat
$ nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
$ nft add rule ip nat postrouting oifname "eth0" ip saddr 192.168.100.0/24 counter masquerade
$ nft list ruleset > /etc/nftables.conf
```
Si la configuración no ha persistido tras un reinicio, podemos recuperarla con:
```shell
$ nft -f /etc/nftables.conf
```

## Fichero Preseed

Para añadir el fichero preseed, tenemos dos opciones. Añadirlo a los ficheros que se están distribuyendo a través de `PXE`, o utilizar un `servidor apache`, realizándose de la misma manera que en el paso anterior.

Para utilizar el fichero `preseed.cfg` modificamos el fichero `txt.cfg` para que utilice el que estamos ofreciendo en el servidor apache:
```shell
label install
	menu label ^Install
	kernel debian-installer/amd64/linux
	append vga=788 initrd=debian-installer/amd64/initrd.gz --- quiet 
label unattended-gnome
        menu label ^Instalacion Debian Desatendida Preseed
        kernel debian-installer/amd64/linux
        append vga=788 initrd=debian-installer/amd64/initrd.gz preseed/url=192.168.100.5/preseed.txt locale=es_ES console-setup/ask_detect=false keyboard-configuration/xkb-keymap=e>
```

# Lado del cliente

La instalación desde el lado del cliente es muy similar al paso anterior. Antes de empezar, hay que añadirle una tarjeta de red que esté en la red del DHCP, y hacer que sea una opción de arranque. Una vez hecho esto, el cliente iniciará la imagen en red, y desde ahí, podemos seguir los pasos que ya sabemos para utilizar el fichero preseed.cfg
