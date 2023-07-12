#!/bin/bash

hugo
scp -r public/* calcetines@nodriza.admichin.es:/home/calcetines/blog/

