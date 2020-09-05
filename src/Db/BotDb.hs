module Db.BotDb (
  retrievePatternsForChannel,
  getChannels
) where

import Relude
import Data.Vector
import Hasql.Statement (Statement(..))
import qualified Hasql.TH as TH

sumStatement :: Statement (Int64, Int64) Int64
sumStatement =
  [TH.singletonStatement|
    select ($1 :: int8 + $2 :: int8) :: int8
  |]

divModStatement :: Statement (Int64, Int64) (Int64, Int64)
divModStatement =
  [TH.singletonStatement|
    select
      (($1 :: int8) / ($2 :: int8)) :: int8,
      (($1 :: int8) % ($2 :: int8)) :: int8
  |]

retrievePatternsForChannel :: Statement Int64 (Vector (Text, Text, Text))
retrievePatternsForChannel =
  [TH.vectorStatement|
    select
        r.strategy    :: text,
        r.pattern     :: text,
        r.replacement :: text
        from
            reply_tg_bot.channels c
            join reply_tg_bot.replacements r
                on c.id = r.channel_id
        where c.telegram_id = ($1 :: int8)
  |]

getChannels :: Statement () (Vector (Int64, Int64))
getChannels =
  [TH.vectorStatement|
    select
        c.id           :: int8,
        c.telegram_id  :: int8
        from reply_tg_bot.channels c
  |]