:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        replace_at/4,
        valid_shot_position/5,
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

valid_shot_position(_Grid, 1, _Column, _Block, _NumCols) :- !.
valid_shot_position(Grid, RowIndex, Column, Block, NumCols) :-
    RowAbove is RowIndex - 1,
    IndexAbove is (RowAbove - 1) * NumCols + (Column - 1),
    nth0(IndexAbove, Grid, BlockAbove),
    ( BlockAbove == '-' ; BlockAbove == Block ).

/**
 * insert_block_with_merge(+Grid, +RowIndex, +Column, +Block, +NumCols, -UpdatedGrid)
 * Inserta el bloque y si el de arriba es igual, los suma y repite recursivamente.
 */
insert_block_with_merge(Grid, RowIndex, Column, Block, NumCols, FinalGrid) :-
    insert_block(Grid, RowIndex, Column, Block, NumCols, TempGrid),
    maybe_merge_up(TempGrid, RowIndex, Column, NumCols, FinalGrid).

maybe_merge_up(Grid, 1, _Column, _NumCols, Grid) :- !.  % No se puede subir más

maybe_merge_up(Grid, RowIndex, Column, NumCols, FinalGrid) :-
    RowAbove is RowIndex - 1,
    Index is (RowIndex - 1) * NumCols + (Column - 1),
    IndexAbove is (RowAbove - 1) * NumCols + (Column - 1),
    nth0(Index, Grid, Block),
    nth0(IndexAbove, Grid, BlockAbove),
    Block == BlockAbove,
    Sum is Block + BlockAbove,
    replace_at(Grid, IndexAbove, Sum, Grid1),
    replace_at(Grid1, Index, '-', Grid2),
    maybe_merge_up(Grid2, RowAbove, Column, NumCols, FinalGrid).

maybe_merge_up(Grid, _RowIndex, _Column, _NumCols, Grid).  % Si no hay match, retornar como está
