:- module(proylcc, 
    [  
        randomBlock/2,
        shoot/5    
    ]).

:- use_module(logic/grid/grid_utils).
:- use_module(logic/grid/grid_gravity, [apply_gravity/3]).
:- use_module(logic/block_factory, [random_block/2, allowed_range/2]).

shoot(Block, Column, Grid, NumCols, Effects) :-
    find_empty_row(Grid, Column, NumCols, RowIndex),
    insert_block_with_merge_effects_targeted(Grid, RowIndex, Column, Block, NumCols, Column, RawEffects),
    enhance_effects_with_game_info(Grid, RawEffects, NumCols, Effects).

enhance_effects_with_game_info(OriginalGrid, RawEffects, NumCols, EnhancedEffects) :-
    enhance_effects_list(OriginalGrid, RawEffects, [], 0, TempEffects),
    apply_retired_blocks_cleanup(OriginalGrid, TempEffects, NumCols, EnhancedEffects).

enhance_effects_list(_, [], Acc, _, Acc).
enhance_effects_list(OriginalGrid, [effect(CurrentGrid, EffectInfo)|Rest], Acc, CombinationsSoFar, FinalEffects) :-
    detect_new_maximum_for_effect(OriginalGrid, CurrentGrid, NewMax),
    (has_merge_effect(EffectInfo)
    -> NewCombinationsSoFar is CombinationsSoFar + 1
    ; NewCombinationsSoFar = CombinationsSoFar
    ),
    (has_merge_effect(EffectInfo), NewCombinationsSoFar > 1
    -> ComboCount = NewCombinationsSoFar
    ; ComboCount = 0
    ),
    
    build_enhanced_effect_list(EffectInfo, ComboCount, NewMax, EnhancedInfo),

    append(Acc, [effect(CurrentGrid, EnhancedInfo)], NewAcc),
    
    enhance_effects_list(CurrentGrid, Rest, NewAcc, NewCombinationsSoFar, FinalEffects).

apply_retired_blocks_cleanup(OriginalGrid, Effects, NumCols, FinalEffects) :-
    (Effects = [] -> 
        FinalEffects = Effects
    ; 
        last(Effects, effect(FinalGrid, _)),
        max_block(OriginalGrid, OriginalMax),
        max_block(FinalGrid, FinalMax),
        allowed_range(OriginalMax, OriginalRange),
        allowed_range(FinalMax, FinalRange),
        
        (FinalRange \= OriginalRange ->
            findall(B, (member(B, OriginalRange), \+ member(B, FinalRange)), RemovedBlocks),
            findall(B, (member(B, FinalRange), \+ member(B, OriginalRange)), AddedBlocks),
            
            (RemovedBlocks \= [] ->
                clean_retired_blocks(FinalGrid, RemovedBlocks, CleanedGrid),
                apply_gravity(CleanedGrid, NumCols, GravityGrid),
                create_cleanup_effects_with_gravity(CleanedGrid, GravityGrid, AddedBlocks, RemovedBlocks, CleanupEffects),
                append(Effects, CleanupEffects, FinalEffects)
            ; 
                (AddedBlocks \= [] ->
                    create_range_effects(FinalGrid, AddedBlocks, [], RangeEffects),
                    append(Effects, RangeEffects, FinalEffects)
                ;
                    FinalEffects = Effects
                )
            )
        ;
            FinalEffects = Effects
        )
    ).

create_cleanup_effects_with_gravity(CleanedGrid, GravityGrid, AddedBlocks, RemovedBlocks, Effects) :-
    findall(effect(CleanedGrid, [blockRetired(B)]), member(B, RemovedBlocks), RetiredEffects),
    (CleanedGrid \= GravityGrid ->
        GravityEffect = [effect(GravityGrid, [])],
        findall(effect(GravityGrid, [newBlockAdded(B)]), member(B, AddedBlocks), AddedEffects),
        append(RetiredEffects, GravityEffect, TempEffects),
        append(TempEffects, AddedEffects, Effects)
    ;
        findall(effect(CleanedGrid, [newBlockAdded(B)]), member(B, AddedBlocks), AddedEffects),
        append(RetiredEffects, AddedEffects, Effects)
    ).

create_cleanup_effects(CleanedGrid, AddedBlocks, RemovedBlocks, Effects) :-
    findall(effect(CleanedGrid, [blockRetired(B)]), member(B, RemovedBlocks), RetiredEffects),
    findall(effect(CleanedGrid, [newBlockAdded(B)]), member(B, AddedBlocks), AddedEffects),
    append(RetiredEffects, AddedEffects, Effects).

create_range_effects(Grid, AddedBlocks, [], Effects) :-
    findall(effect(Grid, [newBlockAdded(B)]), member(B, AddedBlocks), Effects).

% Limpia bloques retirados de la grilla
clean_retired_blocks(Grid, RetiredBlocks, CleanedGrid) :-
    foldl(clean_block, RetiredBlocks, Grid, CleanedGrid).

clean_block(Block, InGrid, OutGrid) :-
    maplist(replace_retired(Block), InGrid, OutGrid).

replace_retired(Block, Block, '-') :- !.
replace_retired(_, X, X).





count_merge_effects([], 0).
count_merge_effects([effect(_, EffectInfo)|Rest], Count) :-
    count_merge_effects(Rest, RestCount),
    (has_merge_effect(EffectInfo)
    -> Count is RestCount + 1
    ; Count = RestCount
    ).

has_merge_effect(EffectInfo) :-
    member(newBlock(Points), EffectInfo),
    Points > 0.

detect_new_maximum_for_effect(OriginalGrid, NewGrid, NewMax) :-
    max_block(OriginalGrid, OriginalMax),
    max_block(NewGrid, CurrentMax),
    (CurrentMax > OriginalMax -> 
        NewMax = CurrentMax
    ; 
        NewMax = 0
    ).

max_block(Grid, Max) :-
    include(number, Grid, Numbers),
    (Numbers == [] -> Max = 0 ; max_list(Numbers, Max)).

build_enhanced_effect_list(OriginalInfo, ComboCount, NewMax, EnhancedInfo) :-
    findall(Effect, (
        member(Effect, OriginalInfo)
    ), BaseEffects),

    findall(AdditionalEffect, (
        (ComboCount > 1 -> AdditionalEffect = combo(ComboCount) ; fail);
        (NewMax > 0 -> AdditionalEffect = newMaximum(NewMax) ; fail)
    ), ExtraEffects),

    append(BaseEffects, ExtraEffects, EnhancedInfo).

randomBlock(Grid, Block) :-
    random_block(Grid, Block).