module Web.Run (run) where
import Relude
import App.WebApp

run :: WebApp ()
run = putStrLn "Web.Run"
