ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$style(".shiny-notification {top: 50% !important; left: 50% !important; margin-top: -100px !important; color: #212121;")
  ),
  titlePanel(
    div(
      class = "headerContainer",
      a(
        img(
          src = "https://github.com/traffordDataLab/traffordDataLab.github.io/raw/master/images/trafford_council_logo_black_on_white_100px.png",
          style = "position: relative; top: -5px;",
          height = 60
        ),
        href = "https://www.trafford.gov.uk",
        target = "_blank"
      ),
      "Climate emergency slide pack"
    ),
    windowTitle = "Climate emergency slide pack"
  ),
  fluidRow(
    div(
      class = "col-sm-12 col-md-6 col-lg-4",
      box(
        width = '100%',
        textOutput("updated"), br(),
        em("Annual average global temperatures (1850-2018)"),
        div(style="display:inline-block;",
            a(img(src="_stripes_GLOBE---1850-2018-MO.png", style="width:70%;align:left;padding-top:10px;padding-bottom:10px"),
            href = "https://showyourstripes.info", target = "_blank")),
        em("Source: ", a(href = "https://showyourstripes.info", target = "_blank", "showyourstripes.info")),
        br(),br(),
        includeHTML("intro.html"),
        br(),
        selectInput("selection", tags$strong("Choose a local authority district:"), 
                    choices = sort(unique(lookup$area_name)),
                    selected = "Trafford"),
        downloadButton("slides", "Build slides")
    )
    )
    ),
  br(),
  br(),
  br(),
  tags$footer(
    fluidRow(
      "Developed in ",
      a(href = "https://cran.r-project.org/", target = "_blank", "R"),
      " by the ",
      a(href = "https://www.trafforddatalab.io", target = "_blank", "Trafford Data Lab"),
      " under the ",
      a(href = "https://www.trafforddatalab.io/LICENSE.txt", target = "_blank", "MIT"),
      " licence"
    ),
    style = "position:fixed; text-align:center; left: 0; bottom:0; width:100%; z-index:1000; height:30px; color: #7C7C7C; padding: 5px 20px; background-color: #E7E7E7"
  )
)







