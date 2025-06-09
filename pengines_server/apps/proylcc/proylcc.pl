:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid/grid_utils).
:- use_module(logic/block_factory, [random_block/2]).

shoot(Block, Column, Grid, NumCols, Effects) :-
    find_empty_row(Grid, Column, NumCols, RowIndex),
    insert_block_with_merge_effects(Grid, RowIndex, Column, Block, NumCols, Effects).

randomBlock(Grid, Block) :-
    random_block(Grid, Block).