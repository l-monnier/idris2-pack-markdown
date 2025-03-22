module Internal.String

import Data.List
import Data.List1
import Data.Maybe
import Data.String
import Data.String.Extra

%default total

namespace List
  private
  partial
  range : Nat -> List Nat
  range n =
    reverse (drop 1 (iterate next n))
      where
        next : Nat -> Maybe Nat
        next (S k) = Just k
        next Z = Nothing
  
  private
  partial
  zipWithIndex : List a -> List (a, Nat)
  zipWithIndex l =
    zip l (range (length l))
  
  export
  partial
  findAll : Eq a => List a -> List a -> List Nat
  findAll l k =
    reverse (findAllHelper l k 0 [])
    where
      findAllHelper : List a -> List a -> Nat -> List Nat -> List Nat
      findAllHelper l k index acc =
        case l of
          [] =>
            acc
          _ =>
            let
              nextAcc =
                if isPrefixOf k l then
                  (index :: acc)
                else
                  acc
            in
              findAllHelper (drop 1 l) k (index + 1) nextAcc
  
  export
  partial
  replace : Eq a => List a -> List a -> List a -> List a
  replace l k v =
    let
      matches = findAll l k
      repl = reverse v
      skipLen = case length k of
        Z =>
          0 -- This is really impossible but we haven't refined our types to say so
        (S Z) =>
          0
        (S k) =>
          k
    in
      reverse $ fst $ foldl (\(acc, skip), (c, i) =>
        case skip of
          Just (S k) =>
            (acc, Just k)
          _ =>
            if isJust (find (== i) matches) then
              -- We need to insert a replacement and then skip N els
              (repl ++ acc, Just skipLen)
            else
              (c :: acc, Nothing)
      ) ([], (the (Maybe Nat) Nothing)) (zipWithIndex l)

private
wrap : String -> String -> String
wrap sym str =
  sym ++ str ++ sym

private
listOp : (List Char -> List Char) -> String -> String
listOp op =
  pack . op . unpack

export
partial
findAll : String -> String -> List Nat
findAll str lookup =
  List.findAll (unpack str) (unpack lookup)

export
partial
replace : String -> String -> String -> String
replace k v str =
  pack (List.replace (unpack str) (unpack k) (unpack v))

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
partial
quote : String -> String
quote =
  (wrap "\"")
  . (replace "\n" "\\n")
  . (replace "\"" "\\\"")
