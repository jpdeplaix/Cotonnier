{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
module Mongo(
initMongoCo
, mongoRun
, valueToString
, queryMetadataById
, queryTenLastsDocuments
, checkResponse
, getString
, getValue
, getDate
, getList
, getId
) where

import Database.MongoDB as MongoDB
import Data.Maybe as Maybe
import Control.Monad.Trans (liftIO)
import System.Locale as Locale
import Data.Time
import Data.Time.Format as Format

initMongoCo = runIOE $ MongoDB.connect $ MongoDB.host "127.0.0.1"

mongoRun pipe = MongoDB.access pipe MongoDB.master "cotonnier"

valueToString :: Maybe String -> String
valueToString (Just a) = a
valueToString Nothing = "Error xd"

getId :: Either String (Maybe Integer) -> Maybe Integer
getId (Left error) = Nothing
getId (Right (Just a)) = Just a
getId (Right Nothing) = Nothing

getDate :: Either String (Maybe UTCTime) -> String
getDate (Left error) = error
getDate (Right Nothing) = "Value error"
getDate (Right (Just date)) = Format.formatTime Locale.defaultTimeLocale "%A %e, %B %Y" date

getString :: Either String (Maybe String) -> String
getString (Left error) = error
getString (Right Nothing) = "Value error"
getString (Right (Just value)) = value

getList :: Either String (Maybe [String]) -> [String]
getList (Left error) = [error]
getList (Right Nothing) = ["Value error"]
getList (Right (Just list)) = list

getValue :: (Val a) => Either String Document -> Label -> Either String (Maybe a)
getValue (Left error) _ = Left error
getValue (Right document) field = Right $ MongoDB.look field document >>= MongoDB.cast'

queryMetadataById :: Integer -> IO (Either String Document)
queryMetadataById id = do
  pipe <- initMongoCo
  response <- mongoRun pipe $ MongoDB.findOne $ MongoDB.select ["id" =: id] "cotons"
  let document = checkResponse response
  return document

queryTenLastsDocuments = do
  pipe <- initMongoCo
  response <- mongoRun pipe $ MongoDB.find (MongoDB.select [] "cotons") {limit = 10} >>= MongoDB.rest
  return response

checkResponse :: Val a => Either Failure (Maybe a) -> Either String a
checkResponse (Left _) = Left "Error while querying MongoDB"
checkResponse (Right Nothing) = Left "Querying return nothing"
checkResponse (Right (Just a)) = Right a
