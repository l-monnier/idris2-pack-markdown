module Text.Markdown.Parser

import Text.Markdown.Lexer
import Text.Markdown.Data
import Text.Parser
import Text.Token
import Data.List

import public Text.Markdown.Tokens

-- Note: this is currently infinitely recursive
-- %default total

mutual
  private
  markdown : Grammar state MarkdownToken False Markdown
  markdown =
    do
      els <- many (
              (map Just header)
          <|> (map Just paragraph)
          <|> (map (const Nothing) $ newLine)
        )
      pure $ Doc (mapMaybe id els)

  private
  inline : Grammar state MarkdownToken True Inline
  inline =
    (
          text
      <|> pre
      <|> codeBlock
      <|> bold
      <|> italics
      <|> image
      <|> link
      <|> html
      <|> parts
    )

  -- TODO: Handle other incomplete parts
  parts : Grammar state MarkdownToken True Inline
  parts =
    map (const $ Text "!") (match ImageSym)

  wrapInline : MarkdownTokenKind -> (List Inline -> a) -> Grammar state MarkdownToken True a
  wrapInline sym tok =
    do
      start <- match sym
      contents <- some inline
      end <- match sym
      pure $ tok $ toList contents

  private
  header : Grammar state MarkdownToken True Block
  header =
    do
      level <- match HeadingSym
      commit -- TODO: Should we commit here?
      contents <- many inline
      blockTerminal
      pure $ Header level contents

  blockTerminal : Grammar state MarkdownToken False ()
  blockTerminal =
    (map (const ()) $ (some newLine)) <|>
    eof

  private
  newLine : Grammar state MarkdownToken True ()
  newLine =
    map (const ()) (match NewLine)

  private
  paragraph : Grammar state MarkdownToken True Block
  paragraph =
    do
      contents <- some inline
      blockTerminal
      pure $ Paragraph $ toList contents

  private
  text : Grammar state MarkdownToken True Inline
  text =
    map Text (match MdText)

  private
  pre : Grammar state MarkdownToken True Inline
  pre =
    map Pre (match MdPre)

  private
  codeBlock : Grammar state MarkdownToken True Inline
  codeBlock =
    map (uncurry CodeBlock) (match MdCodeBlock)

  private
  bold : Grammar state MarkdownToken True Inline
  bold =
    wrapInline BoldSym Bold

  private
  italics : Grammar state MarkdownToken True Inline
  italics =
    wrapInline ItalicsSym Italics

  private
  image : Grammar state MarkdownToken True Inline
  image =
    do
      match ImageSym
      r <- match MdLink
      buildImage r

  private
  buildImage : (String, String) -> Grammar state MarkdownToken False Inline
  buildImage (alt, src) =
    pure $ Image alt src

  private
  link : Grammar state MarkdownToken True Inline
  link =
    map (\(href, desc) => Link href desc) (match MdLink)

  private
  html : Grammar state MarkdownToken True Inline
  html =
    do
      openTag <- match HtmlOpenTag
      contents <- many inline
      closer openTag -- TODO: Is this inefficient?
      pure $ Html openTag contents

  private
  closer : String -> Grammar state MarkdownToken True ()
  closer tag =
    do
      closeTag <- match HtmlCloseTag
      checkTag closeTag tag

  private
  checkTag : String -> String -> Grammar state MarkdownToken False ()
  checkTag x y =
    if x == y
      then pure ()
      else fail "tag mismatch"

export
parseMarkdown : List MarkdownToken -> Maybe Markdown
parseMarkdown toks = 
  let 
    bounds = MkBounds 0 0 10000000 80
    boundedToks = map (\tok => MkBounded tok True bounds) toks
  in
  case parse markdown boundedToks of
    Right (j, []) => Just j
    _ => Nothing
