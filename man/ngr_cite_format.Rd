% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngr_cite_keys_to_xref.R
\name{ngr_cite_format}
\alias{ngr_cite_format}
\title{Format Multiple Citations}
\usage{
ngr_cite_format(raw_key, bib_obj, ...)
}
\arguments{
\item{raw_key}{A raw citation key string, possibly with brackets.}

\item{bib_obj}{The bibliography object.}

\item{...}{Additional arguments passed from the main function.}
}
\value{
Formatted citation as a string.
}
\description{
Formats one or more citation keys into a single inline reference.
}
\seealso{
Other cite: 
\code{\link{ngr_cite_assemble}()},
\code{\link{ngr_cite_bib_keys_missing}()},
\code{\link{ngr_cite_format_single}()},
\code{\link{ngr_cite_keys_extract}()},
\code{\link{ngr_cite_keys_to_inline}()},
\code{\link{ngr_cite_keys_to_xref}()}
}
\concept{cite}
