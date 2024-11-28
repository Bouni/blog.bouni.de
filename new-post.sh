#!/bin/sh 

echo "Enter a title for your new post:"

read title

slug=$(echo ${title//[,._ ]/-} | tr -s '-')

echo "Enter tags, seperated by , :"

read tags

year=$(date +"%Y")

if [ ! -d ./content/posts/$year ]; then
  echo Create new folder for year $year in ./content/posts/$year
  mkdir ./content/posts/$year
fi

if [ ! -d ./content/posts/$year/$slug ]; then
  echo Create folder for new post: ./content/posts/$year/$slug
  mkdir ./content/posts/$year/$slug
fi

if [ -f ./content/posts/$year/$slug/index.md ]; then
  echo Warning: index.md already exists!
  echo Delete and start over [yN]?
  read delete
  if [[ "$delete" == "y" ]]; then 
    echo Deleteing ./content/posts/$year/$slug/index.md
    rm ./content/posts/$year/$slug/index.md
  else
    echo Abort
    exit 1
  fi
fi

echo "---" > ./content/posts/$year/$slug/index.md
echo "title: \"$title\"" >> ./content/posts/$year/$slug/index.md
echo "date: $(date +"%Y-%m-%d")" >> ./content/posts/$year/$slug/index.md
if [[ $tags ]]; then
  echo "tags: [ $tags ]" >> ./content/posts/$year/$slug/index.md
fi
echo "daft: true" >> ./content/posts/$year/$slug/index.md
echo "---" >> ./content/posts/$year/$slug/index.md

