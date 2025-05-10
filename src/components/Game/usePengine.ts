import { useEffect, useState } from 'react';
import PengineClient from '../../logic/PengineClient';

export function usePengine() {
  const [pengine, setPengine] = useState<any>(null);

  useEffect(() => {
    const init = async () => {
      const client = await PengineClient.create();
      setPengine(client);
    };
    init();
  }, []);

  return pengine;
}
