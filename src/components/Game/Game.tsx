import { useState, useEffect, useCallback } from 'react';
import { usePengine } from './usePengine';
import { useEffectAnimator, EffectTerm } from './useEffectAnimator';
import Board from '../Board/Board';
import Block from '../Block/Block';
import NotificationSystem, { Notification } from '../NotificationSystem/NotificationSystem';

export type Grid = (number | "-")[];

function Game() {
  const pengine = usePengine();

  const [grid, setGrid] = useState<Grid | null>(null);
  const [numOfColumns, setNumOfColumns] = useState<number | null>(null);
  const [score, setScore] = useState<number>(0);
  const [shootBlock, setShootBlock] = useState<number | null>(null);
  const [nextBlock, setNextBlock] = useState<number | null>(null);
  const [waiting, setWaiting] = useState<boolean>(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [showNextBlock, setShowNextBlock] = useState<boolean>(false);

  const addNotification = useCallback((notification: Omit<Notification, 'id'>) => {
    const id = Date.now() + Math.random();
    setNotifications(prev => [...prev, { ...notification, id }]);
  }, []);

  const removeNotification = useCallback((id: number) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  const animateEffect = useEffectAnimator(setGrid, setScore, setWaiting, addNotification);

  useEffect(() => {
    if (!pengine) return;

    const initGame = async () => {
      const response = await pengine.query('init(Grid, NumOfColumns), randomBlock(Grid, Block1), randomBlock(Grid, Block2)');
      setGrid(response['Grid']);
      setShootBlock(response['Block1']);
      setNextBlock(response['Block2']);
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
      setShootBlock(nextBlock);
      setNextBlock(response['Block']);
    } else {
      setWaiting(false);
    }
  };

  const toggleNextBlock = () => {
    setShowNextBlock(!showNextBlock);
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
      
      <Board 
        grid={grid} 
        numOfColumns={numOfColumns!} 
        onLaneClick={handleLaneClick}
      />
      
      <div className="footer">
        <div className="controls-section">
          <div className="boosters">
            <button 
              className={`booster-btn ${showNextBlock ? 'active' : ''}`}
              onClick={toggleNextBlock}
              title="Mostrar siguiente bloque"
            >
              Siguiente
            </button>
          </div>
          
          <div className="blocks-section">
            <div className="current-block">
              <div className="block-label">Actual</div>
              <div className="blockShoot">
                <Block value={shootBlock!} position={[0, 0]} />
              </div>
            </div>
            
            {showNextBlock && nextBlock && (
              <div className="next-block">
                <div className="block-label">Siguiente</div>
                <div className="blockShoot next">
                  <Block value={nextBlock} position={[0, 0]} />
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
      
      <NotificationSystem 
        notifications={notifications}
        onRemove={removeNotification}
      />
    </div>
  );
}

export default Game;