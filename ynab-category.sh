#!/bin/zsh

# BUDGET_ID, TOKEN
source $(dirname "$0")"/.env"

flag_filter=true
categoryName="Costco Annual Membership"

categoryData=$(curl -s -H "Authorization: Bearer $TOKEN" \
	https://api.youneedabudget.com/v1/budgets/$BUDGET_ID/categories \
	| jq '[.data .category_groups[].categories[] | {"\(.name)": { id: .id }}]')

if [ "$flag_filter" = true ] ; then
  jq ".[] | select( has(\"$categoryName\")).\"$categoryName\".id" <<< "$categoryData"
else
  jq <<< "$categoryData"
fi