/* Stockfish 19, unmodified browser build: GPL-3.0. See engine/README.md. */
window.StockfishBoss = (() => {
  let worker, ready, rejectSearch, rejectReady, loadTimer, searchTimer, searchSerial = 0;
  function cancel() {
    searchSerial++;
    if (!rejectSearch && !rejectReady) return;
    clearTimeout(loadTimer); clearTimeout(searchTimer);
    if (rejectSearch) { rejectSearch(new Error('Search cancelled')); rejectSearch = null; }
    if (rejectReady) { rejectReady(new Error('Loading cancelled')); rejectReady = null; }
    if (worker) worker.terminate();
    worker = null; ready = null;
  }
  function prepare() {
    if (ready) return ready;
    ready = new Promise((resolve, reject) => {
      rejectReady = reject;
      worker = new Worker('engine/stockfish-19-single.js');
      loadTimer = setTimeout(() => { cancel(); reject(new Error('Engine loading timed out')); }, 45000);
      worker.onerror = () => { cancel(); reject(new Error('Engine unavailable')); };
      worker.onmessage = event => {
        const line = String(event.data);
        if (line === 'uciok') {
          worker.postMessage('setoption name Hash value 64');
          worker.postMessage('setoption name UCI_LimitStrength value false');
          worker.postMessage('isready');
        } else if (line === 'readyok') { clearTimeout(loadTimer); rejectReady = null; resolve(); }
      };
      worker.postMessage('uci');
    });
    return ready;
  }
  async function choose(fen, ms = 2400, history) {
    const serial = searchSerial;
    await prepare();
    if (serial !== searchSerial) throw new Error('Search cancelled');
    return new Promise((resolve, reject) => {
      rejectSearch = reject;
      searchTimer = setTimeout(() => { cancel(); reject(new Error('Engine search timed out')); }, ms + 10000);
      worker.onerror = () => { cancel(); reject(new Error('Engine failed')); };
      worker.onmessage = event => {
        const match = /^bestmove\s+(\S+)/.exec(String(event.data));
        if (match) { clearTimeout(searchTimer); rejectSearch = null; resolve(match[1]); }
      };
      // Preserve the game history for repetition detection.
      worker.postMessage(Array.isArray(history) ? 'position startpos moves ' + history.join(' ') : 'position fen ' + fen);
      worker.postMessage('go movetime ' + ms);
    });
  }
  return { prepare, choose, cancel };
})();
