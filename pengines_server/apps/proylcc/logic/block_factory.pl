:- module(block_factory,
    [ random_block/1 ]).

/**
 * random_block(-Block)
 * Genera aleatoriamente un bloque válido.
 */
random_block(Block) :-
    random_member(Block, [2, 4]).
