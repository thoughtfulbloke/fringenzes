# helper functions


#function for extracting the percent of each answer of interest for a column from each
# combo of Year, Age, & Gender

yes_no_dunno <- function(setofdata, targetcol, thumbsup=1, thumbsdown=5, waitwhat=6){
  if(length(targetcol) == 0){return(NULL)}
  lessdata <- setofdata[,c("Year","Age","Gender", targetcol)]
  names(lessdata) <- c("Year","Age","Gender", "Placeholder")
  percents <- lessdata |> 
    filter(!is.na(Year), !is.na(Age), !is.na(Gender)) |>  
    summarise(.by=c(Year,Age,Gender),
              Strongly_Agree = 100*sum(as.numeric(Placeholder) %in% thumbsup & !is.na(Placeholder))/sum(!is.na(Placeholder)),
              Strongly_Disagree = 100*sum(as.numeric(Placeholder) %in% thumbsdown & !is.na(Placeholder))/sum(!is.na(Placeholder)),
              Dont_Know = 100*sum(as.numeric(Placeholder) == waitwhat & !is.na(Placeholder))/sum(!is.na(Placeholder)))
  return(percents)
}

yes_no_dunno_3var <- function(setofdata, targetcol){
  # this function assumes the coloumn names are in self, labour, national order
  # with three cols the don't know state is more complex
  lessdata <- setofdata[,c("Year","Age","Gender", targetcol)]
  names(lessdata) <- c("Year","Age","Gender", "Self", "Labour", "National")
  percents <- lessdata |> 
    filter(!is.na(Year), !is.na(Age), !is.na(Gender)) |>
    mutate(
      Self = as.numeric(Self),
      Labour = as.numeric(Labour),
      National = as.numeric(National),
      Placeholder = Self - (Labour + National) / 2,
      Placeholder = ifelse(Self == 12 | Labour == 12 | National == 12,
           99, Placeholder)) |> # 99 as impossible value IDing a don't know
    filter(!is.nan(Placeholder)) |> 
    summarise(.by=c(Year,Age,Gender),
              Strongly_Agree = 100*sum(Placeholder< -3 & !is.na(Placeholder))/sum(!is.na(Placeholder)),
              Strongly_Disagree = 100*sum(Placeholder > 3 & Placeholder < 90 & !is.na(Placeholder))/sum(!is.na(Placeholder)),
              Dont_Know = 100*sum(Placeholder == 99 & !is.na(Placeholder))/sum(!is.na(Placeholder)))
  return(percents)
}

# make a table to dispaly the ordered contents of a factor variable

order_contents <- function(targetcol){
  factord <- data.frame(
    order = 1:length(levels(targetcol)),
    text_in_2017 = levels(targetcol)
  )
}

# theme info

library(ggplot2)
library(ggthemes)
six_cols <- colorblind_pal()(6)
footer <- paste0("\nGraph made ", trimws(format(Sys.time(), format="%e %b %Y")),". Contact: thoughtfulnz on mastodon.nz or bsky.app")

theme_davidhood <- function(){
  theme_minimal(base_family="Atkinson Hyperlegible",#base_family="OpenSans",#
                base_size = 11) %+replace%   
    theme(axis.line.x = element_line(linewidth=0.1),
          axis.line.y = element_line(linewidth=0.1),
          axis.ticks = element_line(linewidth=0.2),
          axis.title.y.left = element_text(margin = margin(t = 0.5, r = 0.5, b = 0.5, l = 0, unit = "lines")),
          axis.title.x.bottom = element_text(margin = margin(t = 0.5, r = 0.5, b = 0, l = 0.5, unit = "lines")),
          panel.grid = element_blank(),
          legend.position = "bottom",
          strip.background = element_rect(fill= "#FFFFFF", colour="#EFEFEF"),
          strip.text = element_text(margin = margin(t = 5, r = 5, b = 5, l = 5, unit = "pt")),
          strip.placement = "inside",
          panel.background = element_rect(fill = "#FFFFFF", colour = "#FFFFFF"),
          panel.spacing = unit(0.8, "lines"),
          plot.title = element_text(lineheight = 1.18, size=13,
                                    margin=margin(t = 0, r = 0, b = 0.5, l = 0, unit = "lines"),
                                    hjust=0),
          plot.subtitle = element_text(lineheight = 1.18, size=11,
                                       margin=margin(t = 0, r = 0, b = 0.5, l = 0, unit = "lines"),
                                       hjust=0),
          plot.background = element_rect(fill = "#FAFAFA"),
          plot.caption = element_text(margin=margin(t = 0.5, r = 1, b = 0, l = 1, unit = "lines"),
                                      lineheight = 1.15,
                                      size=9, hjust=1),
          plot.caption.position = "plot",
          plot.title.position = "plot",
          plot.margin = margin(t=0.5,r=0.5,b=0.5,l=0.5, unit="lines"))
  
}
