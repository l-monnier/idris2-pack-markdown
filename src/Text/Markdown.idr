module Text.Markdown

import Text.Markdown.Lexer
import Text.Markdown.Parser

import public Text.Markdown.Data

-- TODO: not total at the moment
%default total

||| Parse a Markdown string
export
partial
parse : String -> Maybe Markdown
parse x = parseMarkdown !(lexMarkdown x)
