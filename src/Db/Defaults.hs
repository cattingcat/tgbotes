module Db.Defaults (
defaultHost,
defaultPort,
defaultUser,
defaultDbName,
defaultPassword
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

defaultPassword :: ByteString
defaultPassword = "F%HzxKnu9|X7ec24Z)"