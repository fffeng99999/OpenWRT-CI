#!/bin/bash

if [ -d "./wrt/.git" ]; then
	cd ./wrt/

	CURRENT_URL=$(git remote get-url origin 2>/dev/null || echo "")
	if [ "$CURRENT_URL" != "$WRT_REPO" ] && [ -n "$WRT_REPO" ]; then
		git remote set-url origin "$WRT_REPO"
	fi

	git fetch --all --prune
	if git show-ref --verify --quiet "refs/remotes/origin/$WRT_BRANCH"; then
		git checkout -B "$WRT_BRANCH" "origin/$WRT_BRANCH"
	else
		git checkout -B "$WRT_BRANCH"
	fi
	git reset --hard "origin/$WRT_BRANCH" 2>/dev/null || true
else
	if [ -d "./wrt" ]; then
		rm -rf ./wrt/* ./wrt/.[!.]* ./wrt/..?* || true
	fi

	git clone --depth=1 --single-branch --branch "$WRT_BRANCH" "$WRT_REPO" ./wrt/
	cd ./wrt/
fi

cd ./wrt/ 2>/dev/null || exit 1
echo "WRT_HASH=$(git log -1 --pretty=format:'%h')" >> "$GITHUB_ENV"
