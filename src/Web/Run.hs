module Web.Run (run) where
import Relude
import Web.Server (waiApp)
import App.WebApp
import qualified Network.Wai.Handler.Warp as Warp

run :: WebApp ()
run = do
  putStrLn "Web.Run"
  pool <- asks dbPool
  liftIO (Warp.run 8888 (waiApp pool))
