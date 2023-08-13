#!/bin/zsh

# BUDGET_ID, TOKEN
source $(dirname "$0")"/.env"

flag_raw=false
flag_list=false
flag_filter=false
categoryName=""

while [ $# -gt 0 ]; do
  case $1 in
    -r | --raw) flag_raw=true;;
    -l | --list) flag_list=true;;
    -f | --filter)
      flag_filter=true;
      [ -z "$2" ] && echo "error: -f --filter requires a category name" && exit 1
      categoryName=$2;
      shift
      ;;
    *) echo "error: unrecognized option $1" && exit 1;;
  esac
  shift
done

if [ $flag_raw = true  ]; then
    if [ $flag_list = true ]; then
        echo "warning: -r and -l are mutually exclusive"
    fi
fi

if [ $flag_filter = true ]; then
    if [ $flag_raw = true ] || [ $flag_list = true ]; then
        echo "warning: -f and -r or -l are mutually exclusive"
    fi
fi

# positional parameters
#command=${script_args[0]}
#flag_key=${script_args[1]}

YNABCategoriesResponseCode=$(curl -s -w "%{http_code}" -o .ynab_categories_response \
  -H "Authorization: Bearer $TOKEN" \
	"https://api.youneedabudget.com/v1/budgets/$BUDGET_ID/categories")
YNABCategoriesResponse=$(cat .ynab_categories_response)

if [ "$YNABCategoriesResponseCode" != "200" ]; then
  echo "error: $YNABCategoriesResponseCode"
  jq <<< "$YNABCategoriesResponse"
  exit 1
fi

if [ "$flag_raw" = true ]; then
    jq <<< "$YNABCategoriesResponse"
    exit 1
fi

if [ "$flag_list" = true ]; then
  jq -r '.data .category_groups[].categories[] | .name' <<< "$YNABCategoriesResponse"
  exit 0
fi

categories=$(jq '[.data .category_groups[].categories[] | {"\(.name)": { id: .id }}]' <<< "$YNABCategoriesResponse")

if [ "$flag_filter" = true ] ; then
  jq -r ".[] | select( has(\"$categoryName\")).\"$categoryName\".id" <<< "$categories"
else
  jq <<< "$categories"
fi