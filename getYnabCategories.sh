#!/bin/zsh

# BUDGET_ID, TOKEN
source .env

curl -v -H "Authorization: Bearer $TOKEN" \
	https://api.youneedabudget.com/v1/budgets/$BUDGET_ID/categories \
	| jq '.data .category_groups[].categories[] | "\(.name) \(.id)"'

