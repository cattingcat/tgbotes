module Bot.ReplyBot (replyBot) where
import Relude
import qualified Data.Text as T
import Telegram.Bot.Simple
import Telegram.Bot.API

import Bot.Actions
import Bot.State

replyBot :: BotApp Model Action
replyBot = BotApp
  { botInitialModel = initialState
  , botAction = updateToAction
  , botHandler = handleAction
  , botJobs = []
  }

updateToAction :: Update -> Model -> Maybe Action
updateToAction Update{updateMessage=m} model =
  case m of
    Just msg -> processMessage model msg
    Nothing  -> Nothing

handleAction :: Action -> Model -> Eff Action Model
handleAction action model = case action of
  NoOp -> pure model
  AddPattern -> undefined
  ErrorCommand msgId errorText -> model <# do
    replyTo' msgId errorText
    pure NoOp
  Replace msgId msg -> model <# do
    replyTo' msgId msg
    pure NoOp

processMessage :: Model -> Message -> Maybe Action
processMessage model Message{messageText=t, messageMessageId=msgId} =
  case t of
    Nothing  -> Nothing
    Just txt ->
      if | "/addPattern" `T.isPrefixOf` txt -> Just AddPattern
         | "/chatId"     `T.isPrefixOf` txt -> Just GetChatId
         | "/"           `T.isPrefixOf` txt -> Just (ErrorCommand msgId txt)
         | otherwise -> Just (Replace msgId txt)

replyTo' :: MessageId -> Text -> BotM ()
replyTo' msgId text = reply (ReplyMessage text Nothing Nothing Nothing (Just msgId) Nothing)
