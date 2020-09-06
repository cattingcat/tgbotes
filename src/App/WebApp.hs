module App.WebApp (
  WebApp,
  WebAppConfig(..),
  runWebApp
) where
import Relude
import qualified App.Types as T
import Hasql.Connection
import qualified Hasql.Pool as P
import Telegram.Bot.API (Token(..))

data WebAppConfig = WebAppConfig
  { tgToken :: !Token
  , dbPool :: !P.Pool
  }

newtype WebApp a = WebApp { upApp2 :: ReaderT WebAppConfig IO a }
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadReader WebAppConfig)

runWebApp :: WebApp a -> T.App a
runWebApp wa = do
  config <- asks (\T.MkAppConfig{..} -> settings dbHost dbPort dbUser dbPassword dbName)
  tgToken <- asks (\T.MkAppConfig{..} -> tgToken)
  pool <- liftIO (P.acquire (5, 300, config))
  let waConf = WebAppConfig tgToken pool
  liftIO $ runReaderT (upApp2 wa) waConf