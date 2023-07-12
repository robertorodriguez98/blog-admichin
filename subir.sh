#!/bin/bash

hugo
rsync -azP public/* calcetines@nodriza.admichin.es:/home/calcetines/blog/

