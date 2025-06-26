import Lane from './Lane';
import GridBlock from './GridBlock';
import { Grid } from '../Game/Game';

interface Hint {
  column: number;
  info: string[];
  points: number;
  hasCombo: boolean;
  comboCount: number;
  isValid: boolean;
}

interface BoardProps {
  grid: Grid;
  numOfColumns: number;
  onLaneClick: (lane: number) => void;
  showHints?: boolean;
  hints?: Hint[];
}

function Board({ grid, numOfColumns, onLaneClick, showHints = false, hints = [] }: BoardProps) {
  const numOfRows = grid.length / numOfColumns;
  const getHintClass = (hint: Hint): string => {
    if (!hint.isValid || hint.info.some(info => info.includes('Columna llena') || info.includes('Error'))) {
      return 'hint-overlay hint-invalid';
    }
    if (hint.hasCombo) {
      return 'hint-overlay hint-combo';
    }
    if (hint.points > 50) {
      return 'hint-overlay hint-high-points';
    }
    if (hint.points > 15) {
      return 'hint-overlay hint-medium-points';
    }
    if (hint.points > 0) {
      return 'hint-overlay hint-low-points';
    }
    return 'hint-overlay hint-no-merge';
  };

  const formatHintContent = (hint: Hint) => {
    if (!hint.isValid) {
      return (
        <>
          <span className="hint-icon">🚫</span>
          <span className="hint-info-line primary">Llena</span>
        </>
      );
    }

    if (hint.info.includes('Error')) {
      return (
        <>
          <span className="hint-icon">⚠️</span>
          <span className="hint-info-line primary">Error</span>
        </>
      );
    }

    const elements = [];
  
    if (hint.hasCombo) {
      elements.push(
        <span key="combo" className="hint-info-line accent">
          🔥 x{hint.comboCount}
        </span>
      );
    }

    hint.info.forEach((info, index) => {
      if (info.includes('Bloque')) {
        const blockValue = info.replace('Bloque ', '');
        elements.push(
          <span key={`block-${index}`} className="hint-info-line primary">
            📦 {blockValue}
          </span>
        );
      } else if (info.includes('pts')) {
        elements.push(
          <span key={`points-${index}`} className="hint-info-line secondary">
            {info}
          </span>
        );
      } else if (info.includes('🏆')) {
        elements.push(
          <span key={`trophy-${index}`} className="hint-info-line accent">
            {info}
          </span>
        );
      } else if (info === 'Sin merge') {
        elements.push(
          <span key={`no-merge-${index}`} className="hint-info-line primary">
            Sin Merge
          </span>
        );
      } else if (!info.includes('Combo')) {
        elements.push(
          <span key={`other-${index}`} className="hint-info-line secondary">
            {info}
          </span>
        );
      }
    });

    return elements;
  };

  return (
    <div className="board">
      <div
        className="blocks"
        style={{
          gridTemplateColumns: `repeat(${numOfColumns}, 70px)`,
          gridTemplateRows: `repeat(${numOfRows}, 70px)`,
        }}
      >
        
        {Array.from({ length: numOfColumns }).map((_, i) => (
          <Lane 
            key={i} 
            index={i} 
            numOfRows={numOfRows} 
            onClick={onLaneClick}
          />
        ))}

        {grid.map((value, i) => (
          <GridBlock
            key={i}
            index={i}
            value={value}
            numOfColumns={numOfColumns}
          />
        ))}

        {showHints && hints.map((hint, index) => (
          <div
            key={`hint-${hint.column}`}
            className={getHintClass(hint)}
            style={{
              left: `${(hint.column - 1) * 75 + 2.5}px`,
            }}
          >
            {formatHintContent(hint)}
          </div>
        ))}
      </div>
    </div>
  );
}

export default Board;