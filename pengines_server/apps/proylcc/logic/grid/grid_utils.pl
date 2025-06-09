:- module(grid_utils,
    [
        find_empty_row/4,
        insert_block/6,
        insert_block_with_merge/6,
        insert_block_with_merge_effects/6
    ]).

:- use_module(grid_indexing).
:- use_module(grid_merge).
:- use_module(grid_gravity).

find_empty_row(Grid, Col, NumCols, RowIndex) :-
    length(Grid, Len),
    NumRows is Len // NumCols,
    find_empty_row_from_top(Grid, Col, NumCols, 1, NumRows, RowIndex).

find_empty_row_from_top(Grid, Col, NumCols, Row, NumRows, Row) :-
    Row =< NumRows,
    grid_indexing:get_cell(Grid, Row, Col, NumCols, '-'), !.

find_empty_row_from_top(Grid, Col, NumCols, Row, NumRows, RowIndex) :-
    Row < NumRows,
    R1 is Row + 1,
    find_empty_row_from_top(Grid, Col, NumCols, R1, NumRows, RowIndex).

insert_block(Grid, Row, Col, Block, NumCols, NewGrid) :-
    grid_indexing:set_cell(Grid, Row, Col, NumCols, Block, NewGrid).

% Versión original para compatibilidad
insert_block_with_merge(Grid, Row, Col, Block, NumCols, FinalGrid) :-
    insert_block_with_merge_effects(Grid, Row, Col, Block, NumCols, Effects),
    last(Effects, effect(FinalGrid, _)).

% Nueva versión que genera efectos paso a paso
insert_block_with_merge_effects(Grid, Row, Col, Block, NumCols, Effects) :-
    insert_block(Grid, Row, Col, Block, NumCols, TempGrid),
    % Agregar efecto inicial del bloque insertado
    apply_merge_and_gravity_with_effects(TempGrid, NumCols, [effect(TempGrid, [])], Effects).

% Aplica merge y gravedad generando efectos paso a paso
apply_merge_and_gravity_with_effects(Grid, NumCols, AccEffects, FinalEffects) :-
    % Aplicar gravedad primero
    grid_gravity:apply_gravity(Grid, NumCols, GravityGrid),
    
    % Si la gravedad cambió algo, agregar efecto de gravedad
    (Grid \= GravityGrid
    -> append(AccEffects, [effect(GravityGrid, [])], GravityEffects)
    ;  GravityEffects = AccEffects
    ),
    
    % Intentar hacer UNA SOLA combinación
    grid_merge:find_and_merge_single_with_effects(GravityGrid, NumCols, MergedGrid, MergeEffects),
    
    % Si hubo combinación, agregar el efecto y continuar
    (GravityGrid \= MergedGrid
    -> append(GravityEffects, MergeEffects, NewEffects),
       apply_merge_and_gravity_with_effects(MergedGrid, NumCols, NewEffects, FinalEffects)
    ;  % Si no hubo cambios pero no tenemos efectos, agregar el estado actual
       (GravityEffects = []
       -> FinalEffects = [effect(Grid, [])]
       ;  FinalEffects = GravityEffects
       )
    ).