module Bot.ReplyBot (replyBot) where
import Relude
import qualified Data.Text as T
import Telegram.Bot.Simple
import Telegram.Bot.API

import Bot.Actions
import Bot.State
import Fmt

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
  AddPattern -> pure model -- TODO: Add pattern logic
  GetChatId msgId (ChatId chatId) -> model <# do
    replyTo' msgId (fmt $  ""+|chatId|+"")
    pure NoOp
  ErrorCommand msgId errorText -> model <# do
    replyTo' msgId errorText
    pure NoOp
  Replace msgId msg -> model <# do
    case findReplacement model msg of
      Just r  -> replyTo' msgId r
      Nothing -> pure ()
    pure NoOp

processMessage :: Model -> Message -> Maybe Action
processMessage _ Message{
  messageText=t,
  messageMessageId=msgId,
  messageChat=Chat{chatId}} =
  case t of
    Nothing  -> Nothing
    Just txt ->
      if | "/addPattern" `T.isPrefixOf` txt -> Just AddPattern
         | "/chatId"     `T.isPrefixOf` txt -> Just (GetChatId msgId chatId)
         | "/"           `T.isPrefixOf` txt -> Just (ErrorCommand msgId txt)
         | otherwise -> Just (Replace msgId txt)

replyTo' :: MessageId -> Text -> BotM ()
replyTo' msgId text = reply (ReplyMessage text Nothing Nothing Nothing (Just msgId) Nothing)
