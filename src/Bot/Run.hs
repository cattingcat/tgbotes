module Bot.Run (run) where
import Relude
import Telegram.Bot.Simple
import Telegram.Bot.API
import App.WebApp
import Bot.ReplyBot

run :: WebApp ()
run = do
  token <- asks (\WebAppConfig{tgToken} -> tgToken)
  liftIO $ do
    putStrLn "Bot.Run"
    env <- defaultTelegramClientEnv token
    --  startBot_ (conversationBot updateChatId replyBot) env
    startBotAsync_ replyBot env