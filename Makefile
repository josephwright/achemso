################################################################
################################################################
# Makefile for achemso                                         #
################################################################
################################################################

.SILENT:

################################################################
# Default with no target is to give help                       #
################################################################

help:
	@echo ""
	@echo " make clean               - clean out test directory"
	@echo " make ctan                - create a CTAN-ready archive"
	@echo " make doc                 - typeset documentation"
	@echo " make localinstall        - install files in local texmf tree"
	@echo " make tds                 - create a TDS-ready archive"
	@echo " make unpack              - extract packages"
	@echo ""
	
##############################################################
# Master package name                                        #
##############################################################

PACKAGE = achemso

##############################################################
# Directory structure for making zip files                   #
##############################################################

CTANROOT := ctan
CTANDIR  := $(CTANROOT)/$(PACKAGE)
TDSDIR   := tds

##############################################################
# Data for local installation and TDS construction           #
##############################################################

INCLUDEPDF  := $(PACKAGE)
INCLUDETEX  := $(PACKAGE)-demo
INCLUDETXT  := README
PACKAGEROOT := latex/$(PACKAGE)

##############################################################
# Details of source files                                    #
##############################################################

DTX      = $(PACKAGE).dtx
DTXFILES = $(PACKAGE)
UNPACK   = $(PACKAGE).dtx

##############################################################
# Clean-up information                                       #
##############################################################

AUXFILES = \
	aux  \
	bbl  \
	blg  \
	cmds \
	glo  \
	gls  \
	hd   \
	idx  \
	ilg  \
	ind  \
	log  \
	out  \
	tmp  \
	toc  \
	xref
	
CLEAN = \
	bib \
	bst \
	cfg \
	cls \
	gz  \
	ins \
	pdf \
	sty \
	tex \
	txt \
	zip 

################################################################
# PDF Settings                                                 #
################################################################

PDFSETTINGS = \
	\pdfminorversion=5  \
	\pdfcompresslevel=9 \
	\pdfobjcompresslevel=2
	
################################################################
# File building: default actions                               #
################################################################

%.pdf: %.dtx
	NAME=`basename $< .dtx` ; \
	echo "Typesetting $$NAME" ; \
	pdflatex -draftmode -interaction=nonstopmode "$(PDFSETTINGS) \AtBeginDocument{\OnlyDescription} \input $<" &> /dev/null ; \
	if [ $$? = 0 ] ; then  \
	  bibtex8 --wolfgang $$NAME.aux &> /dev/null ; \
	  makeindex -s gglo.ist -o $$NAME.gls $$NAME.glo &> /dev/null ; \
	  makeindex -s gind.ist -o $$NAME.ind $$NAME.idx &> /dev/null ; \
	  pdflatex -interaction=nonstopmode "$(PDFSETTINGS) \AtBeginDocument{\OnlyDescription} \input $<" &> /dev/null ; \
	  makeindex -s gglo.ist -o $$NAME.gls $$NAME.glo &> /dev/null ; \
	  makeindex -s gind.ist -o $$NAME.ind $$NAME.idx &> /dev/null ; \
	  pdflatex -interaction=nonstopmode "$(PDFSETTINGS) \AtBeginDocument{\OnlyDescription} \input $<" &> /dev/null ; \
	else \
	  echo "  Complilation failed" ; \
	fi ; \
	for I in $(AUXFILES) ; do \
	  rm -f $$NAME.$$I ; \
	done

################################################################
# File building: special files                                 #
################################################################

achemso-demo.pdf:
	echo "Typesetting achemso-demo" ; \
	pdflatex -draftmode -interaction=nonstopmode "$(PDFSETTINGS) \input achemso-demo" &> /dev/null ; \
	if [ $$? = 0 ] ; then  \
	  bibtex8 --wolfgang achemso-demo.aux &> /dev/null ; \
	  pdflatex -interaction=nonstopmode "$(PDFSETTINGS) \input achemso-demo" &> /dev/null ; \
	  pdflatex -interaction=nonstopmode "$(PDFSETTINGS) \input achemso-demo" &> /dev/null ; \
	else \
	  echo "  Complilation failed" ; \
	fi ; \
	for I in $(AUXFILES) ; do \
	  rm -f achemso-demo.$$I ; \
	done
	
################################################################
# User make options                                            #
################################################################

.PHONY = \
	clean        \
	ctan         \
	doc          \
	localinstall \
	tds          \
	unpack
	
clean:
	echo "Cleaning up"
	for I in $(AUXFILES) $(CLEAN) ; do \
	  rm -f *.$$I ; \
	done
	rm -rf $(CTANROOT)/
	rm -rf $(TDSDIR)/
	
ctan: tds
	echo "Creating CTAN archive"
	mkdir -p $(CTANDIR)/
	rm -rf $(CTANDIR)/*
	cp -f *.dtx $(CTANDIR)/ ; \
	cp -f *.ins $(CTANDIR)/ ; \
	for I in $(INCLUDEPDF) ; do \
	  cp -f $$I.pdf $(CTANDIR)/ ; \
	done ; \
	for I in $(INCLUDETEX); do \
	  cp -f $$I.pdf $(CTANDIR)/ ; \
	  cp -f $$I.tex $(CTANDIR)/ ; \
	done ; \
	for I in $(INCLUDETXT); do \
	  cp -f $$I.txt $(CTANDIR)/; \
	  mv $(CTANDIR)/$$I.txt $(CTANDIR)/$$I ; \
	done ; \
	cp $(PACKAGE).tds.zip $(CTANDIR)/ 
	cd $(CTANDIR) ; \
	zip -ll -q -r -X $(PACKAGE).zip .
	cp $(CTANDIR)/$(PACKAGE).zip ./
	rm -rf $(CTANROOT)/
	
doc: \
	$(foreach FILE,$(INCLUDEPDF),$(FILE).pdf) \
	$(foreach FILE,$(INCLUDETEX),$(FILE).pdf) \
	
localinstall: unpack
	echo "Installing files"
	TEXMFHOME=`kpsewhich --var-value=TEXMFHOME` ; \
	rm -rf $$TEXMFHOME/tex/$(PACKAGEROOT)/*.* ; \
	cp *.sty $$TEXMFHOME/tex/$(PACKAGEROOT)/ ; \
	texhash &> /dev/null
	
tds: doc
	echo "Creating TDS archive"
	mkdir -p $(TDSDIR)/
	rm -rf $(TDSDIR)/*
	mkdir -p $(TDSDIR)/bibtex/bst/$(PACKAGE)/
	mkdir -p $(TDSDIR)/doc/$(PACKAGEROOT)/
	mkdir -p $(TDSDIR)/tex/$(PACKAGEROOT)/config/
	mkdir -p $(TDSDIR)/source/$(PACKAGEROOT)/
	cp -f *.bst $(TDSDIR)/bibtex/bst/$(PACKAGE)/ ; \
	cp -f *.cfg $(TDSDIR)/tex/$(PACKAGEROOT)/config/ ; \
	cp -f *.cls $(TDSDIR)/tex/$(PACKAGEROOT)/  ; \
	cp -f *.dtx $(TDSDIR)/source/$(PACKAGEROOT)/ ; \
	cp -f *.ins $(TDSDIR)/source/$(PACKAGEROOT)/ ; \
	for I in $(INCLUDEPDF) ; do \
	  cp -f $$I.pdf $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	done ; \
	cp -f *.sty $(TDSDIR)/tex/$(PACKAGEROOT)/ ; \
	for I in $(INCLUDETEX); do \
	  cp -f $$I.bib $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  cp -f $$I.pdf $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  cp -f $$I.tex $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	done ; \
	for I in $(INCLUDETXT); do \
	  cp -f $$I.txt $(TDSDIR)/doc/$(PACKAGEROOT)/ ; \
	  mv $(TDSDIR)/doc/$(PACKAGEROOT)/$$I.txt $(TDSDIR)/doc/$(PACKAGEROOT)/$$I ; \
	done 
	cd $(TDSDIR) ; \
	zip -ll -q -r -X $(PACKAGE).tds.zip .
	cp $(TDSDIR)/$(PACKAGE).tds.zip ./
	rm -rf $(TDSDIR)
	
unpack: 
	echo "Unpacking files"
	for I in $(UNPACK) ; do \
	  tex $$I &> /dev/null ; \
	done