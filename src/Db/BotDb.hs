module Db.BotDb (
  retrievePatternsForChat,
  getChats,
  addPatternsForChat,
  removePattern
) where

import Relude
import Data.Vector
import Hasql.Statement (Statement(..))
import qualified Hasql.TH as TH

sumStatement :: Statement (Int64, Int64) Int64
sumStatement = [TH.singletonStatement|
    select ($1 :: int8 + $2 :: int8) :: int8
  |]

divModStatement :: Statement (Int64, Int64) (Int64, Int64)
divModStatement = [TH.singletonStatement|
    select
      (($1 :: int8) / ($2 :: int8)) :: int8,
      (($1 :: int8) % ($2 :: int8)) :: int8
  |]

retrievePatternsForChat :: Statement Int64 (Vector (Int64, Text, Text, Text))
retrievePatternsForChat = [TH.vectorStatement|
    select
        r.id          :: int8,
        r.strategy    :: text,
        r.pattern     :: text,
        r.replacement :: text
        from
            reply_tg_bot.channels c
            join reply_tg_bot.replacements r
                on c.id = r.channel_id
        where c.telegram_id = ($1 :: int8)
  |]

getChats :: Statement () (Vector Int64)
getChats = [TH.vectorStatement|
    select
        c.telegram_id  :: int8
        from reply_tg_bot.channels c
  |]

addPatternsForChat :: Statement (Int64, Text, Text, Text) ()
addPatternsForChat = [TH.resultlessStatement|
    insert into  reply_tg_bot.replacements
      (strategy, pattern, channel_id, replacement)
       values (($2 :: text), ($3 :: text), ($1 :: int8), ($4 :: text))
  |]

removePattern :: Statement Int64 Int64
removePattern = [TH.rowsAffectedStatement|
    delete from reply_tg_bot.replacements r
        where r.id = ($1 :: int8)
  |]