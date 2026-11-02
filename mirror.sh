#!/usr/bin/env bash
# Copies every image in images.txt to ghcr.io/OWNER/mirror/<image>, with all its
# platforms and the same digests, so a node pulling through the mirror gets
# exactly what the source serves. An image already there is skipped, which saves
# Docker Hub's pull limit on a rerun.
set -euo pipefail

owner=${GITHUB_REPOSITORY_OWNER:?}
failed=0

digest() {
    skopeo inspect --raw --retry-times 3 "docker://$1" | sha256sum | cut -d' ' -f1
}

while read -r image _; do
    [[ -z $image || $image == \#* ]] && continue
    target="ghcr.io/$owner/mirror/$image"
    if ! want="$(digest "$image")"; then
        echo "::error::cannot read $image"
        failed=1
        continue
    fi
    if [[ "$(digest "$target" 2>/dev/null || true)" == "$want" ]]; then
        echo "up to date: $image"
    elif skopeo copy --all --preserve-digests --retry-times 3 "docker://$image" "docker://$target" &&
        [[ "$(digest "$target")" == "$want" ]]; then
        echo "copied: $image"
    else
        echo "::error::could not copy $image"
        failed=1
    fi
done <images.txt

# This tag exists only here. A node that can pull
# docker.io/library/busybox:ghcr-mirror-check went through the mirror, because
# the fallback to Docker Hub would have found nothing.
base="ghcr.io/$owner/mirror/docker.io/library/busybox"
skopeo copy --all --preserve-digests --retry-times 3 "docker://$base:1.38.0" "docker://$base:ghcr-mirror-check"

exit "$failed"
