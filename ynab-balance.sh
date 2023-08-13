#!/bin/zsh

# BUDGET_ID, TOKEN
source $(dirname "$0")"/.env"

flag_raw=false
positionalArgsEaten=0
categoryName=""

while [ $# -gt 0 ]; do
  case $1 in
    -r | --raw) flag_raw=true;;
    --category-name)
      categoryName=$2;
      [ -z "$2" ] && echo "error: --category-name requires a category name" && exit 1
      shift
      ;;
    *) # grab categoryId as first arg
      [ $positionalArgsEaten = 0 ] && categoryId=$1

      [ $positionalArgsEaten -gt 0 ] && echo "error: unexpected arg $1" && exit 1

      if [ -n "$categoryName"  ]; then
              echo "warning: categoryId $1 will be ignored if --category-name is passed"
      fi

      positionalArgsEaten=$((positionalArgsEaten + 1))

      ;;
  esac
  shift
done

if [ "$categoryName" ]; then
  categoryId=$(./ynab-category.sh --filter "$categoryName")
fi

YNABBalanceResponseCode=$(curl -s -w "%{http_code}" -o .ynab_balance_response \
  -H "Authorization: Bearer $TOKEN" \
	"https://api.youneedabudget.com/v1/budgets/$BUDGET_ID/categories/$categoryId")
YNABBalanceResponse=$(cat .ynab_balance_response)

if [ "$YNABBalanceResponseCode" != "200" ]; then
  echo "error: $YNABBalanceResponseCode"
  jq <<< "$YNABBalanceResponse"
  exit 1
fi

if [ "$flag_raw" = true ]; then
    jq <<< "$YNABBalanceResponse"
    exit 1
fi

balance=$(jq -r '.data.category.balance' <<< "$YNABBalanceResponse")
minus=""
if [ "$balance" -lt 0 ]; then
    balance=$((balance * -1))
    minus="-"
fi

printf "$minus$%.2f \n" $((balance *.001))