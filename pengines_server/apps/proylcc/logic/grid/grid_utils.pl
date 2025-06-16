:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        insert_block_with_merge/6,
        insert_block_with_merge_effects/6
    ]).

:- use_module(grid_indexing).
:- use_module(grid_merge).
:- use_module(grid_gravity).

find_empty_row(Grid, Col, NumCols, RowIndex) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_empty_row_from_top(Grid, Col, NumCols, 1, NumRows, RowIndex).

find_empty_row_from_top(Grid, Col, NumCols, Row, NumRows, Row) :-
    Row =< NumRows,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, '-'), !.

find_empty_row_from_top(Grid, Col, NumCols, Row, NumRows, RowIndex) :-
    Row < NumRows,
    R1 is Row + 1,
    find_empty_row_from_top(Grid, Col, NumCols, R1, NumRows, RowIndex).

insert_block(Grid, Row, Col, Block, NumCols, NewGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Block, NewGrid).

insert_block_with_merge(Grid, Row, Col, Block, NumCols, FinalGrid) :-
    insert_block_with_merge_effects(Grid, Row, Col, Block, NumCols, Effects),
    last(Effects, effect(FinalGrid, _)).

insert_block_with_merge_effects(Grid, Row, Col, Block, NumCols, Effects) :-
    insert_block(Grid, Row, Col, Block, NumCols, TempGrid),
    apply_merge_and_gravity_with_individual_effects(TempGrid, NumCols, [effect(TempGrid, [])], Effects).

apply_merge_and_gravity_with_individual_effects(Grid, NumCols, AccEffects, FinalEffects) :-

    grid_gravity:apply_gravity(Grid, NumCols, GravityGrid),

    (Grid \= GravityGrid
    -> append(AccEffects, [effect(GravityGrid, [])], GravityEffects)
    ;  GravityEffects = AccEffects
    ),

    grid_merge:merge_all_possible_with_effects(GravityGrid, NumCols, FinalMergedGrid, MergeEffects),
    
    (MergeEffects \= []
    -> append(GravityEffects, MergeEffects, NewEffects),
       apply_merge_and_gravity_with_individual_effects(FinalMergedGrid, NumCols, NewEffects, FinalEffects)
    ; 
       (GravityEffects = []
       -> FinalEffects = [effect(Grid, [])]
       ;  FinalEffects = GravityEffects
       )
    ).