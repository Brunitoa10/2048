:- module(init, [ init/2 ]).

/**
 * init(-Grid, -NumOfColumns).
 * 
 * Predicado especificando la grilla inicial, que será mostrada al comienzo del juego, donde
 * Grid es una lista con los números que conforman la grilla, y NumOfColumns es la cantidad de columnas, 
 * determinando las dimensiones de la misma.
 */

init([
    2,   512,  256,  128,  8,
    8,   2,    128,  64,   16,
    256, 128,  2,    512,  32,
    2,   64,   32,   2,    64,
    64,  256,  16,   8,    256,
    32,  16,   256,  4,    2,
    16,  8,    4,    256,  -
], 5).