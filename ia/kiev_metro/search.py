from kiev_metro.metro import Line, Station


class Node:

    nodes = {}

    def __init__(self, station, parent, distance):
        self.station = station
        self.parent = parent
        self.acc = self.parent.acc + distance if parent else distance
        self.nodes[station] = self

    def path(self):
        if self.parent:
            return self.parent.path() + [self.station]
        else:
            return [self.station]

    def heuristic(self, destination: Station):
        # Función heuristica.
        # El equivalente a h().
        tranfer = 3000 if self.station.line != destination.line else 0
        return self.station.stations_to(destination) * 920 + tranfer

    def total(self, destination: Station):
        return self.acc + self.heuristic(destination)


def short_path(origin: Station, destination: Station):
    open_list = set()
    open_list.add(Node(origin, None, 0))
    prev = None
    cur = min(open_list, key=lambda x: x.total(destination))
    open_list.remove(cur)
    while cur.station != destination:
        for neigh in cur.station.connections():
            if neigh[0] != prev:
                node = Node(neigh[0], cur, neigh[1])
                open_list.add(node)

        prev = cur.station
        cur = min(open_list, key=lambda x: x.total(destination))
        open_list.remove(cur)
    return cur.path(), cur.acc
