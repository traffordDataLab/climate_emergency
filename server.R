server <- function(input, output){
  output$slides <- downloadHandler(
    filename = "slides.pptx",
    content = function(file) {
      withProgress(style = "notification", message = 'Building your slide pack ...',{
      tempSlides <- file.path(tempdir(), "slides.Rmd")
      file.copy("slides.Rmd", tempSlides, overwrite = TRUE)
      params <- list(la = filter(lookup, area_name == input$selection)$area_code)
      rmarkdown::render(tempSlides, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
      })
    }
  )
}