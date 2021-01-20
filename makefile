client_elm_out=./bin/main.js
elm_compress='pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe'
assets_out=./bin
local_storage_out=./bin/local-storage.js

all:
	make elm
	make assets

elm:
	elm make ./src/Main.elm --optimize --output=$(client_elm_out)
	terser $(client_elm_out) --compress $(elm_compress) | terser --mangle --output $(client_elm_out)

elm-debug:
	elm make ./src/Main.elm --output=$(client_elm_out)

assets:
	cp -R ./site/. $(assets_out)
