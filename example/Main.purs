module Main where

import Control.Logger (Logger(..), cfilter, log)
import Data.DateTime (DateTime)
import Data.Map (Map, singleton)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect (Effect)
import Effect.Now(nowDateTime)
import Effect.Console as Console
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.FS (FileFlags(..))
import Node.FS.Sync as S
import Node.Path (concat) as Path
import Node.Path (FilePath)
import Prelude (class Eq, class Ord, bind, class Show, show, discard, Unit, (#), ($), (/=), (<>), (==))

data Level = Debug | Info | Warning | Error
derive instance eqLevel :: Eq Level
derive instance ordLevel :: Ord Level
instance showLevel :: Show Level where
  show Debug = "Debug"
  show Info = "Info"
  show Warning = "Warning"
  show Error = "Error"

type Entry =
  { time   :: DateTime
  , level  :: Level
  , fields :: Map String String
  }

toString :: Entry -> String
toString { time, level, fields } =
  joinWith " " [ show time, show level, show fields]

consoleLogger :: Logger Effect Entry
consoleLogger = Logger \entry ->
  do
    Console.log "this should only be informational"
    Console.log $ toString entry

fileLogger :: FilePath -> Logger Effect Entry
fileLogger filepath = Logger \entry -> 
  do
    fd0 <- S.fdOpen filepath A (Just 420)
    buf0 <- Buffer.fromString (toString entry <> "\n") UTF8
    bytes0 <- S.fdAppend fd0 buf0
    S.fdFlush fd0
    S.fdClose fd0


main :: Effect Unit
main = do
  let debugFilePath         = Path.concat [".", "debug.log"]
  let productionFilePath    = Path.concat [".", "production.log"]
  let debugLogger      = fileLogger debugFilePath      # cfilter (\e -> e.level == Debug)
  let productionLogger = fileLogger productionFilePath # cfilter (\e -> e.level /= Debug)
  let terminalLogger   = cfilter (\e -> e.level == Info) $ consoleLogger
  let logger = debugLogger <> productionLogger <> terminalLogger

  time <- nowDateTime
  log logger { time, level: Info, fields: singleton "info" "initial message" }
  log logger { time, level: Debug, fields: singleton "debug" "oh man, something went wrong" }
