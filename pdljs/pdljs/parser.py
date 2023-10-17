from sly import Parser
from item import Item, Type
from lexer import PDLLexer
from error_handler import ErrInfo, ErrCode, error
from symbols import SymbolManager
from intermediate_code import ICOperator, ICInstruction, ICListing


class Expression(Item):

    def __init__(self, rule, sign, children=None, value=None, listing=ICListing()):
        super().__init__(sign)
        self.rule = rule
        self.children = children
        self.value = value
        self.listing = listing


class PDLParser(Parser):

    tokens = PDLLexer.tokens
    debugfile = './out/parserdebug.txt'

    def __init__(self, sym_manager: SymbolManager):
        self.sym_manager = sym_manager
        self.rules = []
        self.context = ['globals']

    def error(self, p):
        if p == None:
            error(ErrInfo('Parser', 'EOF', ErrCode.UNEXPECTED_EOF, (), 1))
        
        error(ErrInfo('Parser', p.lineno, ErrCode.MISSING_SEMICOLON, p.value, 0))
        
        if p.type in ('WHL', 'FUN'):
            skip = 'BRC'
        else:
            skip = 'SCL'
        while tok := next(self.tokens, None):
            if tok.type == skip:
                break
        self.restart()

    @_('B P')
    def P(self, p):
        # Setup
        children = (p.B, p.P)
        sign = (Type.STMT,)
    
        # Return
        e = Expression(1, sign, children)
        self.rules.append(1)
        return e

    @_('F P')
    def P(self, p):
        children = (p.F, p.P)
        sign = (Type.STMT,)
        e = Expression(2, sign, children)
        self.rules.append(2)
        return e

    @_('empty')
    def P(self, p):
        sign = ()
        e = Expression(3, sign)
        self.rules.append(3)
        return e

    @_('LET TYP VID SCL')
    def B(self, p):
        if self.sym_manager.get_symbol(self.context[-1], p.VID):
            error(ErrInfo("Parser", p.lineno, ErrCode.VAR_REDECLARED, p.VID, False))

        self.sym_manager.set_symbol(self.context[-1], p.VID,
                                    (Type.from_tok(p.TYP),))
        sign = (Type.STMT,)
        e = Expression(4, sign)
        self.rules.append(4)
        return e

    @_('IFT PAO E PAC S')
    def B(self, p):
        children = (p.E, p.S)
        if children[0].sign[0] != Type.BOOL:
            error(ErrInfo("Parser", p.lineno, ErrCode.COND_TYPE_MISMATCH, '', False))
        sign = (Type.STMT,)
        e = Expression(5, sign, children)
        self.rules.append(5)
        return e

    @_('S')
    def B(self, p):
        children = (p.S,)
        sign = (Type.STMT,)
        e = Expression(6, sign, children)
        self.rules.append(6)
        return e

    @_('WHL PAO E PAC BRO C BRC')
    def B(self, p):
        children = (p.E, p.C)
        if children[0].sign[0] != Type.BOOL:
            error(ErrInfo("Parser"), p.lineno, ErrCode.COND_TYPE_MISMATCH, '', False)
        sign = (Type.STMT,)
        e = Expression(7, sign, children)
        self.rules.append(7)
        return e

    @_('VID ASG E SCL')
    def S(self, p):
        children = (p.E,)
        var = self.sym_manager.get_symbol(self.context[-1], p.VID)
        if not children[0]:
            error(ErrInfo("Parser", p.lineno, ErrCode.ASSIGNMENT_ERROR,
                p.VID, True))
        elif var and children[0].sign[0] != var[0].sign[0]:
            error(ErrInfo("Parser", p.lineno, ErrCode.ASG_TYPE_MISMATCH,
                (var[0].sign[0], children[0].sign[0]), True))

        var_type = var[0].sign[0] if var else children[0].sign[0]
        self.sym_manager.set_symbol(self.context[-1], p.VID, (var_type,),
                                    children[0].value)
        sign = (Type.STMT,)
        e = Expression(8, sign, children)
        self.rules.append(8)
        return e

    @_('VID PAS E SCL')
    def S(self, p):
        children = (p.E, )
        var = self.sym_manager.get_symbol(self.context[-1], p.VID)
        if not var:
            error(ErrInfo("Parser", p.lineno, ErrCode.VAR_UNDECLARED,
                          (var[0].sign[0], children[0].sign[0]), True))
        elif children[0].sign[0] != var[0].sign[0]:
            error(ErrInfo("Parser", p.lineno, ErrCode.ASG_TYPE_MISMATCH,
                (var[0].sign[0], children[0].sign[0]), True))

        var_type = var[0].sign[0]
        if var_type != Type.INT:
            error(ErrInfo("Parser", ))

        self.sym_manager.set_symbol(self.context[-1], p.VID, (var_type,),
                                    children[0].value)

        sign = (Type.STMT,)
        e = Expression(9, sign, children)
        self.rules.append(9)
        return e

    @_('RET X SCL')
    def S(self, p):
        children = (p.X,)
        if len(self.context) < 2:
            error(ErrInfo("Parser", p.lineno, ErrCode.GLOBAL_RETURN, (), False))
            return Expression(10, (), children)

        ret_type = self.sym_manager.get_symbol('globals', self.context[-1])[0].sign[-1]
        if children[0].sign and children[0].sign[0] != ret_type:
            error(ErrInfo("Parser", p.lineno, ErrCode.RET_TYPE_MISMATCH,
                (self.context[-1], children[0].sign[0], ret_type), True))

        sign = (Type.STMT,)
        e = Expression(10, sign, children)
        self.rules.append(10)
        return e

    @_('VID PAO L PAC SCL')
    def S(self, p):
        children = (p.L,)
        vid = self.sym_manager.get_symbol('globals', p.VID)

        if children[0].sign != vid[0].sign[1:-1]:
            error(ErrInfo("Parser", p.lineno, ErrCode.FUNC_UNDECLARED,
            (p.VID, children[0].sign), False))

        match vid[0].sign[0]:
            case 'int':
                sign = (Type.INT,)
            case 'bool':
                sign = (Type.BOOL,)
            case 'str':
                sign = (Type.STR,)
            case _:
                sign = (Type.STMT,)

        e = Expression(11, sign, children)
        self.rules.append(11)
        return e

    @_('PRT PAO E PAC SCL')
    def S(self, p):
        children = (p.E, )

        sign = (Type.STMT,)
        e = Expression(12, sign, children)
        self.rules.append(12)
        return e

    @_('INP PAO VID PAC SCL')
    def S(self, p):
        var = self.sym_manager.get_symbol(self.context[-1],
                                       p.VID)
        
        if not var:
            error(ErrInfo("Parser", p.lineno, ErrCode.VAR_UNDECLARED,
                p.VID, True))
        if var[0].sign[0] != Type.STR:
            error(ErrInfo("Parser", p.lineno, ErrCode.INPUT_TYPE_MISMATCH,
                (p.VID, var[0].sign[0]), True))

        sign = (Type.STMT,)
        e = Expression(13, sign)
        self.rules.append(13)
        return e

    @_('E')
    def X(self, p):
        children = (p.E,)
        sign = children[0].sign
        e = Expression(14, sign, children)
        self.rules.append(14)
        return e

    @_('empty')
    def X(self, p):
        sign = ()
        e = Expression(15, sign)
        self.rules.append(15)
        return e

    @_('B C')
    def C(self, p):
        sign = (Type.STMT,)
        children = (p.B, p.C)
        e = Expression(16, sign, children)
        self.rules.append(16)
        return e

    @_('empty')
    def C(self, p):
        sign = ()
        e = Expression(17, sign)
        self.rules.append(17)
        return e

    @_('E Q')
    def L(self, p):
        children = (p.E, p.Q)
        sign = (*children[0].sign, *children[1].sign)
        e = Expression(18, sign, children)
        self.rules.append(18)
        return e

    @_('empty')
    def L(self, p):
        sign = ()
        e = Expression(19, sign)
        self.rules.append(19)
        return e

    @_('COM E Q')
    def Q(self, p):
        children = (p.E, p.Q)
        sign = (*children[0].sign, *children[1].sign)
        e = Expression(20, sign, children)
        self.rules.append(20)
        return e

    @_('empty')
    def Q(self, p):
        sign = ()
        e = Expression(21, sign)
        self.rules.append(21)
        return e

    @_('FUN VID H before_func_args PAO A PAC after_func_args BRO C BRC')
    def F(self, p):
        children = (p.H, p.A, p.C)
        self.context.pop(-1)
        sign = (Type.FUNC, *children[1].sign, *children[0].sign)
        e = Expression(22, sign, children)
        self.rules.append(22)
        return e

    @_('')
    def before_func_args(self, p):
        self.sym_manager.add_table(p[-2])
        self.context.append(p[-2])

    @_('')
    def after_func_args(self, p):
        func_ret = p[-5]
        func_args = p [-2]
        sign = (Type.FUNC, *func_args.sign, *func_ret.sign)
        self.sym_manager.set_symbol('globals', p[-6], sign)

    @_('TYP')
    def H(self, p):
        sign = (Type.from_tok(p.TYP),)
        e = Expression(23, sign)
        self.rules.append(23)
        return e

    @_('empty')
    def H(self, p):
        sign = ()
        e = Expression(24, sign)
        self.rules.append(24)
        return e

    @_('TYP VID K')
    def A(self, p):
        children = (p.K,)
        sign = (Type.from_tok(p.TYP), *children[0].sign)
        self.sym_manager.set_symbol(self.context[-1], p.VID, (sign[0],))
        e = Expression(25, sign, children)
        self.rules.append(25)
        return e

    @_('empty')
    def A(self, p):
        sign = ()
        e = Expression(26, sign)
        self.rules.append(26)
        return e

    @_('COM TYP VID K')
    def K(self, p):
        children = (p.K, )
        sign = (Type.from_tok(p.TYP), *children[0].sign)
        self.sym_manager.set_symbol(self.context[-1], p.VID, (sign[0],))
        e = Expression(27, sign, children)
        self.rules.append(27)
        return e

    @_('empty')
    def K(self, p):
        sign = ()
        e = Expression(28, sign)
        self.rules.append(28)
        return e

    @_('E AND R')
    def E(self, p):
        children = (p.E, p.R)
        if children[0].sign[0] != Type.BOOL or \
                children[1].sign[0] != Type.BOOL:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.AND, (children[0].sign[0], children[1].sign[0])), True))
        sign = (Type.BOOL,)
        e = Expression(29, sign, children)
        self.rules.append(29)
        return e

    @_('R')
    def E(self, p):
        children = (p.R,)
        sign = children[0].sign
        e = Expression(30, sign, children)
        self.rules.append(30)
        return e

    @_('R EQS Y')
    def R(self, p):
        children = (p.R, p.Y)
        if children[0].sign[0] != Type.INT or \
                children[1].sign[0] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.EQS, (children[0].sign[0], children[1].sign[0])), True))

        sign = (Type.BOOL,)
        e = Expression(31, sign, children)
        self.rules.append(31)
        return e

    @_('Y')
    def R(self, p):
        children = (p.Y, )
        sign = children[0].sign
        e = Expression(32, sign, children)
        self.rules.append(32)
        return e

    @_('Y GRT U')
    def Y(self, p):
        children = (p.Y, p.U)
        if children[0].sign[0] != Type.INT or \
                children[1].sign[0] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.GRT, (children[0].sign[0], children[1].sign[0])), True))

        sign = (Type.BOOL,)
        e = Expression(33, sign, children)
        self.rules.append(33)
        return e

    @_('U')
    def Y(self, p):
        children = (p.U,)
        sign = children[0].sign
        e = Expression(34, sign, children)
        self.rules.append(34)
        return e

    @_('U PLS W')
    def U(self, p):
        children = (p.U, p.W)
        if children[0].sign[-1] != Type.INT or \
                children[1].sign[-1] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH, 
            (p.PLS, (children[0].sign[-1], children[1].sign[-1])), 1))

        sign = (Type.INT,)
        e = Expression(35, sign, children)
        self.rules.append(35)
        return e

    @_('U MIN W')
    def U(self, p):
        children = (p.U, p.W)
        if children[0].sign[0] != Type.INT or \
                children[1].sign[0] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.MIN, (children[0].sign[0], children[1].sign[0])), True))

        sign = (Type.INT,)
        e = Expression(36, sign, children)
        self.rules.append(36)
        return e

    @_('W')
    def U(self, p):
        children = (p.W,)
        sign = children[0].sign
        e = Expression(37, sign, children)
        self.rules.append(37)
        return e

    @_('NOT W')
    def W(self, p):
        children = (p.W,)
        if children[0].sign[0] != Type.BOOL:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.NOT, (children[0].sign[0])), True))

        sign = (Type.BOOL,)
        e = Expression(38, sign, children)
        self.rules.append(38)
        return e

    @_('PLS W')
    def W(self, p):
        children = (p.W,)
        if children[0].sign[0] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.PLS, (children[0].sign[0])), True))

        sign = (Type.INT,)
        e = Expression(39, sign, children)
        self.rules.append(39)
        return e

    @_('MIN W')
    def W(self, p):
        children = (p.W,)
        if children[0].sign[0] != Type.INT:
            error(ErrInfo("Parser", p.lineno, ErrCode.OP_TYPE_MISMATCH,
            (p.MIN, (children[0].sign[0])), True))

        sign = (Type.INT,)
        e = Expression(40, sign, children)
        self.rules.append(40)
        return e

    @_('V')
    def W(self, p):
        children = (p.V,)
        sign = children[0].sign
        e = Expression(41, sign, children)
        self.rules.append(41)
        return e

    @_('VID')
    def V(self, p):
        vid = self.sym_manager.get_symbol(self.context[-1], p.VID)
        if not vid:
            error(ErrInfo("Parser", p.lineno, ErrCode.VAR_UNDECLARED, p.VID, False))
            return Expression(42, ())
        sign = vid[0].sign
        e = Expression(42, sign, value=vid)
        self.rules.append(42)
        return e

    @_('PAO E PAC')
    def V(self, p):
        children = (p.E,)
        sign = children[0].sign
        e = Expression(43, sign, children, value=p.E.value)
        self.rules.append(43)
        return e

    @_('VID PAO L PAC')
    def V(self, p):
        # Setup
        children = (p.L,)

        # Semantic errors.
        func = self.sym_manager.get_symbol('globals', p.VID)
        if not func or children[0].sign != func[0].sign[1:-1]:
            error(ErrInfo("Parser", p.lineno, ErrCode.FUNC_UNDECLARED,
             (p.VID, children[0].sign), True))

        # Code Generation.
        code = ICListing(
            *[ICInstruction(ICOperator.PARAM if child.sign[-1] != Type.STR else ICOperator.PARAMDIR,
                child.value
            ) for child in children[0].children]
        )

        # Return
        e = Expression(44, (func[0].sign[-1],), children)
        self.rules.append(44)
        return e

    @_('INT')
    def V(self, p):
        sign = (Type.INT,)
        e = Expression(45, sign, value=p.INT)
        self.rules.append(45)
        return e

    @_('BOL')
    def V(self, p):
        sign = (Type.BOOL,)
        e = Expression(46, sign, value=p.BOL)
        self.rules.append(46)
        return e

    @_('STR')
    def V(self, p):
        sign = (Type.STR,)
        e = Expression(47, sign, value=p.STR)
        self.rules.append(47)
        return e

    @_('')
    def empty(self, p):
        pass