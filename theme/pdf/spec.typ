// The BFFO PDF. Overrides iyo's default `assets/pdf/spec.typ`, which it is
// otherwise a restyling of: the model contract, the internal cross-reference
// linking and the PDF/A requirements below are the default's and must stay.
//
// Typography is deliberately *not* Inter, though the website is. Typst embeds
// four font families -- Libertinus Serif, New Computer Modern, its maths
// companion, and DejaVu Sans Mono -- and none of them is a sans text face.
// Asking for Inter would make Typst fall back to whatever the machine happens
// to have installed, silently, so the same sources would produce a different
// PDF on a different machine and iyo's byte-identical rebuild would stop
// meaning anything. The brand is carried by colour, rule and layout instead,
// all of which are reproducible. Shipping Inter with this theme and building
// in two steps with `iyo pdf --font-path` is the alternative, and it is a
// decision about committing font binaries rather than about taste.

#let model = json("model.json")
#let site = model.site
#let doc = model.document
#let lang = site.at("lang", default: "en")

// Palette 2, the same values `tokens.toml` gives the HTML.
#let ink = rgb("#102A43")       // neutral-900
#let muted = rgb("#486581")     // neutral-600
#let brand = rgb("#003E6B")     // primary-900
#let accent = rgb("#0F609B")    // primary-700
#let wash = rgb("#F0F4F8")      // neutral-50
#let hairline = rgb("#C5D0DB")  // the HTML's own decorative rule
#let badge-bg = rgb("#B6E0FE")  // primary-100
#let badge-fg = rgb("#003E6B")  // primary-900, 7.93:1 on the above

#set document(
  title: doc.title,
  author: doc.creators.map(c => c.at("name", default: "")).filter(n => n != ""),
  keywords: (doc.at("prefix", default: ""),).filter(k => k != ""),
  description: doc.at("description", default: (value: "")).at("value", default: ""),
)
#set text(lang: lang, size: 10pt, fill: ink)
#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.6cm, bottom: 2.4cm),
  numbering: "1",
  header: context {
    // Suppressed on the title page, where it would sit above the title.
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: muted)
      grid(
        columns: (1fr, auto),
        align: (left, right),
        doc.at("prefix", default: doc.title),
        doc.at("version", default: ""),
      )
      v(-0.45em)
      line(length: 100%, stroke: 0.5pt + hairline)
    }
  },
  footer: context [
    #set text(size: 8pt, fill: muted)
    #doc.title
    #h(1fr)
    #counter(page).display("1 of 1", both: true)
  ],
)
#set par(justify: false, leading: 0.68em)
#set heading(numbering: none)

// Section openers ("Classes", "Object properties") get the brand band.
#show heading.where(level: 1): it => block(above: 1.8em, below: 1em, width: 100%)[
  #block(fill: brand, inset: (x: 10pt, y: 7pt), radius: 2pt, width: 100%)[
    #set text(size: 15pt, weight: 700, fill: white)
    #it.body
  ]
]
// A term. The rule down the left is what makes a run of them read as cards.
#show heading.where(level: 2): it => block(above: 1.5em, below: 0.6em)[
  #set text(size: 12.5pt, weight: 700, fill: brand)
  #it.body
]
#show heading.where(level: 3): it => block(above: 1.1em, below: 0.45em)[
  #set text(size: 10pt, weight: 600, fill: muted)
  #upper(it.body)
]
#show link: set text(fill: accent)
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt)

#let iri(value) = raw(value)

#let local_iris = doc.sections.map(s => s.terms.map(t => t.iri)).flatten()

// Do not name a variable `label` here: `label()` is the built-in that turns
// an IRI into an anchor, and shadowing it is what kept every cross-reference
// pointing at the web instead of at the page four sheets on.
#let reference(r) = {
  let name = r.at("label", default: r.at("iri", default: ""))
  let target = r.at("iri", default: "")
  if target != "" and local_iris.contains(target) {
    link(label(target), name)
  } else if "url" in r {
    link(r.url, name)
  } else {
    name
  }
}

#let references(list) = list.map(reference).join(", ")

#let badge(body) = box(
  fill: badge-bg,
  inset: (x: 5pt, y: 2.5pt),
  radius: 2pt,
  text(size: 7.5pt, weight: 600, fill: badge-fg, upper(body)),
)

// A definition list. Labels are muted and small; the values carry the weight.
#let facts(rows) = {
  if rows.len() == 0 { return }
  block(above: 0.6em, below: 1em, width: 100%, grid(
    columns: (8.5em, 1fr),
    row-gutter: 0.5em,
    column-gutter: 0.8em,
    ..rows.map(((name, value)) => (
      text(size: 8.5pt, weight: 600, fill: muted, upper(name)),
      value,
    )).flatten(),
  ))
}

// --- title page ------------------------------------------------------------

#block(above: 2.5em, below: 0.6em, text(size: 26pt, weight: 700, fill: brand, doc.title))
#line(length: 100%, stroke: 2pt + brand)

#if "description" in doc [
  #block(above: 1em, below: 0.4em, text(size: 11.5pt, fill: muted, doc.description.value))
]

#block(above: 1.6em, width: 100%, fill: wash, inset: 12pt, radius: 3pt)[
  #facts((
    ("Namespace", iri(doc.namespace)),
    ..if "prefix" in doc { (("Preferred prefix", raw(doc.prefix)),) } else { () },
    ..if "version_iri" in doc { (("This version", link(doc.version_iri, doc.version_iri)),) } else { () },
    ..if "status" in doc { (("Status", doc.status),) } else { () },
    ..if "modified" in doc { (("Modified", doc.modified),) } else { () },
    ..if "license" in doc { (("Licence", link(doc.license, doc.license)),) } else { () },
    ("Terms", str(doc.term_count)),
    ("Documentation", link(site.base_url, site.base_url)),
  ))
]

#if doc.abstract_paragraphs.len() > 0 [
  #block(above: 1.8em, below: 0.6em, text(size: 13pt, weight: 700, fill: brand)[About this vocabulary])
  #for paragraph in doc.abstract_paragraphs [ #par(paragraph) ]
]

#pagebreak()
#block(below: 0.8em, text(size: 15pt, weight: 700, fill: brand)[Contents])
#show outline.entry.where(level: 1): it => { v(0.35em, weak: true); strong(it) }
#outline(title: none, depth: 2, indent: 1.1em)

// --- terms -----------------------------------------------------------------

#for section in doc.sections [
  #pagebreak()
  = #section.title

  #for term in section.terms [
    == #term.label
    #label(term.iri)

    #block(above: -0.2em, below: 0.6em)[
      #badge(term.kind)
      #h(0.5em)
      #if "curie" in term { raw(term.curie) }
    ]

    #facts((
      ("IRI", iri(term.iri)),
      ..if term.super_terms.len() > 0 { (("Sub-class of", references(term.super_terms)),) } else { () },
      ..if term.property.domain.len() > 0 { (("Domain", references(term.property.domain)),) } else { () },
      ..if term.property.range.len() > 0 { (("Range", references(term.property.range)),) } else { () },
      ..if term.concept.broader.len() > 0 { (("Broader", references(term.concept.broader)),) } else { () },
      ..if "status" in term { (("Status", term.status),) } else { () },
    ))

    #if term.deprecated [
      #block(fill: rgb("#FFF3C4"), inset: 9pt, radius: 3pt, width: 100%)[
        #text(weight: 700)[Deprecated.]
        #if term.replaced_by.len() > 0 [ Use #references(term.replaced_by). ]
      ]
    ]

    #if "definition" in term [ #par(term.definition.value) ]

    #for note in term.notes [ #par(text(size: 9pt, fill: muted, note.value)) ]

    #for view in term.shapes [
      === Record template: #view.shape.label
      #text(size: 8.5pt, fill: muted)[Applies to #view.targeting.]
      #block(above: 0.5em, table(
        columns: (1fr, 1fr, auto),
        stroke: 0.5pt + hairline,
        inset: 6pt,
        fill: (_, row) => if row == 0 { wash } else { none },
        table.header(
          text(size: 8.5pt, weight: 700, fill: brand)[Field],
          text(size: 8.5pt, weight: 700, fill: brand)[Values],
          text(size: 8.5pt, weight: 700, fill: brand)[Count],
        ),
        ..view.fields.map(f => (
          [#f.name#if f.required [ #text(size: 7.5pt, fill: muted)[(required)]]
           #if "description" in f [\ #text(size: 8pt, fill: muted, f.description)]],
          [#f.value_type#if f.in_scheme.len() > 0 [ #text(size: 8pt, fill: muted)[from #references(f.in_scheme)]]],
          [#f.at("cardinality", default: "any")],
        )).flatten(),
      ))
    ]

    #if term.constraints.len() > 0 [
      #facts(term.constraints.map(c => (
        "Constrained by",
        [#reference(c.shape)#if "cardinality" in c [, #c.cardinality]#if c.required [, required]],
      )))
    ]
  ]
]
