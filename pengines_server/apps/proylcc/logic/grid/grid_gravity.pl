:- module(grid_gravity, [
    apply_gravity/3
]).

:- use_module(grid_indexing).

apply_gravity(Grid, NumCols, NewGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    apply_gravity_to_all_columns(Grid, NumCols, NumRows, 1, NewGrid).

apply_gravity_to_all_columns(Grid, NumCols, _, Col, Grid) :-
    Col > NumCols, !.

apply_gravity_to_all_columns(Grid, NumCols, NumRows, Col, FinalGrid) :-
    Col =< NumCols,
    apply_gravity_to_column(Grid, NumCols, NumRows, Col, TempGrid),
    NextCol is Col + 1,
    apply_gravity_to_all_columns(TempGrid, NumCols, NumRows, NextCol, FinalGrid).

apply_gravity_to_column(Grid, NumCols, NumRows, Col, NewGrid) :-
    collect_column_blocks(Grid, NumCols, NumRows, Col, 1, [], Blocks),
    clear_column(Grid, NumCols, NumRows, Col, ClearedGrid),
    place_blocks_at_top(ClearedGrid, NumCols, NumRows, Col, Blocks, NewGrid).

collect_column_blocks(_, _, NumRows, _, Row, Acc, Acc) :-
    Row > NumRows, !.

collect_column_blocks(Grid, NumCols, NumRows, Col, Row, Acc, Blocks) :-
    Row =< NumRows,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    NextRow is Row + 1,
    (Value = '-' 
    -> collect_column_blocks(Grid, NumCols, NumRows, Col, NextRow, Acc, Blocks)
    ;  append(Acc, [Value], NewAcc),
       collect_column_blocks(Grid, NumCols, NumRows, Col, NextRow, NewAcc, Blocks)
    ).

clear_column(Grid, _, NumRows, _, Grid) :-
    NumRows =< 0, !.

clear_column(Grid, NumCols, NumRows, Col, NewGrid) :-
    NumRows > 0,
    clear_column_recursive(Grid, NumCols, NumRows, Col, 1, NewGrid).

clear_column_recursive(Grid, _, NumRows, _, Row, Grid) :-
    Row > NumRows, !.

clear_column_recursive(Grid, NumCols, NumRows, Col, Row, NewGrid) :-
    Row =< NumRows,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    NextRow is Row + 1,
    clear_column_recursive(TempGrid, NumCols, NumRows, Col, NextRow, NewGrid).

place_blocks_at_top(Grid, _, _, _, [], Grid) :- !.

place_blocks_at_top(Grid, NumCols, _, Col, Blocks, NewGrid) :-
    place_blocks_from_row(Grid, NumCols, Col, 1, Blocks, NewGrid).

place_blocks_from_row(Grid, _, _, _, [], Grid) :- !.

place_blocks_from_row(Grid, NumCols, Col, Row, [Block|RestBlocks], NewGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Block, TempGrid),
    NextRow is Row + 1,
    place_blocks_from_row(TempGrid, NumCols, Col, NextRow, RestBlocks, NewGrid).