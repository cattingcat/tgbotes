module Web.Types (
  User(..),
  ReplyPattern(..),
  ServerAPI
) where
import Relude
import Data.Aeson
import Servant.API

data User = User
  { name :: Text
  , surname :: Text
  }
  deriving stock Generic
  deriving anyclass ToJSON

data ReplyPattern = ReplyPattern
  { strategy :: Text
  , pat :: Text
  , reply :: Text
  }
  deriving stock Generic
  deriving anyclass ToJSON


type ServerAPI = "users" :> "list-all" :> Get '[JSON] [User]
            :<|> "list-all" :> "users" :> Get '[JSON] [User]
            :<|> "patterns" :> Capture "chatId" Int64 :> Get '[JSON] [ReplyPattern]
--            :<|> Raw