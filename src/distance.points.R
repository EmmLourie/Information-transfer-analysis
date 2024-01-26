# Function to get distances between consecutive points
pt.dist <- function(x, y){
  dist <- NA
  for(i in 2:length(x)){
    dx <- x[i]-x[i-1]
    dy <- y[i]-y[i-1]
    dist[i] <- (dx^2 + dy^2)^0.5
    }
  return(dist)
}


