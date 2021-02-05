client_elm_out=./bin/main.js
elm_compress='pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe'
assets_out=./bin

ghi_elm_out=./main.js

all:
	make elm
	make assets

github-io:
	make elm-ghi
	cp -R ./site/. ./

elm:
	elm make ./src/Main.elm --optimize --output=$(client_elm_out)
	terser $(client_elm_out) --compress $(elm_compress) | terser --mangle --output $(client_elm_out)

elm-ghi:
	elm make ./src/Main.elm --optimize --output=$(ghi_elm_out)
	terser $(ghi_elm_out) --compress $(elm_compress) | terser --mangle --output $(ghi_elm_out)

debug:
	elm make ./src/Main.elm --output=$(client_elm_out)

assets:
	cp -R ./site/. $(assets_out)

