https://github.com/commitizen/cz-cli
https://repo1.dso.mil/platform-one/big-bang/charter/-/blob/master/DevCIWorkflow.md
https://www.conventionalcommits.org/en/v1.0.0/
https://commitlint.js.org/#/
https://github.com/conventional-changelog/commitlint

git checkout workflow-example
git reset $(git merge-base master $(git rev-parse --abbrev-ref HEAD))
git add -A
git commit -m "feat: example squashed conventional commit"
git push --force

npm install -g commitizen
