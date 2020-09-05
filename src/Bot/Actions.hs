module Bot.Actions (
  Action(..)
) where
import Relude
import Telegram.Bot.API.Types (MessageId)



data Action
  = NoOp
  | AddPattern
  | GetChatId
  | ErrorCommand MessageId Text
  | Replace MessageId Text
  deriving stock (Show)