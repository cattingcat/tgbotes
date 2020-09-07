module Web.W (
  WebAppErr,
  W(..),
  runW
) where
import Relude
import Hasql.Pool
import qualified Hasql.Session as S
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


instance TgBotStoreMonad W where
  retrievePatternsForChat :: ChatId -> W (Vector ReplyPat)
  retrievePatternsForChat (ChatId chatId) = do
    pool <- ask
    res <- liftIO $ use pool (S.statement chatId D.retrievePatternsForChat)
    case res of
      Left _ -> throwError " "
      Right v -> do
        let r = fmap (\(a, b, c) -> ReplyPat a b c) v
        pure r

