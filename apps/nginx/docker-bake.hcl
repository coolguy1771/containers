target "docker-metadata-action" {}

variable "APP" {
  default = "nginx"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=nginx versioning=semver
  default = "1.27.0"
}

variable "CHANNEL" {
  default = "stable"
}

variable "SOURCE" {
  default = "https://github.com/nginxinc/nginx-unified"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CHANNEL = "${CHANNEL}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
