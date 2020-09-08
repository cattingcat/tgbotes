module Web.W (
  WebAppErr,
  W(..),
  runW
) where
import Relude
import Hasql.Pool
import qualified Hasql.Session as S
import qualified Hasql.Statement as S
import qualified Db.BotDb as D
import Db.TgBotMonad
import Data.Vector
import Control.Monad.Except

type WebAppErr = Text

newtype W a = W { _runW :: ReaderT Pool (ExceptT WebAppErr IO) a }
  deriving newtype (
    Functor,
    Applicative,
    Monad,
    MonadIO,
    MonadReader Pool,
    MonadError WebAppErr)

runW :: Pool -> W a -> ExceptT WebAppErr IO a
runW pool w = runReaderT (_runW w) pool

runStatement :: S.Statement a b -> a -> Text -> W b
runStatement s a errorTxt = do 
  pool <- ask
  res <- liftIO $ use pool (S.statement a s)
  case res of
    Left _ -> throwError errorTxt
    Right v -> pure v


instance TgBotStoreMonad W where
  retrievePatternsForChat :: ChatId -> W (Vector ReplyPat)
  retrievePatternsForChat (ChatId chatId) = do
    v <- runStatement D.retrievePatternsForChat chatId " "
    let r = fmap (\(i, a, b, c) -> ReplyPat (PatternId i) a b c) v
    pure r

  getChats :: W (Vector ChatId)
  getChats = do
    v <- runStatement D.getChats () " "
    pure $ fmap ChatId v

  insPattern :: ChatId -> ReplyPatInsert -> W ()
  insPattern (ChatId chatId) ReplyPatInsert{..} = 
    runStatement D.addPatternsForChat  (chatId, strategy, pat, reply) " "