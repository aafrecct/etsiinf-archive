:- module(_,_,[assertions, regtypes]).
:- doc(title, "Práctica 1").
:- doc(author, "Borja Martinena, b190242").
:- doc(module, 

"The module contains the predicates specified for the
first practical exercise of the @em{Programación Declarativa} course at ETSIINF
in the academic year 2021-2022.

@noindent
This is mostly composed of predicates dealing with simple byte operations. First 
binary and hexadecimal digits are defined:

@begin{verbatim}
bind/1
hexd/1
@end{verbatim}


@noindent
And bytes, which are lists of either 8 bits/binds or 2 hexadecimal digits.

@begin{verbatim}
binary_byte/1
hex_byte/1
byte/1
@end{verbatim}


The rest of the predicates are implemented with these considerations.
").

:- doc(hide, author_data/4).
:- doc(hide, get_nth_bit_from_byte_rec/3).
:- doc(hide, byte_xor_rec/3).


author_data('Martinena', 'Cepa', 'Borja', 'b190242').

% Binary Digit.
:- prop bind(D) # "@var{D} is a binary digit. @noindent @includedef{bind/1}".

bind(0).
bind(1).

% Binary Byte.
:- pred binary_byte(B) # "@var{B} is a binary byte.
A binary byte is a list of binary digits of length 8.

@begin{verbatim}
binary_byte([bind(B7), bind(B6), bind(B5), bind(B4),
             bind(B3), bind(B2), bind(B1), bind(B0)]) :-
        bind(B7),
        bind(B6),
        bind(B5),
        bind(B4),
        bind(B3),
        bind(B2),
        bind(B1),
        bind(B0).
@end{verbatim}".

binary_byte([bind(B7), bind(B6), bind(B5), bind(B4),
             bind(B3), bind(B2), bind(B1), bind(B0)]) :-
        bind(B7),
        bind(B6),
        bind(B5),
        bind(B4),
        bind(B3),
        bind(B2),
        bind(B1),
        bind(B0).

% Hex Digit.
:- prop hexd(D) # "@var{D} is a hexadecimal digit. @noindent @includedef{hexd/1}".

hexd(0).
hexd(1).
hexd(2).
hexd(3).
hexd(4).
hexd(5).
hexd(6).
hexd(7).
hexd(8).
hexd(9).
hexd(a).
hexd(b).
hexd(c).
hexd(d).
hexd(e).
hexd(f).

% Hex Byte
:- pred hex_byte(B) # "@var{B} is a hexadecimal byte.
A binary byte is a list of binary digits of length 8. @noindent @includedef{hex_byte/1}".

hex_byte([hexd(H1), hexd(H0)]) :-
        hexd(H1),
        hexd(H0).


% Byte
:- pred byte(B) # "@var{B} is a byte that is: a binary byte or a hexadecimal byte. @noindent @includedef{byte/1}".

byte(BB) :-
    binary_byte(BB).

byte(HB) :-
    hex_byte(HB).

% Predicado 1
:- test byte_list(BL) : ( BL = [[hexd(a), hexd(b)]] ) => () + not_fails # "Un byte hexadecimal.".
:- test byte_list(BL) : ( BL = [[hexd(9), hexd(6)], [hexd(5), hexd(c)], [hexd(d), hexd(f)]] ) => (  ) + not_fails # "Tres bytes hexadecimal.".
:- test byte_list(BL) : ( BL = [[bind(1), bind(0), bind(0), bind(0), bind(0), bind(1), bind(1), bind(0)]] ) => (  ) + not_fails # "Un byte binario.".

:- pred byte_list(BL) # "True if @var{BL} is a list of valid bytes.".

byte_list([]).
byte_list([H | T]) :- byte(H), byte_list(T).

% Predicado 2
:- pred hex_to_bin(HD, BN) # "True if @var{HD}, a hexadecimal digit is equal in
value to @var{BN}, a binary nibble. Used to convert hex digits to binary.

@begin{verbatim}
?- hex_to_bin(hexd(b), BN).
BN = [bind(1), bind(0), bind(1), bind(1)] ? ;
no.
@end{verbatim} ".

hex_to_bin(hexd(0), [bind(0), bind(0), bind(0), bind(0)]).
hex_to_bin(hexd(1), [bind(0), bind(0), bind(0), bind(1)]).
hex_to_bin(hexd(2), [bind(0), bind(0), bind(1), bind(0)]).
hex_to_bin(hexd(3), [bind(0), bind(0), bind(1), bind(1)]).
hex_to_bin(hexd(4), [bind(0), bind(1), bind(0), bind(0)]).
hex_to_bin(hexd(5), [bind(0), bind(1), bind(0), bind(1)]).
hex_to_bin(hexd(6), [bind(0), bind(1), bind(1), bind(0)]).
hex_to_bin(hexd(7), [bind(0), bind(1), bind(1), bind(1)]).
hex_to_bin(hexd(8), [bind(1), bind(0), bind(0), bind(0)]).
hex_to_bin(hexd(9), [bind(1), bind(0), bind(0), bind(1)]).
hex_to_bin(hexd(a), [bind(1), bind(0), bind(1), bind(0)]).
hex_to_bin(hexd(b), [bind(1), bind(0), bind(1), bind(1)]).
hex_to_bin(hexd(c), [bind(1), bind(1), bind(0), bind(0)]).
hex_to_bin(hexd(d), [bind(1), bind(1), bind(0), bind(1)]).
hex_to_bin(hexd(e), [bind(1), bind(1), bind(1), bind(0)]).
hex_to_bin(hexd(f), [bind(1), bind(1), bind(1), bind(1)]).

:- test byte_conversion(HB, BB) : ( HB = [hexd(f), hexd(f)] ) =>
    ( BB = [bind(1), bind(1), bind(1), bind(1), bind(1), bind(1), bind(1), bind(1)] ) + not_fails # "Byte máximo.".
:- test byte_conversion(HB, BB) : ( HB = [hexd(0), hexd(1)] )  =>
    ( BB = [bind(0), bind(0), bind(0), bind(0), bind(0), bind(0), bind(0), bind(1)] ) + not_fails # "Byte con valor 1.".
:- test byte_conversion(HB, BB) : ( BB = [bind(1), bind(1), bind(1), bind(1), bind(0), bind(0), bind(0), bind(1)]) =>
    ( HB = [hexd(f), hexd(1)] ) + not_fails # "Conversion binario a hexadecimal.".

:- pred byte_conversion(HB, BB) # " True if @var{HB}, a hex byte, is equal in
value to @var{BB}, a binary byte. Used to convert hex bytes to binary.

@begin{verbatim}
?- byte_conversion([hexd(b), hexd(f)], BB).
BB = [bind(1), bind(0), bind(1), bind(1),
      bind(1), bind(1), bind(1), bind(1)] ? ;
no.
@end{verbatim} ".

byte_conversion(HB, BB) :-
    hex_byte(HB), binary_byte(BB),
    [HB1|[HB2|[]]] = HB,
    [BB0|[BB1|[BB2|[BB3|BBR]]]] = BB,
    hex_to_bin(HB1, [BB0, BB1, BB2, BB3]),
    hex_to_bin(HB2, BBR).

% Predicado 3
:- test byte_list_conversion(HBL, BBL) : ( HB = [[hexd(4), hexd(4)]] ) =>
    ( BB = [bind(1), bind(1), bind(1), bind(1), bind(1), bind(1), bind(1), bind(1)] ) + not_fails # "Regular call with list of length 1.".

:- pred byte_list_conversion(HBL, BBL) # "True if @var{HBL}, a hex byte list, is equal in
value to @var{BBL}, a binary byte list. Used to convert hex bytes lists to binary.

Two empty lists are considered to be equal in value.
Tests with lists longer than length 1 will cause a TeX hbox overflow in trying to display the binary bite list.

@begin{verbatim}
?- byte_list_conversion([[hexd(b), hexd(f)]], BN).
BN = [[bind(1), bind(0), bind(1), bind(1),
       bind(1), bind(1), bind(1), bind(1)]] ? ;
no.
@end{verbatim} ".

byte_list_conversion([], []).
byte_list_conversion(HBL, BBL) :-
    [HB1|HBR] = HBL,
    [BB1|BBR] = BBL,
    byte_conversion(HB1, BB1),
    byte_list_conversion(HBR, BBR).

% Predicado 4

:- pred tail(L, R, T) # "Provides a way to access lists in reverse order, instead of accessing them via head/tail,
@var{R} is the leading part of the list (rest), and @var{T} is the last item (tail).

However, this operation has linear complexity, to access lists in reverse order, it would be more efficient to reverse them.".
tail([H | []], [], H).
tail(L, R, T) :-
    [L0 | L1] = L,
    [R0 | R1] = R,
    L0 = R0,
    tail(L1, R1, T).

get_nth_bit_from_byte_rec(0, B, BN) :-
    tail(B, _, B0),
    BN = B0.

get_nth_bit_from_byte_rec(s(A), B, BN) :- 
    tail(B, BR, _),
    get_nth_bit_from_byte_rec(A, BR, BN).


:- test get_nth_bit_from_byte(N, B, BN) : ( N = s(s(0)), B = [hexd(0), hexd(4)] ) =>
    ( BN = bind(1) ) + not_fails .

:- test get_nth_bit_from_byte(N, B, BN) : ( BN = bind(1), B = [hexd(0), hexd(8)] ) =>
    ( N = s(s(s(0)))) + not_fails .

:- pred get_nth_bit_from_byte(N, B, BN) # "True if @var{BN} is equivalent to the bit at position @var{N} of the byte @var{B}.

Used to get the bit at position @var{N} of the byte where @var{N} is a natural number expresed in terms of Peano's axioms, that is,
as the succesor of another number recursively until reaching 0.

Bytes are big endian so the 0th bit is actually the last.
This predicate is quite inefficient because it uses the tail/1 predicate, which has linear time complexity, in each recursive step.".

get_nth_bit_from_byte(N, BB, BN) :-
    binary_byte(BB),
    get_nth_bit_from_byte_rec(N, BB, BN).

get_nth_bit_from_byte(N, HB, BN) :-
    byte_conversion(HB, BB),
    get_nth_bit_from_byte_rec(N, BB, BN).

% Predicado 5
:- pred byte_list_clsh(L, CLShL) # "Performs a circular left shift on byte list @var{L}.@p
@tt{NOT IMPLEMENTED}".

byte_list_clsh(L, CLShL) :-
    byte_list(L), byte_list(CLShL).

% Predicado 6
:- pred byte_list_crsh(L, CLShL) # "Performs a circular right shift on byte list @var{L}.@p
@tt{NOT IMPLEMENTED}".

byte_list_crsh(L, CRShL) :-
    byte_list(L), byte_list(CRShL).

% Predicado 7
:- pred xor(B1, B2, BR) # "Implements the logical gate xor for two bit @var{B1} and @var{B2} with a result @var{BR}. @includedef{xor/3} ".

xor(bind(0), bind(0), bind(0)).
xor(bind(0), bind(1), bind(1)).
xor(bind(1), bind(0), bind(1)).
xor(bind(1), bind(1), bind(0)).

byte_xor_rec([], [], []).

byte_xor_rec(B1, B2, B3) :-
    [H1|T1] = B1, [H2|T2] = B2, [H3|T3] = B3,
    xor(H1, H2, H3), byte_xor_rec(T1, T2, T3).

:- test byte_xor(B1, B2, B3) : ( B1 = [hexd(a), hexd(b)], B2 = [hexd(4), hexd(f)] ) => ( B3 = [hexd(e), hexd(4)] ) + not_fails .

:- pred byte_xor(B1, B2, B3) # "Implements a bitwise XOR operation between two input bytes @var{B1} and @var{B2}.
Hex bytes are first converted to binary bytes and then the xor predicate is used recursively on each bit.

@var{B3} is the output byte.

Three empty lists B1 = [], B2 = [] and B3 = [] will validate this predicate.".

byte_xor(B1, B2, B3) :-
    binary_byte(B1), binary_byte(B2), binary_byte(B3),
    byte_xor_rec(B1, B2, B3).

byte_xor(B1, B2, B3) :-
    byte_conversion(B1, BB1), byte_conversion(B2, BB2), byte_conversion(B3, BB3),
    byte_xor_rec(BB1, BB2, BB3).

