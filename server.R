# This is the server logic for a Shiny web application of the MAI Dynamic App.
#

library(shiny)

######################################
# conduct necessary data preparation.
# load necessary libraries
library(googleVis)
library(lubridate)
library(data.table)
library(dplyr)

#load the data
#sbdt is the sub data set of maintenance data (a04v9) after cleansing.
#set right working directory
sbdt <- read.csv("sbdt.csv")
#change the actual start date to year month in data format
sbdt$yrmn <- as.Date(paste(sbdt$yrmn,"-01",sep=""))

#prepare the operation related dataset, i.e. costs, hours
sbdt.op <- aggregate(cbind(pm1no, pm2no, pm3no, pm1cost, pm2cost, pm3cost, 
                                  pm1cost.lab, pm2cost.lab, pm3cost.lab, 
                                  pm1cost.mt, pm2cost.mt, pm3cost.mt, 
                                  cost.acttl, cost.labor, costs_actual_service, costs_actual_material, 
                           smu_hours_cumulative, man_hours) ~
                                  operation + yrmn, data = sbdt, FUN = "mean")

#prepare the truck level dataset
sbdt.tk <- aggregate(cbind(pm1no, pm2no, pm3no, pm1cost, pm2cost, pm3cost, 
                           pm1cost.lab, pm2cost.lab, pm3cost.lab, 
                           pm1cost.mt, pm2cost.mt, pm3cost.mt, 
                           cost.acttl, cost.labor, costs_actual_service, costs_actual_material, 
                           man_hours) ~ 
                           truck + yrmn, data = sbdt, FUN = "sum")
operated.hrs <- aggregate(smu_hours_cumulative ~ truck + yrmn, data = sbdt, FUN = "mean")

#join different summaries
operated.hrs <- data.table(operated.hrs)
        setkey(operated.hrs, truck, yrmn)
sbdt.tk <- data.table(sbdt.tk)
        setkey(sbdt.tk, truck, yrmn)
sbdt.tk <- inner_join(sbdt.tk, operated.hrs)

#add operations information to truck level data
trk.op <- sbdt[,c(2,3)]
        trk.op <- trk.op[!duplicated(trk.op$truck),]
sbdt.tk <- data.table(sbdt.tk)
        trk.op <- data.table(trk.op)
setkey(sbdt.tk, truck)
        setkey(trk.op, truck)
sbdt.tk <- inner_join(sbdt.tk, trk.op)



######################################

shinyServer(function(input, output) 
        {
        output$view <- renderGvis({
                if(input$select=="Maintenance Analysis by Operations")
                {gvisMotionChart(sbdt.op, 
                                 idvar = 'operation', timevar = 'yrmn', 
                                 xvar = 'smu_hours_cumulative', yvar = 'pm3cost',
                                 options = list(width = 800, height = 600))}
                else{gvisMotionChart(sbdt.tk, 
                                 idvar = 'truck', timevar = 'yrmn', 
                                 xvar = 'smu_hours_cumulative', yvar = 'pm3cost',
                                 options = list(width = 800, height = 600))}
        })
        
})