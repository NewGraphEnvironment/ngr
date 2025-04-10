% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngr_str_replace_in_files.R
\name{ngr_str_replace_in_files}
\alias{ngr_str_replace_in_files}
\title{Perform Bulk Find-and-Replace on Multiple Files Using stringr}
\usage{
ngr_str_replace_in_files(text_current, text_replace, files, ask = TRUE)
}
\arguments{
\item{text_current}{\link{character} A string representing the text to be replaced in filenames.}

\item{text_replace}{\link{character} A string representing the new text to replace the current text in filenames.}

\item{ask}{\link{logical} Whether to prompt the user for confirmation before renaming. Default is \code{TRUE}.}
}
\value{
\link{logical} Invisibly returns a logical vector indicating success for each file.
}
\description{
This function explicitly reads the content of files, performs find-and-replace
operations using \code{stringr}, and writes the updated content back to the files.
It handles word boundaries, trailing punctuation, and allows for specific symbols
like \code{@} to precede the text to be replaced.
}
