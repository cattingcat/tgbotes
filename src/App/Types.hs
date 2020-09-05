module App.Types (
  AppConfig(..),
  App,
  runApp
) where
import Relude
import Telegram.Bot.API (Token)

data AppConfig = AppConfig
  { dbHost :: !ByteString
  , dbPort :: !Word16
  , dbUser :: ByteString
  , dbPassword :: ByteString
  , dbName :: ByteString
  , tgToken :: Token
  }

newtype App a = App { upApp :: ReaderT AppConfig IO a }
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadReader AppConfig)

runApp :: App a -> AppConfig -> IO a
runApp = runReaderT . upApp