#!/bin/sh
set -eu
no_verify=
no_extract=
while [ $# -gt 0 ]; do
	case "$1" in
		--no-verify) no_verify=1;;
		--no-extract) no_extract=1;;
		*) echo "Unknown argument $1"; exit 1;;
	esac
	shift
done
mkdir -p obj bin
test -z $no_extract && sed -n '/<Binary /{s!<Binary !!;s!/>!!;s!\r!!g;p}' src/bins.xml | while IFS= read -r line; do
	eval "$line"
	: "${Offset:?} ${Length:?} ${FileName:?}"
	mkdir -p "$(dirname "bin/$FileName")"
	tail -c "+$(( Offset + 16 + 1 ))" ext/Original.nes | head -c "$Length" > "bin/$FileName"
done
objs=""
for src in src/*asm; do
	echo "Assembling $src"
	obj="obj/$(basename "$src" .asm).o"
	lst="obj/$(basename "$src" .asm).lst"
	ca65 "$src" -o "$obj" -l "$lst" --bin-include-dir bin
	objs="$objs $obj"
done
echo "Linking"
# shellcheck disable=SC2086
ld65 -o bin/Z.bin -C src/Z.cfg $objs
echo "Combining"
cat OriginalNesHeader.bin bin/Z.bin > bin/Z.nes
test -z $no_verify && { diff -qs "bin/Z.nes" "ext/Original.nes" || true; }
