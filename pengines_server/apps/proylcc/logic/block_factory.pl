:- module(block_factory, [ random_block/2 ]).

/**
 * random_block(+Grid, -Block)
 * Genera un bloque aleatorio en función del valor máximo de la grilla.
 */
random_block(Grid, Block) :-
    max_block(Grid, Max),
    allowed_range(Max, Range),
    random_member(Block, Range).

% Encuentra el bloque máximo actual en la grilla
max_block(Grid, Max) :-
    include(number, Grid, Numbers),
    ( Numbers == [] -> Max = 0 ; max_list(Numbers, Max) ).

% Define los rangos dinámicos en base al máximo bloque
allowed_range(Max, Range) :-
    ( Max =< 8       -> Range = [2, 4]
    ; Max =< 16      -> Range = [2, 4, 8]
    ; Max =< 32      -> Range = [2, 4, 8, 16]
    ; Max =< 64      -> Range = [2, 4, 8, 16, 32]
    ; Max =< 128     -> Range = [2, 4, 8, 16, 32, 64]
    ; Max =< 256     -> Range = [4, 8, 16, 32, 64, 128]
    ; Max =< 512     -> Range = [ 8, 16, 32, 64, 128, 256]
    ; Max =< 1024    -> Range = [16, 32, 64, 128, 256, 512]
    ; Max =< 2048    -> Range = [32, 64, 128, 256, 512, 1024]
    ;                 Range = [64, 128, 256, 512, 1024, 2048]
    ).