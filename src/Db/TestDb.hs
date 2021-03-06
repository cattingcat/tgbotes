module Db.TestDb (test) where
import Relude
import qualified Hasql.Session as S
import qualified Hasql.Connection as C
import Db.BotDb
import App.Types

test :: App ()
test = do
  connStr <- asks (\MkAppConfig{..} -> C.settings dbHost dbPort dbUser dbPassword dbName)
  liftIO $ do
    putStrLn "Db.TestDb"
    c <- C.acquire connStr
    case c of
      Right connection -> do
        res <- S.run (S.statement () getChats)  connection
        print res
      Left err -> putStrLn ("Err: " ++ show err)

