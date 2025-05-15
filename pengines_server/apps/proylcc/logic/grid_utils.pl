:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        replace_at/4,
        /*valid_shot_position/5,*/
        insert_block_with_merge/6
    ]).

find_empty_row(Grid, Column, NumCols, RowIndex) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_empty_row_from_top(Grid, Column, NumCols, 1, NumRows, RowIndex).

find_empty_row_from_top(Grid, Column, NumCols, CurrentRow, NumRows, RowIndex) :-
    CurrentRow =< NumRows,
    Index is (CurrentRow - 1) * NumCols + (Column - 1),
    nth0(Index, Grid, Value),
    Value == '-',
    RowIndex = CurrentRow.

find_empty_row_from_top(Grid, Column, NumCols, CurrentRow, NumRows, RowIndex) :-
    CurrentRow < NumRows,
    Index is (CurrentRow - 1) * NumCols + (Column - 1),
    nth0(Index, Grid, Value),
    Value \= '-',
    NextRow is CurrentRow + 1,
    find_empty_row_from_top(Grid, Column, NumCols, NextRow, NumRows, RowIndex).

insert_block(Grid, RowIndex, Column, Block, NumCols, UpdatedGrid) :-
    Index is (RowIndex - 1) * NumCols + (Column - 1),
    replace_at(Grid, Index, Block, UpdatedGrid).

replace_at([_|Tail], 0, Value, [Value|Tail]).
replace_at([Head|Tail], Index, Value, [Head|UpdatedTail]) :-
    Index > 0,
    NextIndex is Index - 1,
    replace_at(Tail, NextIndex, Value, UpdatedTail).

/*valid_shot_position(_Grid, 1, _Column, _Block, _NumCols) :- !.
valid_shot_position(Grid, RowIndex, Column, Block, NumCols) :-
    RowAbove is RowIndex - 1,
    IndexAbove is (RowAbove - 1) * NumCols + (Column - 1),
    nth0(IndexAbove, Grid, BlockAbove),
    ( BlockAbove == '-' ; BlockAbove == Block ).*/

/**
 * insert_block_with_merge(+Grid, +RowIndex, +Column, +Block, +NumCols, -FinalGrid)
 * Inserta el bloque y realiza merges verticales y horizontales recursivos.
 */
insert_block_with_merge(Grid, RowIndex, Column, Block, NumCols, FinalGrid) :-
    insert_block(Grid, RowIndex, Column, Block, NumCols, TempGrid),
    maybe_merge_recursive(TempGrid, RowIndex, Column, NumCols, FinalGrid).

% Caso base: si no hay merge posible, retorna la grilla igual
maybe_merge_recursive(Grid, Row, Col, NumCols, Grid) :-
    \+ can_merge(Grid, Row, Col, NumCols).

% Caso recursivo: hay merge posible
maybe_merge_recursive(Grid, Row, Col, NumCols, FinalGrid) :-
    can_merge(Grid, Row, Col, NumCols),
    perform_merge(Grid, Row, Col, NumCols, NewGrid, NewRow, NewCol),
    maybe_merge_recursive(NewGrid, NewRow, NewCol, NumCols, FinalGrid).

/**
 * can_merge(+Grid, +Row, +Col, +NumCols)
 * Verifica si hay al menos un bloque adyacente con el mismo valor (arriba, izquierda o derecha).
 */
can_merge(Grid, Row, Col, NumCols) :-
    nth0(Index, Grid, Block),
    Index is (Row - 1) * NumCols + (Col - 1),
    nth0(Index, Grid, Block),
    Block \= '-',
    (
        % Arriba
        Row > 1,
        RowAbove is Row - 1,
        IndexAbove is (RowAbove - 1) * NumCols + (Col - 1),
        nth0(IndexAbove, Grid, BlockAbove),
        Block == BlockAbove
    ;
        % Izquierda
        Col > 1,
        ColLeft is Col - 1,
        IndexLeft is (Row - 1) * NumCols + (ColLeft - 1),
        nth0(IndexLeft, Grid, BlockLeft),
        Block == BlockLeft
    ;
        % Derecha
        Col < NumCols,
        ColRight is Col + 1,
        IndexRight is (Row - 1) * NumCols + (ColRight - 1),
        nth0(IndexRight, Grid, BlockRight),
        Block == BlockRight
    ).

/**
 * perform_merge(+Grid, +Row, +Col, +NumCols, -NewGrid, -NewRow, -NewCol)
 * Realiza la suma con un bloque adyacente igual y actualiza la grilla.
 * Retorna la nueva posición del bloque fusionado para seguir chequeando.
 */
perform_merge(Grid, Row, Col, NumCols, NewGrid, NewRow, NewCol) :-
    nth0(Index, Grid, Block),
    Index is (Row - 1) * NumCols + (Col - 1),
    % Prioridad para fusionar hacia arriba, luego izquierda, luego derecha
    (
        Row > 1,
        RowAbove is Row - 1,
        IndexAbove is (RowAbove - 1) * NumCols + (Col - 1),
        nth0(IndexAbove, Grid, BlockAbove),
        Block == BlockAbove,
        Sum is Block + BlockAbove,
        replace_at(Grid, IndexAbove, Sum, Grid1),
        replace_at(Grid1, Index, '-', Grid2),
        NewGrid = Grid2,
        NewRow = RowAbove,
        NewCol = Col
    ;
        Col > 1,
        ColLeft is Col - 1,
        IndexLeft is (Row - 1) * NumCols + (ColLeft - 1),
        nth0(IndexLeft, Grid, BlockLeft),
        Block == BlockLeft,
        Sum is Block + BlockLeft,
        replace_at(Grid, IndexLeft, Sum, Grid1),
        replace_at(Grid1, Index, '-', Grid2),
        NewGrid = Grid2,
        NewRow = Row,
        NewCol = ColLeft
    ;
        Col < NumCols,
        ColRight is Col + 1,
        IndexRight is (Row - 1) * NumCols + (ColRight - 1),
        nth0(IndexRight, Grid, BlockRight),
        Block == BlockRight,
        Sum is Block + BlockRight,
        replace_at(Grid, IndexRight, Sum, Grid1),
        replace_at(Grid1, Index, '-', Grid2),
        NewGrid = Grid2,
        NewRow = Row,
        NewCol = ColRight
    ).
