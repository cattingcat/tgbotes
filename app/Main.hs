module Main (main) where
import Relude
import App.Types
import App.WebApp
import qualified Bot.Run as Bot
import qualified Web.Run as Web
import qualified Db.TestDb as Db

main :: IO ()
main = do
  confMaybe <- getConfig
  case  confMaybe of
    Nothing -> putStrLn "Incorrect config"
    Just c -> runApp app c
  putStrLn "Press <enter> to stop"
  _ <- getLine
  pure ()
  where
    app = do
      Db.test
      runWebApp (Bot.run >> Web.run)