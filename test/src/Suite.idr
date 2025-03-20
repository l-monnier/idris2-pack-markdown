module Suite

import IdrTest.Test

import Markdown.Format.HtmlTest
import Markdown.LexerTest
import MarkdownTest

suite : IO ()
suite = do
  runSuites
    [ Markdown.LexerTest.suite
    , MarkdownTest.suite
    , Markdown.Format.HtmlTest.suite
    ]
