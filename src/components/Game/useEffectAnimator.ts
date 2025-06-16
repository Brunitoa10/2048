import { useCallback } from 'react';
import { delay } from '../../logic/util';
import { Grid } from './Game';
import { Notification } from '../NotificationSystem/NotificationSystem';

export interface EffectTerm {
  functor: 'effect';
  args: [Grid, EffectInfoTerm[]];
}

export interface NewBlockTerm {
  functor: 'newBlock';
  args: [number];
}

export interface ComboTerm {
  functor: 'combo';
  args: [number];
}

export interface NewMaximumTerm {
  functor: 'newMaximum';
  args: [number];
}

type EffectInfoTerm = NewBlockTerm | ComboTerm | NewMaximumTerm;

export function useEffectAnimator(
  setGrid: (grid: Grid) => void,
  setScore: React.Dispatch<React.SetStateAction<number>>,
  setWaiting: (wait: boolean) => void,
  addNotification: (notification: Omit<Notification, 'id'>) => void
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
        if (args[0] > 0) {
          addNotification({
            type: 'points',
            message: `+${args[0]} puntos`,
            value: args[0]
          });
        }
      } else if (functor === 'combo') {
        addNotification({
          type: 'combo',
          message: `Combo x${args[0]}!`,
          value: args[0]
        });
      } else if (functor === 'newMaximum') {
        addNotification({
          type: 'newMaximum',
          message: `¡Nuevo máximo: ${args[0]}!`,
          value: args[0]
        });
      }
    });

    await delay(1000);
    animateEffect(effects.slice(1));
  }, [setGrid, setScore, setWaiting, addNotification]);

  return animateEffect;
}