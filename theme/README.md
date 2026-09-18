# BFFO theme for `iyo`

A demonstration theme, not the final BFFO brand. It exists to show that the
tool's theme layer can carry a real house style, and to find out what a theme
actually needs, which is the evidence a theme *package* format should be
designed from.

## What is here

| | |
| --- | --- |
| `tokens.toml` | the palette, merged over `iyo`'s defaults |
| `assets/bffo.css` | the site header and footer, Tailwind translated to plain CSS |
| `templates/base.html.jinja` | the layout, replacing the embedded one |

Build with it:

```sh
iyo build ontology/bffo.ttl ontology/bffo-shapes.ttl 'vocabularies/*.ttl' \
    --out dist --config iyo.toml --theme theme
```

`iyo.toml` carries `base_url`, the documentation licence, and
`external_paths` -- the paths on `bffo.org` that belong to the website rather
than to this build.

## The palette is the website's, with three exceptions

Colours come from Refactoring UI Palette 2, the same set
`bffo-webapp/src/app.css` declares, so the documentation and the site are the
same blues rather than two people's idea of blue.

Three of the website's own values do not pass `iyo`'s build-time contrast
gate, which refuses to write a site whose colour pairs fail WCAG. Each is
recorded beside the value it replaced in `tokens.toml`, with the measured
ratio. None is a disagreement with the brand: the website uses those colours
in places the rules do not reach, and documentation uses them for table
rules, focus rings and status banners, where they do.

## The chrome links to the website absolutely

Browse, Categories, Domains, Organizations, About and the BFFO wordmark all
point at `https://bffo.org/`. They are cross-property links: a different
application that exists only there, and that this build does not contain.

Everything *inside* the documentation stays relative, so the tree browses
from any host, any subdirectory, or a bare filesystem. The two are separate
on purpose -- `iyo` governs how its own output addresses itself, and where
the surrounding website lives is a fact about the deployment.

There is no search box. The website's is a client-side index over formats;
this tree ships `terms.json` and no JavaScript, and a box that looked the
same and did nothing would be worse than its absence.
