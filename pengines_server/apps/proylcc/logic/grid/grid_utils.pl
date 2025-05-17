
:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        insert_block_with_merge/6
    ]).

:- use_module(grid_indexing).
:- use_module(grid_merge).

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
    insert_block(Grid, Row, Col, Block, NumCols, TempGrid),
    grid_merge:merge_all_possible(TempGrid, NumCols, FinalGrid).