# Test rendering of doc chunks
content = """
# Test chunk

Test rendering \$\alpha\$
"""

dchunk = Weave.DocChunk(content, 1, 1)

pformat = Weave.formats["github"]
f = Weave.format_chunk(dchunk, pformat.formatdict, pformat)
@test f == content

docformat = Weave.formats["md2html"]
f_check = "<h1>Test chunk</h1>\n<p>Test rendering <span class=\"math\">\$\alpha\$</span></p>\n"
f = Weave.format_chunk(dchunk, docformat.formatdict, docformat)
@test f_check == f

# Test with actual doc

parsed = Weave.WeaveDoc("documents/chunk_options.noweb")
doc = run_doc(parsed, doctype = "md2html")

c_check = "<pre class='hljl'>\n<span class='hljl-n'>x</span><span class='hljl-t'> </span><span class='hljl-oB'>=</span><span class='hljl-t'> </span><span class='hljl-p'>[</span><span class='hljl-ni'>12</span><span class='hljl-p'>,</span><span class='hljl-t'> </span><span class='hljl-ni'>10</span><span class='hljl-p'>]</span><span class='hljl-t'>\n</span><span class='hljl-nf'>println</span><span class='hljl-p'>(</span><span class='hljl-n'>y</span><span class='hljl-p'>)</span>\n</pre>\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[3].content, doc.format)
@test c_check == c

o_check = "\nprintln&#40;x&#41;\n"
o = Weave.format_output(doc.chunks[4].content, doc.format)
@test o_check == o

doc.template = "templates/mini.tpl"
rendered = Weave.render_doc("Hello", doc)
@test rendered == "\nHello\n"

# Tex format
parsed = Weave.WeaveDoc("documents/chunk_options.noweb")
doc = run_doc(parsed, doctype = "md2tex")

c_check = "\\begin{lstlisting}\n(*@\\HLJLnf{println}@*)(*@\\HLJLp{(}@*)(*@\\HLJLn{x}@*)(*@\\HLJLp{)}@*)\n\\end{lstlisting}\n"
doc.format.formatdict[:theme] = doc.highlight_theme
c = Weave.format_code(doc.chunks[4].content, doc.format)
@test c_check == c

o_check = "\nx = [12, 10]\nprintln(y)\n"
o = Weave.format_output(doc.chunks[3].content, doc.format)
@test o_check == o

doc.template = "templates/mini.tpl"
rendered = Weave.render_doc("Hello", doc)
@test rendered == "\nHello\n"

# Test wrapping

cows = repeat("🐄", 100)
testcows = """
🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄
🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄"""

wcows = Weave.wrapline(cows)

@test wcows == testcows
@test length(split(wcows, "\n")[1]) == 75
@test length(split(wcows, "\n")[2]) == 25


tfied = "\\ensuremath{\\bm{\\mathrm{L}}} \\ensuremath{\\bm{\\mathfrak{F}}} \\ensuremath{\\bm{\\iota}} \\ensuremath{\\mathfrak{A}} \\ensuremath{\\bm{\\varTheta}}"

@test Weave.uc2tex("𝐋 𝕱 𝛊 𝔄 𝚹") == tfied

# Test markdown output from chunks
parsed = Weave.WeaveDoc("documents/markdown_output.jmd")
doc = run_doc(parsed, doctype = "md2html")
@test doc.chunks[1].rich_output == "\n<div class=\"markdown\"><h3>Small markdown sample</h3>\n<p><strong>Hello</strong> from <code>code</code> block.</p>\n</div>"
@test doc.chunks[2].rich_output == "\n<div class=\"markdown\"><ul>\n<li><p>one</p>\n</li>\n<li><p>two</p>\n</li>\n<li><p>three</p>\n</li>\n</ul>\n</div>"

ldoc = run_doc(parsed, doctype = "md2tex")
@test ldoc.chunks[1].rich_output == "\n\\subsubsection{Small markdown sample}\n\\textbf{Hello} from \\texttt{code} block.\n\n"
@test ldoc.chunks[2].rich_output == "\n\\begin{itemize}\n\\item one\n\n\n\\item two\n\n\n\\item three\n\n\\end{itemize}\n"

mdoc = run_doc(parsed, doctype = "github")
@test mdoc.chunks[1].rich_output == "\n\n### Small markdown sample\n\n**Hello** from `code` block.\n\n"
@test mdoc.chunks[2].rich_output == "\n\n* one\n* two\n* three\n\n"


# Test disable escaping of unicode
content = """
# Test chunk
α
"""

dchunk = Weave.DocChunk(content, 1, 1)

pformat = Weave.formats["md2tex"]

f = Weave.format_chunk(dchunk, pformat.formatdict, pformat)
@test f == "\\section{Test chunk}\n\\ensuremath{\\alpha}\n\n"
pformat.formatdict[:keep_unicode] = true
f = Weave.format_chunk(dchunk, pformat.formatdict, pformat)
@test f == "\\section{Test chunk}\nα\n\n"


str = """
```julia
α = 10
```
"""

let
    doc = run_doc(mock_doc(str), doctype = "md2tex")
    @test occursin(Weave.uc2tex("α"), Weave.format(doc))
    @test !occursin("α", Weave.format(doc))
end

let
    doc = run_doc(mock_doc(str), doctype = "md2tex",latex_keep_unicode = true)
    @test occursin("α", Weave.format(doc))
    @test !occursin(Weave.uc2tex("α"), Weave.format(doc))
end
