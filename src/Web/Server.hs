module Web.Server (waiApp) where
import Relude
import Web.Types
import Web.W
import Servant.API
import Servant.Server
import qualified Network.Wai as Wai
import Hasql.Pool (Pool)
import Db.TgBotMonad
import Control.Monad.Except (throwError)

waiApp :: Pool -> Wai.Application
waiApp pool = serve (Proxy @ServerAPI) (hoist pool)

hoist :: Pool -> Server ServerAPI
hoist pool = hoistServer (Proxy @ServerAPI) foo server
  where
    foo :: forall x . W x -> Handler x
    foo w = do
      r <- liftIO (runExceptT (runW pool w))
      case r of
        Left _ -> throwError (ServerError 400 "err" "" [])
        Right res -> pure res


server :: TgBotStoreMonad m => ServerT ServerAPI m
server = handlerUser
    :<|> handlerUser
    :<|> handlerPatterns
--    :<|> rawHandler

handlerUser ::TgBotStoreMonad m => m [User]
handlerUser = pure [User "fname" "lname", User "fname2" "lname2"]

handlerPatterns :: TgBotStoreMonad m => Int64 -> m [ReplyPattern]
handlerPatterns chatId = do
  vect <- retrievePatternsForChat (ChatId chatId)
  let patterns = fmap (\(ReplyPat a b c) -> ReplyPattern a b c) vect
  pure $ toList patterns

--rawHandler :: Tagged m Application
--rawHandler = Tagged undefined
