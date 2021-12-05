from metro import Line, Station

class Node:

    def __init__(self, station, parent, total):
        self.station = station
        self.parent = parent
        self.total = total


def heuristic(station):
    # Función heuristica.
    ...

def short_path(origin: Station, destination: Station):
    open_list = []
    close_list = []
    # Algoritmo A*
    ...