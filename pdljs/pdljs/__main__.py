from sys import argv, path
path.insert(0, '/'.join(__file__.replace('\\', '/').split('/')[:-1]))

from os.path import abspath, exists
from os import makedirs

print(abspath('.'))
if not exists('./out'):
    print("Creating 'out' folder.")
    makedirs('./out')

from sly import Lexer, Parser
from symbols import SymbolManager
from lexer import PDLLexer
from parser import PDLParser

if len(argv) < 2:
    print("You need to specify a file to parse.")
    exit(1)


def main():
    symbol_manager = SymbolManager()
    parser = PDLParser(symbol_manager)
    lexer = PDLLexer(symbol_manager, parser, argv[1])

    result = parser.parse(lexer.source_tokens())
    symbol_manager.output_symbols()

    with open('./out/parserules.txt', 'w') as file:
        print("A", end=" ", file=file)
        print(' '. join(str(i) for i in parser.rules), file=file)


def print_tree(node, file=None):
    print(node.rule, end=" ", file=file)
    if node.children:
        for c in node.children:
            print_tree(c, file)


if __name__ == '__main__':
    main()
