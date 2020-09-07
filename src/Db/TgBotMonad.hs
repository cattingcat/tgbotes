module Db.TgBotMonad (
  ChatId(..),
  ReplyPat(..),
  TgBotStoreMonad(..)
) where
import Relude
import Data.Vector

newtype ChatId = ChatId Int64

data ReplyPat = ReplyPat
  { strategy :: Text
  , pat :: Text
  , reply :: Text
  }

class Monad m => TgBotStoreMonad m where
  retrievePatternsForChat :: ChatId -> m (Vector ReplyPat)