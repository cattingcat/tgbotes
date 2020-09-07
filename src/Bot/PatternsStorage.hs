module Bot.PatternsStorage () where
import Relude
import Hasql.Pool
import qualified Hasql.Session as S
import Data.Vector
import Bot.State
import Db.BotDb

tst :: Pool -> Int64 -> IO (Either UsageError [ReplaceModel])
tst pool channelId = use pool $ do
  vect <- S.statement channelId retrievePatternsForChat
  pure $ catMaybesVect (mapToReplaceModel <$> vect)
  where
    mapToReplaceModel :: (Text, Text, Text) -> Maybe ReplaceModel
    mapToReplaceModel (strat, pat, replacement) =
       (\s -> ReplaceModel s pat replacement) <$> tryParseStrategy strat


catMaybesVect :: Vector (Maybe a) -> [a]
catMaybesVect = Data.Vector.foldl' (\l a -> case a of {Just a' -> a':l; _ -> l}) []