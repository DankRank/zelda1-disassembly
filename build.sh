#!/bin/sh
set -eu
no_verify=
no_extract=
quiet=
diff=
rev1=
asflags=
origrom='ext/Legend of Zelda, The (USA).nes'
while [ $# -gt 0 ]; do
	case "$1" in
		--no-verify) no_verify=1;;
		--quiet) quiet=1;;
		--no-extract) no_extract=1;;
		--diff) diff=1;;
		--rev1) rev1=1 asflags=-DREV1 origrom='ext/Legend of Zelda, The (USA) (Rev 1).nes';;
		--ce) rev1=1 asflags=-DREV1\ -DZELDACE origrom='ext/Legend of Zelda, The (USA) (GameCube Edition).nes';;
		--ac) rev1=1 asflags=-DREV1 origrom='ext/Legend of Zelda, The (USA) (Rev 1) (GameCube Edition).nes';;
		--vc) rev1=1 asflags=-DREV1\ -DZELDACE\ -DZELDAVC origrom='ext/Legend of Zelda, The (USA) (Rev 1) (Virtual Console).nes';;
		*) echo "Unknown argument $1"; exit 1;;
	esac
	shift
done
mkdir -p obj bin
test -z "$no_extract" && sed -n '/<Binary /{s!<Binary !!;s!/>!!;s!\r!!g;p}' src/bins.xml | while IFS= read -r line; do
	unset Offset Length FileName Rev1Offset Rev1Length
	eval "$line"
	: "${Offset:?} ${Length:?} ${FileName:?}"
	mkdir -p "$(dirname "bin/$FileName")"
	test -n "$rev1" && Offset=${Rev1Offset:-$Offset} Length=${Rev1Length:-$Length}
	tail -c "+$(( Offset + 16 + 1 ))" "$origrom" | head -c "$Length" > "bin/$FileName"
done
objs=""
for src in src/*asm; do
	test -z "$quiet" && echo "Assembling $src"
	obj="obj/$(basename "$src" .asm).o"
	lst="obj/$(basename "$src" .asm).lst"
	# shellcheck disable=SC2086
	ca65 "$src" -o "$obj" -l "$lst" --bin-include-dir bin $asflags
	objs="$objs $obj"
done
test -z "$quiet" && echo "Linking"
# shellcheck disable=SC2086
ld65 -o bin/Z.bin -C src/Z.cfg -m bin/Z.map $objs
test -z "$quiet" && echo "Combining"
cat NTSCHeader.bin bin/Z.bin > bin/Z.nes
test -z "$no_verify" && { diff -qs "bin/Z.nes" "$origrom" || true; }
test -n "$diff" && {
	xxd bin/Z.nes | cut -d' ' -f-9 >obj/z.txt
	xxd "$origrom" | cut -d' ' -f-9 >obj/orig.txt
	vimdiff obj/z.txt obj/orig.txt
}
