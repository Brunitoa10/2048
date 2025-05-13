:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid_utils).
:- use_module(logic/block_factory).

/**
 * shoot(+Block, +Column, +Grid, +NumCols, -Effects) 
 * Coloca un bloque en la primera posición vacía de una columna.
 */
shoot(Block, Column, Grid, NumCols, [effect(UpdatedGrid, [])]) :-
    find_empty_row(Grid, Column, NumCols, EmptyRowIndex),
    insert_block(Grid, EmptyRowIndex, Column, Block, NumCols, UpdatedGrid).

/**
 * randomBlock(+Grid, -Block)
 * Elige un bloque aleatorio entre 2 y 4.
 */
randomBlock(_Grid, Block) :-
    random_block(Block).
