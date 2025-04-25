#!/bin/bash

# This script mirrors the MASTER_BRANCH to the REMOTE_MASTER_BRANCH on the repository REPOSITORY_URL
# It does this by using squash merges of the MASTER_BRANCH into the latest version of the
# target repository.
set -ex

# EEA repository corresponding to this repository
REPOSITORY_URL="git@github.com:eea/clcplus-core-openstack-setup.git"
MASTER_BRANCH="master"
REMOTE_MASTER_BRANCH="main"
# files that will be deleted after merge and before commit.
EXCLUDE_FILES=(

)

# create remote
git remote add eea "$REPOSITORY_URL" || echo "OK remote exists"
git fetch eea

# checkout branch eea-mirror tracking the eea master branch
git switch -c eea-mirror --track "eea/$REMOTE_MASTER_BRANCH" || git switch eea-mirror
git pull

# squash merge local master into eea-mirror without creating a merge commit
git merge --squash "$MASTER_BRANCH" --allow-unrelated-histories -X theirs

# remove secret files
#git rm -f "${EXCLUDE_FILES[@]}"

# commit the changes, read commit message from user input
read -p "Commit Message: " COMMIT_MSG
git commit -m "$COMMIT_MSG"

# push changes to remote
printf "Done. If you are happy with the changes you can push them with:

git push eea eea-mirror:$REMOTE_MASTER_BRANCH
"
