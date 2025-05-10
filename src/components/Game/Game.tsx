import { useState, useEffect } from 'react';
import { usePengine } from './usePengine';
import { useEffectAnimator, EffectTerm } from './useEffectAnimator';
import Board from '../Board/Board';
import Block from '../Block/Block';

export type Grid = (number | "-")[];

function Game() {
  const pengine = usePengine();

  const [grid, setGrid] = useState<Grid | null>(null);
  const [numOfColumns, setNumOfColumns] = useState<number | null>(null);
  const [score, setScore] = useState<number>(0);
  const [shootBlock, setShootBlock] = useState<number | null>(null);
  const [waiting, setWaiting] = useState<boolean>(false);

  const animateEffect = useEffectAnimator(setGrid, setScore, setWaiting);

  useEffect(() => {
    if (!pengine) return;

    const initGame = async () => {
      const response = await pengine.query('init(Grid, NumOfColumns), randomBlock(Grid, Block)');
      setGrid(response['Grid']);
      setShootBlock(response['Block']);
      setNumOfColumns(response['NumOfColumns']);
    };

    initGame();
  }, [pengine]);

  const handleLaneClick = async (lane: number) => {
    if (waiting || !grid || shootBlock === null || numOfColumns === null) return;

    setWaiting(true);

    const gridStr = JSON.stringify(grid).replace(/"/g, '');
    const query = `shoot(${shootBlock}, ${lane}, ${gridStr}, ${numOfColumns}, Effects), last(Effects, effect(RGrid,_)), randomBlock(RGrid, Block)`;

    const response = await pengine.query(query);

    if (response) {
      animateEffect(response['Effects'] as EffectTerm[]);
      setShootBlock(response['Block']);
    } else {
      setWaiting(false);
    }
  };

  if (!grid) return null;

  return (
    <div className="game">
      <div className="header">
      <div className="score-box">
        <span className="score-label">🏆 Score</span>
        <span className="score-value">{score}</span>
      </div>

      </div>
      <Board grid={grid} numOfColumns={numOfColumns!} onLaneClick={handleLaneClick} />
      <div className="footer">
        <div className="blockShoot">
          <Block value={shootBlock!} position={[0, 0]} />
        </div>
      </div>
    </div>
  );
}

export default Game;
