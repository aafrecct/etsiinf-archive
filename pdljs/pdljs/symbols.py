from sys import stdin
from item import Item, Type


class Symbol(Item):

    def __init__(self, index, id, sign, disp, value):
        super().__init__(sign)
        self.index = index
        self.id = id
        self.disp = disp
        self.value = value


class SymbolTable:

    def __init__(self, name):
        self.name = name
        self.table = {}
        self.size = 0
        self.disp = 0

    def add(self, id, item: Item, value=None):
        match item.sign[0]:
            case Type.INT:
                disp = 4
            case Type.BOOL:
                disp = 1
            case Type.STR:
                disp = 64
            case _:
                disp = 0

        if symbol := self.table.get(id, None):
            symbol.value = value
        else:
            symbol = Symbol(self.size, id, item.sign, self.disp, value)
            self.disp += disp
            self.table[id] = symbol
            self.size += 1
        return symbol

    def __getitem__(self, item):
        return self.table[item]

    def __contains__(self, item):
        return item in self.table.keys()


class SymbolManager:

    def __init__(self):
        self.tables = {'globals': (0, SymbolTable('globals'))}
        self.size = 1

    def __getitem__(self, key):
        return self.tables[key]

    def add_table(self, name):
        self.tables[name] = (self.size, SymbolTable(name))
        self.size += 1
        return self.tables[name]

    def get_symbol(self, context, id):
        if id in self.tables[context][1]:
            return self.tables[context][1][id], context
        elif id in self.tables['globals'][1]:
            return self.tables['globals'][1][id], 'globals'
        else:
            return ()

    def set_symbol(self, context, id, sign, value=None):
        # Default values
        if not value:
            match sign[-1]:
                case 'int':
                    value = 0
                case 'bool':
                    value = False
                case 'str':
                    value = ""

        item = Item(sign)
        return self.tables[context][1].add(id, item, value)

    def output_symbols(self):
        with open('./out/symbols.txt', 'w') as ts_file:
            for i, table in self.tables.values():
                ts_file.write(f'{table.name} # {i} : \n')
                for symbol in table.table.values():
                    ts_file.write(f'\t*  \'{symbol.id}\'\n')
                    ts_file.write(f'\t\t+  Tipo:            {symbol.sign[0]}\n')
                    if symbol.sign[0] != Type.FUNC:
                        ts_file.write(f'\t\t+  Despl:           {symbol.disp}\n')
                    else:
                        ts_file.write(f'\t\t+  numParam:        {len(symbol.sign) - 2}\n')
                        for j in range(len(symbol.sign)- 2):
                            ts_file.write(f'\t\t+  TipoParam{j:02d}:     {symbol.sign[j+1]}\n')
                        ts_file.write(f'\t\t+  TipoRetorno:     {symbol.sign[-1]}\n')
                        ts_file.write(f'\t\t+  EtiqFuncion:     {symbol.sign}\n')


