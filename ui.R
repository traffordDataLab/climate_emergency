ui <- fluidPage(title = "Climate emergency slide pack",
  # Set the language of the page - important for accessibility
  tags$html(lang = "en-GB"),
  tags$head(
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$style("
                @import url('https://fonts.googleapis.com/css?family=Open+Sans%7CRoboto');
               
                .shiny-notification {
                  top: 50% !important;
                  left: 50% !important;
                  margin-top: -100px !important;
                  color: #212121;
                }
               
                h1 {
                  font-family: 'Roboto', sans-serif;
                  color: #707070;
                  display: inline-block;
                }

                a, a:hover, a:focus, a:visited {
                  color: #046dc3;
                }

                a {
                  text-decoration: none;
                }

                a:hover {
                  text-decoration: underline;
                }
                
                footer {
                  position:fixed;
                  text-align:center;
                  left: 0; bottom:0;
                  width:100%;
                  z-index:1000;
                  height:30px;
                  padding: 5px 20px;
                  background-color: #f5f9ff;
                }
               ")
  ),
  tags$header(
    class = "headerContainer",
    a(
      img(
        src = "https://www.trafforddatalab.io/images/trafford_council_logo_black_on_white_100px.png",
          style = "position: relative; top: -5px;",
          height = 60,
          alt = "Trafford Council"
      ),
      href = "https://www.trafford.gov.uk",
      target = "_blank"
    ),
    h1("Climate emergency slide pack")
  ),
  fluidRow(
    div(
      class = "col-sm-12 col-md-6 col-lg-4",
      box(
        width = '100%',
        p("Last updated: 08 September 2020"),
        
        tags$figure(style="display:inline-block;",
          img(
            src="_stripes_GLOBE---1850-2018-MO.png",
            style="width:100%;align:left;padding-top:10px;padding-bottom:10px",
            alt=""
          ),
          tags$figcaption(
            em("Annual average global temperatures (1850-2018). Source: ", a(href = "https://showyourstripes.info", target = "_blank", "showyourstripes.info"))
          )
        ),
        br(),br(),
        includeHTML("intro.html"),
        br(),
        tags$label(id="a11y-selection", style="display: none;", "Choose a local authority district"),
        selectInput("selection", tags$strong("Choose a local authority district:"), 
                    choices = sort(unique(lookup$area_name)),
                    selected = "Trafford"),
        downloadButton("slides", "Build slides")
    )
    )
    ),
  br(),br(),br(),
  tags$footer(
      "Developed in ",
      a(href = "https://cran.r-project.org/", target = "_blank", "R"),
      " by the ",
      a(href = "https://www.trafforddatalab.io", target = "_blank", "Trafford Data Lab"),
      " under the ",
      a(href = "https://www.trafforddatalab.io/LICENSE.txt", target = "_blank", "MIT"),
      " licence"
  ),
  HTML("
      <script>
          // Add label to the hidden select element for the LA choice
          var cb_selectLabel = setInterval(function() {
              try {
                  var label = document.getElementById('a11y-selection');
                  label.setAttribute('for', 'selection');
                  clearInterval(cb_selectLabel); // cancel further calls to this fn
              }
              catch(e) {
                  // do nothing, wait until function is called again next interval
              }
          }, 500);
      </script>
  ")
)







