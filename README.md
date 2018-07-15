# purescript-logging

Composable loggers for PureScript.

## Usage

A logger receives records and potentially performs some effects. You can create
a logger from any function `r -> m Unit` for any `r` and `m`.

Unlike most other logging libraries, purescript-logger has no separate concepts
"loggers" and "handlers". Instead, loggers can be composed into larger loggers
using the `Semigroup` instance. Loggers can also be transformed using `cmap`
(for transforming records) and `cfilter` (for filtering records). An example
use case might be the following:

```purescript
data Level = Debug | Info | Warning | Error
derive instance eqLevel :: Eq Level
derive instance ordLevel :: Ord Level

type Entry =
  { time   :: DateTime
  , level  :: Level
  , fields :: Map String String
  }

fileLogger :: Path -> Logger Effect Entry
fileLogger path = Logger \entry -> ?todo {- append entry to file -}

main = do
  let debugLogger      = fileLogger "debug.log"      # cfilter (\e -> e.level == Debug)
  let productionLogger = fileLogger "production.log" # cfilter (\e -> e.level /= Debug)
  let logger = debugLogger <> productionLogger

  time <- now
  log logger {time, level: Info, fields: Map.singleton "msg" "boot"}
```
