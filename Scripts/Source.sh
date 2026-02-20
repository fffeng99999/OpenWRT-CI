#!/bin/bash

if [ -d "./wrt/.git" ]; then
	CURRENT_URL=$(git -C ./wrt remote get-url origin 2>/dev/null || echo "")
	if [ "$CURRENT_URL" != "$WRT_REPO" ] && [ -n "$WRT_REPO" ]; then
		git -C ./wrt remote set-url origin "$WRT_REPO"
	fi

	git -C ./wrt fetch --all --prune
	if git -C ./wrt show-ref --verify --quiet "refs/remotes/origin/$WRT_BRANCH"; then
		git -C ./wrt checkout -B "$WRT_BRANCH" "origin/$WRT_BRANCH"
	else
		git -C ./wrt checkout -B "$WRT_BRANCH"
	fi
	git -C ./wrt reset --hard "origin/$WRT_BRANCH" 2>/dev/null || true
else
	if [ -d "./wrt" ]; then
		rm -rf ./wrt/* ./wrt/.[!.]* ./wrt/..?* || true
	fi

	git clone --depth=1 --single-branch --branch "$WRT_BRANCH" "$WRT_REPO" ./wrt/
fi

cd ./wrt/ 2>/dev/null || exit 1
echo "WRT_HASH=$(git log -1 --pretty=format:'%h')" >> "$GITHUB_ENV"
