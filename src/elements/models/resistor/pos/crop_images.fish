for file in (find . -name '*.png')
    convert $file -background white -alpha remove $file
    shotwell $file
end
