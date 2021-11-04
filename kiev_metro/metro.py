"""
La implementación de la estructura del Metro de Kiev con Lineas, paradas,
distancias y otra información.
"""
import enum


class Line(enum.Enum):
    """ Cada una de las lineas de metro.

    Cada linea tiene una lista de estaciones.
    """
    LINE_1 = []
    LINE_2 = []
    LINE_3 = []


class Station:
    """ Representa una estación de metro.

    """

    all = {}
    __lines = {1: Line.LINE_1, 2: Line.LINE_2, 3: Line.LINE_3}

    def __init__(self, name: str, ukranian_name: str, line: int, number: int, neighbours: list):
        self.id = line * 100 + number + 10
        self.name = name
        self.ukranian_name = name
        self.line = line
        self.number = number
        self.neighbours = neighbours

        all[id] = self
        self.__lines[line].append(self)

    def get_distance_to(self, station):
        if type(station) is str:
            station = self.all[station]



