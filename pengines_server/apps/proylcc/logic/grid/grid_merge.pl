:- module(grid_merge, [
    merge_all_possible/3,
    merge_all_possible_with_effects/4,
    find_and_merge_single_with_effects/4
]).

:- use_module(grid_indexing, [get_cell/5, set_cell/6]).

merge_all_possible(Grid, NumCols, FinalGrid) :-
    merge_all_possible_with_effects(Grid, NumCols, FinalGrid, _).

merge_all_possible_with_effects(Grid, NumCols, FinalGrid, Effects) :-
    merge_step_by_step(Grid, NumCols, [], FinalGrid, Effects).

merge_step_by_step(Grid, NumCols, AccEffects, FinalGrid, FinalEffects) :-
    find_and_merge_one_pattern_with_effects(Grid, NumCols, TempGrid, StepEffects),
    (Grid \= TempGrid -> 
       append(AccEffects, StepEffects, NewAccEffects),
       merge_step_by_step(TempGrid, NumCols, NewAccEffects, FinalGrid, FinalEffects);
       FinalGrid = Grid,
       FinalEffects = AccEffects
    ).

% Buscar UN patrón a la vez, en orden de prioridad (mayor a menor puntaje)
find_and_merge_one_pattern_with_effects(Grid, NumCols, ResultGrid, Effects) :-
    (find_and_merge_quad_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_specific_l_pattern_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_trio_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_pair_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; ResultGrid = Grid,
      Effects = []
    ).

% Función original para combinaciones 
find_and_merge_single_with_effects(Grid, NumCols, ResultGrid, Effects) :-
    find_all_simultaneous_merges(Grid, NumCols, AllMerges),
    (AllMerges \= []
    -> apply_simultaneous_merges(Grid, NumCols, AllMerges, ResultGrid, TotalPoints),
       Effects = [effect(ResultGrid, [newBlock(TotalPoints)])]
    ; ResultGrid = Grid,
      Effects = []
    ).

% Encuentra todas las combinaciones que pueden ocurrir simultáneamente
find_all_simultaneous_merges(Grid, NumCols, SimultaneousMerges) :-
    findall(merge(Type, Positions, Value), find_single_merge(Grid, NumCols, Type, Positions, Value), AllMerges),
    filter_non_overlapping_merges(AllMerges, SimultaneousMerges).

% Encuentra una combinación específica
find_single_merge(Grid, NumCols, quad, Positions, Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_quad_connected(Grid, NumRows, NumCols, Positions, Value).

find_single_merge(Grid, NumCols, l_pattern, [Row-Col], Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value).

find_single_merge(Grid, NumCols, trio_row, [Row, StartCol], Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_trio_in_row(Grid, NumRows, NumCols, Row, StartCol, Value).

find_single_merge(Grid, NumCols, trio_col, [StartRow, Col], Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_trio_in_col(Grid, NumRows, NumCols, StartRow, Col, Value).

find_single_merge(Grid, NumCols, pair_row, [Row, Col], Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value).

find_single_merge(Grid, NumCols, pair_col, [Row, Col], Value) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value).

filter_non_overlapping_merges([], []).
filter_non_overlapping_merges([Merge|Rest], [Merge|FilteredRest]) :-
    remove_overlapping_merges(Rest, Merge, NonOverlapping),
    filter_non_overlapping_merges(NonOverlapping, FilteredRest).

remove_overlapping_merges([], _, []).
remove_overlapping_merges([Merge|Rest], ReferenceMerge, Result) :-
    (merges_overlap(Merge, ReferenceMerge)
    -> remove_overlapping_merges(Rest, ReferenceMerge, Result)
    ; Result = [Merge|FilteredRest],
      remove_overlapping_merges(Rest, ReferenceMerge, FilteredRest)
    ).

merges_overlap(merge(_, Positions1, _), merge(_, Positions2, _)) :-
    merge_positions_to_cells(Positions1, Cells1),
    merge_positions_to_cells(Positions2, Cells2),
    intersection(Cells1, Cells2, Intersection),
    Intersection \= [].

merge_positions_to_cells(Positions, Cells) :-
    (is_list(Positions), Positions = [_-_|_] 
    -> Cells = Positions
    ; Positions = [Row-Col]
    -> get_l_pattern_cells(Row, Col, Cells)
    ; Positions = [Row, StartCol], number(Row)
    -> EndCol is StartCol + 2,
       MiddleCol is StartCol + 1,
       Cells = [Row-StartCol, Row-MiddleCol, Row-EndCol]
    ; Positions = [StartRow, Col], number(StartRow)
    -> EndRow is StartRow + 2,
       MiddleRow is StartRow + 1,
       Cells = [StartRow-Col, MiddleRow-Col, EndRow-Col]
    ; Positions = [Row, Col] 
    -> Cells = [Row-Col, Row-(Col+1)] 
    ; Cells = []
    ).

get_l_pattern_cells(Row, Col, Cells) :-
    NextRow is Row + 1,
    NextCol is Col + 1,
    Cells = [Row-Col, NextRow-Col, NextRow-NextCol].

% Aplica todas las combinaciones simultáneas
apply_simultaneous_merges(Grid, NumCols, Merges, FinalGrid, TotalPoints) :-
    apply_merges_to_grid(Grid, NumCols, Merges, FinalGrid),
    calculate_total_points(Merges, TotalPoints).

apply_merges_to_grid(Grid, _, [], Grid).
apply_merges_to_grid(Grid, NumCols, [Merge|Rest], FinalGrid) :-
    apply_single_merge_to_grid(Grid, NumCols, Merge, TempGrid),
    apply_merges_to_grid(TempGrid, NumCols, Rest, FinalGrid).

apply_single_merge_to_grid(Grid, NumCols, merge(quad, Positions, Value), ResultGrid) :-
    merge_quad_blocks(Grid, Positions, Value, NumCols, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(l_pattern, [Row-Col], Value), ResultGrid) :-
    merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(trio_row, [Row, StartCol], Value), ResultGrid) :-
    merge_trio_in_row(Grid, Row, StartCol, Value, NumCols, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(trio_col, [StartRow, Col], Value), ResultGrid) :-
    merge_trio_in_col(Grid, StartRow, Col, Value, NumCols, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(pair_row, [Row, Col], Value), ResultGrid) :-
    merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(pair_col, [Row, Col], Value), ResultGrid) :-
    merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid).

calculate_total_points([], 0).
calculate_total_points([merge(Type, _, Value)|Rest], TotalPoints) :-
    calculate_merge_points(Type, Value, Points),
    calculate_total_points(Rest, RestPoints),
    TotalPoints is Points + RestPoints.

calculate_merge_points(quad, Value, Points) :- Points is Value * 8.
calculate_merge_points(l_pattern, Value, Points) :- Points is Value * 4.
calculate_merge_points(trio_row, Value, Points) :- Points is Value * 4.
calculate_merge_points(trio_col, Value, Points) :- Points is Value * 4.
calculate_merge_points(pair_row, Value, Points) :- Points is Value * 2.
calculate_merge_points(pair_col, Value, Points) :- Points is Value * 2.

% Versiones con efectos para cada tipo de merge 
find_and_merge_quad_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 0,
    NumCols > 0,
    find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value),
    !,
    merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid),
    Points is Value * 8.

find_and_merge_specific_l_pattern_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 1,
    NumCols > 1,
    find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value),
    !,
    merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid),
    Points is Value * 4.

find_and_merge_trio_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    NumRows > 2,
    NumCols > 2,
    (find_trio_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_row(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_trio_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_col(Grid, Row, Col, Value, NumCols, ResultGrid)
    ),
    !,
    Points is Value * 4.

find_and_merge_pair_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    (find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid),
       Points is Value * 2
    ; find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid),
       Points is Value * 2
    ),
    !.

% Búsqueda de cuádruples conectados
find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value) :-
    between(1, NumRows, StartRow),
    between(1, NumCols, StartCol),
    get_cell(Grid, StartRow, StartCol, NumCols, Value),
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
        get_cell(Grid, R, C, NumCols, CellValue),
        CellValue == Value
    ), ValidCells).

merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 8,
    
    sort(BlockPositions, SortedPositions),
    SortedPositions = [FinalRow-FinalCol|_],
    
    clear_blocks(Grid, BlockPositions, NumCols, TempGrid),
    
    set_cell(TempGrid, FinalRow, FinalCol, NumCols, MergeValue, ResultGrid).

clear_blocks(Grid, [], _, Grid) :- !.
clear_blocks(Grid, [Row-Col|Rest], NumCols, ResultGrid) :-
    set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    clear_blocks(TempGrid, Rest, NumCols, ResultGrid).

% Patrones L
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
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, NextRow, Col, NumCols, Value),
    get_cell(Grid, NextRow, NextCol, NumCols, Value).

find_l_pattern_2(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(2, NumCols, Col),  
    NextRow is Row + 1,
    PrevCol is Col - 1,
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, NextRow, Col, NumCols, Value),
    get_cell(Grid, NextRow, PrevCol, NumCols, Value).

find_l_pattern_3(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(1, NumCols, Col),
    Col < NumCols,
    NextRow is Row + 1,
    NextCol is Col + 1,
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, Row, NextCol, NumCols, Value),
    get_cell(Grid, NextRow, Col, NumCols, Value).

find_l_pattern_4(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    Row < NumRows,
    between(2, NumCols, Col),
    NextRow is Row + 1,
    PrevCol is Col - 1,
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, Row, PrevCol, NumCols, Value),
    get_cell(Grid, NextRow, Col, NumCols, Value).

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
    get_cell(Grid, NextRow, Col, NumCols, Value),
    get_cell(Grid, NextRow, NextCol, NumCols, Value),
    set_cell(Grid, Row, Col, NumCols, '-', G1),
    set_cell(G1, NextRow, Col, NumCols, '-', G2),
    set_cell(G2, NextRow, NextCol, NumCols, '-', G3),
    set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_2(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    PrevCol is Col - 1,
    Col > 1,
    get_cell(Grid, NextRow, Col, NumCols, Value),
    get_cell(Grid, NextRow, PrevCol, NumCols, Value),
    set_cell(Grid, Row, Col, NumCols, '-', G1),
    set_cell(G1, NextRow, Col, NumCols, '-', G2),
    set_cell(G2, NextRow, PrevCol, NumCols, '-', G3),
    set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_3(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    NextCol is Col + 1,
    get_cell(Grid, Row, NextCol, NumCols, Value),
    get_cell(Grid, NextRow, Col, NumCols, Value),
    set_cell(Grid, Row, Col, NumCols, '-', G1),
    set_cell(G1, Row, NextCol, NumCols, '-', G2),
    set_cell(G2, NextRow, Col, NumCols, '-', G3),
    set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

merge_l_pattern_4(Grid, Row, Col, Value, NumCols, MergeValue, ResultGrid) :-
    NextRow is Row + 1,
    PrevCol is Col - 1,
    Col > 1,
    get_cell(Grid, Row, PrevCol, NumCols, Value),
    get_cell(Grid, NextRow, Col, NumCols, Value),
    set_cell(Grid, Row, Col, NumCols, '-', G1),
    set_cell(G1, Row, PrevCol, NumCols, '-', G2),
    set_cell(G2, NextRow, Col, NumCols, '-', G3),
    set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

% Tríos
find_trio_in_row(Grid, NumRows, NumCols, Row, StartCol, Value) :-
    between(1, NumRows, Row),
    MaxStartCol is NumCols - 2,
    MaxStartCol > 0,
    between(1, MaxStartCol, StartCol),
    get_cell(Grid, Row, StartCol, NumCols, Value),
    number(Value),
    Value > 0,
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    get_cell(Grid, Row, MiddleCol, NumCols, Value),
    get_cell(Grid, Row, EndCol, NumCols, Value).

find_trio_in_col(Grid, NumRows, NumCols, StartRow, Col, Value) :-
    between(1, NumCols, Col),
    MaxStartRow is NumRows - 2,
    MaxStartRow > 0,
    between(1, MaxStartRow, StartRow),
    get_cell(Grid, StartRow, Col, NumCols, Value),
    number(Value),
    Value > 0,
    MiddleRow is StartRow + 1,
    EndRow is StartRow + 2,
    get_cell(Grid, MiddleRow, Col, NumCols, Value),
    get_cell(Grid, EndRow, Col, NumCols, Value).

merge_trio_in_row(Grid, Row, StartCol, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 4,
    MiddleCol is StartCol + 1,
    EndCol is StartCol + 2,
    set_cell(Grid, Row, StartCol, NumCols, '-', TempGrid1),
    set_cell(TempGrid1, Row, EndCol, NumCols, '-', TempGrid2),
    set_cell(TempGrid2, Row, MiddleCol, NumCols, MergeValue, ResultGrid).

merge_trio_in_col(Grid, StartRow, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    MergeValue is Value * 4,
    MiddleRow is StartRow + 1,
    EndRow is StartRow + 2,
    set_cell(Grid, StartRow, Col, NumCols, '-', TempGrid1),
    set_cell(TempGrid1, EndRow, Col, NumCols, '-', TempGrid2),
    set_cell(TempGrid2, MiddleRow, Col, NumCols, MergeValue, ResultGrid).

% Pares
find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row),
    MaxCol is NumCols - 1,
    MaxCol > 0,
    between(1, MaxCol, Col),
    NextCol is Col + 1,
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, Row, NextCol, NumCols, Value).

find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumCols, Col),
    MaxRow is NumRows - 1,
    MaxRow > 0,
    between(1, MaxRow, Row),
    NextRow is Row + 1,
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value),
    Value > 0,
    get_cell(Grid, NextRow, Col, NumCols, Value).

merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    Sum is Value + Value,
    NextCol is Col + 1,
    set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid).

merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value),
    Sum is Value + Value,
    NextRow is Row + 1,
    set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    set_cell(TempGrid, NextRow, Col, NumCols, '-', ResultGrid).