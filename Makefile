include common.mk

TEXDIRS=titlepage \
abstract \
declaration \
content/introduction \
content/conclusion \
content/reschap1 \
content/reschap2 \
content/reschap3
# add more directories here, e.g. directories for result chapters...

IMAGEDIRS=content/reschap1/images \
content/reschap2/images \
content/reschap3/images

CLEANDIRS = $(IMAGEDIRS:%=clean-%)

THESIS=phd_thesis

SEARCH=

.PHONY: texdirs $(TEXDIRS)
.PHONY: imagedirs $(IMAGEDIRS)
.PHONY: cleandirs $(CLEANDIRS)
.PHONY: all
.PHONY: fullthesis
.PHONY: thesis
.PHONY: run
.PHONY: bib
.PHONY: ref
.PHONY: spellcheck
.PHONY: clean
.PHONY: allclean

default: thesis

imagedirs: $(IMAGEDIRS)
$(IMAGEDIRS):
	@$(MAKE) -C $@ all

fullthesis: allclean imagedirs ref thesis

thesis:run bib
	@if fgrep ${LATEXMISSCITATION} ${THESIS}.log; then make run; fi
	@if fgrep ${LATEXCITATIONCHG} ${THESIS}.log; then make run; fi
	@if fgrep ${LATEXRERUN} ${THESIS}.log; then make run; fi
	@if fgrep ${LATEXMULTIPLELABEL} ${THESIS}.log; then make run; fi
	@if fgrep ${LATEXLABELCHG} ${THESIS}.log; then make run; fi
	@make warnings

run:
	@${LATEX} ${LATEXOPT} ${THESIS}

bib:ref
	test -s ${THESIS}.aux || { echo "${THESIS}.aux not found. Running LaTeX on ${THESIS}.tex ..."; make run; }
	@${BIBTEX} ${THESIS}

ref:
	@$(MAKE) -C references all

warnings:
	@if fgrep ${LATEXWARNING} ${THESIS}.log; then echo "+++ The following warnings were found +++"; ${FGREP} ${LATEXWARNING} ${THESIS}.log; else echo "+++ No warnings found +++"; fi
	@if fgrep ${LATEXOFULL} ${THESIS}.log; then echo "+++ The following OVERFULL boxes were found +++"; ${FGREP} -B 1 ${LATEXOFULL} ${THESIS}.log; else echo "+++ No overfull boxes found +++"; fi
	@if fgrep ${LATEXUFULL} ${THESIS}.log; then echo "+++ The following UNDERFULL boxes were found +++"; ${FGREP} -B 1 ${LATEXUFULL} ${THESIS}.log; else echo "+++ No underfull boxes found +++"; fi
	@if fgrep ${LATEXBADNESS} ${THESIS}.log; then echo "+++ The following BADNESS warnings were found +++"; ${FGREP} -B 1 ${LATEXBADNESS} ${THESIS}.log; else echo "+++ No badness warnings found +++"; fi
	@if fgrep ${LATEXMULTIPLELABEL} ${THESIS}.log; then echo "+++ FIX YOUR LABELS! Exiting +++"; ${GREP} ${LATEXMULTIPLYLABELS} ${THESIS}.log; ${FGREP} ${LATEXMULTIPLELABEL} ${THESIS}.log; fi
	@if fgrep ${LATEXMISSCITATION} ${THESIS}.log; then echo "+++ STILL MISSING CITATIONS, FIX YOUR BIB-FILES +++"; ${FGREP} ${LATEXMISSCITATION} ${THESIS}.log; fi
	@if fgrep ${LATEXRERUN} ${THESIS}.log; then echo "+++ Rerun ${LATEX} to get rid of some warnings +++"; fi

spellcheck: texdirs
	@echo "spell check on ${THESIS}.tex"
	sleep 3
	@${ASPELL} $(ASPELLOPT) ${THESIS}.tex

texdirs: $(TEXDIRS)
$(TEXDIRS):
	@$(MAKE) -C $@ spellcheck

texcount:
	@${TEXCOUNT} ${TEXCOUNTOPT} ${THESIS}.tex
	@echo "and pdftops ... ps2ascii: "
	pdftops ${THESIS}.pdf; ps2ascii ${THESIS}.ps | wc -w

clean:
	@-rm *.aux *.log *.blg *.bbl *.lof *.lot *.toc *.fff *.out *~

allclean: clean $(CLEANDIRS)
$(CLEANDIRS): 
	@echo "cleaning directory $(@:clean-%=%):"
	@$(MAKE) -C $(@:clean-%=%) allclean

search:
	@echo "searching all texfiles for $(SEARCH):"
	@find . -name "*.tex" | xargs grep -i --color=auto $(SEARCH)

