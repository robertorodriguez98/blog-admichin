---
title: "Taller 1"
date: 2022-10-03T12:56:47+02:00
draft: false
---
# Taller 1:Introducción a git y GitHub 

### 1. Una captura de pantalla donde se vea que has creado el repositorio.
![](ksnip_20220923-092817.png)
### 2. El contenido del fichero .git/config para que se vea que has clonado el repositorio con la URL ssh.
![](ksnip_20220923-093016.png)
### 3. La salida de la instrucción git log para ver los commits que has realizado (debe aparecer como autor tu nombre completo).
![](ksnip_20220923-093101.png)
### 4. Buscar información para crear un nuevo repositorio llamado prueba2_tu_nombre. En esta ocasión, crea primero el repositorio local (usando git init) y luego busca información para sincronizarlo y crear el repositorio remoto en GitHub. Comenta los pasos que has realizado y manda alguna prueba de funcionamiento.

Para crear el repositiorio local, hay que seguir los siguientes pasos:
* Crear el repositorio vacío en github.com
```bash
git init
git add .
git commit -m "primer commit"
git remote add origin git@github.com:robertorodriguez98/prueba2_roberto.git
git push -u origin main
```
![](ksnip_20220923-094604.png)
