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
    ; find_and_merge_pair(Grid, NumCols, ResultGrid)
    ).


find_and_merge_quad(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value),
    !,
    merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid).
    
find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value) :-
    between(1, NumRows, StartRow),
    between(1, NumCols, StartCol),
    grid_indexing:get_cell(Grid, StartRow, StartCol, NumCols, Value),
    Value \= '-',
    find_connected_blocks(Grid, NumRows, NumCols, [StartRow-StartCol], [], [StartRow-StartCol], Value, BlockPositions),
    length(BlockPositions, 4).

find_connected_blocks(_, _, _, [], Visited, Visited, _, Visited).
find_connected_blocks(Grid, NumRows, NumCols, [Row-Col|Stack], Visited, CurrentPath, Value, Result) :-
    length(CurrentPath, Length),
    (Length >= 4 
    -> Result = CurrentPath
    ; adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells),
      filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells),
      append(ValidCells, Stack, NewStack),
      append(Visited, ValidCells, NewVisited),
      find_connected_blocks(Grid, NumRows, NumCols, NewStack, NewVisited, NewVisited, Value, Result)
    ).

adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells) :-
    findall(R-C, (
        (R is Row-1, C is Col, R >= 1);
        (R is Row+1, C is Col, R =< NumRows);
        (R is Row, C is Col-1, C >= 1);
        (R is Row, C is Col+1, C =< NumCols)
    ), AdjacentCells).

filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells) :-
    findall(R-C, (
        member(R-C, AdjacentCells),
        \+ member(R-C, Visited),
        grid_indexing:get_cell(Grid, R, C, NumCols, CellValue),
        CellValue == Value
    ), ValidCells).

merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid) :-
    MergeValue is Value * 8,
    
    sort(BlockPositions, SortedPositions),
    SortedPositions = [FinalRow-FinalCol|_],
    
    clear_blocks(Grid, BlockPositions, NumCols, TempGrid),
    
    grid_indexing:set_cell(TempGrid, FinalRow, FinalCol, NumCols, MergeValue, ResultGrid).

clear_blocks(Grid, [], _, Grid).
clear_blocks(Grid, [Row-Col|Rest], NumCols, ResultGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    clear_blocks(TempGrid, Rest, NumCols, ResultGrid).


find_and_merge_specific_l_pattern(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
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
    Value \= '-',
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, NextCol, NumCols, Value).

find_l_pattern_2(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(2, NumCols, Col),  
    NextRow is Row + 1,
    PrevCol is Col - 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    Value \= '-',
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
    Value \= '-',
    grid_indexing:get_cell(Grid, Row, NextCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

find_l_pattern_4(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    NextRow is Row + 1,
    PrevCol is Col - 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    Value \= '-',
    grid_indexing:get_cell(Grid, Row, PrevCol, NumCols, Value),
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid) :-
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
    (find_trio_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_row(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_trio_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_col(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; fail
    ).

find_trio_in_row(Grid, NumRows, NumCols, Row, StartCol, Value) :-
    between(1, NumRows, Row),
    between(1, NumCols, StartCol),
    StartCol =< NumCols - 2, 
    grid_indexing:get_cell(Grid, Row, StartCol, NumCols, Value),
    Value \= '-',
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    grid_indexing:get_cell(Grid, Row, MiddleCol, NumCols, Value),
    grid_indexing:get_cell(Grid, Row, EndCol, NumCols, Value).

find_trio_in_col(Grid, NumRows, NumCols, StartRow, Col, Value) :-
    between(1, NumCols, Col),
    between(1, NumRows, StartRow),
    StartRow =< NumRows - 2,  
    grid_indexing:get_cell(Grid, StartRow, Col, NumCols, Value),
    Value \= '-',
    MiddleRow is StartRow + 1,
    EndRow is StartRow + 2,
    grid_indexing:get_cell(Grid, MiddleRow, Col, NumCols, Value),
    grid_indexing:get_cell(Grid, EndRow, Col, NumCols, Value).

merge_trio_in_row(Grid, Row, StartCol, Value, NumCols, ResultGrid) :-
    MergeValue is Value * 4,
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    grid_indexing:set_cell(Grid, Row, StartCol, NumCols, '-', TempGrid1),
    grid_indexing:set_cell(TempGrid1, Row, EndCol, NumCols, '-', TempGrid2),
    grid_indexing:set_cell(TempGrid2, Row, MiddleCol, NumCols, MergeValue, ResultGrid).

merge_trio_in_col(Grid, StartRow, Col, Value, NumCols, ResultGrid) :-
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
    between(1, NumCols, Col),
    Col < NumCols,
    NextCol is Col + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    Value \= '-',
    grid_indexing:get_cell(Grid, Row, NextCol, NumCols, Value).

find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumCols, Col),
    between(1, NumRows, Row),
    Row < NumRows,
    NextRow is Row + 1,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, Value),
    Value \= '-',
    grid_indexing:get_cell(Grid, NextRow, Col, NumCols, Value).

merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    Sum is Value + Value,
    NextCol is Col + 1,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid).

merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    Sum is Value + Value,
    NextRow is Row + 1,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, NextRow, Col, NumCols, '-', ResultGrid).