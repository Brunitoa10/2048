import Lane from './Lane';
import GridBlock from './GridBlock';
import { Grid } from '../Game/Game';

interface BoardProps {
  grid: Grid;
  numOfColumns: number;
  onLaneClick: (lane: number) => void;
}

function Board({ grid, numOfColumns, onLaneClick }: BoardProps) {
  const numOfRows = grid.length / numOfColumns;

  return (
    <div className="board">
      <div
        className="blocks"
        style={{
          gridTemplateColumns: `repeat(${numOfColumns}, 70px)`,
          gridTemplateRows: `repeat(${numOfRows}, 70px)`,
        }}
      >
        {/* Lanes para manejar los clics */}
        {Array.from({ length: numOfColumns }).map((_, i) => (
          <Lane key={i} index={i} numOfRows={numOfRows} onClick={onLaneClick} />
        ))}

        {/* Renderizado de los bloques */}
        {grid.map((value, i) => (
          <GridBlock
            key={i}
            index={i}
            value={value}
            numOfColumns={numOfColumns}
          />
        ))}
      </div>
    </div>
  );
}

export default Board;
