import { useCallback } from 'react';
import { delay } from '../../logic/util';
import { Grid } from './Game';

export interface EffectTerm {
  functor: 'effect';
  args: [Grid, EffectInfoTerm[]];
}

export interface NewBlockTerm {
  functor: 'newBlock';
  args: [number];
}

type EffectInfoTerm = NewBlockTerm;

export function useEffectAnimator(
  setGrid: (grid: Grid) => void,
  setScore: React.Dispatch<React.SetStateAction<number>>,
  setWaiting: (wait: boolean) => void
) {
  const animateEffect = useCallback(async (effects: EffectTerm[]) => {
    if (effects.length === 0) {
      setWaiting(false);
      return;
    }

    const [grid, info] = effects[0].args;
    setGrid(grid);

    info.forEach(({ functor, args }) => {
      if (functor === 'newBlock') {
        setScore(prev => prev + args[0]);
      }
    });

    await delay(1000);
    animateEffect(effects.slice(1));
  }, [setGrid, setScore, setWaiting]);

  return animateEffect;
}
