:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid/grid_utils).
:- use_module(logic/block_factory, [random_block/2]).

shoot(Block, Column, Grid, NumCols, [effect(UpdatedGrid, EffectInfo)]) :-
    find_empty_row(Grid, Column, NumCols, RowIndex),
    insert_block_with_merge(Grid, RowIndex, Column, Block, NumCols, UpdatedGrid),
    calculate_effects(Grid, UpdatedGrid, Block, EffectInfo).

calculate_effects(OldGrid, NewGrid, Block, EffectInfo) :-
    calculate_points(OldGrid, NewGrid, Points),
    detect_combo(OldGrid, NewGrid, ComboCount),
    detect_new_maximum(OldGrid, NewGrid, NewMax),
    build_effect_list(Points, ComboCount, NewMax, EffectInfo).

calculate_points(OldGrid, NewGrid, Points) :-
    findall(V, (member(V, OldGrid), number(V)), OldValues),
    findall(V, (member(V, NewGrid), number(V)), NewValues),
    sum_list(OldValues, OldSum),
    sum_list(NewValues, NewSum),
    Points is NewSum - OldSum.

detect_combo(OldGrid, NewGrid, ComboCount) :-
    findall(V, (member(V, OldGrid), number(V)), OldValues),
    findall(V, (member(V, NewGrid), number(V)), NewValues),
    length(OldValues, OldCount),
    length(NewValues, NewCount),
    (OldCount > NewCount -> 
        ComboCount is OldCount - NewCount
    ; 
        ComboCount = 0
    ).

detect_new_maximum(OldGrid, NewGrid, NewMax) :-
    max_block(OldGrid, OldMax),
    max_block(NewGrid, CurrentMax),
    (CurrentMax > OldMax -> 
        NewMax = CurrentMax
    ; 
        NewMax = 0
    ).

max_block(Grid, Max) :-
    include(number, Grid, Numbers),
    (Numbers == [] -> Max = 0 ; max_list(Numbers, Max)).

build_effect_list(Points, ComboCount, NewMax, EffectInfo) :-
    findall(Effect, (
        (Points > 0 -> Effect = newBlock(Points) ; fail);
        (ComboCount > 1 -> Effect = combo(ComboCount) ; fail);
        (NewMax > 0 -> Effect = newMaximum(NewMax) ; fail)
    ), EffectInfo).

randomBlock(Grid, Block) :-
    random_block(Grid, Block).