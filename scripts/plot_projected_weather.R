##  Script to plot GCM weather projections through time

##  Author: Andrew Tredennick
##  Email: atredenn@gmail.com
##  Date created: 10-09-2015


##  Clear the workspace...
rm(list=ls())


####
####  Load libraries -----------------------------------------------------------
####
library(ggplot2)
library(plyr)
library(reshape2)
library(gridExtra)



####
####  Read in GCM weather ------------------------------------------------------
####
precip <- readRDS("../data/CMIP5_yearly_project_precipitation.RDS")
precip <- subset(precip, scenario!="rcp26" & season!="summer")
temp <- readRDS("../data/CMIP5_yearly_project_temperature.RDS")
temp <- subset(temp, scenario!="rcp26")

ppt_agg <- ddply(precip, .(Year, scenario, season), summarise,
                 avg_value = mean(ppt),
                 upval=quantile(ppt, 0.95, na.rm=TRUE),
                 loval=quantile(ppt, 0.05, na.rm=TRUE))

temp_agg <- ddply(temp, .(Year, scenario, season), summarise,
                 avg_value = mean(TmeanSpr),
                 upval=quantile(TmeanSpr, 0.95, na.rm=TRUE),
                 loval=quantile(TmeanSpr, 0.05, na.rm=TRUE))

# cols <- c("tan","coral","darkred")
cols <- c("grey10", "grey30", "grey60")

g1 <- ggplot(ppt_agg)+
  geom_ribbon(aes(x=Year, ymin=loval, ymax=upval, fill=scenario),
              alpha=0.5)+
  geom_line(aes(x=Year, y=avg_value, color=scenario))+
  stat_smooth(method="lm", se=FALSE, aes(x=Year, y=avg_value), color="black", linetype=2)+
  geom_vline(aes(xintercept=2011))+
  scale_fill_manual(values=cols, 
                    name="IPCC \nScenario",
                    labels=c("RCP 4.5", "RCP 6.0", "RCP 8.5"))+
  scale_color_manual(values=cols, 
                     name="IPCC \nScenario",
                     labels=c("RCP 4.5", "RCP 6.0", "RCP 8.5"))+
  ylab("Fall through Spring Ppt. (mm)")+
  ggtitle("A) GCM Precipitation Projections")+
  theme_bw()

g2 <- ggplot(temp_agg)+
  geom_ribbon(aes(x=Year, ymin=loval, ymax=upval, fill=scenario),
              alpha=0.5)+
  geom_line(aes(x=Year, y=avg_value, color=scenario))+
  stat_smooth(method="lm", se=FALSE, aes(x=Year, y=avg_value), color="black", linetype=2)+
  geom_vline(aes(xintercept=2011))+
  scale_fill_manual(values=cols, 
                    name="IPCC \nScenario",
                    labels=c("RCP 4.5", "RCP 6.0", "RCP 8.5"))+
  scale_color_manual(values=cols, 
                     name="IPCC \nScenario",
                     labels=c("RCP 4.5", "RCP 6.0", "RCP 8.5"))+
  ylab("Mean Spring Temperature (deg. C)")+
  ggtitle("B) GCM Temperature Projections")+
  theme_bw()


png("../docs/components/figure/weather_projections.png", width = 6, height = 8, res = 200, units="in")
outplot <- grid.arrange(g1, g2, ncol=1)
dev.off()
