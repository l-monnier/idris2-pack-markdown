## Markdown

Pack Mardown is a fork of [Inigo Markdown](https://github.com/bbarker/inigo/tree/master/Base/Markdown).
It is a markdown parser and renderer for Idris2.

The library can be installed with [Pack](https://github.com/stefan-hoeck/idris2-pack).

## Getting Started

The package name is `idris2-pack-markdown`.

To install it from Pack package collection, run:

```sh
pack install idris2-pack-markdown
``` 

## Parsing and Rendering

You can simply run `parse` to parse Markdown text:

```haskell
import Text.Markdown

parse "# Hello world\n\nHow are _you_?"

> Just Doc
	[ Header 1 [ Text "Hello world" ]
	, Paragraph [ Text "How are ", Italics "you", Text "?" ]
	]
```

Then you can render that doc to Html.

```haskell
import Text.Markdown
import Text.Markdown.Format.Html

map toHtml $ parse "# Hello world\n\nHow are _you_?"

> Just "<h1>Hello world</h1>\n<p>How are <em>you</em>!</p>"
```

## Supported Features

* Headers `#`
* Paragraphs
* Text
* Italics `_`
* Bold `**`
* Links `[]()`
* Images `![]()`
* Html `<>` (Basic Support)
* Preformatted Text
* Code Fences

## Contributing

There are a lot of features to add and support, so feel free to contribute and improve this library. Please make an issue for any bugs.

## Changelog

* `0.1.1` - Remove the `Text.Markdown.Format.Text` module
* `0.1.0` - Standalone library compatible with Pack
* `0.0.4` - Fix issues regarding whitespace
* `0.0.3` - Add support for `pre` and code blocks
* `0.0.2` - Fix non-HTML brackets
* `0.0.1` - Initial commit

## License

This code is licensed under the MIT license. All contributors must release all code under this same license.
