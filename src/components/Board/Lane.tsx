interface LaneProps {
  index: number;
  numOfRows: number;
  onClick: (lane: number) => void;
}

function Lane({ index, numOfRows, onClick }: LaneProps) {
  return (
    <div
      className="lane"
      style={{
        gridColumn: index + 1,
        gridRow: `1 / span ${numOfRows}`,
      }}
      onClick={() => onClick(index + 1)}
    />
  );
}

export default Lane;