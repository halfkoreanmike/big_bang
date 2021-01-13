#!/usr/bin/env bash

# store failure
failure=false

# debug output
echo "Linting all commits between $CI_DEFAULT_BRANCH and $CI_COMMIT_REF_NAME"
echo "--------------------------------------------------------"

# loop over commit sha's for commits that exist in this branch but not the default branch
for sha in $(git log origin/$CI_DEFAULT_BRANCH..origin/$CI_COMMIT_REF_NAME --format=format:%H); do
  # get the commit message from the sha
  message=$(git log --format=format:%s -n 1 $sha)
  # debug output sha and message
  echo "Linting commit: $sha - $message"
  # lint message and store possible failure
  if ! echo "$message" | npx commitlint; then failure=true; fi
done

# if we have a failure
if $failure; then
  # guide developer to resolution
  echo "--------------------------------------------------------"
  echo "You have commits that have failed linting because they do not follow conventional standards"
  echo "You must rebase your branch, and amend the commits to follow conventional standards"
  echo "Commit standards guide - https://www.conventionalcommits.org/"
  echo "> git rebase -i $CI_DEFAULT_BRANCH"
  echo "> git push --force"
  exit 1
fi