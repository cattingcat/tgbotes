module Bot.State (
  Model(..),
  ReplaceModel(..),
  ReplacementStrategy(..),
  initialState,
  findReplacement,
  tryParseStrategy
) where
import Relude
import Data.Text (isInfixOf, toLower)

data ReplacementStrategy = WholeMessage | Contains
  deriving stock Show
  
tryParseStrategy :: Text -> Maybe ReplacementStrategy
tryParseStrategy "wholeMessage" = Just WholeMessage
tryParseStrategy "contains"     = Just Contains
tryParseStrategy _              = Nothing

data ReplaceModel = ReplaceModel
  { strategy :: ReplacementStrategy
  , pat :: Text
  , replacement :: Text
  }
  deriving stock (Show)

data Model = Model
  { replacements :: [ReplaceModel]
  , stats :: Int
  }
  deriving stock (Show)

initialState :: Model
initialState = Model replacementMap 0

replacementMap :: [ReplaceModel]
replacementMap =
  [ ReplaceModel Contains "не нужен" "Ты не нужен"
  ]

findReplacement :: Model -> Text -> Maybe Text
findReplacement Model{replacements} = replaceText replacements

replaceText :: [ReplaceModel] -> Text -> Maybe Text
replaceText replacements (toLower -> text) = replacement <$> find p replacements
  where
    p :: ReplaceModel -> Bool
    p (ReplaceModel WholeMessage key _) | key == text = True
    p (ReplaceModel Contains     key _) | key `isInfixOf` text = True
    p _ = False