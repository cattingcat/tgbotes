module Main (main) where
import Relude
import App.Types
import Bot.Defaults
import Bot.Run (run)
import Db.Defaults
import Db.TestDb (test)

main :: IO ()
main = runApp app (AppConfig
      defaultHost
      defaultPort
      defaultUser
      defaultPassword
      defaultDbName
      defaultTgToken)
  where
    app = do
      test
      run