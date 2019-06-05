-- | Channel endpoints
module Calamity.HTTP.Channel
    ( ChannelRequest(..) ) where

import           Calamity.HTTP.Internal.Request
import           Calamity.HTTP.Internal.Route
import           Calamity.HTTP.Types
import           Calamity.Types.General
import           Calamity.Types.Snowflake

import           Data.Aeson

import           Network.Wreq

data ChannelRequest a where
  CreateMessage :: Snowflake Channel -> Text -> ChannelRequest Message
  GetChannel :: Snowflake Channel -> ChannelRequest Channel
  ModifyChannel :: Snowflake Channel -> ChannelUpdate -> ChannelRequest Channel
  DeleteChannel :: Snowflake Channel -> ChannelRequest Channel
  GetChannelMessages :: Snowflake Channel -> Maybe ChannelMessagesQuery -> ChannelRequest Channel

baseRoute :: Snowflake Channel -> RouteBuilder _
baseRoute id = mkRouteBuilder // S "channels" // ID @Channel
  & giveID id

instance Request (ChannelRequest a) a where
  toRoute (CreateMessage id _) = baseRoute id // S "messages"
    & buildRoute
  toRoute (GetChannel id) = baseRoute id
    & buildRoute
  toRoute (ModifyChannel id _) = baseRoute id
    & buildRoute
  toRoute (DeleteChannel id) = baseRoute id
    & buildRoute
  toRoute (GetChannelMessages id _) = baseRoute id // S "messages"
    & buildRoute

  toAction (CreateMessage _ t) = postWith' (object ["content" .= t])
  toAction (GetChannel _) = getWith
  toAction (ModifyChannel _ p) = putWith' (toJSON p)
  toAction (DeleteChannel _) = deleteWith
  toAction (GetChannelMessages _ (Just (ChannelMessagesAround (show . fromSnowflake -> a)))) = getWithP (param "around" .~ [a])
  toAction (GetChannelMessages _ (Just (ChannelMessagesBefore (show . fromSnowflake -> a)))) = getWithP (param "before" .~ [a])
  toAction (GetChannelMessages _ (Just (ChannelMessagesAfter  (show . fromSnowflake -> a)))) = getWithP (param "after"  .~ [a])
  toAction (GetChannelMessages _ (Just (ChannelMessagesLimit  (show -> a))))                 = getWithP (param "around" .~ [a])
  toAction (GetChannelMessages _ Nothing) = getWith
