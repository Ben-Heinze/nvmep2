;;; org-pdf-export.el --- Batch org -> PDF export for nvim -*- lexical-binding: t; -*-
;;
;; Loaded (via `emacs --batch -l`) by nvim/lua/user/org_pdf.lua to render the
;; current org buffer to a PDF that is opened in zathura. Its main job beyond a
;; plain `ox-latex' export is to inject the editor's rainbow `hl' palette into
;; the LaTeX preamble so that {{{hl(colour,text)}}} highlights survive in the
;; PDF (they otherwise vanish, being HTML-only export snippets).

(require 'ox-latex)
(require 'oc)
(require 'oc-natbib)

;; LuaLaTeX (not pdflatex) so the pgf `graphdrawing' engine can auto-position
;; `\graph' nodes -- this is global to every org export here. xcolor and the
;; `hl' palette below all work identically under LuaLaTeX.
;;
;; Citations use org-cite's `natbib' processor (not `biblatex') because
;; `biblatex' needs the `biber' backend, which isn't installed here --
;; `natbib' only needs plain `bibtex', which `latexmk' (picked automatically
;; by `org-latex-pdf-process' since it's on PATH) already knows how to invoke
;; as an extra pass when it sees `\bibliography{}' in the .aux file.
(setq org-confirm-babel-evaluate nil
      org-export-with-broken-links t
      org-latex-compiler "lualatex"
      org-cite-export-processors '((latex natbib))
      ;; A single shared bibliography for every note, so `[cite:@key]' works
      ;; without each org file needing its own `#+bibliography:' line.
      org-cite-global-bibliography (list (expand-file-name "~/projects/yappopotamus/main.bib")))

;; Palette mirrors nvim/plugin/note-highlight.lua and
;; ~/projects/yappopotamus/static/style.css -- keep the three in sync.
;; `org-latex-packages-alist' accepts raw preamble strings, so this applies to
;; every exported file without needing a per-file #+LATEX_HEADER.
(setq org-latex-packages-alist
      (append org-latex-packages-alist
              (list
               "\\usepackage{xcolor}"
               "\\definecolor{hlred}{HTML}{F7768E}"
               "\\definecolor{hlorange}{HTML}{FF9E64}"
               "\\definecolor{hlyellow}{HTML}{E0AF68}"
               "\\definecolor{hlgreen}{HTML}{9ECE6A}"
               "\\definecolor{hlcyan}{HTML}{7DCFFF}"
               "\\definecolor{hlblue}{HTML}{7AA2F7}"
               "\\definecolor{hlpurple}{HTML}{BB9AF7}"
               ;; \hl{colour}{text}: coloured + bold, mirroring the editor extmarks.
               "\\newcommand{\\hl}[2]{\\textcolor{hl#1}{\\textbf{#2}}}"
               ;; TikZ + auto-layout for the graph snippets (snippets_tikz.lua).
               ;; graphdrawing needs LuaLaTeX (set above); quotes gives edge labels.
               "\\usepackage{tikz}"
               "\\usetikzlibrary{graphs, graphdrawing, quotes, arrows.meta, positioning}"
               "\\usegdlibrary{force, layered, trees, circular}")))

(provide 'org-pdf-export)
;;; org-pdf-export.el ends here
