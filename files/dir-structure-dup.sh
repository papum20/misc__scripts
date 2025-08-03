cd $1
find . -type d -print0 | xargs -0 -I {} mkdir -p "$2/{}"
