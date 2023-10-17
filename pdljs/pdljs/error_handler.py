from enum import IntEnum
from sys import stderr, exit
from collections import namedtuple

file = stderr

class ErrCode (IntEnum):
    BAD_TOKEN = 1
    INT_RANGE = 2
    STR_RANGE = 3
    ASG_TYPE_MISMATCH = 4
    RET_TYPE_MISMATCH = 5
    VAR_UNDECLARED = 6
    FUNC_UNDECLARED = 7
    OP_TYPE_MISMATCH = 8
    COND_TYPE_MISMATCH = 9
    GEN_TYPE_MISMATCH = 10
    INPUT_TYPE_MISMATCH = 11
    MISSING_SEMICOLON = 12
    ASSIGNMENT_ERROR = 13
    UNEXPECTED_EOF = 14
    VAR_REDECLARED = 15
    GLOBAL_RETURN = 16


ErrInfo = namedtuple("Info", ("module", "line", "errcode", "detail", "halt"))


def error(info: ErrInfo):
    match info.module:

        case "Lexer":
            match info.errcode:
                case ErrCode.BAD_TOKEN:
                    errstr = f"Bad token: {info.detail}"
                case ErrCode.INT_RANGE:
                    errstr = f"Integer value out of range.\n" \
                             f"\tValue: {info.detail}. Range: (-32768, 32767)"
                case ErrCode.STR_RANGE:
                    errstr = f"String literal too long. \n" \
                             f"\tLength: {info.detail} characters. Max allowed is 64."

        case "Parser":
            match info.errcode:
                case ErrCode.VAR_REDECLARED:
                    errstr = f"Variable '{info.detail}' had already been declared. You cannot redeclare variables or change their type."
                case ErrCode.VAR_UNDECLARED:
                    errstr = f"Variable '{info.detail}' used but not declared."
                case ErrCode.FUNC_UNDECLARED:
                    errstr = f"Function {info.detail[0]}{info.detail[1]} not declared."
                case ErrCode.ASG_TYPE_MISMATCH:
                    errstr = f"Incompatible types in assignment expression variable is of {info.detail[0]} but new value is {info.detail [1]}."
                case ErrCode.RET_TYPE_MISMATCH:
                    errstr = f"Function {info.detail[0]} should return {info.detail[2]} but {info.detail[1]} was found."
                case ErrCode.OP_TYPE_MISMATCH:
                    errstr = f"Incompatible types for operator {info.detail[0]}, {info.detail[1]}."
                case ErrCode.COND_TYPE_MISMATCH:
                    errstr = f"Expression in conditional statement (if or while) doesn't seem to evaluate to BOOL type."
                case ErrCode.GEN_TYPE_MISMATCH:
                    errstr = f"Type mismatch: found {info.detail[1]}, should be {info.detail[0]}."
                case ErrCode.INPUT_TYPE_MISMATCH:
                    errstr = f"Can only read string but {info.detail[0]} is of type {info.detail[1]}."
                case ErrCode.MISSING_SEMICOLON:
                    errstr = f"Probably missing ';' after expression but found '{info.detail}'."
                case ErrCode.ASSIGNMENT_ERROR:
                    errstr = f"Could not assign value to variable '{info.detail}'."
                case ErrCode.GLOBAL_RETURN:
                    errstr = f"Global returns are not allowed. Only use return inside a function."
                case ErrCode.UNEXPECTED_EOF:
                    errstr = f"Unexpectedly reached EOF while parsing expression."
        case _:
            errstr = f"Unknown error. Things went very bad. \n\tErrInfo: {info}"


    print(f"{info.module} found an error in line {info.line}.\n\t{errstr}", file=file)
    if info.halt:
        exit(1)
