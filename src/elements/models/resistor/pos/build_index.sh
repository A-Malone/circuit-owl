find . -name '*.png' -exec identify -format '%i 1 0 0 %w %h\n' \{\} \; > index.dat
