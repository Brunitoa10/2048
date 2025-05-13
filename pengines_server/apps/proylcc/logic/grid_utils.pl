:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        replace_at/4
    ]).

/**
 * find_empty_row(+Grid, +Column, +NumCols, -RowIndex)
 * Encuentra la primera fila (desde arriba) donde la celda está vacía.
 */
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

/**
 * insert_block(+Grid, +RowIndex, +Column, +Block, +NumCols, -UpdatedGrid)
 * Coloca el bloque en la posición especificada (fila, columna).
 */
insert_block(Grid, RowIndex, Column, Block, NumCols, UpdatedGrid) :-
    Index is (RowIndex - 1) * NumCols + (Column - 1),
    replace_at(Grid, Index, Block, UpdatedGrid).

/**
 * replace_at(+List, +Index, +Value, -UpdatedList)
 * Reemplaza el elemento en la posición Index por Value.
 */
replace_at([_|Tail], 0, Value, [Value|Tail]).
replace_at([Head|Tail], Index, Value, [Head|UpdatedTail]) :-
    Index > 0,
    NextIndex is Index - 1,
    replace_at(Tail, NextIndex, Value, UpdatedTail).
