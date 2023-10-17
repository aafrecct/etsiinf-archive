from sys import stderr

def direction(i, j, k):  
    if i < j:
        return -1
    elif k < j:
        return 1
    else:
        return 0

def triple(i, bot, top):
    return [max(bot, i - 1), i, min(top, i + 1)]

def findLowPoint(to):
    print(dir(to), file=stderr)
    size = to.size()
    bot, top = 0, size
    idx = (bot + top) // 2
    while d := direction(*[to.get(i) for i in triple(idx, 0, size - 1)]):
        if d < 0:
            top = idx
        else:
            bot = idx
        idx = (bot + top) // 2
    return idx


# For testing purposes
class Arr:

    def __init__(self, arr):
        self.arr = arr

    def size(self):
        return len(self.arr)

    def get(self, idx):
        return self.arr[idx]

