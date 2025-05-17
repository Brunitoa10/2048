:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid/grid_utils).
:- use_module(logic/block_factory, [random_block/2]).

shoot(Block, Column, Grid, NumCols, [effect(UpdatedGrid, [newBlock(Points)])]) :-
    find_empty_row(Grid, Column, NumCols, RowIndex),
    insert_block_with_merge(Grid, RowIndex, Column, Block, NumCols, UpdatedGrid),
    calculate_points(Grid, UpdatedGrid, Block, Points).

calculate_points(OldGrid, NewGrid, _, Points) :-
    findall(V, (member(V, OldGrid), number(V)), OldValues),
    findall(V, (member(V, NewGrid), number(V)), NewValues),
    
    sum_list(OldValues, OldSum),
    sum_list(NewValues, NewSum),
    
    Points is NewSum - OldSum.

randomBlock(Grid, Block) :-
    random_block(Grid, Block).