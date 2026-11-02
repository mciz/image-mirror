# image-mirror

Unmodified copies of the public images a home k3s cluster pulls, kept on GitHub
Packages. `images.txt` lists them; each is copied to
`ghcr.io/mciz/mirror/<image>` with all its platforms and the same digest. Every
image keeps its upstream licence.

The nodes reach them through a redirect in k3s's `registries.yaml`. An image
that isn't here yet still comes from upstream.

To add an image, add a line to `images.txt` and push to `main`.
