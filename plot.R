require(jsonlite)
require(ggplot2)

data <- fromJSON("sent.json", flatten=TRUE)
datetimes <- as.POSIXlt(data$date, tz="GMT")
minutesAfterMidnight <- datetimes[[3]]*60 + datetimes[[2]]
dates <- as.Date(strftime(datetimes, "%Y-%m-%d"))
plotData <- data.frame(dates=dates, minutes=as.POSIXct('1900-1-1', tz="GMT") + minutesAfterMidnight*60)
plot <- ggplot(plotData, aes(x=dates, y=minutes)) + geom_point(size=0.5)
plot <- plot + scale_x_date() + scale_y_datetime(labels=date_format('%H:%M'))
plot <- plot + theme(axis.title.y = element_blank(), axis.title.x = element_blank())



day_of_year <- as.POSIXct('1900-1-1', tz="GMT") + datetimes$yday*24*60*60
day_of_year_plot <- ggplot(mapping = aes(x=day_of_year)) + geom_histogram(aes(y = ..density.., alpha=0.5), show.legend=FALSE, binwidth=24*60*60*3) + geom_density(adjust=0.8, color="red")
day_of_year_plot <- day_of_year_plot + geom_hline(yintercept=0, colour="white", size=0.5) # Avoids red border at the bottom
day_of_year_plot <- day_of_year_plot + scale_x_datetime(labels=date_format('%b'))
day_of_year_plot <- day_of_year_plot + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), axis.title.x = element_blank())



month_plot <- qplot(datetimes$mon, geom="histogram", binwidth=1)



time_of_day <- as.POSIXct('1900-1-1', tz="GMT") + datetimes[[3]]*60*60 + datetimes[[2]]*60 + datetimes[[1]]
time_of_day_plot <- ggplot(mapping=aes(x=time_of_day)) + geom_histogram(aes(y = ..density.., alpha=0.5), show.legend=FALSE, binwidth = 10*60) + geom_density(adjust=0.8, color="red") # 10 minutes bin
time_of_day_plot <- time_of_day_plot + scale_x_datetime(labels=date_format('%H:%M:%S')) + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), axis.title.x = element_blank())
time_of_day_plot <- time_of_day_plot + geom_hline(yintercept=0, colour="white", size=0.5) # Avoids red border at the bottom
time_of_day_plot <- time_of_day_plot + xlab("Time of day")



weekdaysStartingMonday <- ((datetimes$wday+6) %% 7)
time_of_week <- as.POSIXct('1900-1-1', tz="GMT") + weekdaysStartingMonday*24*60*60 + datetimes[[3]]*60*60 + datetimes[[2]]*60 + datetimes[[1]]
time_of_week_plot <- ggplot(mapping=aes(x=time_of_week)) + geom_histogram(aes(y = ..density.., alpha=0.5), show.legend=FALSE, binwidth = 10*7*60) + geom_density(adjust=1/3, color="red") # 10*7 minutes bin
time_of_week_plot <- time_of_week_plot + scale_x_datetime(labels=date_format('%a'), date_breaks="1 day") + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), axis.title.x = element_blank())
time_of_week_plot <- time_of_week_plot + geom_hline(yintercept=0, colour="white", size=0.5) # Avoids red border at the bottom
time_of_week_plot <- time_of_week_plot + xlab("Time of week")