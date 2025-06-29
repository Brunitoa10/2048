import { useState, useEffect, useCallback } from 'react';
import { usePengine } from './usePengine';
import { useEffectAnimator, EffectTerm } from './useEffectAnimator';
import Board from '../Board/Board';
import Block from '../Block/Block';
import NotificationSystem, { Notification } from '../NotificationSystem/NotificationSystem';

export type Grid = (number | "-")[];

interface Hint {
  column: number;
  info: string[];
  points: number;
  hasCombo: boolean;
  comboCount: number;
  isValid: boolean;
}

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
  
  const [nextBlockTimer, setNextBlockTimer] = useState<number>(0);
  const [nextBlockTimerActive, setNextBlockTimerActive] = useState<boolean>(false);
  
  const [showHints, setShowHints] = useState<boolean>(false);
  const [hints, setHints] = useState<Hint[]>([]);
  const [calculatingHints, setCalculatingHints] = useState<boolean>(false);

  const addNotification = useCallback((notification: Omit<Notification, 'id'>) => {
    const id = Date.now() + Math.random();
    setNotifications(prev => [...prev, { ...notification, id }]);
  }, []);

  const removeNotification = useCallback((id: number) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  const animateEffect = useEffectAnimator(setGrid, setScore, setWaiting, addNotification);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (nextBlockTimerActive && nextBlockTimer > 0) {
      interval = setInterval(() => {
        setNextBlockTimer(prev => {
          if (prev <= 1) {
            setShowNextBlock(false);
            setNextBlockTimerActive(false);
            addNotification({
              type: 'boostExpired',
              message: 'Boost retirado'
            });
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [nextBlockTimerActive, nextBlockTimer, addNotification]);

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

  const calculateHints = useCallback(async () => {
    if (!pengine || !grid || shootBlock === null || numOfColumns === null) return;

    setCalculatingHints(true);
    const newHints: Hint[] = [];

    for (let column = 1; column <= numOfColumns; column++) {
      try {
        const gridStr = JSON.stringify(grid).replace(/"/g, '');
        const query = `shoot(${shootBlock}, ${column}, ${gridStr}, ${numOfColumns}, Effects)`;
        
        const response = await pengine.query(query);
        
        if (response && response.Effects) {
          const hint = analyzeEffects(column, response.Effects);
          newHints.push(hint);
        } else {
          newHints.push({
            column,
            info: ['Columna llena'],
            points: 0,
            hasCombo: false,
            comboCount: 0,
            isValid: false
          });
        }
      } catch (error) {
        console.error(`Error calculating hint for column ${column}:`, error);
        newHints.push({
          column,
          info: ['Error'],
          points: 0,
          hasCombo: false,
          comboCount: 0,
          isValid: false
        });
      }
    }

    setHints(newHints);
    setCalculatingHints(false);
  }, [pengine, grid, shootBlock, numOfColumns]);
  
  const analyzeEffects = (column: number, effects: EffectTerm[]): Hint => {
    let totalPoints = 0;
    let hasCombo = false;
    let comboCount = 0;
    let maxNewBlock = 0;
    const info: string[] = [];

    effects.forEach(effect => {
      if (effect.functor === 'effect' && effect.args[1]) {
        effect.args[1].forEach((effectInfo: any) => {
          if (effectInfo.functor === 'newBlock') {
            const points = effectInfo.args[0];
            totalPoints += points;
            if (points > 0) {
              const blockValue = calculateBlockFromPoints(points);
              if (blockValue > maxNewBlock) {
                maxNewBlock = blockValue;
              }
            }
          } else if (effectInfo.functor === 'combo') {
            hasCombo = true;
            comboCount = Math.max(comboCount, effectInfo.args[0]);
          } else if (effectInfo.functor === 'newMaximum') {
            const newMax = effectInfo.args[0];
            info.push(`🏆 ${newMax}`);
          }
        });
      }
    });

    if (totalPoints === 0) {
      info.unshift('Sin merge');
    } else {
      if (maxNewBlock > 0) {
        info.unshift(`Bloque ${maxNewBlock}`);
      }
      if (totalPoints > 0) {
        info.push(`+${totalPoints} pts`);
      }
    }

    if (hasCombo) {
      info.push(`Combo x${comboCount}`);
    }

    return {
      column,
      info,
      points: totalPoints,
      hasCombo,
      comboCount,
      isValid: true
    };
  };

  const calculateBlockFromPoints = (points: number): number => {
    if (points === 4) return 4;   
    if (points === 8) return 8;   
    if (points === 16) return 16; 
    if (points === 32) return 32; 
    if (points === 64) return 64; 
    if (points <= 8) return Math.max(4, points);
    if (points <= 32) return Math.max(8, points / 2);
    return Math.max(shootBlock! * 2, Math.floor(points / 4));
  };

  const handleLaneClick = async (lane: number) => {
    if (waiting || !grid || shootBlock === null || numOfColumns === null) return;

    setShowHints(false);
    setHints([]);

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
    if (showNextBlock) {
      setShowNextBlock(false);
      setNextBlockTimerActive(false);
      setNextBlockTimer(0);
    } else {
      setShowNextBlock(true);
      setNextBlockTimerActive(true);
      setNextBlockTimer(10);
    }
  };

  const toggleHints = async () => {
    if (calculatingHints) return; 
    if (showHints) {
      setShowHints(false);
      setHints([]);
    } else {
      setShowHints(true);
      await calculateHints();
    }
  };

  const getHintButtonText = () => {
    if (calculatingHints) return '';
    return showHints ? '💡 Ocultar' : '💡 Hint';
  };

  const getHintButtonClasses = () => {
    let classes = 'booster-btn';
    if (showHints) classes += ' active';
    if (waiting || calculatingHints) classes += ' disabled';
    return classes;
  };

  const getNextBlockButtonText = () => {
    if (nextBlockTimerActive && nextBlockTimer > 0) {
      return `Siguiente (${nextBlockTimer}s)`;
    }
    return 'Siguiente';
  };

  const getNextBlockButtonClasses = () => {
    let classes = 'booster-btn';
    if (showNextBlock) classes += ' active';
    if (nextBlockTimerActive) classes += ' timer-active';
    if (nextBlockTimerActive && nextBlockTimer <= 3) classes += ' timer-urgent';
    if (waiting) classes += ' disabled';
    return classes;
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
        showHints={showHints}
        hints={hints}
      />
      
      <div className="footer">
        <div className="controls-section">
          <div className="boosters">
            <button 
              className={getNextBlockButtonClasses()}
              onClick={toggleNextBlock}
              disabled={waiting}
              title="Mostrar siguiente bloque (10 segundos)"
            >
              {getNextBlockButtonText()}
            </button>
            
            <button 
              className={getHintButtonClasses()}
              onClick={toggleHints}
              disabled={waiting || calculatingHints}
              title={showHints ? 'Ocultar pistas' : 'Mostrar pistas de jugada'}
            >
              {calculatingHints ? (
                <div className="loading-indicator">
                  <span>Calculando</span>
                  <div className="loading-spinner"></div>
                </div>
              ) : (
                getHintButtonText()
              )}
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
                <div className={`block-label ${nextBlockTimerActive ? 'timer-active' : ''}`}>
                  {nextBlockTimerActive ? `Siguiente (${nextBlockTimer}s)` : 'Siguiente'}
                </div>
                <div className={`blockShoot next ${nextBlockTimerActive ? 'timer-active' : ''}`}>
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