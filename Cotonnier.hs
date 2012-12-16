{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell, OverloadedStrings, ExtendedDefaultRules #-}

import Yesod as Yesod
import Mongo as Mongo
import Yesod.Markdown as Markdown

data Cotonnier = Cotonnier

mkYesod "Cotonnier" [parseRoutes|
/ HomeR GET
/#Integer CotonsIdR GET
|]

instance Yesod Cotonnier

getStaticArticle id = "/home/engil/static/" ++ (show id) ++ "/article.md"

getHomeR :: Handler Yesod.RepHtml
getHomeR = Yesod.defaultLayout [whamlet|Accueil|]

getCotonsIdR :: Integer -> Handler Yesod.RepHtml
getCotonsIdR id = do
  query <- Yesod.liftIO $ Mongo.queryMetadataById id
  corpusmd <- Yesod.liftIO $ Markdown.markdownFromFile (getStaticArticle id)
  let metadatas = query
      author = Mongo.getString $ getValue metadatas "author"
      tags = Mongo.getString $ getValue metadatas "tags"
      date = Mongo.getString $ getValue  metadatas "date"
      title = Mongo.getString $ getValue  metadatas "title"
      corpus = Markdown.markdownToHtml corpusmd
  Yesod.defaultLayout $(Yesod.whamletFile "Post.hamlet")

main :: IO ()
main = Yesod.warpDebug 3000 Cotonnier
