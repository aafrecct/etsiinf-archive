def direction(i, j, k):
    return i - j if i <= j else j - k

def triple(i, bot, top):
    return [max(bot, i - 1), i, min(top, i + 1)]

def findLowPoint(to):
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

class Arr:

    def __init__(self, arr):
        self.arr = arr

    def size(self):
        return len(self.arr)

    def get(self, idx):
        return self.arr[idx]

