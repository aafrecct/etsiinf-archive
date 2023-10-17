:- module(_,_,[classic, assertions, regtypes]).
:- doc(title, "Práctica 2").
:- doc(author, "Borja Martinena, b190242").
:- doc(module, 

"The module contains the predicates specified for the
second practical exercise of the @em{Programación Declarativa} course at ETSIINF
in the academic year 2021-2022.

@noindent
Not all of the predicates are included as aranya/1 has NOT been inplemented.
The first group of predicates belong to the first exercise. The goal of this 
first exercise is to find the amount of M-ary partitions a number N has.
This must be done relatively eficiently so as to avoid timelimit issues.
The following predicates belong to the first exercise.
@begin{itemize}
    @item{@tt{largest_pow_with_max_start}}
    @item{@tt{largest_pow_with_max}}
    @item{@tt{pots_with_start}}
    @item{@tt{pots}}
    @item{@tt{mpart_rec_top}}
    @item{@tt{mpart}}
    @item{@tt{maria}}
@end{itemize}

Only the first part of the second exercise is implemented, which allows
the user to create a non-directed graph. The following predicates belong
to this feature:
@begin{itemize}
    @item{@tt{arista_check}}
    @item{@tt{guardar_arista}}
    @item{@tt{guardar_grafo_rec}}
    @item{@tt{guardar_grafo}}
@end{itemize}

While this document sometimes mentions actions common to imperative programming,
such as @em{adding} an element to a list. These should be take to mean the
apropiate equivalent, in this case, creating a new list with the new element,
usually prepended.
").

:- doc(hide, author_data/4).


author_data('Martinena', 'Cepa', 'Borja', 'b190242').

% Binary Digit.
:- prop bind(D) # "@var{D} is a binary digit. @noindent @includedef{bind/1}".

bind(0).
bind(1).

:- prop debug(L) # "@var{L} is a list of things to print to stderr.

@tt{debug} is an auxiliary predicate to help with understanding the flow
of the program. It's similar to the print function in other languages. Takes
a list of arguments and prints them to stderr separated by spaces.

@noindent @includedef{debug/1}".

debug([]) :-
    write(user_error, '\n').

debug([H|T]) :-
    write(user_error, H),
    write(user_error, ' '),
    debug(T).

:- prop largest_pow_with_max_start(N, M, P, L) # "
@var{N} is the base number.\n
@var{M} is the maximum number. \n
@var{P} is the result (stands for Power).\n
@var{L} is the start (generaly the last result).

@tt{largest_pow_with_max_start} is a recursive predicate that calculates the
largest power of N thats lower than M, starting from L.

@noindent @includedef{largest_pow_with_max_start/1}".

largest_pow_with_max_start(N, M, P, L) :-
    PT is L*N,
    (PT > M ->
        P = L;
        largest_pow_with_max_start(N, M, P, PT)).

:- prop largest_pow_with_max(N, M, P) # "
Equivalent to @tt{largest_pow_with_max_start(N, M, P, 1).}

@noindent @includedef{bind/1}".

largest_pow_with_max(N, M, P) :-
    largest_pow_with_max_start(N, M, P, 1).


:- prop pots_with_start(N, S, L) # "
A helper predicate for @tt{pots/2}.

@var{N} is the base number.
@var{S} is the largest power to place in L.
@var{L} a list of all powers of N up to S in reverse order.

@tt{pots_with_start} recursively adds S to L and divides it by N.

@noindent @includedef{bind/1}".
pots_with_start(_, 1, [1]).

pots_with_start(N, S, [S | Rs]) :-
    S > 0,
    T is S//N,
    pots_with_start(N, T, Rs).



:- prop pots(N, M, Ps) # "
    Calls @tt{pots_with_start} starting with the result of
    @tt{largest_pow_with_max} for N and M.
".

pots(N, M, Ps) :-
    largest_pow_with_max(N, M, S),
    pots_with_start(N, S, Ps).

:- prop mpart_rec_top(N, L, M, Ps) # "
A helper predicate for mpart.

@var{N} The number to partition.
@var{L} A possible partition of N.
@var{M} The maximum value for the number to be added to L.
@var{Ps} The list of possible values to partition N with.

The predicate recursively calls itself to add to the partition
new numbers, always from largest to smallest. Recursion ends
when the remaining value in @var{N}, coincides with a number
in @var{Ps}.

The predicate will return all different partitions when asked
for more answers.

@noindent
@includedef{mpart_rec_top/4}
".

mpart_rec_top(R, [R], M, Ps) :-
    member(R, Ps),
    R =< M.

mpart_rec_top(R, [X | P], M, Ps) :-
    R > 0,
    member(X, Ps),
    X =< M,
    R2 is R - X,
    mpart_rec_top(R2, P, X, Ps).


:- prop mpart(M, N, P) # "
Partitions @var{N} as a sum of powers of M.
First finds all powers of M smaller than N via @tt{pots/3}.
Then returns all the answers of @tt{mpart_rec_top/4} with
that list and a max equal to N.

@noindent
@includedef{mpart/3}
".

mpart(M, N, P) :-
    M =< N,
    pots(M, N, Ps),
    mpart_rec_top(N, P, N, Ps).



:- prop maria(M, N, NParts) # "
Counts all the solutions found by mpart for @var{M} and @var{N}
by using @tt{findall} and @{length}.
Also checks if M and N are integers in order to only do so once.

@noindent
@includedef{maria/3}".

maria(M, N, NParts) :-
    integer(M),
    integer(N),
    findall(P, mpart(M, N, P), PS), 
    length(PS, NParts).

:- prop arista(V1, V2) # "Defines an edge in a graph. Takes two nodes.
@noindent @includedef{arista/2}".

:- dynamic arista/2.

:- prop arista(V1, V2) # "Checks if the same edge has already been added
with the nodes specified in the inverse order.

@noindent
@includedef{arista_check/2}".

arista_check(P1, P2) :-
    \+ arista(P2, P1).


:- prop guardar_arista(arista(V1, V2)) # "Adds @tt{arista(V1, V2)} to the rule list.
essentially saving the edge, after checking it had been added already.

@noindent
@includedef{guardar_arista/1}".
guardar_arista(arista(P1, P2)) :-
    arista_check(P1, P2),
    assert(arista(P1, P2)).

:- prop guardar_grafo_rec(L) # "Recursively adds all the edges in L.".
guardar_grafo_rec([]).

guardar_grafo_rec([H|T]) :-
    guardar_arista(H),
    guardar_grafo_rec(T).

:-prop guardar_grafo(L) # ".
Clears all saved edges and add the edges in L. Essentially replacing the graph.

@var{L} is a list of edges.

@noindent
@includedef{guardar_grafo/1}
".
guardar_grafo(L) :-
    retractall(arista(_,_)),
    guardar_grafo_rec(L).

