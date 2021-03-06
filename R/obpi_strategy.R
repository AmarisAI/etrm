#' Option Based Portfolio Insurance (OBPI)
#'
#' Implements OBPI strategy for commodity price risk management
#' @param q numeric value for quantity to be hedged, either positive (net buyer) or negative (net seller)
#' @param tdate date vector with trading days
#' @param f numeric futures price vector
#' @param k numeric value for option strike price
#' @param vol value for volatility
#' @param r value for interest rate
#' @param tdays integer assumed number of trading days per year
#' @param daysleft integer with days left to option expiry
#' @param tcost numeric transaction costs pr unit
#' @param int TRUE/ FALSE integer restriction on tradable volume
#' @return instance of the OBPI class
#' @export

obpi <- function(
  q,
  tdate,
  f,
  k = f[1],
  vol,
  r = 0,
  tdays = 250,
  daysleft,
  tcost = 0,
  int = TRUE
  ){

  # validation of arguments

  # missing arguments
  if (missing(q))
    stop("No volume specified")

  if (missing(tdate))
    stop("No date vector specified")

  if (missing(f))
    stop("No price vector specified")

  # invalid arguments
  if (tcost < 0)
    stop("Transaction cost cannot be a negative number")

  if (k <= 0)
    stop("Strike price must be a positive number")

  if (vol <= 0)
    stop("Volatility must be a positive number")

  if (tdays <= 0)
    stop("Number of trading days per year must be a positive number")

  if (daysleft <= 0)
    stop("Number of trading days left must be a positive number")

  if (length(tdate) != length(f))
    stop("Date and price vectors must be of equal length")

  if (int==FALSE){
    # model without tradeable volume restrictions (int=FALSE)
    digits<-10
  }
  else {
    # model with smallest tradeable volume unit = 1 (int=TRUE)
    digits<-0
  }

  # remaining time in years, d1 and d2 from Black76
  t<-(daysleft:1)/tdays
  d1<-(log(f/k)+(0.5*vol^2*t))/(vol*sqrt(t))
  d2 <- d1-vol*sqrt(t)

  # option premiums, delta hedges and implied portfolio target price for
  # positive q (net buyer)
  # and negative q (net seller)
  if(q>0){
    # european b76 call premium
    premium <- exp(-r*t[1])*(f[1]*pnorm(d1[1])-k*pnorm(d2[1]))
    # delta hedge volumes
    h<-round(q*pnorm(d1)*exp(-r*t),digits)
    # implied target price
    TargetPrice <- (k[1] + premium[1])
  } else {
    # european b76 put premium
    premium <- exp(-r*t[1])*(k*pnorm(-d2[1])-f[1]*pnorm(-d1[1]))
    # delta hedge volumes
    h<-round(q*pnorm(-d1)*exp(-r*t),digits)
    # implied target price
    TargetPrice <- (k[1] - premium[1])
  }

  # calculation of trades, exposed volume and portfolio price
  hper<-h/q                                       # hedged %
  tr<-c((h[1]),diff(h))                           # traded volumes
  exp<-q-h                                        # exposed volume
  pp<-(cumsum(tr*(f+sign(tr)*tcost))+exp*f)/q     # portfolio price

  # create an instance of the obpi class
  out <- new("OBPI",
             Name="OBPI",
             Volume=q,
             TargetPrice=TargetPrice,
             StrikePrice=k,
             AnnVol=vol,
             InterestRate=r,
             TradingDays=tdays,
             TransCost=tcost,
             TradeisInt=int,
             Results=data.frame(
               Date=tdate,
               Price=f,
               Traded=tr,
               Exposed=exp,
               Hedged=h,
               HedgeRate=hper,
               Target = rep(TargetPrice,length(f)),
               PortfPrice=pp))

  # return OBPI object
  return(out)
}
