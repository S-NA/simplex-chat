#!/bin/bash

cp -R blog website/src
cp -R images website/src
rm website/src/blog/README.md
cd website

# keys of the english language are used as the base keys
base_keys=($(jq -r 'keys[]' 'langs/en.json'))
langs=()

# this loop finds out the available languages
for file in langs/*.json; do
  if [ -f "$file" ]; then
    file_name=$(basename "$file")
    file_name=${file_name%.*}
    langs+=($file_name)
  fi
done

# this program generates a combined translations.json file
main_json_obj="{}"
for key in "${base_keys[@]}"; do
  val_json_obj="{}"
  for lang in "${langs[@]}"; do
    val="$(jq .["\"$key\""] langs/$lang.json)"
    if [ ! -z "$val" ] && [ "$val" != "null" ]; then
      val_json_obj=$(echo "$val_json_obj" | jq ". + {$lang: $val}")
    fi
  done
  main_json_obj=$(echo "$main_json_obj" | jq ". + {\"$key\": $val_json_obj}") 
done
echo "$main_json_obj" > translations.json

# creating folders for each language for internationalization
langs_json="{\"langs\": []}"
for lang in "${langs[@]}"; do
  langs_json=$(echo "$langs_json" | jq ".langs += [\"$lang\"]")
  mkdir src/$lang
  cp src/index.html src/$lang
  cp src/contact.html src/$lang
  cp src/invitation.html src/$lang
  cp src/blog.html src/$lang
  mkdir src/$lang/blog
  cp -R src/blog/images src/$lang/blog
  echo "done $lang copying"
done
echo $langs_json > "src/_data/supported_languages.json"
# the list in the supported_languages.json file is used as the reference list for displaying available languages on the frontend

npm install
npm run build

for lang in "${langs[@]}"; do
  rm -rf src/$lang
  echo "done $lang deletion"
done

# for val in "${langs[@]}"; do
#   json_content=$(echo "$json_content" | jq ". + {$val: $(jq . langs/$val.json)}")
# done
# echo "$json_content" > translations.json