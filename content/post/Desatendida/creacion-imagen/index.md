---
title: "Creación Imagen"
date: 2022-10-06T7:00:09+02:00
draft: false
tags: ["Debian","preseed"]
---

## Descomprimimos la imagen

Vamos a utilizar la versión de debian que contiene software privativo, para, por ejemplo, tener disponibles más drivers en caso de que fueran necesarios. Tenemos que seguir los siguientes pasos:
1. Descargamos la imagen de la página de debian:
```shell
$ wget https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-11.5.0-amd64-netinst.iso
```
2. Descomprimimos la imagen utilizando `xorriso` en el directorio `isofiles/`:
```shell
$ xorriso -osirrox on -indev firmware-11.5.0-amd64-netinst.iso -extract / isofiles/
```

## Introducimos el preseed

1. copiamos el fichero `preseed.cfg` a la raíz de la imagen:
```shell
$ sudo cp preseed.cfg isofiles/preseed.cfg
```
2. Editamos el fichero `txt.cfg` (encargado del contenido del menú inicial de instalación) para añadir una opción que utilice el `preseed` además de que cargue el idioma español:
```shell
$ sudo nano isofiles/isolinux/txt.cfg
```
```shell
label install
        menu label ^Install
        kernel /install.amd/vmlinuz
        append vga=788 initrd=/install.amd/initrd.gz --- quiet
label unattended-gnome
        menu label ^Instalacion Debian Desatendida Preseed
        kernel /install.amd/gtk/vmlinuz
        append vga=788 initrd=/install.amd/gtk/initrd.gz preseed/file=/cdrom/preseed.cfg locale=es_ES console-setup/ask_detect=false keyboard-configuration/xkb-keymap=e>
```

## Volvemos a generar la imagen

1. Como hemos alterado los ficheros que contiene la imagen, tenemos que generar un nuevo fichero `md5sum.txt`:
```shell
$ cd isofiles/
$ chmod a+w md5sum.txt
$ md5sum `find -follow -type f` > md5sum.txt
$ chmod a-w md5sum.txt
$ cd .
``` 
2. Por último cambiamos los permisos de `isolinux` y creamos la imagen nueva:
```shell
$ chmod a+w isofiles/isolinux/isolinux.bin
$ genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o debian-preseed.iso isofiles
```
