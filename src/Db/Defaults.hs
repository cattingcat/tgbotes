module Db.Defaults (
  defaultHost,
  defaultPort,
  defaultUser,
  defaultDbName
) where
import Relude

defaultHost :: ByteString
defaultHost = "51.158.130.90"

defaultPort :: Word16
defaultPort = 10997

defaultUser :: ByteString
defaultUser = "admin"

defaultDbName :: ByteString
defaultDbName = "rdb"