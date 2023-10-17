from sys import stdin


def cases():
    case = []
    while (line := next(stdin).strip()) != "0 0":
        line = [int(i) for i in line.split(' ') if i]
        if line:
            if not case:
                case = [[] for i in range(line[1])]
            else:
                for i, n in enumerate(line):
                    case[i].append(n)
        else:
            yield case
            case = []


def minr(iterable, key=None):
    curmin = None
    if key is not None: 
        for i in reversed(iterable):
            v = key(i)
            if not curmin or v < curmin[1]:
                curmin = i, v
    else:
        for i in reversed(iterable):
            if not curmin or i < curmin:
                curmin = i
    return curmin[0] if len(curmin) > 1 else curmin


def get_best_path(pos, val, prev, best_matrix):
    paths = [((*x[0], pos[1]),x[1] + val + abs(x[0][-1] - pos[1]) * 5) for x in prev]
    if pos[1] >= len(best_matrix[pos[0]]):
        best_matrix[pos[0]].append(minr(paths, key=lambda x:x[1]))
    else:
        best_matrix[pos[0]][pos[1]] = minr(paths, key=lambda x:x[1])
    return best_matrix[pos[0]][pos[1]]



for case in cases():
    best_matrix = [[] for l in range(len(case))]
    best_matrix[0] = [((i[0],), i[1]) for i in enumerate(case[0])]
    for i, c in enumerate(case[1:]):
        for j, o in enumerate(c):
            get_best_path((i + 1, j), o, best_matrix[i], best_matrix)
    sol = minr(best_matrix[-1], key= lambda x: x[1])
    print(f"{sol[1]}\n", *sol[0], sep="  ", end="\n\n")

