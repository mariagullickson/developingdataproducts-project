# load all the data
heightData <- read.csv('data/lenageinf.csv', as.is=TRUE)
weightData <- read.csv('data/wtageinf.csv', as.is=TRUE)
headData <- read.csv('data/hcageinf.csv', as.is=TRUE)

kilogramsPerPound <- 0.453592
centimersPerInch <- 2.54

# compute the percentile for a given value give a data row
percentile <- function(value, dataRow)
{
    if (nrow(dataRow) == 0 | value == 0)
    {
        return('Unknown');
    }
    
    # compute the percentile
    if (dataRow$L == 0)
    {
        zScore <- ln(value/dataRow$M) / dataRow$S;
    } else
    {
        zScore <- ((value/dataRow$M)^dataRow$L-1) / (dataRow$L*dataRow$S);
    }
    pct <- as.integer(pnorm(zScore) * 100);

    # now add the ordinal ending, for example turning "21" into "21st"
    ones <- pct %% 10;
    onesAndTens <- pct %% 100;
    if (ones == 1 & onesAndTens != 11)
    {
        ending <- "st";
    } else if (ones == 2 & onesAndTens != 12)
    {
        ending <- "nd";
    } else if (ones == 3 & onesAndTens != 13)
    {
        ending <- "rd";
    } else
    {
        ending <- "th";
    }
    paste0(pct, ending)
}

shinyServer(
  function(input, output) {
      # pretty up age and gender to echo back to the user
      output$age <- renderText(if(input$months == -1) '' else paste(input$months, 'month old'))
      output$gender <- renderText(if(input$gender == 1) 'Male' else if(input$gender == 2) 'Female' else '')
      
      # height
      output$heightpct <- reactive({
          heightRow <- heightData[heightData$Sex == input$gender & heightData$Agemos == input$months,];
          if (is.null(input$height))
          {
              height <- 0;
          } else
          {
              height <- input$height;
          }
          if (input$heightunit == 'in')
          {
              height <- height * centimersPerInch;
          }
          percentile(height, heightRow);
      })

      # weight
      output$weightpct <- reactive({
          weightRow <- weightData[weightData$Sex == input$gender & weightData$Agemos == input$months,]
          weight <- input$weight;
          if (!is.null(input$weight))
          {
              weight <- input$weight;
              if (input$weightunit == 'lb')
              {
                  weight <- weight * kilogramsPerPound;
              }
              percentile(weight, weightRow);
          }
      })

      # head
      output$headpct <- reactive({
          headRow <- headData[headData$Sex == input$gender & headData$Agemos == input$months,]
          head <- input$head;
          if (is.null(input$head))
          {
              head <- 0;
          } else
          {
              head <- input$head;
          }
          if (input$headunit == 'in')
          {
              head <- head * centimersPerInch;
          }
          percentile(head, headRow);
      })
  }
)
