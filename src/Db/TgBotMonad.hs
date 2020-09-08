module Db.TgBotMonad (
  ChatId(..),
  PatternId(..),
  ReplyPat(..),
  TgBotStoreMonad(..),
  ReplyPatInsert(..)
) where
import Relude
import Data.Vector

newtype ChatId = ChatId Int64
newtype PatternId = PatternId Int64

data ReplyPat = ReplyPat
  { patId :: PatternId
  , strategy :: Text
  , pat :: Text
  , reply :: Text
  }

data ReplyPatInsert = ReplyPatInsert
  { strategy :: Text
  , pat :: Text
  , reply :: Text
  }

class Monad m => TgBotStoreMonad m where
  retrievePatternsForChat :: ChatId -> m (Vector ReplyPat)
  getChats :: m (Vector ChatId)
  insPattern :: ChatId -> ReplyPatInsert -> m ()