# Engine attribution and corresponding source

The unmodified single-thread WebAssembly build of Stockfish 19 is distributed under GNU GPL version 3. The license is in [Copying.txt](Copying.txt).

Stockfish.js copyright 2026 Chess.com, LLC, Nathan Rugg, and the Stockfish contributors.

Exact upstream release and corresponding source (including build scripts):
https://github.com/nmrugg/stockfish.js/tree/v19.0.0
https://github.com/nmrugg/stockfish.js/archive/refs/tags/v19.0.0.zip

Engine build: stockfish@19.0.0 from https://registry.npmjs.org/stockfish/-/stockfish-19.0.0.tgz

Only the strongest single-thread build is loaded, on demand, for the boss option. It is about 99 MB, so the initial download can take longer than three seconds. No reduced-strength setting is applied. The 9999 UI label is fictional, not a measured Elo rating.

Replacement puzzles come from https://database.lichess.org/lichess_db_puzzle.csv.zst under CC0. The 123 selected entries have strictly increasing Lichess puzzle ratings. These ratings estimate human difficulty; individual perception can differ. The puzzle set has its own progress version so old completion indices are not assigned to new positions.
