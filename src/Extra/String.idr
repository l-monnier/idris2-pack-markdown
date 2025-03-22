module Extra.String

import Data.List
import Data.List1
import Data.Maybe
import Data.String
import Data.String.Extra
import Extra.List

private
wrap : String -> String -> String
wrap sym str =
  sym ++ str ++ sym

private
listOp : (List Char -> List Char) -> String -> String
listOp op =
  pack . op . unpack

export
findAll : String -> String -> List Nat
findAll str lookup =
  findAll (unpack str) (unpack lookup)

export
replace : String -> String -> String -> String
replace k v str =
  pack (Extra.List.replace (unpack str) (unpack k) (unpack v))

export
filter : (Char -> Bool) -> String -> String
filter test =
  pack . filter test . unpack

export
showList : (a -> String) -> List a -> String
showList f els =
  "[" ++ (join "," (map f els)) ++ "]"

export
split : Char -> String -> List String
split c =
  ( map pack ) . Prelude.toList . (Data.List.split (== c)) . unpack

export
quote : String -> String
quote =
  (wrap "\"")
  . (replace "\n" "\\n")
  . (replace "\"" "\\\"")
