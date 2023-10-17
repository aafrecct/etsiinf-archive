from os.path import abspath
from sys import path
path.insert(0, '/'.join(__file__.replace('\\', '/').split('/')[:-1]))