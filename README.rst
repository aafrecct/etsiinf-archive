**********
KIEV METRO
**********

Proyecto de la asignatura de Inteligencia Artificial de la
ETSIINF UPM. El objetivo es crear una aplicación con una
GUI interesante que calcule el tramo más corto entre dos
paradas del metro de Kiev, usando el algoritmo A*.

Autores
=======

Antonio Carpintero Castilla (Coord)
Borja Martinena Cepa
Jaime Martín González
Pablo Calero
Julián Alonso
Javier Rodriguez Peña

Instrucciones para desarrollo
=============================

Una vez clonado el repositorio, desde dentro de la carpeta,
hay que crear un entorno virtual::
    
    python -m venv ./venv

Este habrá de ser activado cada vez que se vaya a trabajar en
el proyecto, en una máquina linux::
    
    source ./venv/bin/activate

Utilizando un editor como PyCharm, estas dos cosas las hace 
el editor.

Por último, la primera vez que se vaya a trabajar, habrá que
instalar las dependencias. Para esto hay un target init en el
makefile. Dentro del entorno virtual, ejecutar::
    
    make init




