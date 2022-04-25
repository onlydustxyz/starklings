.PHONY: build

build:
	protostar build --cairo-path lib/cairo_contracts/src

test:
	protostar test ./tests --cairo-path lib/cairo_contracts/src $(args)

date:
	date
	
cli: date
	sh ./cli/menu.sh