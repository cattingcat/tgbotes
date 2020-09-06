module Bot.Actions (
  Action(..)
) where
import Relude
import Telegram.Bot.API.Types



data Action
  = NoOp
  | AddPattern
  | GetChatId MessageId ChatId
  | ErrorCommand MessageId Text
  | Replace MessageId Text
  deriving stock (Show)