#!/bin/bash

hugo
rsync -azP public/* calcetines@nodriza.robertops.com:/home/calcetines/blog/

