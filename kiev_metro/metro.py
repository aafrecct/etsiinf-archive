"""
La implementación de la estructura del Metro de Kiev con Lineas, paradas,
distancias y otra información.
"""
from json import load


class Line:
    """ Representa una linea de metro
    """

    all = []

    def __init__(self, number: int, length: int, color: str, transfers):
        self.number = number
        self.length = length
        self.color = color
        self.stations = []
        self.trasfers = transfers
        self.all.append(self)

    def __repr__(self):
        return f"Line {self.number}: {repr(self.stations[0])} - {repr(self.stations[-1])}"

    def __str__(self):
        stations = " - ".join([repr(s) for s in self.stations])
        return f"Line {self.number}, color {self.color} has stations: \n{stations}\n"


class Station:
    """ Representa una estación de metro.
    """

    all = {}

    def __init__(self, name: str, ukranian_name: str, line: int, number: int, connects_with=None,
                 prev=None, next=None):
        self.id = line * 100 + number + 10
        self.name = name
        self.ukranian_name = ukranian_name
        self.line = line
        self.number = number
        self.connects_with = connects_with
        self.prev = prev
        self.next = next

        self.all[name] = self

    def __repr__(self):
        return f"({self.id}) {self.name}"

    def __str__(self):
        return f"Station {self.name} with id {self.id} is part of line {self.line}."

    @classmethod
    def id(cls, id):
        line = Line.all[(id // 100) - 1]
        return line.stations[id % 100 - 10]

    def connections(self):
        return [s for s in [(self.connects_with, 0), self.next, self.prev] if s and s[0]]

    def stations_to(self, destination):
        if destination.line == self.line:
            return abs(destination.id - self.id)
        else:
            line = Line.all[self.line - 1]
            return abs(line.trasfers[f'Line {destination.line}'][0] - self.id) +\
                   abs(line.trasfers[f'Line {destination.line}'][1] - destination.id)


with open("data/metro_network.json", "r", encoding='utf-8') as json_network:
    network = load(json_network)

with open("data/metro_distances.json", "r", encoding='utf-8') as json_distances:
    distances = load(json_distances)

connections = {}
for l in network.values():
    line = Line(l['number'], l['length'], l['color'], l['transfers'])
    last = None
    for n, s in enumerate(l['stations']):
        station = Station(s['name'], s['ukranian_name'], line.number, n)
        line.stations.append(station)
        if "connects_with" in s.keys():
            connections[s['name']] = s["connects_with"]

for s1, s2 in connections.items():
    s1 = Station.all[s1]
    s2 = Station.all[s2]
    s1.connects_with = s2
    s2.connects_with = s1

for l, name in enumerate(distances.keys()):
    for n, distance in enumerate(distances[name]):
        Line.all[l].stations[n].next = (Line.all[l].stations[n + 1], distance)
        Line.all[l].stations[n + 1].prev = (Line.all[l].stations[n], distance)
