from sys import stdin, stderr


def get_day ():
    for line in stdin:
        print(line, file=stderr)

if __name__ == '__main__':
    get_day()
