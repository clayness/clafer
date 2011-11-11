{-# OPTIONS -fno-warn-incomplete-patterns #-}
module Printclafer where

-- pretty-printer generated by the BNF converter

import Absclafer
import Char

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)


instance Print Ident where
  prt _ (Ident i) = doc (showString i)



instance Print Module where
  prt i e = case e of
   Module declarations -> prPrec i 0 (concatD [prt 0 declarations])


instance Print Declaration where
  prt i e = case e of
   EnumDecl id enumids -> prPrec i 0 (concatD [doc (showString "enum") , prt 0 id , doc (showString "=") , prt 0 enumids])
   ClaferDecl clafer -> prPrec i 0 (concatD [prt 0 clafer])
   ConstDecl constraint -> prPrec i 0 (concatD [prt 0 constraint])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Clafer where
  prt i e = case e of
   Clafer abstract gcard id super card elements -> prPrec i 0 (concatD [prt 0 abstract , prt 0 gcard , prt 0 id , prt 0 super , prt 0 card , prt 0 elements])


instance Print Constraint where
  prt i e = case e of
   Constraint exps -> prPrec i 0 (concatD [doc (showString "[") , prt 0 exps , doc (showString "]")])


instance Print Abstract where
  prt i e = case e of
   AbstractEmpty  -> prPrec i 0 (concatD [])
   Abstract  -> prPrec i 0 (concatD [doc (showString "abstract")])


instance Print Elements where
  prt i e = case e of
   ElementsEmpty  -> prPrec i 0 (concatD [])
   ElementsList elementcls -> prPrec i 0 (concatD [doc (showString "{") , prt 0 elementcls , doc (showString "}")])


instance Print ElementCl where
  prt i e = case e of
   Subclafer clafer -> prPrec i 0 (concatD [prt 0 clafer])
   ClaferUse name card elements -> prPrec i 0 (concatD [doc (showString "`") , prt 0 name , prt 0 card , prt 0 elements])
   Subconstraint constraint -> prPrec i 0 (concatD [prt 0 constraint])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Super where
  prt i e = case e of
   SuperEmpty  -> prPrec i 0 (concatD [])
   SuperColon name -> prPrec i 0 (concatD [doc (showString ":") , prt 0 name])
   SuperExtends name -> prPrec i 0 (concatD [doc (showString "extends") , prt 0 name])
   SuperArrow exp -> prPrec i 0 (concatD [doc (showString "->") , prt 0 exp])


instance Print GCard where
  prt i e = case e of
   GCardEmpty  -> prPrec i 0 (concatD [])
   GCardXor  -> prPrec i 0 (concatD [doc (showString "xor")])
   GCardOr  -> prPrec i 0 (concatD [doc (showString "or")])
   GCardMux  -> prPrec i 0 (concatD [doc (showString "mux")])
   GCardOpt  -> prPrec i 0 (concatD [doc (showString "opt")])
   GCardInterval gncard -> prPrec i 0 (concatD [doc (showString "<") , prt 0 gncard , doc (showString ">")])


instance Print Card where
  prt i e = case e of
   CardEmpty  -> prPrec i 0 (concatD [])
   CardLone  -> prPrec i 0 (concatD [doc (showString "?")])
   CardSome  -> prPrec i 0 (concatD [doc (showString "+")])
   CardAny  -> prPrec i 0 (concatD [doc (showString "*")])
   CardInterval ncard -> prPrec i 0 (concatD [prt 0 ncard])


instance Print GNCard where
  prt i e = case e of
   GNCard n exinteger -> prPrec i 0 (concatD [prt 0 n , doc (showString "-") , prt 0 exinteger])


instance Print NCard where
  prt i e = case e of
   NCard n exinteger -> prPrec i 0 (concatD [prt 0 n , doc (showString "..") , prt 0 exinteger])


instance Print ExInteger where
  prt i e = case e of
   ExIntegerAst  -> prPrec i 0 (concatD [doc (showString "*")])
   ExIntegerNum n -> prPrec i 0 (concatD [prt 0 n])


instance Print Name where
  prt i e = case e of
   LocClafer id -> prPrec i 0 (concatD [prt 0 id])
   ModClafer modids id -> prPrec i 0 (concatD [prt 0 modids , prt 0 id])


instance Print Exp where
  prt i e = case e of
   DeclExp exquant decls exp -> prPrec i 0 (concatD [prt 0 exquant , prt 0 decls , doc (showString "|") , prt 1 exp])
   EIff exp0 exp -> prPrec i 1 (concatD [prt 1 exp0 , doc (showString "<=>") , prt 2 exp])
   EImplies exp0 exp -> prPrec i 2 (concatD [prt 2 exp0 , doc (showString "=>") , prt 3 exp])
   EImpliesElse exp0 exp1 exp -> prPrec i 2 (concatD [prt 2 exp0 , doc (showString "=>") , prt 3 exp1 , doc (showString "else") , prt 3 exp])
   EOr exp0 exp -> prPrec i 3 (concatD [prt 3 exp0 , doc (showString "||") , prt 4 exp])
   EXor exp0 exp -> prPrec i 4 (concatD [prt 4 exp0 , doc (showString "xor") , prt 5 exp])
   EAnd exp0 exp -> prPrec i 5 (concatD [prt 5 exp0 , doc (showString "&&") , prt 6 exp])
   ENeg exp -> prPrec i 6 (concatD [doc (showString "~") , prt 7 exp])
   QuantExp quant exp -> prPrec i 7 (concatD [prt 0 quant , prt 7 exp])
   ELt exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "<") , prt 8 exp])
   EGt exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString ">") , prt 8 exp])
   EEq exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "=") , prt 8 exp])
   ELte exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "<=") , prt 8 exp])
   EGte exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString ">=") , prt 8 exp])
   ENeq exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "!=") , prt 8 exp])
   EIn exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "in") , prt 8 exp])
   ENin exp0 exp -> prPrec i 7 (concatD [prt 7 exp0 , doc (showString "not") , doc (showString "in") , prt 8 exp])
   EAdd exp0 exp -> prPrec i 8 (concatD [prt 8 exp0 , doc (showString "+") , prt 9 exp])
   ESub exp0 exp -> prPrec i 8 (concatD [prt 8 exp0 , doc (showString "-") , prt 9 exp])
   EMul exp0 exp -> prPrec i 9 (concatD [prt 9 exp0 , doc (showString "*") , prt 10 exp])
   EDiv exp0 exp -> prPrec i 9 (concatD [prt 9 exp0 , doc (showString "/") , prt 10 exp])
   ECSetExp exp -> prPrec i 10 (concatD [doc (showString "#") , prt 11 exp])
   EInt n -> prPrec i 10 (concatD [prt 0 n])
   EDouble d -> prPrec i 10 (concatD [prt 0 d])
   EStr str -> prPrec i 10 (concatD [prt 0 str])
   Union exp0 exp -> prPrec i 11 (concatD [prt 11 exp0 , doc (showString "++") , prt 12 exp])
   Difference exp0 exp -> prPrec i 11 (concatD [prt 11 exp0 , doc (showString "--") , prt 12 exp])
   Intersection exp0 exp -> prPrec i 12 (concatD [prt 12 exp0 , doc (showString "&") , prt 13 exp])
   Domain exp0 exp -> prPrec i 13 (concatD [prt 13 exp0 , doc (showString "<:") , prt 14 exp])
   Range exp0 exp -> prPrec i 14 (concatD [prt 14 exp0 , doc (showString ":>") , prt 15 exp])
   Join exp0 exp -> prPrec i 15 (concatD [prt 15 exp0 , doc (showString ".") , prt 16 exp])
   ClaferId name -> prPrec i 16 (concatD [prt 0 name])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print Decl where
  prt i e = case e of
   Decl disj locids exp -> prPrec i 0 (concatD [prt 0 disj , prt 0 locids , doc (showString ":") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Disj where
  prt i e = case e of
   DisjEmpty  -> prPrec i 0 (concatD [])
   Disj  -> prPrec i 0 (concatD [doc (showString "disj")])


instance Print Quant where
  prt i e = case e of
   QuantNo  -> prPrec i 0 (concatD [doc (showString "no")])
   QuantLone  -> prPrec i 0 (concatD [doc (showString "lone")])
   QuantOne  -> prPrec i 0 (concatD [doc (showString "one")])
   QuantSome  -> prPrec i 0 (concatD [doc (showString "some")])


instance Print ExQuant where
  prt i e = case e of
   ExQuantAll  -> prPrec i 0 (concatD [doc (showString "all")])
   ExQuantQuant quant -> prPrec i 0 (concatD [prt 0 quant])


instance Print EnumId where
  prt i e = case e of
   EnumIdIdent id -> prPrec i 0 (concatD [prt 0 id])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "|") , prt 0 xs])

instance Print ModId where
  prt i e = case e of
   ModIdIdent id -> prPrec i 0 (concatD [prt 0 id])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString "\\")])
   x:xs -> (concatD [prt 0 x , doc (showString "\\") , prt 0 xs])

instance Print LocId where
  prt i e = case e of
   LocIdIdent id -> prPrec i 0 (concatD [prt 0 id])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])


