from enum import Enum


class Type(Enum):

    INT = "int"
    BOOL = "bool"
    STR = "str"
    FUNC = "func"
    STMT = "stmt"

    def __repr__(self) -> str:
        return self.__str__()

    @classmethod
    def from_tok(cls, value):
        match value:
            case 'str' | 'string':
                return cls.STR
            case 'bool' | 'boolean':
                return cls.BOOL
            case 'int' | 'integer':
                return cls.INT


class Item:

    def __init__(self, sign: tuple[Type]):
        self.sign: tuple[Type] = sign

    def get_value(self):
        return self.value if len(self.value) > 1 else self.value[0]

    def get_type(self):
        return self.value[0]

    def __len__(self):
        return len(self.sign)

    def __and__(self, other):
        ss = self.sign[1:-1] if self.sign[0] == Type.FUNC else self.sign
        os = other.sign[1:-1] if other.sign[0] == Type.FUNC else other.sign

        return ss == os