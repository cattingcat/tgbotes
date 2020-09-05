module Bot.Run (run) where
import Relude
import Telegram.Bot.Simple
import Telegram.Bot.API
import App.Types
import Bot.ReplyBot

run :: App ()
run = do
  token <- asks (\AppConfig{tgToken} -> tgToken)
  liftIO $ do
    putStrLn "Bot.Run"
    env <- defaultTelegramClientEnv token
    --  startBot_ (conversationBot updateChatId replyBot) env
    startBot_ replyBot env