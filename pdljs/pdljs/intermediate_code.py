from enum import Enum

class ICOperator(Enum):
    PLUS = '+'
    MINUS = '-'
    EQUALS = '=='
    GREATER = '>'
    GOTO = '->'
    IFGOTO = '?->'
    CALL = '!'
    PARAM = '$'
    PARAMDIR = '$&'
    RETURN = '@'

class ICInstruction:
    def __init__(self, operator: ICOperator, result, operand1=None, operand2=None):
        self.operator = operator
        self.result = result
        if operand1:
            self.operand1 = operand1
        if operand2:
            self.operand2 = operand2

    def tuple(self) -> tuple:
        if not (self.operand1 or self.operand2):
            return self.operator, self.result
        elif not self.operand2:
            return self.operator, self.operand1, self.result
        else:
            return self.operator, self.operand1, self.operand2, self.result
    
    def __str__(self) -> str:
        return str(self.tuple)
    
    def __repr__(self) -> str:
        if not (self.operand1 or self.operand2):
            return f"{self.operator} {self.result}"
        elif not self.operand2:
            return f"{self.result} = {self.operator} ({self.operand1})"
        else:
            return f"{self.result} = {self.operator} ({self.operand1}, {self.operand2})"

class ICListing:
    def __init__(self, *instructions):
        self.listing: list[ICInstruction] = instructions

    def __add__(self, operand):
        if type(operand) is ICListing:
            return ICListing(*self.listing, *operand.listing)
        elif type(operand) is ICInstruction:
            return ICListing(*self.listing, operand)
        else:
            raise ArithmeticError(f"Operator + not suported for types {self.__class__} and {operand.__class__}.")
    
    def __or__(self, operand):
        if type(operand) is ICListing:
            self.listing += operand.listing
            return self
        elif type(operand) is ICInstruction:
            self.listing.append(operand)
            return self
        else:
            raise ArithmeticError(f"Operator + not suported for types {self.__class__} and {operand.__class__}.")
    