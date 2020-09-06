module Lib where
import Relude
import Data.String
import Control.Conditional

tst :: Bool -> String
tst b = if b then " xvdf" else "sdf"

tst2 :: ToBool b => b -> String
tst2 b = if' b "fsdf" "cvbcvb"


data Woods = Woods 
  { flag :: IsTree 
  , flag2 :: Bool
  }

newtype IsTree = IsTree Bool
  deriving newtype (ToBool)
  
newtype MyNumber = MyNumber Int
  deriving newtype (Eq, Show, Num, Read) 
  
tst3 :: Woods -> String
tst3 Woods{flag} = if' flag "sdf" "sdfsd"



data MyAppConfig = MyAppConfig
  { dbConf :: Woods
  , token :: String
  , n :: Int
  } 
  
newtype App a = App (ReaderT MyAppConfig IO a)
  deriving newtype (Functor, Applicative, Monad, MonadReader MyAppConfig)
  
--instance HasState "woods" Woods App where 
--  
--runWebApp :: HasState "dbConf" Woods m => m ()
--runTgApp :: HasState "token" String m => m ()