from sly import Lexer
from error_handler import ErrInfo, ErrCode, error


class PDLLexer(Lexer):

    def __init__(self, sym_manager, parser, source_file=None):
        super().__init__()
        self.token_file = './out/tokens.txt'
        self.sym_manager = sym_manager
        self.parser = parser
        self.source = source_file

    tokens = {INT, BOL, STR, PAS, EQS, PLS, MIN, ASG, GRT, AND, NOT, TYP, LET,
              FUN, RET, IFT, WHL, PRT, INP, VID, SCL, COM, PAO, PAC, BRO, BRC}

    VID = '[a-zA-Z][a-zA-Z0-9_]*'

    VID['int'] = TYP
    VID['boolean'] = TYP
    VID['string'] = TYP
    VID['let'] = LET
    VID['function'] = FUN
    VID['return'] = RET
    VID['if'] = IFT
    VID['while'] = WHL
    VID['print'] = PRT
    VID['input'] = INP
    VID['true'] = BOL
    VID['false'] = BOL

    def VID(self, t):
        return t

    @_(r'\d+')
    def INT(self, t):
        t.value = int(t.value)
        if not (-32768 <= t.value <= 32767):
            error(ErrInfo("Lexer", self.lineno, ErrCode.INT_RANGE, t.value, False))
            t.value = 0
        return t

    @_(r'true', r'false')
    def BOL(self, t):
        t.value = t.value == "true"
        return t

    @_(r'".*?"')
    def STR(self, t):
        if len(t.value) - 2 > 64:
            error(ErrInfo("Lexer", self.lineno, ErrCode.STR_RANGE, len(t.value) - 2, False))
            t.value = t.value[:63] + '"'
        return t

    PAS = r'\+='
    EQS = r'=='
    PLS = r'\+'
    MIN = r'-'
    ASG = r'='
    GRT = r'>'
    NOT = r'!'
    AND = r'&&'

    SCL = r';'
    COM = r','
    PAO = r'\('
    PAC = r'\)'
    BRO = r'{'
    BRC = r'}'

    ignore = ' \t'

    @_(r'/\*(.|\n)*?\*/')
    def ignore_comments(self, t):
        self.lineno += t.value.count('\n')

    @_(r'\n+')
    def ignore_newline(self, t):
        self.lineno += len(t.value)

    def error(self, t):
        error(ErrInfo("Lexer", self.lineno, ErrCode.BAD_TOKEN, t.value.split()[0], True))
        self.index += len(t.value)

    def source_tokens(self):
        with open(self.source, 'r') as file:
            with open(self.token_file, 'w') as tokfile:
                filestr = file.read()
                for token in self.tokenize(filestr):
                    if token.type == "VID":
                        var = self.sym_manager.get_symbol(self.parser.context[-1], token.value)
                        if var:
                            print(f"<{token.type}, {var[0].index + 1}>", file=tokfile)
                        else:
                            print(f"<{token.type}, {self.sym_manager[self.parser.context[-1]][1].size + 1}>", file=tokfile)
                    else:
                        print(f"<{token.type}, {token.value}>", file=tokfile)
                    yield token