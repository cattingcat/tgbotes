module Web.Server (waiApp) where
import Relude
import Web.Types
import Servant.API
import Servant.Server
import qualified Network.Wai as Wai
import Hasql.Pool (Pool, use)
import qualified Hasql.Session as S
import Db.BotDb
import Control.Exception.Safe (throwM)

waiApp :: Pool -> Wai.Application
waiApp pool = serve (Proxy @ServerAPI) (server pool)

server :: Pool -> Server ServerAPI
server pool = handlerUser
    :<|> handlerUser
    :<|> handlerPatterns pool
    :<|> rawHandler

handlerUser :: Handler [User]
handlerUser = pure [User "fname" "lname", User "fname2" "lname2"]

handlerPatterns :: Pool -> Int64 -> Handler [ReplyPattern]
handlerPatterns pool chatId = do
  res <- liftIO $ use pool (S.statement chatId retrievePatternsForChannel)
  case res of
    Left _ -> throwM (ServerError 400 "" "" [])
    Right vect -> do
      let patterns = fmap (\(a, b, c) -> ReplyPattern a b c) vect
      pure $ toList patterns

rawHandler :: Tagged Handler Application
rawHandler = Tagged undefined


