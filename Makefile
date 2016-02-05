NAME  = mynsfc
SHELL = bash
PWD   = $(shell pwd)
TEMP := $(shell mktemp -d -t dtxgen.XXXXXXXXXX)
TDIR  = $(TEMP)/$(NAME)
VERS  = $(shell ltxfileinfo -v $(NAME).dtx)
LOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE = $(shell kpsewhich --var-value TEXMFHOME)
all:	$(NAME).pdf clean
	$(MAKE) -C examples all
$(NAME).pdf: $(NAME).dtx
	xelatex -shell-escape -recorder -interaction=batchmode $(NAME).dtx >/dev/null
	if [ -f $(NAME).glo ]; then makeindex -q -s gglo.ist -o $(NAME).gls $(NAME).glo; fi
	if [ -f $(NAME).idx ]; then makeindex -q -s gind.ist -o $(NAME).ind $(NAME).idx; fi
	xelatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null
	xelatex --recorder --interaction=nonstopmode $(NAME).dtx > /dev/null
clean:
	$(RM) $(NAME).{aux,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}
	$(MAKE) -C examples clean
distclean: clean
	$(RM) $(NAME).{pdf,cls}
	$(MAKE) -C examples distclean
inst: all
	mkdir -p $(UTREE)/{tex,source,doc}/xelatex/$(NAME)
	cp $(NAME).dtx $(UTREE)/source/xelatex/$(NAME)
	cp $(NAME).cls $(UTREE)/tex/xelatex/$(NAME)
	cp $(NAME).pdf $(UTREE)/doc/xelatex/$(NAME)
install: all
	sudo mkdir -p $(LOCAL)/{tex,source,doc}/xelatex/$(NAME)
	sudo cp $(NAME).dtx $(LOCAL)/source/xelatex/$(NAME)
	sudo cp $(NAME).cls $(LOCAL)/tex/xelatex/$(NAME)
	sudo cp $(NAME).pdf $(LOCAL)/doc/xelatex/$(NAME)
zip: all
	mkdir $(TDIR)
	cp $(NAME).{pdf,dtx} README.md $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
