:- module(grid_merge, [
    merge_all_possible/3,
    merge_all_possible_with_effects/4,
    merge_all_possible_with_effects_targeted/5,
    find_and_merge_single_with_effects/4
]).

:- use_module(grid_indexing, [get_cell/5, set_cell/6]).

merge_all_possible(Grid, NumCols, FinalGrid) :-
    merge_all_possible_with_effects(Grid, NumCols, FinalGrid, _).

merge_all_possible_with_effects(Grid, NumCols, FinalGrid, Effects) :-
    merge_step_by_step(Grid, NumCols, [], FinalGrid, Effects).

merge_all_possible_with_effects_targeted(Grid, NumCols, TargetCol, FinalGrid, Effects) :-
    merge_step_by_step_targeted(Grid, NumCols, TargetCol, [], FinalGrid, Effects).

merge_step_by_step(Grid, NumCols, AccEffects, FinalGrid, FinalEffects) :-
    find_and_merge_one_pattern_with_effects(Grid, NumCols, TempGrid, StepEffects),
    (Grid \= TempGrid -> 
       append(AccEffects, StepEffects, NewAccEffects),
       merge_step_by_step(TempGrid, NumCols, NewAccEffects, FinalGrid, FinalEffects);
       FinalGrid = Grid,
       FinalEffects = AccEffects
    ).

merge_step_by_step_targeted(Grid, NumCols, TargetCol, AccEffects, FinalGrid, FinalEffects) :-
    find_and_merge_one_pattern_with_effects_targeted(Grid, NumCols, TargetCol, TempGrid, StepEffects),
    (Grid \= TempGrid -> 
       append(AccEffects, StepEffects, NewAccEffects),
       merge_step_by_step_targeted(TempGrid, NumCols, TargetCol, NewAccEffects, FinalGrid, FinalEffects);
       FinalGrid = Grid,
       FinalEffects = AccEffects
    ).

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

find_and_merge_one_pattern_with_effects_targeted(Grid, NumCols, TargetCol, ResultGrid, Effects) :-
    (find_and_merge_quad_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_specific_l_pattern_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_trio_with_effects(Grid, NumCols, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; find_and_merge_pair_with_effects_targeted(Grid, NumCols, TargetCol, TempGrid, Effects)
    -> ResultGrid = TempGrid
    ; ResultGrid = Grid,
      Effects = []
    ).

find_and_merge_single_with_effects(Grid, NumCols, ResultGrid, Effects) :-
    find_all_simultaneous_merges(Grid, NumCols, AllMerges),
    (AllMerges \= []
    -> apply_simultaneous_merges(Grid, NumCols, AllMerges, ResultGrid, TotalPoints),
       Effects = [effect(ResultGrid, [newBlock(TotalPoints)])]
    ; ResultGrid = Grid,
      Effects = []
    ).

% ==========================================
% PATRONES L UNIFICADOS (4 funciones → 1)
% ==========================================

find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value) :-
    between(1, NumRows, Row), Row < NumRows,
    between(1, NumCols, Col),
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value), Value > 0,
    NextRow is Row + 1,
    % Patrón 1: ⌊ (abajo-derecha)
    ((Col < NumCols, NextCol is Col + 1,
      get_cell(Grid, NextRow, Col, NumCols, Value),
      get_cell(Grid, NextRow, NextCol, NumCols, Value)) ;
    % Patrón 2: ⌐ (abajo-izquierda)  
     (Col > 1, PrevCol is Col - 1,
      get_cell(Grid, NextRow, Col, NumCols, Value),
      get_cell(Grid, NextRow, PrevCol, NumCols, Value)) ;
    % Patrón 3: Γ (derecha-abajo)
     (Col < NumCols, NextCol is Col + 1,
      get_cell(Grid, Row, NextCol, NumCols, Value),
      get_cell(Grid, NextRow, Col, NumCols, Value)) ;
    % Patrón 4: ⌙ (izquierda-abajo)
     (Col > 1, PrevCol is Col - 1,
      get_cell(Grid, Row, PrevCol, NumCols, Value),
      get_cell(Grid, NextRow, Col, NumCols, Value))).

merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    number(Value), MergeValue is Value * 4,
    NextRow is Row + 1,
    % Detectar y limpiar patrón específico
    ((Col < NumCols, NextCol is Col + 1,
      get_cell(Grid, NextRow, Col, NumCols, Value),
      get_cell(Grid, NextRow, NextCol, NumCols, Value),
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, NextRow, Col, NumCols, '-', G2),
      set_cell(G2, NextRow, NextCol, NumCols, '-', G3)) ;
     (Col > 1, PrevCol is Col - 1,
      get_cell(Grid, NextRow, Col, NumCols, Value),
      get_cell(Grid, NextRow, PrevCol, NumCols, Value),
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, NextRow, Col, NumCols, '-', G2),
      set_cell(G2, NextRow, PrevCol, NumCols, '-', G3)) ;
     (Col < NumCols, NextCol is Col + 1,
      get_cell(Grid, Row, NextCol, NumCols, Value),
      get_cell(Grid, NextRow, Col, NumCols, Value),
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, Row, NextCol, NumCols, '-', G2),
      set_cell(G2, NextRow, Col, NumCols, '-', G3)) ;
     (Col > 1, PrevCol is Col - 1,
      get_cell(Grid, Row, PrevCol, NumCols, Value),
      get_cell(Grid, NextRow, Col, NumCols, Value),
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, Row, PrevCol, NumCols, '-', G2),
      set_cell(G2, NextRow, Col, NumCols, '-', G3))),
    set_cell(G3, Row, Col, NumCols, MergeValue, ResultGrid).

% ==========================================
% LÍNEAS UNIFICADAS (4 funciones → 2)
% ==========================================

% Unifica trio_in_row y trio_in_col
find_trio_pattern(Grid, NumRows, NumCols, Row, Col, Value, Direction) :-
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value), Value > 0,
    ((Direction = row, Col =< NumCols - 2,
      C2 is Col + 1, C3 is Col + 2,
      get_cell(Grid, Row, C2, NumCols, Value),
      get_cell(Grid, Row, C3, NumCols, Value)) ;
     (Direction = col, Row =< NumRows - 2,
      R2 is Row + 1, R3 is Row + 2,
      get_cell(Grid, R2, Col, NumCols, Value),
      get_cell(Grid, R3, Col, NumCols, Value))).

merge_trio_pattern(Grid, Row, Col, Value, NumCols, Direction, ResultGrid) :-
    number(Value), MergeValue is Value * 4,
    ((Direction = row,
      C2 is Col + 1, C3 is Col + 2,
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, Row, C3, NumCols, '-', G2),
      set_cell(G2, Row, C2, NumCols, MergeValue, ResultGrid)) ;
     (Direction = col,
      R2 is Row + 1, R3 is Row + 2,
      set_cell(Grid, Row, Col, NumCols, '-', G1),
      set_cell(G1, R3, Col, NumCols, '-', G2),
      set_cell(G2, R2, Col, NumCols, MergeValue, ResultGrid))).

% Unifica pair_in_row y pair_in_col
find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, Direction) :-
    get_cell(Grid, Row, Col, NumCols, Value),
    number(Value), Value > 0,
    ((Direction = row, Col < NumCols,
      NextCol is Col + 1,
      get_cell(Grid, Row, NextCol, NumCols, Value)) ;
     (Direction = col, Row < NumRows,
      NextRow is Row + 1,
      get_cell(Grid, NextRow, Col, NumCols, Value))).

merge_pair_pattern(Grid, Row, Col, Value, NumCols, Direction, ResultGrid) :-
    number(Value), Sum is Value + Value,
    ((Direction = row,
      NextCol is Col + 1,
      set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
      set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid)) ;
     (Direction = col,
      NextRow is Row + 1,
      set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
      set_cell(TempGrid, NextRow, Col, NumCols, '-', ResultGrid))).

merge_pair_horizontal_targeted(Grid, Row, Col, Value, NumCols, TargetCol, ResultGrid) :-
    number(Value), Sum is Value + Value,
    NextCol is Col + 1,
    DistanceCol is abs(Col - TargetCol),
    DistanceNextCol is abs(NextCol - TargetCol),
    (DistanceCol =< DistanceNextCol ->
        set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
        set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid);
        set_cell(Grid, Row, NextCol, NumCols, Sum, TempGrid),
        set_cell(TempGrid, Row, Col, NumCols, '-', ResultGrid)).

% ==========================================
% FUNCIONES DE BÚSQUEDA SIMPLIFICADAS
% ==========================================

find_and_merge_specific_l_pattern_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len), NumRows is Len // NumCols,
    NumRows > 1, NumCols > 1,
    between(1, NumRows, Row), between(1, NumCols, Col),
    find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value), !,
    merge_l_pattern_direct(Grid, Row, Col, Value, NumCols, ResultGrid),
    Points is Value * 4.

find_and_merge_trio_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len), NumRows is Len // NumCols,
    NumRows > 2, NumCols > 2,
    between(1, NumRows, Row), between(1, NumCols, Col),
    (find_trio_pattern(Grid, NumRows, NumCols, Row, Col, Value, Direction),
     merge_trio_pattern(Grid, Row, Col, Value, NumCols, Direction, ResultGrid)), !,
    Points is Value * 4.

find_and_merge_pair_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len), NumRows is Len // NumCols,
    between(1, NumRows, Row), between(1, NumCols, Col),
    (find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, Direction),
     merge_pair_pattern(Grid, Row, Col, Value, NumCols, Direction, ResultGrid)), !,
    Points is Value * 2.

find_and_merge_pair_with_effects_targeted(Grid, NumCols, TargetCol, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len), NumRows is Len // NumCols,
    between(1, NumRows, Row), between(1, NumCols, Col),
    (find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, row),
     merge_pair_horizontal_targeted(Grid, Row, Col, Value, NumCols, TargetCol, ResultGrid), Points is Value * 2;
     find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, col),
     merge_pair_pattern(Grid, Row, Col, Value, NumCols, col, ResultGrid), Points is Value * 2), !.

% ==========================================
% RESTO DEL CÓDIGO (FUNCIONES COMPLEJAS SIN CAMBIO)
% ==========================================

find_all_simultaneous_merges(Grid, NumCols, SimultaneousMerges) :-
    findall(merge(Type, Positions, Value), find_single_merge(Grid, NumCols, Type, Positions, Value), AllMerges),
    filter_non_overlapping_merges(AllMerges, SimultaneousMerges).

find_single_merge(Grid, NumCols, quad, Positions, Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_quad_connected(Grid, NumRows, NumCols, Positions, Value).

find_single_merge(Grid, NumCols, l_pattern, [Row-Col], Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_l_pattern_direct(Grid, NumRows, NumCols, Row, Col, Value).

find_single_merge(Grid, NumCols, trio_row, [Row, StartCol], Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_trio_pattern(Grid, NumRows, NumCols, Row, StartCol, Value, row).

find_single_merge(Grid, NumCols, trio_col, [StartRow, Col], Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_trio_pattern(Grid, NumRows, NumCols, StartRow, Col, Value, col).

find_single_merge(Grid, NumCols, pair_row, [Row, Col], Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, row).

find_single_merge(Grid, NumCols, pair_col, [Row, Col], Value) :-
    length(Grid, Len), NumRows is Len // NumCols,
    find_pair_pattern(Grid, NumRows, NumCols, Row, Col, Value, col).

filter_non_overlapping_merges([], []).
filter_non_overlapping_merges([Merge|Rest], [Merge|FilteredRest]) :-
    remove_overlapping_merges(Rest, Merge, NonOverlapping),
    filter_non_overlapping_merges(NonOverlapping, FilteredRest).

remove_overlapping_merges([], _, []).
remove_overlapping_merges([Merge|Rest], ReferenceMerge, Result) :-
    (merges_overlap(Merge, ReferenceMerge) ->
        remove_overlapping_merges(Rest, ReferenceMerge, Result);
        Result = [Merge|FilteredRest],
        remove_overlapping_merges(Rest, ReferenceMerge, FilteredRest)).

merges_overlap(merge(_, Positions1, _), merge(_, Positions2, _)) :-
    merge_positions_to_cells(Positions1, Cells1),
    merge_positions_to_cells(Positions2, Cells2),
    intersection(Cells1, Cells2, Intersection),
    Intersection \= [].

merge_positions_to_cells(Positions, Cells) :-
    (is_list(Positions), Positions = [_-_|_] -> Cells = Positions;
     Positions = [Row-Col] -> get_l_pattern_cells(Row, Col, Cells);
     Positions = [Row, StartCol], number(Row) ->
        EndCol is StartCol + 2, MiddleCol is StartCol + 1,
        Cells = [Row-StartCol, Row-MiddleCol, Row-EndCol];
     Positions = [StartRow, Col], number(StartRow) ->
        EndRow is StartRow + 2, MiddleRow is StartRow + 1,
        Cells = [StartRow-Col, MiddleRow-Col, EndRow-Col];
     Positions = [Row, Col] -> Cells = [Row-Col, Row-(Col+1)];
     Cells = []).

get_l_pattern_cells(Row, Col, Cells) :-
    NextRow is Row + 1, NextCol is Col + 1,
    Cells = [Row-Col, NextRow-Col, NextRow-NextCol].

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
    merge_trio_pattern(Grid, Row, StartCol, Value, NumCols, row, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(trio_col, [StartRow, Col], Value), ResultGrid) :-
    merge_trio_pattern(Grid, StartRow, Col, Value, NumCols, col, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(pair_row, [Row, Col], Value), ResultGrid) :-
    merge_pair_pattern(Grid, Row, Col, Value, NumCols, row, ResultGrid).
apply_single_merge_to_grid(Grid, NumCols, merge(pair_col, [Row, Col], Value), ResultGrid) :-
    merge_pair_pattern(Grid, Row, Col, Value, NumCols, col, ResultGrid).

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

find_and_merge_quad_with_effects(Grid, NumCols, ResultGrid, [effect(ResultGrid, [newBlock(Points)])]) :-
    length(Grid, Len), NumRows is Len // NumCols,
    NumRows > 0, NumCols > 0,
    find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value), !,
    merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid),
    Points is Value * 8.

find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value) :-
    between(1, NumRows, StartRow), between(1, NumCols, StartCol),
    get_cell(Grid, StartRow, StartCol, NumCols, Value),
    number(Value), Value > 0,
    find_connected_blocks(Grid, NumRows, NumCols, [StartRow-StartCol], [StartRow-StartCol], Value, BlockPositions),
    length(BlockPositions, 4).

find_connected_blocks(_, _, _, [], Visited, _, Visited) :- !.
find_connected_blocks(Grid, NumRows, NumCols, [Row-Col|Stack], Visited, Value, Result) :-
    length(Visited, Length),
    (Length >= 4 -> Result = Visited;
     adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells),
     filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells),
     append(ValidCells, Stack, NewStack),
     append(Visited, ValidCells, NewVisited),
     find_connected_blocks(Grid, NumRows, NumCols, NewStack, NewVisited, Value, Result)).

adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells) :-
    R1 is Row - 1, R2 is Row + 1, C1 is Col - 1, C2 is Col + 1,
    findall(R-C, ((R = R1, C = Col, R >= 1, R =< NumRows);
                  (R = R2, C = Col, R >= 1, R =< NumRows);
                  (R = Row, C = C1, C >= 1, C =< NumCols);
                  (R = Row, C = C2, C >= 1, C =< NumCols)), AdjacentCells).

filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells) :-
    findall(R-C, (member(R-C, AdjacentCells), \+ member(R-C, Visited),
                  get_cell(Grid, R, C, NumCols, CellValue), CellValue == Value), ValidCells).

merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid) :-
    number(Value), MergeValue is Value * 8,
    sort(BlockPositions, SortedPositions),
    SortedPositions = [FinalRow-FinalCol|_],
    clear_blocks(Grid, BlockPositions, NumCols, TempGrid),
    set_cell(TempGrid, FinalRow, FinalCol, NumCols, MergeValue, ResultGrid).

clear_blocks(Grid, [], _, Grid) :- !.
clear_blocks(Grid, [Row-Col|Rest], NumCols, ResultGrid) :-
    set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    clear_blocks(TempGrid, Rest, NumCols, ResultGrid).