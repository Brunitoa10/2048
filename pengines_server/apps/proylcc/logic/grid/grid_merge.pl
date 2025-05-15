:- module(grid_merge,
    [
        maybe_merge_recursive/5
    ]).

:- use_module(grid_indexing).

maybe_merge_recursive(Grid, Row, Col, NumCols, FinalGrid) :-
    (   can_merge(Grid, Row, Col, NumCols)
    ->  perform_merge(Grid, Row, Col, NumCols, NewGrid, NewRow, NewCol),
        maybe_merge_recursive(NewGrid, NewRow, NewCol, NumCols, FinalGrid)
    ;   FinalGrid = Grid
    ).

can_merge(Grid, Row, Col, NumCols) :-
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Block),
    Block \= '-',
    (
        Row > 1,
        R1 is Row - 1,
        grid_indexing:get_cell(Grid, R1, Col, NumCols, B1),
        Block == B1
    ;
        Col > 1,
        C1 is Col - 1,
        grid_indexing:get_cell(Grid, Row, C1, NumCols, B2),
        Block == B2
    ;
        Col < NumCols,
        C2 is Col + 1,
        grid_indexing:get_cell(Grid, Row, C2, NumCols, B3),
        Block == B3
    ).

perform_merge(Grid, Row, Col, NumCols, NewGrid, NewRow, NewCol) :-
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Block),
    (
        Row > 1,
        R1 is Row - 1,
        grid_indexing:get_cell(Grid, R1, Col, NumCols, B1),
        Block == B1,
        Sum is Block + B1,
        grid_indexing:set_cell(Grid, R1, Col, NumCols, Sum, G1),
        grid_indexing:set_cell(G1, Row, Col, NumCols, '-', NewGrid),
        NewRow = R1, NewCol = Col
    ;
        Col > 1,
        C1 is Col - 1,
        grid_indexing:get_cell(Grid, Row, C1, NumCols, B2),
        Block == B2,
        Sum is Block + B2,
        grid_indexing:set_cell(Grid, Row, C1, NumCols, Sum, G1),
        grid_indexing:set_cell(G1, Row, Col, NumCols, '-', NewGrid),
        NewRow = Row, NewCol = C1
    ;
        Col < NumCols,
        C2 is Col + 1,
        grid_indexing:get_cell(Grid, Row, C2, NumCols, B3),
        Block == B3,
        Sum is Block + B3,
        grid_indexing:set_cell(Grid, Row, C2, NumCols, Sum, G1),
        grid_indexing:set_cell(G1, Row, Col, NumCols, '-', NewGrid),
        NewRow = Row, NewCol = C2
    ).
