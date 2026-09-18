# iyo-demo

Example output from [iyo](https://github.com/bffo-project/iyo), the vocabulary
publishing tool. One small vocabulary is built twice, by the same version of the
tool, from identical inputs. Only `--theme` differs.

**<https://bffo-project.github.io/iyo-demo/>**

| | |
| --- | --- |
| [Default theme](https://bffo-project.github.io/iyo-demo/default/) | what iyo produces with nothing configured |
| [BFFO theme](https://bffo-project.github.io/iyo-demo/bffo/) | a house style supplied as a directory of overrides |

## What is worth looking at

Any term page, then the `.md`, `.ttl` and `.jsonld` files sharing its stem: one
term, four representations, at predictable URLs. Each site root also carries
`llms.txt` written for agents, `manifest.json` describing the content
negotiation the site would need, `versions.json`, and `a11y/` holding the
build's own accessibility audit as data.

Both sites are built with `--snapshots all`, so each namespace also appears
under a version segment, which is what lets an `owl:versionIRI` resolve to the
release it names.

## What this demo cannot show

GitHub Pages serves files and cannot negotiate content. Asking these sites for
`text/turtle` will not redirect you to the Turtle file. That is a property of
the host rather than of iyo: the negotiation contract is in each site's
`manifest.json`, and iyo compiles it into configuration for hosts that can act
on it. Both sites are therefore built with `--link-style file`, so links point
at documents that exist.

## The vocabulary

A sample written for this demo. It describes nothing real, and its terms are
identified by `example.org` IRIs that do not resolve anywhere. Both sites
publish those same identifiers, which is the point iyo is built around: what a
term *is* does not change because its documents are served from somewhere else.

It passes `iyo check --strict` with no warnings, so the demo shows a well-formed
release rather than a flawed one.

## Building it yourself

```console
$ cargo install --locked iyo
$ iyo build vocabulary --out _site/default \
    --base-url https://bffo-project.github.io/iyo-demo/default/ \
    --link-style file --snapshots all --strict
$ iyo build vocabulary --out _site/bffo \
    --base-url https://bffo-project.github.io/iyo-demo/bffo/ \
    --link-style file --snapshots all --theme theme --strict
```

`.github/workflows/pages.yml` runs exactly that on every push, installing iyo
from crates.io rather than from a checkout. A green run is therefore also
evidence that the published crate builds what this page claims it builds.

## What is here

| | |
| --- | --- |
| `vocabulary/` | the sample vocabulary: a root ontology, a SKOS scheme, SHACL shapes |
| `theme/` | the BFFO theme, copied from [bffo-ontology](https://github.com/bffo-project/bffo-ontology) |
| `landing/` | the page at the site root |
| `.github/workflows/pages.yml` | build and deploy |

## Licence

Dual, as [LICENSE](LICENSE) sets out: CC0 for the sample vocabulary, CC-BY-4.0
for everything else.
