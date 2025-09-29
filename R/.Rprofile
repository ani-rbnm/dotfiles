options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  Ncpus = max(1L, parallel::detectCores() - 1L),
  warnPartialMatchAttr = TRUE,
  warnPartialMatchDollar = TRUE,
  warnPartialMatchArgs = TRUE
)

# Prefer pak when available for fast installs
if (interactive() && requireNamespace("pak", quietly = TRUE)) {
  options(install.packages.compile.from.source = "always")
}
