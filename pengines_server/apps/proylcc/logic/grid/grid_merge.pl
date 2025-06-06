:- module(grid_merge, [
    merge_all_possible/3
]).

:- use_module(grid_indexing).

merge_all_possible(Grid, NumCols, FinalGrid) :-
    find_and_merge_any(Grid, NumCols, TempGrid),
    (Grid \= TempGrid 
    -> merge_all_possible(TempGrid, NumCols, FinalGrid)
    ;  FinalGrid = Grid).

find_and_merge_any(Grid, NumCols, ResultGrid) :-
    (find_and_merge_quad(Grid, NumCols, TempGrid)
    -> ResultGrid = TempGrid
    ; find_and_merge_specific_l_pattern(Grid, NumCols, TempGrid)
    -> ResultGrid = TempGrid
    ; find_and_merge_trio(Grid, NumCols, TempGrid)
    -> ResultGrid = TempGrid
    ; find_and_merge_pair(Grid, NumCols, TempGrid)
    -> ResultGrid = TempGrid
    ; ResultGrid = Grid
    ).

find_and_merge_quad(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 0,
    NumCols > 0,
    find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value),
    !,
    merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid).
    
find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value) :-
    between(1, NumRows, StartRow),
    between(1, NumCols, StartCol),
    grid_indexing:get_cell(Grid, StartRow, StartCol, NumCols, Value),
    number(Value),
    Value > 0,
    find_connected_blocks(Grid, NumRows, NumCols, [StartRow-StartCol], [StartRow-StartCol], Value, BlockPositions),
    length(BlockPositions, 4).

find_connected_blocks(_, _, _, [], Visited, _, Visited) :- !.
find_connected_blocks(Grid, NumRows, NumCols, [Row-Col|Stack], Visited, Value, Result) :-
    length(Visited, Length),
    (Length >= 4 
    -> Result = Visited
    ; adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells),
      filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells),
      append(ValidCells, Stack, NewStack),
      append(Visited, ValidCells, NewVisited),
      find_connected_blocks(Grid, NumRows, NumCols, NewStack, NewVisited, Value, Result)
    ).

adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells) :-
    R1 is Row - 1,
    R2 is Row + 1,
    C1 is Col - 1,
    C2 is Col + 1,
    findall(R-C, (
        (R = R1, C = Col, R >= 1, R =< NumRows);
        (R = R2, C = Col, R >= 1, R =< NumRows);
        (R = Row, C = C1, C >= 1, C =< NumCols);
        (R = Row, C = C2, C >= 1, C =< NumCols)
    ), AdjacentCells).

filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells) :-
    findall(R-C, (
        member(R-C, AdjacentCells),
        \+ member(R-C, Visited),
        grid_indexing:get_cell(Grid, R, C, NumCols, CellValue),
        CellValue == Value
    ), ValidCells).

merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 8,
    
    sort(BlockPositions, SortedPositions),
    SortedPositions = [FinalRow-FinalCol|_],
    
    clear_blocks(Grid, BlockPositions, NumCols, TempGrid),
    
    grid_indexing:set_cell(TempGrid, FinalRow, FinalCol, NumCols, MergeValue, ResultGrid).

clear_blocks(Grid, [], _, Grid) :- !.
clear_blocks(Grid, [Row-Col|Rest], NumCols, ResultGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    clear_blocks(TempGrid, Rest, NumCols, ResultGrid).

find_and_merge_specific_l_pattern(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 1,
    NumCols > 1,
    find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value),
    !,
    merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid).

find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value) :-
    (find_l_pattern_1(Grid, NumRows, NumCols, Row, Col, Value) ;
     find_l_pattern_2(Grid, NumRows, NumCols, Row, Col, Value) ;
     find_l_pattern_3(Grid, NumRows, NumCols, Row, Col, Value) ;
     find_l_pattern_4(Grid, NumRows, NumCols, Row, Col, Value)).

find_l_pattern_1(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(1, NumCols, Col),
    Col < NumCols,
    NextRow is Row + 1,
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, NextCol, NumCols, Value).

find_l_pattern_2(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(2, NumCols, Col),  
    NextRow is Row + 1,
    PrevCol is Col - 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, PrevCol, NumCols, Value).

find_l_pattern_3(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(1, NumCols, Col),
    Col < NumCols,
    NextRow is Row + 1,
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, Row, NextCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

find_l_pattern_4(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(2, NumCols, Col),
    NextRow is Row + 1,
    PrevCol is Col - 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, Row, PrevCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 4,
    
    (merge_l_pattern_1(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) ;
     merge_l_pattern_2(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) ;
     merge_l_pattern_3(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) ;
     merge_l_pattern_4(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid)).

merge_l_pattern_1(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, NextCol, NumCols, Value),
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', G1),
    grid_indexing:set_cell(G1, NextRow, Col, NumCols, '-', G2),
    grid_indexing:set_cell(G2, NextRow, NextCol, NumCols, '-', G3),
    grid_indexing:set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_2(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    PrevCol is Col - 1,
    Col > 1,
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, PrevCol, NumCols, Value),
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', G1),
    grid_indexing:set_cell(G1, NextRow, Col, NumCols, '-', G2),
    grid_indexing:set_cell(G2, NextRow, PrevCol, NumCols, '-', G3),
    grid_indexing:set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_3(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, Row, NextCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', G1),
    grid_indexing:set_cell(G1, Row, NextCol, NumCols, '-', G2),
    grid_indexing:set_cell(G2, NextRow, Col, NumCols, '-', G3),
    grid_indexing:set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_4(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    PrevCol is Col - 1,
    Col > 1,
    grid_indexing:get_cell(Grid, Row, PrevCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', G1),
    grid_indexing:set_cell(G1, Row, PrevCol, NumCols, '-', G2),
    grid_indexing:set_cell(G2, NextRow, Col, NumCols, '-', G3),
    grid_indexing:set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

find_and_merge_trio(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 2,
    NumCols > 2,
    (find_trio_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_row(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_trio_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_col(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; fail
    ).

find_trio_in_row(Grid, NumRows, NumCols, Row, StartCol, Value) :-
    between(1, NumRows, Row),
    MaxStartCol is NumCols - 2,
    MaxStartCol > 0,
    between(1, MaxStartCol, StartCol),
    grid_indexing:get_cell(Grid, Row, StartCol, NumCols, Value),
    number(Value),
    Value > 0,
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    grid_indexing:get_cell(Grid, Row, MiddleCol, NumCols, Value),
    grid_indexing:get_cell(Grid, Row, EndCol, NumCols, Value).

find_trio_in_col(Grid, NumRows, NumCols, StartRow, Col, Value) :-
    between(1, NumCols, Col),
    MaxStartRow is NumRows - 2,
    MaxStartRow > 0,
    between(1, MaxStartRow, StartRow),
    grid_indexing:get_cell(Grid, StartRow, Col, NumCols, Value),
    number(Value),
    Value > 0,
    MiddleRow is StartRow + 1,
    EndRow is StartRow + 2,
    grid_indexing:get_cell(Grid, MiddleRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, EndRow, Col, NumCols, Value).

merge_trio_in_row(Grid, Row, StartCol, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 4,
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    grid_indexing:set_cell(Grid, Row, StartCol, NumCols, '-', TempGrid1),
    grid_indexing:set_cell(TempGrid1, Row, EndCol, NumCols, '-', TempGrid2),
    grid_indexing:set_cell(TempGrid2, Row, MiddleCol, NumCols, MergeValue, ResultGrid).

merge_trio_in_col(Grid, StartRow, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 4,
    MiddleRow is StartRow + 1,
    EndRow is StartRow + 2,
    grid_indexing:set_cell(Grid, StartRow, Col, NumCols, '-', TempGrid1),
    grid_indexing:set_cell(TempGrid1, EndRow, Col, NumCols, '-', TempGrid2),
    grid_indexing:set_cell(TempGrid2, MiddleRow, Col, NumCols, MergeValue, ResultGrid).

find_and_merge_pair(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    (find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; Grid = ResultGrid
    ).

find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    MaxCol is NumCols - 1,
    MaxCol > 0,
    between(1, MaxCol, Col),
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, Row, NextCol, NumCols, Value).

find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumCols, Col),
    MaxRow is NumRows - 1,
    MaxRow > 0,
    between(1, MaxRow, Row),
    NextRow is Row + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    Sum is Value + Value,
    NextCol is Col + 1,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid).

merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    Sum is Value + Value,
    NextRow is Row + 1,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, NextRow, Col, NumCols, '-', ResultGrid).