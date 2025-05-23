% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngr_str_link_url.R
\name{ngr_str_link_url}
\alias{ngr_str_link_url}
\title{Create an HTML Link to Repository Resources or GitHub Pages}
\usage{
ngr_str_link_url(
  url_base = "https://www.newgraphenvironment.com",
  url_resource = NULL,
  url_resource_path = TRUE,
  anchor_text = "url_link",
  target = "_blank"
)
}
\arguments{
\item{url_base}{\link{character} A character vector specifying either the URL(s) to link to or (if \code{url_resource} is provided)
the base URL(s) for the repository host. Default is New Graph
gitpages at \url{https://www.newgraphenvironment.com}. \url{https://github.com/NewGraphEnvironment} gets you to the
repository itself.}

\item{url_resource}{\link{character} A character vector representing the repository name(s) to be linked. Optional. Default is \code{NULL}.}

\item{url_resource_path}{\link{logical} A logical value indicating whether to include a \code{/} between \code{url_base} and \code{url_resource}.
Defaults to \code{TRUE}. When set to \code{FALSE}, it facilitates constructing file paths from \code{url_base} and \code{url_resource} without \code{/} in between,
which is useful for API calls such as those to tile servers.}

\item{anchor_text}{\link{character} A character vector specifying the text displayed for the link. Defaults to \code{"url_link"}.}

\item{target}{\link{character} A single string indicating the \code{target} attribute in the HTML link. Default is \code{"_blank"}. Options include:
\itemize{
\item \code{"_blank"}: Opens the link in a new tab or window.
\item \code{"_self"}: Opens the link in the same tab or window.
\item \code{"_parent"}: Opens the link in the parent frame, if applicable.
\item \code{"_top"}: Opens the link in the full body of the window, ignoring frames.
}}
}
\value{
\link{character} A character vector containing the HTML \verb{<a>} tags.
}
\description{
This function generates an HTML \verb{<a>} tag linking to a url or a url related to specified repository resource or
GitHub Pages site hosted from the repository. It is particularly useful for embedding links in html tables such as DT tables.
}
\examples{
# Example 1: Link to the repository with default anchor text
ngr_str_link_url("ngr", url_base = "https://github.com/NewGraphEnvironment")

# Example 2: Link to GitHub Pages with anchor text set to the repository name
ngr_str_link_url(url_resource = "ngr", anchor_text = "ngr")

# Example 3: Link with no url_resource
ngr_str_link_url(url_base = "https://www.newgraphenvironment.com", anchor_text = "Visit New Graph")

# Example 4: Use in a dplyr::mutate()
library(dplyr)
df <- data.frame(
  url_resource = c("ngr", "fpr"),
  url_base = c("https://github.com/NewGraphEnvironment", "https://www.newgraphenvironment.com")
)
df <- df \%>\%
  mutate(
    link = ngr_str_link_url(url_resource = url_resource, url_base = url_base, anchor_text = url_resource)
  )
print(df$link)

}
\seealso{
Other string: 
\code{\link{ngr_str_dir_from_path}()}
}
\concept{string}
