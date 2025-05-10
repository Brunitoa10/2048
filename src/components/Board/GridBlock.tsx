import Block from '../Block/Block';
import { Position } from '../Block/Block';

interface GridBlockProps {
  index: number;
  value: number | "-";
  numOfColumns: number;
}

function GridBlock({ index, value, numOfColumns }: GridBlockProps) {
  if (value === "-") return null;

  const position: Position = [
    Math.floor(index / numOfColumns),
    index % numOfColumns,
  ];

  return <Block value={value} position={position} />;
}

export default GridBlock;
