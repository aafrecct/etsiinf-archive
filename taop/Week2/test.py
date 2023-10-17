from sys import stderr

def is_local_max(prev, subj, succ):
    print(f"Checking if {prev}-{subj}-{succ}", file=stderr)
    if prev > subj:
        return -1
    if succ > subj:
        return 1
    else:
        return 0

def get_and_save(pa, to, length, i):
    if i >= length or i < 0:
        return -1
    else:
        t = to[i]
        pa[i] = t
        return t
    

def findProblematicTemperature(to):
    partial_array = {}
    length = len(to)
    found = -1
    prev_scope = 0
    search = length // 2
    searchb = 0
    while not found + 1:
        print(f"Looking at index: {search}", file=stderr)
        triple = [partial_array.get(search + i, get_and_save(partial_array, to, length, search + i)) for i in [-1, 0, 1]]
        i = is_local_max(*triple)
        if search == searchb:
            return "Loop"
        searchb = search
        if not i:
            return search
        elif i == 1:
            prev_scope = search
            search = (length + prev_scope) // 2
        else:
            length = search
            search = (length + prev_scope) // 2
    

with open('input', 'r') as f:
    for line in f.readlines():
        print('\n New test')
        print(line)
        print(findProblematicTemperature(eval(line)))


