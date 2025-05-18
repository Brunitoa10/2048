:- module(grid_merge,
    [
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
    ; find_and_merge_trio(Grid, NumCols, TempGrid)
    -> ResultGrid = TempGrid
    ; find_and_merge_pair(Grid, NumCols, ResultGrid)
    ).

% Definiciones de los predicados faltantes
find_and_merge_trio(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    (find_trio_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_row(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_trio_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_trio_in_col(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; fail
    ).

find_and_merge_pair(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    (find_pair_in_row(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; find_pair_in_col(Grid, NumRows, NumCols, Row, Col, Value)
    -> merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid)
    ; Grid = ResultGrid
    ).

% Nueva función para encontrar y fusionar 4 bloques adyacentes
find_and_merge_quad(Grid, NumCols, ResultGrid) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value),
    !,
    merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid).
    
% Busca cuatro bloques conectados con el mismo valor
find_quad_connected(Grid, NumRows, NumCols, BlockPositions, Value) :-
    between(1, NumRows, StartRow),
    between(1, NumCols, StartCol),
    grid_indexing:get_cell(Grid, StartRow, StartCol, NumCols, Value),
    Value \= '-',
    find_connected_blocks(Grid, NumRows, NumCols, [StartRow-StartCol], [], [StartRow-StartCol], Value, BlockPositions),
    length(BlockPositions, 4).

% Busca recursivamente bloques conectados con DFS
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

% Obtiene las celdas adyacentes (arriba, abajo, izquierda, derecha)
adjacent_cells(Row, Col, NumRows, NumCols, AdjacentCells) :-
    findall(R-C, (
        (R is Row-1, C is Col, R >= 1);
        (R is Row+1, C is Col, R =< NumRows);
        (R is Row, C is Col-1, C >= 1);
        (R is Row, C is Col+1, C =< NumCols)
    ), AdjacentCells).

% Filtra las celdas que tienen el mismo valor y no han sido visitadas
filter_valid_cells(Grid, AdjacentCells, Visited, NumCols, Value, ValidCells) :-
    findall(R-C, (
        member(R-C, AdjacentCells),
        \+ member(R-C, Visited),
        grid_indexing:get_cell(Grid, R, C, NumCols, CellValue),
        CellValue == Value
    ), ValidCells).

% Fusiona cuatro bloques en uno con valor 8 veces el original
merge_quad_blocks(Grid, BlockPositions, Value, NumCols, ResultGrid) :-
    % Calculamos el nuevo valor (8 veces el valor original)
    MergeValue is Value * 8,
    
    % Encontramos el centro aproximado de los bloques
    sum_positions(BlockPositions, SumRow, SumCol),
    AvgRow is round(SumRow / 4),
    AvgCol is round(SumCol / 4),
    
    % Tratamos de usar una posición existente entre los bloques
    find_best_position(BlockPositions, AvgRow, AvgCol, FinalRow, FinalCol),
    
    % Limpiamos todos los bloques originales
    clear_blocks(Grid, BlockPositions, NumCols, TempGrid),
    
    % Colocamos el nuevo bloque en la posición elegida
    grid_indexing:set_cell(TempGrid, FinalRow, FinalCol, NumCols, MergeValue, ResultGrid).

% Suma las posiciones para calcular el centro
sum_positions([], 0, 0).
sum_positions([Row-Col|Rest], SumRow, SumCol) :-
    sum_positions(Rest, RestRow, RestCol),
    SumRow is RestRow + Row,
    SumCol is RestCol + Col.

% Encuentra la mejor posición para colocar el bloque fusionado
% Ahora selecciona el bloque con la fila más pequeña (el más arriba)
find_best_position(BlockPositions, _, _, FinalRow, FinalCol) :-
    % Ordenamos por fila (para obtener el bloque más arriba)
    findall(Row-Col, member(Row-Col, BlockPositions), Positions),
    sort(Positions, SortedPositions),
    % Tomamos el primer elemento (el que tiene la fila más pequeña)
    SortedPositions = [FinalRow-FinalCol|_].

% Limpia todos los bloques originales
clear_blocks(Grid, [], _, Grid).
clear_blocks(Grid, [Row-Col|Rest], NumCols, ResultGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, '-', TempGrid),
    clear_blocks(TempGrid, Rest, NumCols, ResultGrid).

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

merge_trio_in_row(Grid, Row, StartCol, Value, NumCols, ResultGrid) :-
    MergeValue is Value * 4,
    MiddleCol is StartCol + 1,
    grid_indexing:set_cell(Grid, Row, StartCol, NumCols, '-', TempGrid1),
    grid_indexing:set_cell(TempGrid1, Row, StartCol+2, NumCols, '-', TempGrid2),
    grid_indexing:set_cell(TempGrid2, Row, MiddleCol, NumCols, MergeValue, ResultGrid).

merge_trio_in_col(Grid, StartRow, Col, Value, NumCols, ResultGrid) :-
    MergeValue is Value * 4,
    MiddleRow is StartRow + 1,
    grid_indexing:set_cell(Grid, StartRow, Col, NumCols, '-', TempGrid1),
    grid_indexing:set_cell(TempGrid1, StartRow+2, Col, NumCols, '-', TempGrid2),
    grid_indexing:set_cell(TempGrid2, MiddleRow, Col, NumCols, MergeValue, ResultGrid).

merge_pair_horizontal(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    NextCol is Col + 1,
    Sum is Value + Value,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, Row, NextCol, NumCols, '-', ResultGrid).

merge_pair_vertical(Grid, Row, Col, Value, NumCols, ResultGrid) :-
    NextRow is Row + 1,
    Sum is Value + Value,
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Sum, TempGrid),
    grid_indexing:set_cell(TempGrid, NextRow, Col, NumCols, '-', ResultGrid).