#!/usr/bin/env bash
while getopts a:n:u:d: flag
do
    case "${flag}" in
        a) author=${OPTARG};;
        n) name=${OPTARG};;
        u) urlname=${OPTARG};;
        d) description=${OPTARG};;
    esac
done
echo "Author: $author";
echo "Project Name: $name";
echo "Project URL name: $urlname";
echo "Description: $description";

echo "Rendering the Flask template..."
original_author="author_name"
original_name="project_name"
original_urlname="project_urlname"
original_description="project_description" 
TEMPLATE_DIR="./.github/templates/flask"
for filename in $(find ${TEMPLATE_DIR} -name "*.*" -not \( -name "*.git*" -prune \) -not \( -name "apply.sh" -prune \)) 
do
    sed -i "s/$original_author/$author/g" $filename
    sed -i "s/$original_name/$name/g" $filename
    sed -i "s/$original_urlname/$urlname/g" $filename
    sed -i "s/$original_description/$description/g" $filename
    echo "Renamed $filename"
done

# Add requirements
if [ ! -f pyproject.toml ]
then
    cat ${TEMPLATE_DIR}/requirements.txt >> requirements.txt
    cat ${TEMPLATE_DIR}/requirements-test.txt >> requirements-test.txt
else
    for item in $(cat ${TEMPLATE_DIR}/requirements.txt)
    do
        poetry add "${item}"
    done
    for item in $(cat ${TEMPLATE_DIR}/requirements-test.txt)
    do
        poetry add --dev "${item}"
    done
fi

# Move module files
rm -rf "${name}"
rm -rf tests
cp -R ${TEMPLATE_DIR}/project_name "${name}"
cp -R ${TEMPLATE_DIR}/tests tests

cp ${TEMPLATE_DIR}/README.md README.md
cp ${TEMPLATE_DIR}/Containerfile Containerfile
cp ${TEMPLATE_DIR}/wsgi.py wsgi.py
cp ${TEMPLATE_DIR}/.env .env
cp ${TEMPLATE_DIR}/settings.toml settings.toml


