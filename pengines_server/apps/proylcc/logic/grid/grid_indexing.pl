:- module(grid_indexing,
    [
        index/4,         % index(+Row, +Col, +NumCols, -Index)
        get_cell/4,      % get_cell(+Grid, +Row, +Col, +NumCols, -Value)
        set_cell/5       % set_cell(+Grid, +Row, +Col, +NumCols, +Value, -NewGrid)
    ]).

index(Row, Col, NumCols, Index) :-
    Index is (Row - 1) * NumCols + (Col - 1).

get_cell(Grid, Row, Col, NumCols, Value) :-
    index(Row, Col, NumCols, Index),
    nth0(Index, Grid, Value).

set_cell(Grid, Row, Col, NumCols, Value, NewGrid) :-
    index(Row, Col, NumCols, Index),
    replace_at(Grid, Index, Value, NewGrid).

replace_at([_|T], 0, V, [V|T]).
replace_at([H|T], I, V, [H|R]) :-
    I > 0,
    I1 is I - 1,
    replace_at(T, I1, V, R).
