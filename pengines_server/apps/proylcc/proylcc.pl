:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid/grid_utils).
:- use_module(logic/block_factory, [random_block/2]).

/**
 * shoot(+Block, +Column, +Grid, +NumCols, -Effects) 
 * Coloca un bloque en la primera posición vacía de una columna.
 */
shoot(Block, Column, Grid, NumCols, [effect(UpdatedGrid, [])]) :-
    find_empty_row(Grid, Column, NumCols, RowIndex),
   /* valid_shot_position(Grid, RowIndex, Column, Block, NumCols),*/
    insert_block_with_merge(Grid, RowIndex, Column, Block, NumCols, UpdatedGrid).

/**
 * randomBlock(+Grid, -Block)
 * Elige un bloque aleatorio entre 2 y 4.
 */
randomBlock(Grid, Block) :-
    random_block(Grid, Block).
