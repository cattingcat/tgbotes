module App.Types (
  AppConfigHkd(..),
  AppConfig,
  App,
  runApp,
  getConfig
) where
import Relude
import qualified Db.Defaults as DbD
import qualified System.Envy as E
import qualified Options.Applicative as O
import Telegram.Bot.API (Token(..))


type family C (f :: Type -> Type) (a :: Type) :: Type where
  C Identity a = a
  C f a = f a

data AppConfigHkd f = MkAppConfig
  { dbHost ::     !(C f ByteString)
  , dbPort ::     !(C f Word16)
  , dbUser ::     !(C f ByteString)
  , dbPassword :: !(C f ByteString)
  , dbName ::     !(C f ByteString)
  , tgToken ::    !(C f Token)
  }

deriving stock instance Show (AppConfigHkd Maybe)
deriving stock instance Show (AppConfigHkd Identity)

emptyConfig :: AppConfigHkd Maybe
emptyConfig = MkAppConfig Nothing Nothing Nothing Nothing Nothing Nothing

type AppConfig = AppConfigHkd Identity

getConfig :: IO (Maybe AppConfig)
getConfig = do
  cliConfig <- getFromCLI
  envConfig <- getFromEnv
  let conf = MkAppConfig
        (dbHost     cliConfig <|> dbHost     envConfig <|> Just DbD.defaultHost)
        (dbPort     cliConfig <|> dbPort     envConfig <|> Just DbD.defaultPort)
        (dbUser     cliConfig <|> dbUser     envConfig <|> Just DbD.defaultUser)
        (dbPassword cliConfig <|> dbPassword envConfig)
        (dbName     cliConfig <|> dbName     envConfig <|> Just DbD.defaultDbName)
        (tgToken    cliConfig <|> tgToken    envConfig)
  pure (validateConfig conf)


getFromCLI :: IO (AppConfigHkd Maybe)
getFromCLI = O.execParser (O.info (appConfigCliParser <**> O.helper) desc)
  where
    desc = O.fullDesc <> O.progDesc "" <> O.header ""

appConfigCliParser :: O.Parser (AppConfigHkd Maybe)
appConfigCliParser = MkAppConfig
  <$> O.optional (O.strOption (O.long "DB_HOST" <> O.help ""))
  <*> parseMaybePort
  <*> O.optional (O.strOption (O.long "DB_USER" <> O.help ""))
  <*> O.optional (O.strOption (O.long "DB_PASS" <> O.help ""))
  <*> O.optional (O.strOption (O.long "DB_NAME" <> O.help ""))
  <*> O.optional (O.strOption (O.long "TG_TOKEN" <> O.help ""))
    where
      parseMaybePort :: O.Parser (Maybe Word16)
      parseMaybePort = (>>= readMaybe) <$> O.optional (O.strOption (O.long "DB_PORT" <> O.help ""))

getFromEnv :: IO (AppConfigHkd Maybe)
getFromEnv = do
  eith <- E.runEnv $ MkAppConfig
      <$> E.envMaybe "DB_HOST"
      <*> E.envMaybe "DB_PORT"
      <*> E.envMaybe "DB_USER"
      <*> E.envMaybe "DB_PASS"
      <*> E.envMaybe "DB_NAME"
      <*> ((Token <$>) <$> E.envMaybe "TG_TOKEN")
  pure $ case eith of
    Right r -> r
    Left _ -> emptyConfig

validateConfig ::  AppConfigHkd Maybe -> Maybe AppConfig
validateConfig MkAppConfig{dbHost, dbPort, dbUser, dbPassword, dbName, tgToken} =
  MkAppConfig <$> dbHost <*> dbPort <*> dbUser <*> dbPassword <*> dbName <*> tgToken

newtype App a = App { upApp :: ReaderT AppConfig IO a }
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadReader AppConfig)

runApp :: App a -> AppConfig -> IO a
runApp = runReaderT . upApp
