---
title: "Implantación de aplicaciones web PHP en docker"
date: 2023-02-06T13:41:58+01:00
draft: true
---


Imaginemos que el equipo de desarrollo de nuestra empresa ha desarrollado una aplicación PHP que se llama BookMedik (https://github.com/evilnapsis/bookmedik).

Queremos crear una imagen Docker para implantar dicha aplicación.


## Tarea 1: Creación de una imagen docker con una aplicación web desde una imagen base

```bash
docker run -d --name bd_mariadb -v bookmedik_vol:/var/lib/mysql --network red_bookmedik -e MARIADB_ROOT_PASSWORD=root -e MARIADB_DATABASE=bookmedik -e MARIADB_USER=bookmedik -e MARIADB_PASSWORD=bookmedik mariadb

```

* Entrega la url del repositorio GitHub donde tengas los ficheros necesarios para hacer la construcción de la imagen.
* Entrega una captura de pantalla donde se vea la imagen en el registro de tu entorno de desarrollo.
