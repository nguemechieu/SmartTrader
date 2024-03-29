//+------------------------------------------------------------------+
//|                                                  SmartTrader.mq4 |
//|                          Copyright 2021,Noel Martial Nguemechieu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Created by NOEL MARTIAL NGUEMECHIEU"
#property link      "https://t.me/joinchat/EgyQSXmXuPhjNTJh"
#property strict
#property version   "1.00"
//messages="NEWS ALERT!\nTime : Within  "+string((int)(TimeNewsFunck(i)-TimeCurrent())/60)+" minutes released news \nCurrency : "+NewsArr[1][i]+"\nImpact : "+NewsArr[2][i]+"\nTitle : "+NewsArr[3][i]+"\nForecast\n"+"Previous\n------more detail https://bit.ly/35NPVPi --------------";Now=i;}

#include <MyBot.mqh>
#include <stdlib.mqh>
#include <stderror.mqh>
#include <Comment.mqh>

//--- includes
#include <DoEasy\Engine.mqh>
#ifdef __MQL5__
#include <Trade\Trade.mqh>
#endif 
//--- enums
CEngine        engine;
#ifdef __MQL5__
CTrade         trade;
#endif 

#define TOTAL_IndicatorTypes 6+1

#define TOTAL_OpenOrExit 2
#define TOTAL_IndicatorNum 6
#define IndicatorName0 "Off"
#define IndicatorName1 "hma-trend-indicator_new _build.ex4"
#define IndicatorName2 "Beast Super Signal.ex4"
#define IndicatorName3 "uni_cross.ex4"
#define IndicatorName4 "ZigZag_Pointer.ex4"
#define IndicatorName5 "Auto_Fibonacci_Retracement-V3_ALERT.ex4"
#resource "\\Indicators\\"+IndicatorName1; 
#resource "\\Indicators\\"+IndicatorName2; 
#resource "\\Indicators\\"+IndicatorName3; 
#resource "\\Indicators\\"+IndicatorName4; 
#resource "\\Indicators\\"+IndicatorName5;

datetime LastIndicatorSignalTime[][TOTAL_OpenOrExit][TOTAL_IndicatorNum];


   int TO=0,TB=0,TS=0,sts=11;
enum profittype {
   InCurrencyProfit = 0,                                    // In Currency
   InPercentProfit = 1                                      // In Percent
};

enum losstype {
   InCurrencyLoss = 0,                                      // In Currency
   InPercentLoss = 1                                        // In Percent
};


enum indi {
   Off=0,          // OFF
   hma_trend=1,//Hma-trend
   beast=2,        // Beast
 
   uni_cross=3,          // Uni Cross
   zig_Zag_Pointer=4,    // Zig Zag Pointer
    Triggerline=5    // Trigger
};



indi IndicatorType[TOTAL_OpenOrExit][TOTAL_IndicatorNum];
int SignalBarShift[TOTAL_OpenOrExit][TOTAL_IndicatorNum];
ENUM_TIMEFRAMES timeframe[TOTAL_OpenOrExit][TOTAL_IndicatorNum];
string IndicatorName[TOTAL_IndicatorTypes];
string symbol=Symbol();
enum ENUM_UNIT {
   InPips,                 // SL in pips
   InDollars               // SL in dollars
};
enum inditrend {
   withtrend = 0,   // With Trend
   changetrend = 1       // Change Trend
};
inditrend IndicatorTrendType[TOTAL_OpenOrExit][TOTAL_IndicatorNum];

enum STRATEGY{JOIN=1,//Join
 SEPARATE=0//Separate
 };
enum caraclose {
   opposite = 0,   // Indicator Reversal Signal
   sltp = 1,       // Take Profit and Stop Loss
   bar = 2,       // Close With N Bar
   date = 3       // Close With Date
};
enum Answer{Yes,No};// yes or no response enum
enum DYS_WEEK
  {
   Sunday=0,
   Monday=1,
   Tuesday=2,
   Wednesday,
   Thursday=4,
   Friday=5,
   Saturday
  };
  
enum md
  {
   nm=0, //NORMAL
   rf=1, //REVERSE
  };


 md     Mode            = nm;      // Mode
    // SL if strength for pair is crossing or crossed



int                       x_axis                    =0;
int                       y_axis                    =20;

bool                      UseDefaultPairs            = true;              // Use the default 28 pairs
string                    OwnPairs                   = "";                // Comma seperated own pair list

double Px = 0, Sx = 0, Rx = 0, S1x = 0, R1x = 0, S2x = 0, R2x = 0, S3x = 0, R3x = 0;

int TargetReachedForDay=-1;
int ThisDayOfYear=0;  
datetime TMN=0;
datetime NewCandleTime=0;

string postfix="",prefix="";
bool Os,Om,Od,Oc;
bool CloseOP=false;
color  warnatxt = clrAqua;// Warna Text
double HEDING=true; double maxlot,minlot;
ENUM_BASE_CORNER Info_Corner = 0;
color  FontColorUp1 = Yellow,FontColorDn1 = Pink,FontColor = White,FontColorUp2 = LimeGreen,FontColorDn2 = Red;
double DailyProfit=0;
string closeAskedFor ="";
datetime expire_date;
datetime e_d ;
double minlotx;
datetime sendOnce;
double startbalance;
datetime starttime;
bool isNewBar;
bool trade=true; 
string google_urlx;

color highc          = clrRed;     // Colour important news
color mediumc        = clrBlue;    // Colour medium news
color lowc           = clrLime;    // The color of weak news
int   Style          = 2;          // Line style
int   Upd            = 86400;      // Period news updates in seconds

bool  Vtunggal       = false;
bool  Vhigh          = false;
bool  Vmedium        = false;
bool  Vlow           = false;
int   MinBefore=0;
int   MinAfter=0;

int NomNews=0;
string NewsArr[5][3000];
int Now=0;
datetime LastUpd;
string str1;

double harga;
double lastprice;
string jamberita;
string judulberita;
string infoberita=" >>>> check news";

double P1=0,Wp1=0,MNp1=0,P2=0,P3=0,Persentase1=0,Persentase2=0,Persentase3=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

 //extern     string mysimbol = "EURUSD,USDJPY,GBPUSD,AUDUSD,USDCAD,USDCHF,NZDUSD,EURJPY,EURGBP,EURCAD,EURCHF,EURAUD,EURNZD,AUDJPY,CHFJPY,CADJPY,NZDJPY,GBPJPY,GBPCHF,GBPAUD,GBPCAD,CADCHF,AUDCHF,GBPNZD,AUDNZD,AUDCAD,NZDCAD,NZDCHF";
                       

    double day_high = 0;
    double day_low = 0;
    double yesterday_high = 0;
    double yesterday_open = 0;
    double yesterday_low = 0;
    double yesterday_close = 0;
    double today_open = 0;
 //   double cur_day = 0;
//    double prev_day = 0;



      int xc,xpair,xbuy,xsell,xcls,xlot,xpnl,xexp,yc,ypair,ysell,ybuy,ylot,ycls,ypnl,yexp,ytxtb,ytxts,ytxtcls,ytxtpnl,ytxtexp;
      double poexp[100];//= { 0,0.00000000000002,0.000000000000000000003,
      double profitss[100];
      double DayProfit ;
      double BalanceStart;
      double DayPnLPercent;

 
   string sep=",";                // A separator as a character 
   ushort u_sep;                  // The code of the separator character 
  // string result;               // An array to get strings 
datetime _opened_last_time = TimeCurrent() ;
datetime _closed_last_time = TimeCurrent()  ;

//+------------------------------------------------------------------+

string eacomment="realTatino";
int maxcek;
string komentar1="OFF",komentar2="OFF",komentar3="OFF",komentar4="OFF";
string komentar1x="OFF",komentar2x="OFF",komentar3x="OFF",komentar4x="OFF";

 
int mtf1=43200,mtf2=43200,mtf3=43200,mtf4=43200,mtfz=43200;
datetime EA_INIT_TIME=0;

datetime PrevTime[];
int NumOfSymbols;
const int OpenOrExit0 = 0, OpenOrExit1 = 1;
const int IndicatorNum0 = 0, IndicatorNum1 = 1, IndicatorNum2 = 2, IndicatorNum3 = 3,IndicatorNum4=4,IndicatorNum5=5;

enum TIME_LOCK
  {
   closeall,//CLOSE_ALL_TRADES
   closeprofit,//CLOSE_ALL_PROFIT_TRADES
   breakevenprofit//MOVE_PROFIT_TRADES_TO_BREAKEVEN
  };    
   

 enum TRADEMODE{Automatic, Manual, Signal_Only ,None};
 enum TRADE_STYLES{LONG, SHORT,BOTH};
enum  ORDERS_TYPE{ MARKET_ORDERS, LIMIT_ORDERS,STOP_ORDERS};


enum  MONEYMANAGEMENT{ FIX_SIZE, POSITION_SIZE,RISK_PERCENTAGE, MARTINGALE_OR_ANTI_MARTINGALE, LOT_OPTIMIZE
};

int LotDigits; //initialized in OnInit


   double MaxLot = MarketInfo(symbol, MODE_MAXLOT);
   double MinLot = MarketInfo(symbol, MODE_MINLOT);

double Riskpertrade(double SL) //Risk % per trade, SL = relative Stop Loss to calculate risk
  {MaxLot = MarketInfo(symbol, MODE_MAXLOT);
    MinLot = MarketInfo(symbol, MODE_MINLOT);
  double tickvalue = MarketInfo(symbol, MODE_TICKVALUE);
   double ticksize = MarketInfo(symbol, MODE_TICKSIZE);
   double lots = Risk_Percentage * 1.0 / 100 * AccountBalance() / (MaxSL / ticksize * tickvalue);
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }
double Martingale_Size() //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
  MaxLot = MarketInfo(symbol, MODE_MAXLOT);
  MinLot = MarketInfo(symbol, MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
         lots = orderlots * MM_Martingale_LossFactor;
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots = MM_Martingale_Start;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }
double PositionSize() //position sizing
  {
    MaxLot = MarketInfo(symbol, MODE_MAXLOT);
    MinLot = MarketInfo(symbol, MODE_MINLOT);
   double lots = AccountBalance() / Position_size;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }
    double  TradingLots =0.01;
double TradeSize(MONEYMANAGEMENT moneymanagement){

switch(moneymanagement){


case RISK_PERCENTAGE: return Riskpertrade( MaxSL); break;


case POSITION_SIZE:  return  PositionSize();break;


case MARTINGALE_OR_ANTI_MARTINGALE: Martingale_Size(); break;



case LOT_OPTIMIZE:  
   
     
  
    TradingLots= (AccountBalance()*Risk_in_dolloar/100)/1000;
     
   if(TradingLots>MaxLot)
     {
      TradingLots=MaxLot;
     }
   if(TradingLots<MinLot)
     {
      TradingLots=MinLot;
     }
   return TradingLots=NormalizeDouble(TradingLots,2);
break;
default : return 0.01; break;

  }
  return 0.01;
}
 

 int vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
//+------------------------------------------------------------------+

      double vpoint = NormalizeDouble(MarketInfo(symbol,MODE_POINT),vdigits);
double ask= NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits);
 double bid=NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits);


string pcom1="",pcom2="",pcom3="",pcom4="";
string pcom1x="",pcom2x="",pcom3x="",pcom4x="";
         int xSell1=0;
         int xSell2=0;
         int xSell3=0;
         int xSell4=0;
         int xBuy1=0;
         int xBuy2=0;
         int xBuy3=0;
         int xBuy4=0;
        int sinyalb1 ;
        int sinyalb2 ;
        int sinyalb3 ;
        int sinyalb4 ;
          int sinyal1;
          int sinyal2;
          int sinyal3;
          int sinyal4;
bool TradeDays()
{ 
   if(SET_TRADING_DAYS == No)
     return(true);
     
   bool ret=false;
   int today=DayOfWeek();
   
   if(EA_START_DAY<EA_STOP_DAY)
    {
     if(today>EA_START_DAY && today<EA_STOP_DAY)
       return(true);
     else
       if(today==EA_START_DAY){
        if(TimeCurrent()>=EA_START_TIME)
           return(true);
        else
           return(false); 
        }  
       else
        if(today==EA_STOP_DAY){
         if(TimeCurrent()<EA_STOP_TIME)
            return(true);
         else
            return(false); 
         }
     }
   else
     if(EA_STOP_DAY<EA_START_DAY)
      {
       if(today>EA_START_DAY || today<EA_STOP_DAY)
         return(true);
       else
         if(today==EA_START_DAY){
           if(TimeCurrent()>=EA_START_TIME)
             return(true);
           else
             return(false); 
          }  
        else
         if(today==EA_STOP_DAY){
          if(TimeCurrent()<EA_STOP_TIME)
            return(true);
          else
            return(false); 
         }
     } 
    else
      if(EA_STOP_DAY==EA_START_DAY)
       {
        datetime st=EA_START_TIME;
        datetime et=EA_STOP_TIME;
        
        if(et>st){ 
          if(today!=EA_STOP_DAY)
             return(false);
          else
            if(TimeCurrent()>=st && TimeCurrent()<et)
               return(true);
            else
               return(false); 
         }
        else
         {
          if(today!=EA_STOP_DAY)
            return(true);
          else
            if(TimeCurrent()>=et && TimeCurrent()<st)
              return(false);
            else
              return(true);
         }
         
       }
        return ret;
       }


void DeleteByDuration(int sec) //delete pending order after time since placing the order
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
        }
     }
   if(success) messages= "Orders deleted by duration: "+symbol+" Magic #"+IntegerToString(MagicNumber); smartBot.SendMessageToChannel(InpChannel,messages);
  }
int  EnterSignal=0;
void DeleteByDistance(double distance) //delete pending order if price went too far from it
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      double price = (OrderType() % 2 == 1) ? NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits) : NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits);
      if(MathAbs(OrderOpenPrice() - price) <= distance) continue;
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
        }
     }
   if(success) myAlert("order", "Orders deleted by distance: "+symbol+" Magic #"+IntegerToString(MagicNumber));
  }


void CloseTradesAtPL(double PL) //close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
  {
   double totalPL = TotalOpenProfit(0);
   if((PL > 0 && totalPL >= PL) || (PL < 0 && totalPL <= PL))
     {
      myOrderClose(OP_BUY, 100, "");
      myOrderClose(OP_SELL, 100, "");
     }
  }


void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
      Print(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("breakout", type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("breakout.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "modify")
     {
      if(Audible_Alerts) Alert(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("breakout", type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | breakout @ "+symbol+","+IntegerToString(Period())+" | "+message);
     }
  }

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != symbol || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == symbol && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(ticket)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {int count=0;
 
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == symbol && OrderMagicNumber() == MagicNumber)
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profits && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
            break;
         count++;
        }
     }
   return(count >= n);
  }

double TotalOpenProfit(int direction)
  {
   double result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)   
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != symbol || OrderMagicNumber() != MagicNumber) continue;
      if((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
      result += OrderProfit();
     }
   return(result);
  }



void myOrderClose(int type, double volumepercent, string ordername) //close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
  {
   if(!IsTradeAllowed()) return;
   if (type > 1)
     {
      myAlert("error", "Invalid type in myOrderClose");
      return;
     }
   bool success = false;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != symbol || OrderType() != type) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      double price = (type == OP_SELL) ? NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits) :  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits);
      double volume = NormalizeDouble(OrderLots()*volumepercent * 1.0 / 100, LotDigits);
      if (NormalizeDouble(volume, LotDigits) == 0) continue;
      success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, vdigits), MaxSlippage, clrWhite);
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderClose"+ordername_+" failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
        }
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   if(success) myAlert("order", "Orders closed"+ordername_+": "+typestr[type]+" "+symbol+" Magic #"+IntegerToString(MagicNumber));
 //  messages= "Orders closed"+ordername_+": "+typestr[type]+" "+symbol+" Magic #"+IntegerToString(MagicNumber);smartBot.SendMessageToChannel(InpChannel,messages);
  }

void TrailingStopTrail(int type, double TSs, double step, bool aboveBE, double aboveBEval) //set Stop Loss to "TS" if price is going your way with "step"
  {
   int total = OrdersTotal();
   double ts = NormalizeDouble(TSs, vdigits);
   step = NormalizeDouble(step, vdigits);
   for(int i = total-1; i >= 0; i--)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != symbol || OrderType() != type) continue;
	  RefreshRates();
      if(type == OP_BUY && (!aboveBE ||  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits) > OrderOpenPrice() + ts + aboveBEval) && (NormalizeDouble(OrderStopLoss(), vdigits) <= 0 ||  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits) > OrderStopLoss() + TS + step))
         myOrderModify(OrderTicket(),  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits) - ts, 0);
      else if(type == OP_SELL && (!aboveBE ||  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits) < OrderOpenPrice() - ts- aboveBEval) && (NormalizeDouble(OrderStopLoss(), vdigits) <= 0 ||  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits) < OrderStopLoss() - TS - step))
         myOrderModify(OrderTicket(),  NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits) +ts, 0);
     }
  }

//---
CComment       comment;

ENUM_RUN_MODE  run_mode;
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if(reason==REASON_CLOSE ||
         reason==REASON_PROGRAM ||
         reason==REASON_PARAMETERS ||
         reason==REASON_REMOVE ||
         reason==REASON_RECOMPILE ||
         reason==REASON_ACCOUNT ||
         reason==REASON_INITFAILED)
   {
      time_check=0;
      comment.Destroy();
   }
//---
   EventKillTimer();
   ChartRedraw();
}
//+------------------------------------------------------------------+
//|   OnChartEvent                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   comment.OnChartEvent(id,lparam,dparam,sparam);
    if(sparam=="Close All")
     {
      string txt="Do you want close all order pair ?";
      PlaySound("alert.wav");
      int ret=MessageBox(txt,"Close ALL",MB_YESNO);
      if(ret==IDYES)
        {
         CloseAllm();
        }
      ObjectSetInteger(0,"Close All",OBJPROP_STATE,false);
     }

   else
      if(sparam=="Close Profit")
        {
         string txt="Do you want close all order Profit?";
         PlaySound("alert.wav");
         int ret=MessageBox(txt,"Close Order Profit",MB_YESNO);
         if(ret==IDYES)
           {
            CloseAllm(1);
           }
         ObjectSetInteger(0,"Close Profit",OBJPROP_STATE,false);
        }
}
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
{

//--- show init error
   if(init_error!=0)
   {
      //--- show error on display
      CustomInfo info;
      GetCustomInfo(info,init_error,InpLanguage);

      //---
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s","TradeExpert","1"),      clrBlue);
      comment.SetText(1,info.text1, clrWhite);
      if(info.text2!="")
         comment.SetText(2,info.text2,clrGreen);
      comment.Show();

      return;
   }

//--- show web error
   if(run_mode==RUN_LIVE)
   {

      //--- check bot registration
      if(time_check<TimeLocal()-PeriodSeconds(PERIOD_H1))
      {
         time_check=TimeLocal();
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
         {
            //---
            web_error=smartBot.GetMe();
            if(web_error!=0)
            {
               //---
               if(web_error==ERR_NOT_ACTIVE)
               {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+300;
               }
               //---
               else
               {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+5;
               }
            }
         }
         else
         {
            web_error=ERR_NOT_CONNECTED;
            time_check=0;
         }
      }

      //--- show error
      if(web_error!=0)
      {
         comment.Clear();
         comment.SetText(0,StringFormat("%s v.%s","TRADE_EXPERT",1),clrGold);

         if(
#ifdef __MQL4__ web_error==ERR_FUNCTION_NOT_CONFIRMED #endif
#ifdef __MQL5__ web_error==ERR_FUNCTION_NOT_ALLOWED #endif
         )
         {
            time_check=0;

            CustomInfo info= {0};
            GetCustomInfo(info,web_error,InpLanguage);
            comment.SetText(1,info.text1,clrWhite);
            comment.SetText(2,info.text2, clrWheat);
         }
         else
            comment.SetText(1,GetErrorDescription(web_error,InpLanguage),clrWheat);

         comment.Show();
         return;
      }
   }

//---
   smartBot.GetUpdates();

//---
   if(run_mode==RUN_LIVE)
   {
      comment.Clear();
      comment.SetText(0,StringFormat("%s v.%s","TRADE_EXPERT",1),clrGreen);
      comment.SetText(1,StringFormat("%s: %s",(InpLanguage==LANGUAGE_EN)?"Bot Name":"Имя Бота",smartBot.Name()),clrGoldenrod);
      comment.SetText(2,StringFormat("%s: %d",(InpLanguage==LANGUAGE_EN)?"Chats":"Чаты",smartBot.ChatsTotal()),clrAqua);
      comment.Show();
   }

//---
  smartBot.ProcessMessages();
}
//+------------------------------------------------------------------+
//|   GetCustomInfo                                                  |
//+------------------------------------------------------------------+
void GetCustomInfo(CustomInfo &info,
                   const int _error_code,
                   const ENUM_LANGUAGES _lang)
{
   switch(_error_code)
   {
#ifdef __MQL5__
   case ERR_FUNCTION_NOT_ALLOWED:
      info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
      info.text2 = TELEGRAM_BASE_URL;
      break;
#endif
#ifdef __MQL4__
   case ERR_FUNCTION_NOT_CONFIRMED:
      info.text1 = (_lang==LANGUAGE_EN)?"The URL does not allowed for WebRequest":"Этого URL нет в списке для WebRequest.";
      info.text2 = TELEGRAM_BASE_URL;
      break;
#endif

   case ERR_TOKEN_ISEMPTY:
      info.text1 = (_lang==LANGUAGE_EN)?"The 'Token' parameter is empty.":"Параметр 'Token' пуст.";
      info.text2 = (_lang==LANGUAGE_EN)?"Please fill this parameter.":"Пожалуйста задайте значение для этого параметра.";
      break;
   }

}
//+------------------------------------------------------------------+


input ENUM_LANGUAGES InpLanguage=LANGUAGE_EN;
input ENUM_LICENSE_TYPE LicenseMode=LICENSE_DEMO;//EA License Mode
input string License="none";// EA License
input string T1;//========= TRADES MODES BOT AND CHANNELS SETTINGS ====================

input bool UseBot=false; // Use Bot  ? (TRUE/FALSE)
input string UserName="noel";
input string  InpUserNameFilter="noel, Olusegun";
input ENUM_UPDATE_MODE InpUpdateMode=UPDATE_FAST ;//BOT UPDATE MODE
input bool SendScreenshot=true;
input string InpChannel =""; //Channel
input long InpChatId=0;
input string InpTocken ="";//Token
input  string InpTemplates="ADX;Momentum; RSI;CCI;ZigZag_Pointer";  //Templates
input string InpIndiNAME="ZigZag_Pointer";//Indicator name for screenshot display
extern string     mysymbol          ="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";//Currencies list
string mysymbolList[];
extern bool UseAllsymbol=true;//Use all symbols in list ?(true/false)
 input string  ts1; //==========================  TRADES  SETTINGS ==========================================
 input TRADEMODE TradeMode=Automatic;//Mode 
input TRADE_STYLES Trade_Styles=BOTH; //Trade Style (long ,short,both)
input  ORDERS_TYPE Order_Type=MARKET_ORDERS; //Orders Types;
input STRATEGY InpStrategy=JOIN;

input bool UsePartialClose                      = true;                  // Use Partial Close
input ENUM_UNIT PartialCloseUnit                = InPips;             // Partial Close Unit
input double PartialCloseTrigger                = 40;                    // Partial Close after
input double PartialClosePercent                = 0.5;                   // Percentage of lot size to close
input int MaxNoPartialClose                     = 1;                     // Max No of Partial Close
input string ___TRADE_MONITORING_TRAILING___    = "";                    // - Trailing Stop Parameters
input bool UseTrailingStop                      = true;                  // Use Trailing Stop
input ENUM_UNIT TrailingUnit                    = InPips;             // Trailing Unit
input double TrailingStart                      = 35;                   // Trailing Activated After
input double TrailingStep                       = 10;                   // Trailing Step
input double TrailingStop                       = 2;                    // Trailing Stop
input string ___TRADE_MONITORING_BE_________    = "";                    // - Break Even Parameters
input bool UseBreakEven                         = true;                  // Use Break Even
input ENUM_UNIT BreakEvenUnit                   = InPips;             // Break Even Unit
input double BreakEvenTrigger                   = 30;                   // Break Even Trigger
input double BreakEvenProfit                    = 1;                   // Break Even Profit
input int MaxNoBreakEven                        = 1;                     // Max No of Break Even
extern Answer     deletepo          = No;          //Delete Pending Order 
extern int        orderexp          = 3;           //Pending order Experation (inBars)
extern caraclose  closetype         = opposite;        //Choose Closing Type

extern bool        OpenNewBarIndicator           = false;        //Open New Bar Indicator

input bool DebugTrailingStop         = true;           // Trailing Stop Infos in Journal
input bool DebugBreakEven            = true;           // Break Even Infos in Journal
input bool DebugUnit                 = true;           // SL TP Trail BE Units Infos in Journal (in tester)
input bool DebugPartialClose         = true;           // Partial close Infos in Journal
input Answer UseFibo_TP=No;//Use Fibo take profit?(yes/no)
  string    ftp               = "Set GMT offset";//=====Use Fibo TP=======
extern int        GMTshift          = 3;//GMT Shift Fibo SnR

extern Answer      sendTradesignal       = Yes; //Send Strategy Trade Signal

extern double MaxSpread = 3; //Spread
extern int MaxSlippage = 2; //Slippage

extern int MagicNumber = 1968098;// Magic Number
extern double MinTP = 50;//Minimum Take Profit
extern double MinSL = 50;//Minimum Take profit

extern double MaxTP = 200;//Take profit
extern double MaxSL = 200;//Stop Loss
extern bool closeTradesAtPL=false;//Use Close trade
extern double CloseAtPL = 50; //Close trade if total profit & loss exceed
extern double PriceTooClose = 10;

extern int        orderdistance     = 30;          //Order Distance 
extern int MaxOpenTrades = 4;
extern int MaxLongTrades = 2;
extern int MaxShortTrades = 1;
extern int MaxPendingOrders = 5;
extern int MaxLongPendingOrders = 5;
 double Trail_Above =TrailingStart;//Trailing above
  double Trail_Step = TrailingStep;// Trailing steps
extern int MaxShortPendingOrders = 5;
extern int PendingOrderExpirationBars = 12; //pending order expiration
extern double DeleteOrderAtDistance = 100; //delete order when too far from current price
extern bool Hedging = true;

extern int OrderRetry = 3; //# Of retries if sending order returns error
extern int OrderWait = 500; //# Of seconds to wait if sending order returns error

 input string  ts2; //==========================  MONEY MANAGEMENT  SETTINGS==========================================

input MONEYMANAGEMENT InpMoneyManagement=LOT_OPTIMIZE;//Select Money Management system

extern int        minbalance        =500;           //Min Euquity Bal to open Trade 
input string M1;//=========== FIX SIZE ========
input double Fixed_size=0.02; //Fix Size

input string  M2;// LOT OPTIMIZE

extern double     SubLots           = 0.03;        //Sub Lots
input double  Risk_in_dolloar=10;//Risk (in dolloar $)
input string M3;//Risk % Per Trade
input double   Risk_Percentage=2; // Risk %

input string M4;//========== POSITION SIZE ==========
input double  Position_size=4000; //Position Size

input string M5;//======MARTINGALE /ANTIMARTINGALE===============
extern double MM_Martingale_Start = 0.01;// Init lot
extern  double MM_Martingale_ProfitFactor = 1;//Profit Factor  ( Example :x 4)
extern  double MM_Martingale_LossFactor = 2;// Losses Factor (Example : x 3)
extern bool MM_Martingale_RestartProfit = true;//Allowed restart profit
extern bool MM_Martingale_RestartLoss = true;//Allowed restart losses
extern int MM_Martingale_RestartLosses = 10;//Number of time to restart losses
extern int MM_Martingale_RestartProfits = 10;//Number of time to restart profits
input string  ts3; //==========================  TIME MANAGEMENT  SETTINGS==========================================

extern string  h1                   ="===Time Management System==="; // =========Monday==========
input  Answer   SET_TRADING_DAYS     = No;// Set trading days ?(yes/no)
input  DYS_WEEK EA_START_DAY        = Sunday;//Start day
input datetime EA_START_TIME          ;// Starting time
input DYS_WEEK EA_STOP_DAY          = Friday;//Stop Day Of Week
input datetime EA_STOP_TIME          ;//Stopping time
input TIME_LOCK EA_TIME_LOCK_ACTION = closeall;// Time Lock Action
extern bool Send_Email = true; //Send email ?(true/false)
extern bool Audible_Alerts = true;
extern bool Push_Notifications = true;
double myPoint; //initialized in OnInit
extern string  sd1;///////////Hma-trend-indicator SETTING/////////
extern int       period=15;
extern int       method=3;                        
extern int       pricess=0;  



input string BEAST_SETTINGS="/////////////////";
input int BEAST_Depth=60;
input int BEAST_Deviation=5;
input int BEAST_BackStep=4;
input int BEAST_StochasticLen=7;
input double BEAST_StochasticFilter=0;
input double BEAST_OverBoughtLevel =70;
input double BEAST_OverSoldLevel = 40;
input int BEAST_MATrendLinePeriod =10;
input ENUM_MA_METHOD  BEAST_MATrendLineMethod =MODE_SMA;
input ENUM_APPLIED_PRICE BEAST_MATrendLinePrice =PRICE_CLOSE;
input int BEAST_MAPerod=15;
input int BEAST_MAShift=0;
input ENUM_MA_METHOD BEAST_MAMethod=MODE_SMA;
input ENUM_APPLIED_PRICE BEAST_MAPrice=PRICE_CLOSE;
input  bool BEAST_alert=false;
input bool BEAST_push=false;
input  bool BEAST_mail=false;
input int BEAST_arrow=50;
input string DD1; ////TRIGGERLINES_SETTINGS"/////////////////";

extern int Rperiod = 15;
extern int LSMA_Period = 5;

input string induniSett = "+++++++ Unicross Settings +++++++";//+++++++ Unicross Settings +++++++
   extern   bool UseSound              = TRUE;           // Alerts plays a sound ? 
    extern  bool TypeChart             = TRUE;           // Alerts displays on screen ?
    extern  bool UseAlert              = false;           // Use alert?
      extern string NameFileSound       = "alert.wav";     // Sound filename
input int T3Period               = 14;              // T3 Period
input ENUM_APPLIED_PRICE T3Price = PRICE_CLOSE;     // T3 Source
input double  bFactor             = 0.618;           // T3 b Factor
input int Snake_HalfCycle        = 5;               // Snake_HalfCycle = 4...10 or other
enum ENUM_CROSSING_MODE {
   T3CrossingSnake,
   SnakeCrossingT3
};
input ENUM_CROSSING_MODE Inverse = T3CrossingSnake; // 0=T3 crossing Snake, 1=Snake crossing T3
input int DeltaForSell           = 0;               // Delta for sell signal
input int DeltaForBuy            = 0;               // Delta for buy signal
   input   double ArrowOffset         = 0.5;             // Arrow vertical offset
   input   int    Maxbars             = 500;              // Lookback
input string ZIGZAG_POINTER_SETTINGS="/////////////////";


input int               InpDepth = 62;         // Depth 
input int           InpDeviation = 15;         // Deviation
input int            InpBackstep = 9;         // Backstep
input Answer                 alerts = Yes;        // Display Alerts / Messages (Yes) or (No)
input Answer             EmailAlert = Yes;         // Email Alert (Yes) or (No)
input int             alertonbar = 3;          // Alert On Bar after Limit
input  Answer               sendnotify =Yes;         // Send Notification (Yes) or (No)
input  Answer             displayinfo = Yes;        // Display Trade Info
//---

extern string  AturNews             ="==================="; // =========IN THE NEWS FILTER==========
extern bool    AvoidNews            = false;                // News Filter
extern bool    CloseBeforNews       =false;                // Close and Stop Order Before News
 extern Answer telegram=Yes;
extern Answer      sendnews         = Yes; //Send News Alert
extern Answer      sendorder        = Yes; //Send Trade Order
extern Answer     sendclose        = Yes; //Send Close Order
extern Answer      sendsignal       = Yes; //Send Single Indicator Signal
input bool sendberita = true;

 int      GMTplus=3;     // Your Time Zone, GMT (for news)
extern string  InvestingUrl         ="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";// Source Url Investing.Com
extern  int    AfterNewsStop        =60;                    // Stop Trading Before News Release (in Minutes)
extern  int    BeforeNewsStop       =60;                    // Start Trading After News Release (in Minutes)
extern bool    NewsLight            = true;                // Low Impact
extern bool    NewsMedium           = true;                // Middle News
extern bool    NewsHard             = true;                 // High Impact News
input  bool    NewsTunggal          =true; // Enable Keyword News
extern string  judulnews            ="FOMC"; // Keyword News
 int  offsets;     // Your Time Zone, GMT (for news)
extern string  NewsSymb             ="USD,EUR,GBP,CHF,CAD,AUD,NZD,JPY"; //Currency to display the news  
extern bool    CurrencyOnly         = false;                 // Only the current currencies
extern bool    DrawLines            = true;                 // Draw lines on the chart
extern bool    Next                 = true;                // Draw only the future of news line
extern bool    Signal               = false;                // Signals on the upcoming news
extern string noterf          = "-----< Other >-----";//=========================================


extern color _tableHeader=clrWhite;
extern color _Header = clrBlue;
extern color _SellSignal = clrRed;
extern color _BuySignal = clrBlue;
extern color _Neutral = clrGray;
extern color _cSymbol = clrPowderBlue;
extern color _Separator = clrMediumPurple;
string prefix2 = "capital_";
//extern bool     snr           = TRUE;           //Use Support & Resistance
extern bool    showfibo       = true;           // Show SnR Fibo Line
 extern  ENUM_TIMEFRAMES snrperiod     = PERIOD_D1;         //Support & Resistance Time Frame
///////////////////////////////////////////////////
extern int Corner = 0;
extern int dys = 15;
input string  Gfgg="";//=============================  Chart Parameters ==================================

extern  Answer              Set Chart Colors                                   = Yes;// Set Chart Colors(yes/no)?

input int ChartHigth =800;//Set chart hight
input int ChartWidth=1280;//Set Chart widht 

input color       BackGround                                         = clrBeige;//Set BackGround   colors 
input color       ForeGround                                         = Black;//Set ForeGround   colors   
input color       Bull Candle                                        = clrGold;// Bull Candle Color    
input color       Bear Candle                                        = Red;//Bear Candle Color
extern string                                                        ="TRADE OBJECTS SETTING";
input    long Bear_Outline=1;
input long Bull_Outline=0;
extern color      color1            = clrGreenYellow;             // EA's name color
extern color      color2            = clrDarkOrange;             // EA's balance & info color
extern color      color3            = clrBeige;             // EA's profit color
extern color      color4            = clrMagenta;             // EA's loss color
extern color      color5            = clrBlue;          // Head Label Color
extern color      color6            = clrBlack;             // Main Label Color
extern int        Xordinate         = 20;                   // X 
extern int        Yordinate         = 20;                   // Y 

extern string strategy1        = "=====Open Indicator I====="; //====Entry Strategy Indicator_I=====

extern indi indikator1     =hma_trend;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe1 = PERIOD_M30;// Entry Time Frame
extern inditrend indicatortrend1 = withtrend;//Type Of Entry
 string comment1           = "B_M30";//Comment
extern int shift1                = 1;//Bar shift

extern string strategy2        = "=====Open Indicator 2====="; //====Entry Strategy Indicator_2=====
extern indi indikator2     =beast;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe2 = PERIOD_M30;// Entry Time Frame
extern inditrend indicatortrend2 = withtrend;//Type Of Entry
 string comment2           = "B_H1";//Comment
extern int shift2                = 1;//Bar shift

extern string strategy3        = "=====Open Indicator 3====="; //====Entry Strategy Indicator_3=====
extern indi indikator3     =uni_cross;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe3 = PERIOD_M30;// Entry Time Frame_1
extern inditrend indicatortrend3 = changetrend;//Type Of Entry
 string comment3           = "Z_H1";//Comment
extern int shift3                = 1;//Bar shift

extern string strategy4        = "=====Open Indicator 4====="; //====Entry Strategy Indicator_4=====
extern indi indikator4     =zig_Zag_Pointer;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe4 = PERIOD_M30;// Entry Time Frame_1
extern inditrend indicatortrend4 = changetrend;//Type Of Entry
 string comment4           = "F_H1";//Comment
extern int shift4                = 1;//Bar shift

extern string strategy1x        = "=====Exit Indicator 1====="; //====Exit Strategy Indicator_1=====
extern indi indikator1x     =uni_cross;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe1x = PERIOD_M30;// Entry Time Frame_1
extern inditrend indicatortrend1x = withtrend;//Type Of Entry

extern string strategy2x        = "=====Exit Indicator 2====="; //====Exit Strategy Indicator_2=====
extern indi indikator2x     =zig_Zag_Pointer;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe2x = PERIOD_M30;// Entry Time Frame_1
 extern inditrend indicatortrend2x = changetrend;//Type Of Entry

extern string strategy3x        = "=====Exit Indicator 3====="; //====Exit Strategy Indicator_3=====
extern indi indikator3x     =Off;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe3x =PERIOD_H1;// Entry Time Frame_1
extern inditrend indicatortrend3x = changetrend;//Type Of Entry

extern string strategy4x        = "=====Exit Indicator 4====="; //====Exit Strategy Indicator_4=====
extern indi indikator4x     =Off;//Select desire Indicator from installed indicators Also This is Master
extern ENUM_TIMEFRAMES timeframe4x = PERIOD_H1;// Entry Time Frame_1
 extern inditrend indicatortrend4x = changetrend;//Type Of Entry
bool NewsFilter = false;
string _token=InpTocken;


int OnInit()
{

//---
   run_mode=GetRunMode();

//--- stop working in tester
   if(run_mode!=RUN_LIVE)
   {
      PrintError(ERR_RUN_LIMITATION,InpLanguage);
      return(INIT_FAILED);
   }

   int y=40;
   if(ChartGetInteger(0,CHART_SHOW_ONE_CLICK))
      y=120;
   comment.Create("myPanel",20,y);
   comment.SetColor(clrDimGray,clrBlack,220);
//--- set language
   smartBot.Language(InpLanguage);

//--- set token
   init_error=smartBot.Token(InpTocken);

//--- set filter
   smartBot.UserNameFilter(InpUserNameFilter);

//--- set templates
   smartBot.Templates(InpTemplates);

//--- set timer
   int timer_ms=3000;
   switch(InpUpdateMode)
   {
   case UPDATE_FAST:
      timer_ms=1000;
      break;
   case UPDATE_NORMAL:
      timer_ms=2000;
      break;
   case UPDATE_SLOW:
      timer_ms=3000;
      break;
   default:
      timer_ms=3000;
      break;
   };
 
   
 
  
  ChartColorSet();

 
   
   
     
 if(TradeMode==Automatic){

    
   HUD();
   HUD2();
  
   //initialize myPoint
   myPoint = vpoint;
 
     EA_INIT_TIME=TimeCurrent();
   
   ObjectsDeleteAll(0,-1,OBJ_LABEL);
 _opened_last_time = TimeCurrent() ;//cek tg
 _closed_last_time = TimeCurrent()  ;//cek tg
 sendOnce=TimeCurrent();
 
 mtfz=MathMin(MathMin(MathMin(mtf1,mtf2),mtf3),mtf4);



   startbalance = AccountBalance();
   starttime = TimeCurrent();
   if ( CloseBeforNews ) NewsFilter = True; else NewsFilter = AvoidNews;

   minlot=MarketInfo(symbol,MODE_MINLOT);
   maxlot=MarketInfo(symbol,MODE_MAXLOT);

  if (CurrencyOnly) NewsSymb ="";
   if(StringLen(NewsSymb)>1)str1=NewsSymb; 
   else str1=Symbol();

   Vtunggal = NewsTunggal;
   Vhigh=NewsHard;
   Vmedium=NewsMedium;
   Vlow=NewsLight;
   
   MinBefore=BeforeNewsStop;
   MinAfter=AfterNewsStop;

   string sf="";
   Comment("");
   int v2 = (StringLen(symbol)-6);
   if(v2>0)
     {
      sf = StringSubstr(symbol,6,v2);
     }
   postfix=sf;

   TMN=0;
   //NewCandleTime=TimeCurrent();

   //  ManageTrade();
   
    e_d = expire_date;
 
   //displaystart();
  // GUI();
    NewCandleTime=TimeCurrent();
 //  EventSetTimer(1);

 

 IndicatorName[0] = IndicatorName0;
   ArrayResize(PrevTime, NumOfSymbols);
   ArrayResize(LastIndicatorSignalTime, NumOfSymbols);
   
     
   //initialize LotDigits
   double LotStep = MarketInfo(symbol, MODE_LOTSTEP);
   if(NormalizeDouble(LotStep, 3) == round(LotStep))
      LotDigits = 0;
   else if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
      LotDigits = 1;
   else if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep))
      LotDigits = 2;
   else LotDigits = 3;
   MaxSL = MaxSL * myPoint;
   MinSL = MinSL * myPoint;
   MaxTP = MaxTP * myPoint;
   MinTP = MinTP * myPoint;
 
}  EventSetMillisecondTimer(timer_ms);
   OnTimer();
//--- done
   return(INIT_SUCCEEDED);
  }




//////////////////////////////ENTER  BUY||SELL SIGNAL 1//////////////////////////////

string Signal1(){   //buy sell 1
double buy, sell;


buy=iCustom(symbol,timeframe1, (string)IndicatorName1,period,method, pricess, indicatortrend1,shift1); 
sell=iCustom(symbol,timeframe1,(string)IndicatorName1,
       period,
       method,                        
     pricess,indicatortrend1 ,shift1); 


if(buy>0){return"BUY";};
if(sell<0){return"SELL";}

return "NO SIGNAL";
}



//////////////////////////////ENTER  BUY||SELL SIGNAL 2//////////////////////////////

string Signal2(){
double buy=iCustom(symbol,timeframe2, IndicatorName2,
Rperiod ,LSMA_Period,indicatortrend2,shift2);
double sell=iCustom(symbol,timeframe2,IndicatorName2,
Rperiod ,LSMA_Period,indicatortrend2,shift2);

if(buy>0){return"BUY";};
 if(sell<0){return"SELL";}

return "NO SIGNAL";
}


//////////////////////////////ENTER  BUY||SELL SIGNAL 3//////////////////////////////

string Signal3(){//unicross
double buy=iCustom(symbol,timeframe3, IndicatorName3,
 UseSound    ,
 TypeChart  ,       
 UseAlert   ,
 NameFileSound  , T3Period  ,           
T3Price,
bFactor ,
 Snake_HalfCycle       ,
 Inverse ,
DeltaForSell        ,
 DeltaForBuy     ,
  ArrowOffset        ,
               Maxbars  ,       
indicatortrend3,shift3); 

double sell=iCustom(symbol,timeframe3,IndicatorName3,
 UseSound    ,
 TypeChart  ,       
 UseAlert   ,
 NameFileSound  , T3Period  ,           
T3Price,
bFactor ,
 Snake_HalfCycle       ,
 Inverse ,
DeltaForSell        ,
 DeltaForBuy     ,
  ArrowOffset        ,
               Maxbars      ,   
indicatortrend3,shift3); 

if(buy>=0){return"BUY";};if(sell<0){return"SELL";}
printf(  "BUY"+(string)buy+ "sell"+(string)sell);
return "NO SIGNAL";
}


//////////////////////////////ENTER  BUY||SELL SIGNAL 4//////////////////////////////
string Signal4(){//zigzag pointer
 double buy=iCustom(symbol,timeframe4,IndicatorName4,period,InpDepth, 
        InpDeviation ,
        InpBackstep ,
                alerts ,
 EmailAlert ,
 alertonbar,
 sendnotify ,  indicatortrend4,shift4);
 
 double sell=iCustom(symbol,timeframe4, IndicatorName4,period,InpDepth,   InpDeviation , InpBackstep , alerts ,EmailAlert ,alertonbar,sendnotify ,  indicatortrend4,shift4);
 
if(buy>0){return"BUY";};

 if(sell<0){return"SELL";}

return "NO SIGNAL";
}


string TradeSignal(){//joint     trade signals
 
 
 bool check=false;
if(InpStrategy==JOIN){
 if(Signal1()=="SELL"&&Signal2()=="SELL"&&Signal3()=="SELL"&&Signal4()=="SELL"){

tradeReason= ">>>>>> Buy Entry Alert  <<<<<<<\nStrategy :"+EnumToString(InpStrategy)+


StringFormat("Name: Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Sell\nPrice: %s\nTime: %s",
                                 symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits),
                                 TimeToString(TimeCurrent()))+
         

"\nReasons: \n"+IndicatorName1 +"\nTimeFrame1:  "+ EnumToString(timeframe1) +"\nSignal1: "+Signal1()+"\n"+
"\n"+IndicatorName2 +"\nTimeFrame2:"+EnumToString(timeframe2)  +"\nSignal2: "+Signal2()+"\n"+IndicatorName3 +"\nTimeFrame3:"+EnumToString(timeframe3) +"\nSignal3: "+Signal3()+"\n"+IndicatorName4 +"\nTimeFrame4:"+EnumToString(timeframe4) +"\nSignal4: "+Signal4()+"\n";

smartBot.SendMessageToChannel(InpChannel,tradeReason);

smartBot.SendScreenShotToChannel(InpChannel,symbol,PERIOD_CURRENT,InpIndiNAME,SendScreenshot);
string mytrade="tradePic";int count=0;
//+---------------------------------------------------------------------------------------------+
  WindowScreenShot(mytrade,ChartWidth,ChartHigth,-1,-1,-1);
     smartBot.SendPhotoToChannel(mytrade,InpChannel,mytrade,NULL,FALSE,10000);
     
     smartBot.SendMessage(InpChatId,tradeReason);
check=true;
return "SELL";


}else if(Signal1()=="BUY"&&Signal2()=="BUY"&&Signal3()=="BUY"&&Signal4()=="BUY"){

    smartBot.SendMessage(chats.m_id,tradeReason);
tradeReason= ">>>>>> Buy Entry Alert  <<<<<<<\nStrategy :"+EnumToString(InpStrategy)+


StringFormat("Name: Signal\xF4E3\nSymbol: %s\nTimeframe: %s\nType: Buy\nPrice: %s\nTime: %s",
                                 symbol,
                                 StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
                                 DoubleToString(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits),
                                 TimeToString(TimeCurrent()))+
         

"\nReasons: \n"+IndicatorName1 +"\nTimeFrame1:  "+ EnumToString(timeframe1) +"\nSignal1: "+Signal1()+"\n"+
"\n"+IndicatorName2 +"\nTimeFrame2:"+EnumToString(timeframe2)  +"\nSignal2: "+Signal2()+"\n"+IndicatorName3 +"\nTimeFrame3:"+EnumToString(timeframe3) +"\nSignal3: "+Signal3()+"\n"+IndicatorName4 +"\nTimeFrame4:"+EnumToString(timeframe4) +"\nSignal4: "+Signal4()+"\n";

check=true;
smartBot.SendMessageToChannel(InpChannel,tradeReason);smartBot.SendScreenShotToChannel(InpChannel,symbol,PERIOD_CURRENT,InpIndiNAME,SendScreenshot);string mytrade="tradePic";int count=0;
//+---------------------------------------------------------------------------------------------+
  WindowScreenShot(mytrade,ChartWidth,ChartHigth,-1,-1,-1);
     smartBot.SendPhotoToChannel(mytrade,InpChannel,mytrade,NULL,FALSE,10000);
    smartBot.SendMessage(InpChatId,tradeReason);
    smartBot.SendScreenShot(InpChatId,symbol,PERIOD_CURRENT,InpIndiNAME,SendScreenshot);

return "BUY";

}




}else if(InpStrategy==SEPARATE){



check=true;
}

if(check==false){
Sleep(10000);
tradeReason= ">>>>>Alert Report <<<<<<<\nStrategy :"+EnumToString(InpStrategy)+"\nTime :"+(string)TimeCurrent()+"\nSymbol:"+symbol+"\n\nEntry Signal :>>  No trade signal found!  <<\n\nReasons :"+"\n"+IndicatorName1 +"\nTimeFrame1:  "+ EnumToString(timeframe1) +"\nSignal1: "+Signal1()+"\n\n"+
IndicatorName2 +"\nTimeFrame2:"+EnumToString(timeframe2)  +"\nSignal2: "+Signal2()+"\n\n"+IndicatorName3 +"\nTimeFrame3:"+EnumToString(timeframe3) +"\nSignal3: "+Signal3()+"\n\n"+IndicatorName4 +"\nTimeFrame4:"+EnumToString(timeframe4) +"\nSignal4: "+Signal4()+"\n";

smartBot.SendMessageToChannel(InpChannel,tradeReason);

    smartBot.SendMessage(InpChatId,tradeReason);
    
}
return "No trade signal";
};


//////////////////////////////////////////////////////////////
string ExitSignal1(){ //exit 1 
double buy, sell;

buy=iCustom(symbol,timeframe1, (string)IndicatorName1,period,method, pricess, indicatortrend1,shift1); 
sell=iCustom(symbol,timeframe1, (string)IndicatorName1,
       period,
       method,                        
     pricess, indicatortrend1,shift1); 
if(buy>=0){return"EXITBUY";}else if(sell<=0){return"EXITSELL";}

return "NO EXIT SIGNAL FOUND";
}

///////////////////////////////////////////////////////////

string ExitSignal2(){ //exit 2
double buy=iCustom(symbol,timeframe2,IndicatorName2,
Rperiod ,LSMA_Period,indicatortrend2,shift2);

double sell=iCustom(symbol,timeframe2,IndicatorName2,
Rperiod ,LSMA_Period,indicatortrend2,shift2);


if(buy<=0){return"EXITBUY";}else if(sell>=0){return"EXITSELL";}
return "NO EXIT SIGNAL FOUND";
}

////////////////////////////////////////////////////


string ExitSignal3(){//exit 3

double buy=iCustom(symbol,timeframe3, (string)IndicatorName3,
 UseSound    ,
 TypeChart  ,       
 UseAlert   ,
 NameFileSound  , T3Period  ,           
T3Price,
bFactor ,
 Snake_HalfCycle       ,
 Inverse ,
DeltaForSell        ,
 DeltaForBuy     ,
  ArrowOffset        ,
               Maxbars  ,indicatortrend3,shift3       
); 

double sell=iCustom(symbol,timeframe3, (string)IndicatorName3,
 UseSound    ,
 TypeChart  ,       
 UseAlert   ,
 NameFileSound  , T3Period  ,           
T3Price,
bFactor ,
 Snake_HalfCycle       ,
 Inverse ,
DeltaForSell        ,
 DeltaForBuy     ,
  ArrowOffset        ,
               Maxbars  ,indicatortrend3,shift3       
); 

if(buy<=0){return"EXITBUY";}else if(sell>=0){return"EXITSELL";}

return "NO EXIT SIGNAL FOUND";
}
//////////////////////////////////////////////////////////////
string ExitSignal4(){//exit 4


 double buy=iCustom(symbol,timeframe4, (string)IndicatorName4,period,InpDepth, 
        InpDeviation ,
        InpBackstep ,
                alerts ,
 EmailAlert ,
 alertonbar,
 sendnotify ,  indicatortrend4,shift4);
 
 double sell=iCustom(symbol,timeframe4, (string)IndicatorName4,period,InpDepth,   InpDeviation , InpBackstep , alerts ,EmailAlert ,alertonbar,sendnotify , indicatortrend4 ,shift4);
 
if(buy<=0){return"EXITBUY";}else if(sell>=0){return"EXITSELL";}

return "NO EXIT SIGNAL FOUND";
}
string signal1=Signal1(),signal2=Signal2(),signal3=Signal3(),signal4=Signal4();

string tradeReason=signal1+ "  " +signal2+"  "+signal3+" "+signal4;
string ExitSignal1=ExitSignal1(),ExitSignal2= ExitSignal2(),ExitSignal3=ExitSignal3(),ExitSignal4=ExitSignal4();
///////////////joint exit signal////////////////////////////////////////


string ExitTrade(){
if(InpStrategy==JOIN){//JOIN EXIT
if( ExitSignal1=="EXITBUY"&&ExitSignal2=="EXITBUY"&&ExitSignal3=="EXITBUY"&&ExitSignal4=="EXITBUY"){
messages="EXIT JOINT BUY"+ symbol;
return "EXITBUY";smartBot.SendMessageToChannel(InpChannel,messages);

}else if( ExitSignal1=="EXITSELL"&&ExitSignal2=="EXITSELL"&&ExitSignal3=="EXITSELL"&&ExitSignal4=="EXITSELL"){

messages="EXIT JOINT SELL"+symbol;

return "EXITSELL";

}

}else if(InpStrategy==0){//SEPARETE EXIT

}
return "NO EXIT SIGNAL FOUND";
}







 
        

void snrfibo ()
{
    int counted_bars = IndicatorCounted();
    double day_highx = 0;
    double day_lowx = 0;
    double yesterday_highx = 0;
    double yesterday_openx = 0;
    double yesterday_lowx = 0;
    double yesterday_closex = 0;
    double today_openx = 0;
    double P = 0, S = 0, R = 0, S1 = 0, R1 = 0, S2 = 0, R2 = 0, S3 = 0, R3 = 0;
    int cnt = 720;
    double cur_dayx = 0;
    double prev_dayx = 0;
    double rates_d1x[2][6];
    //---- exit if period is greater than daily charts
    if(Period() > 1440)
      {
        Print("Error - Chart period is greater than 1 day.");
        return; // then exit
      }
	       cur_dayx = TimeDay(datetime(Time[0] - (gmtoffset()*3600)));
		           yesterday_closex = iClose(NULL,snrperiod,1);
		           today_openx = iOpen(NULL,snrperiod,0);
		           yesterday_highx = iHigh(NULL,snrperiod,1);//day_high;
		           yesterday_lowx = iLow(NULL,snrperiod,1);//day_low;
		           day_highx = iHigh(NULL,snrperiod,1);
		           day_lowx  = iLow(NULL,snrperiod,1);
		           prev_dayx = cur_dayx;
	
	yesterday_highx = MathMax(yesterday_highx,day_highx);	    
	yesterday_lowx = MathMin(yesterday_lowx,day_lowx);	    
       // Comment ("Yesterday High : "+ yesterday_high + ", Yesterday Low : " + yesterday_low + ", Yesterday Close : " + yesterday_close );

    //------ Pivot Points ------
    R = (yesterday_highx - yesterday_lowx);
    P = (yesterday_highx + yesterday_lowx + yesterday_closex)/3; //Pivot
    R1 = P + (R * 0.382);
    R2 = P + (R * 0.618);
    R3 = P + (R * 1);
    S1 = P - (R * 0.382);
    S2 = P - (R * 0.618);
    S3 = P - (R * 1);
    //---- Set line labels on chart window
   drawLine(R3, "R3", clrLime, 0);
   drawLabel("Resistance 3", R3, clrLime);
   drawLine(R2, "R2", clrGreen, 0);
   drawLabel("Resistance 2", R2, clrGreen);
   drawLine(R1, "R1", clrDarkGreen, 0);
   drawLabel("Resistance 1", R1, clrDarkGreen);
   drawLine(P, "PIVIOT", clrBlue, 1);
   drawLabel("Piviot level", P, clrBlue);
   drawLine(S1, "S1", clrMaroon, 0);
   drawLabel("Support 1", S1, clrMaroon);
   drawLine(S2, "S2", clrCrimson, 0);
   drawLabel("Support 2", S2, clrCrimson);
   drawLine(S3, "S3", clrRed, 0);
   drawLabel("Support 3", S3, clrRed);
   return;
//----
}

void drawLabel(string A_name_0, double A_price_8, color A_color_16) {
   if (ObjectFind(A_name_0) != 0) {
      ObjectCreate(A_name_0, OBJ_TEXT, 0, Time[10], A_price_8);
      ObjectSetText(A_name_0, A_name_0, 8, "Arial", CLR_NONE);
      ObjectSet(A_name_0, OBJPROP_COLOR, A_color_16);
      return;
   }
   ObjectMove(A_name_0, 0, Time[10], A_price_8);
}
//+------------------------------------------------------------------+
void drawLabel(string Ln, string Lt, int th, string ts, color Lc, int cr, int xp, int yp)
  {
   ObjectCreate(Ln, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Ln, Lt, th, ts, Lc);
   ObjectSet(Ln, OBJPROP_CORNER, cr);
   ObjectSet(Ln, OBJPROP_XDISTANCE, xp);
   ObjectSet(Ln, OBJPROP_YDISTANCE, yp);
  }

void drawLine(double A_price_0, string A_name_8, color A_color_16, int Ai_20) {
   if (ObjectFind(A_name_8) != 0) {
      ObjectCreate(A_name_8, OBJ_HLINE, 0, Time[0], A_price_0, Time[0], A_price_0);
      if (Ai_20 == 1) ObjectSet(A_name_8, OBJPROP_STYLE, STYLE_SOLID);
      else ObjectSet(A_name_8, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(A_name_8, OBJPROP_COLOR, A_color_16);
      ObjectSet(A_name_8, OBJPROP_WIDTH, 1);
      return;
   }
   ObjectDelete(A_name_8);
   ObjectCreate(A_name_8, OBJ_HLINE, 0, Time[0], A_price_0, Time[0], A_price_0);
   if (Ai_20 == 1) ObjectSet(A_name_8, OBJPROP_STYLE, STYLE_SOLID);
   else ObjectSet(A_name_8, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(A_name_8, OBJPROP_COLOR, A_color_16);
   ObjectSet(A_name_8, OBJPROP_WIDTH, 1);
}




//-------- Debit/Credit total -------------------
 double ProfitValue=0;
bool StopTarget()
{
   if ( (P1/AccountBalance()) *100 >= ProfitValue )  return (true);
   return (false);
}

int gmtoffset()
{
int gmthour;
int gmtminute;
datetime timegmt; // Gmt time
datetime timecurrent; // Current time
int gmtoffset=0;
   timegmt=TimeGMT();
   timecurrent=TimeCurrent();
   gmthour=(int)StringToInteger(StringSubstr(TimeToStr(timegmt),11,2));
   gmtminute=(int)StringToInteger(StringSubstr(TimeToStr(timegmt),14,2));
   gmtoffset=TimeHour(timecurrent)-gmthour;
   if(gmtoffset<0)gmtoffset=24+gmtoffset;
return(gmtoffset);
}
   

//--- HUD Rectangle
void HUD() {
    ObjectCreate(ChartID(), "HUD", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    //--- set label coordinates
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_XDISTANCE, Xordinate+0);
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_YDISTANCE, Yordinate+20);
    //--- set label size
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_XSIZE, 220);
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_YSIZE, 75);
    //--- set background color
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_BGCOLOR, color5);
    //--- set border type
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    //--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_CORNER, 4);
    //--- set flat border color (in Flat mode)
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_COLOR, clrWhite);
    //--- set flat border line style
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_STYLE, STYLE_SOLID);
    //--- set flat border width
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_WIDTH, 1);
    //--- display in the foreground (false) or background (true)
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_BACK, false);
    //--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_SELECTED, false);
    //--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_HIDDEN, false);
    //--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(ChartID(), "HUD", OBJPROP_ZORDER, 0);
}

void HUD2() {
EA_name() ;
    ObjectCreate(ChartID(), "HUD2", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    //--- set label coordinates
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_XDISTANCE, Xordinate+0);
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_YDISTANCE, Yordinate+75);
    //--- set label size
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_XSIZE, 220);
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_YSIZE, 200);
    //--- set background color
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_BGCOLOR, color6);
    //--- set border type
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    //--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_CORNER, 4);
    //--- set flat border color (in Flat mode)
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_COLOR, clrWhite);
    //--- set flat border line style
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_STYLE, STYLE_SOLID);
    //--- set flat border width
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_WIDTH, 1);
    //--- display in the foreground (false) or background (true)
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_BACK, false);
    //--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_SELECTED, false);
    //--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_HIDDEN, false);
    //--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(ChartID(), "HUD2", OBJPROP_ZORDER, 0);
}


void EA_name() {
    string txt2 ="BOT_NAME: " +smartBot.Name()+ "20";
    if (ObjectFind(txt2) == -1) {
        ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt2, OBJPROP_CORNER, 0);
        ObjectSet(txt2, OBJPROP_XDISTANCE, Xordinate+15);
        ObjectSet(txt2, OBJPROP_YDISTANCE, Yordinate+17);
    }
    ObjectSetText(txt2, "SMART_TRADER ", 10, "Century Gothic", color1);

    txt2 = "@reals" + "21";
    if (ObjectFind(txt2) == -1) {
        ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt2, OBJPROP_CORNER, 0);
        ObjectSet(txt2, OBJPROP_XDISTANCE, Xordinate+50);
        ObjectSet(txt2, OBJPROP_YDISTANCE, Yordinate+50);
    }
    ObjectSetText(txt2, "Noel M Nguemechieu || version " + (string)"1", 9, "Arial", clrWhite);

    txt2 = "reel" + "22";
    if (ObjectFind(txt2) == -1) {
        ObjectCreate(txt2, OBJ_LABEL, 1, 1, 1);
        ObjectSet(txt2, OBJPROP_CORNER, 0);
        ObjectSet(txt2, OBJPROP_XDISTANCE, Xordinate+10);
        ObjectSet(txt2, OBJPROP_YDISTANCE, Yordinate+55);
    }
    ObjectSetText(txt2, "_______________________", 11, "Arial", Gold);

    
    
    
}

void GUI() {


    string matauang = "none";

    if (AccountCurrency() == "USD") matauang = "$";
    if (AccountCurrency() == "JPY") matauang = "¥";
    if (AccountCurrency() == "EUR") matauang = "€";
    if (AccountCurrency() == "GBP") matauang = "£";
    if (AccountCurrency() == "CHF") matauang = "CHF";
    if (AccountCurrency() == "AUD") matauang = "A$";
    if (AccountCurrency() == "CAD") matauang = "C$";
    if (AccountCurrency() == "RUB") matauang = "руб";

    if (matauang == "none") matauang = AccountCurrency();

    //--- Equity / balance / floating

    string txt1, content;
    int content_len = StringLen(content);

    string txt2 = "@reels" + "23";
    if (ObjectFind(txt2) == -1) {
        ObjectCreate(txt2, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt2, OBJPROP_CORNER, 0);
        ObjectSet(txt2, OBJPROP_XDISTANCE, Xordinate+20);
        ObjectSet(txt2, OBJPROP_YDISTANCE, Yordinate+75);
    }
    ObjectSetText(txt2, "[TimeServer | "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES)+"]", 10, "Arial", Gold);

    txt1 = "tatino" + "100";
    if (AccountEquity() >= AccountBalance()) {
        if (ObjectFind(txt1) == -1) {
            ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
            ObjectSet(txt1, OBJPROP_CORNER, 4);
            ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
            ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +100);
        }

        if (AccountEquity() == AccountBalance()) ObjectSetText(txt1, "Equity : " + DoubleToStr(AccountEquity(), 2) + matauang, 16, "Century Gothic", color3);
        if (AccountEquity() != AccountBalance()) ObjectSetText(txt1, "Equity : " + DoubleToStr(AccountEquity(), 2) + matauang, 11, "Century Gothic", color3);
    }
    if (AccountEquity() < AccountBalance()) {
        if (ObjectFind(txt1) == -1) {
            ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
            ObjectSet(txt1, OBJPROP_CORNER, 4);
            ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
            ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +100);
        }
        if (AccountEquity() == AccountBalance()) ObjectSetText(txt1, "Equity : " + DoubleToStr(AccountEquity(), 2) + matauang, 17, "Century Gothic", color4);
        if (AccountEquity() != AccountBalance()) ObjectSetText(txt1, "Equity : " + DoubleToStr(AccountEquity(), 2) + matauang, 14, "Century Gothic", color4);
    }

    txt1 = "tatino" + "101";
    if (AccountEquity() - AccountBalance() > 0) {
        if (ObjectFind(txt1) == -1) {
            ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
            ObjectSet(txt1, OBJPROP_CORNER, 4);
            ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
            ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +125);
        }
        ObjectSetText(txt1, "Floating PnL : +" + DoubleToStr(AccountEquity() - AccountBalance(), 2) + matauang, 9, "Century Gothic", color3);
    }
    if (AccountEquity() - AccountBalance() < 0) {
        if (ObjectFind(txt1) == -1) {
            ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
            ObjectSet(txt1, OBJPROP_CORNER, 4);
            ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
            ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +125);
        }
        ObjectSetText(txt1, "Floating PnL : " + DoubleToStr(AccountEquity() - AccountBalance(), 2) + matauang, 9, "Century Gothic", color4);
    }
    
    txt1 = "tatino" + "102";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +140);
    }
    if (OrdersTotal() != 0) ObjectSetText(txt1, "Balance      : " + DoubleToStr(AccountBalance(), 2) + matauang, 9, "Century Gothic", color2);
    if (OrdersTotal() == 0) ObjectSetText(txt1, "Balance      : " + DoubleToStr(AccountBalance(), 2) + matauang, 9, "Century Gothic", color2);

    txt1 = "tatino" + "103";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +155);
    }
   ObjectSetText(txt1, "AcNumber: " + string(AccountNumber()) , 9, "Century Gothic", color2);

    txt1 = "tatino" + "104";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +235);
    }
    ObjectSetText(txt1, "NewsInfo : " + jamberita  , 9, "Century Gothic", color3);

    txt1 = "tatino" + "105";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +250);
    }
        ObjectSetText(txt1, infoberita , 9, "Century Gothic", color3);

    txt1 = "tatino" + "106";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +170);
    }
      if (P1 >= 0) ObjectSetText(txt1, "Day Profit    : " + DoubleToStr(P1, 2) + matauang , 9, "Century Gothic", color3);
      if (P1 < 0) ObjectSetText(txt1, "Day Profit    : " + DoubleToStr(P1, 2) + matauang , 9, "Century Gothic", color4);

    txt1 = "tatino" + "106w";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +185);
    }
      if (Wp1 >= 0) ObjectSetText(txt1, "WeekProfit : " + DoubleToStr(Wp1, 2) + matauang , 9, "Century Gothic", color3);
      if (Wp1 < 0) ObjectSetText(txt1, "WeekProfit : " + DoubleToStr(Wp1, 2) + matauang , 9, "Century Gothic", color4);

    txt1 = "tatino" + "107";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +100);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +210);
    }
    ObjectSetText(txt1, "Spread : " + DoubleToStr(MarketInfo(_Symbol,MODE_SPREAD)*0.1, 1) + " Pips" , 9, "Century Gothic", color3);

    txt1 = "tatino" + "108";
    if (ObjectFind(txt1) == -1) {
        ObjectCreate(txt1, OBJ_LABEL, 0, 0, 0);
        ObjectSet(txt1, OBJPROP_CORNER, 4);
        ObjectSet(txt1, OBJPROP_XDISTANCE, Xordinate +25);
        ObjectSet(txt1, OBJPROP_YDISTANCE, Yordinate +210);
    }
    if (harga > lastprice) ObjectSetText(txt1,  DoubleToStr(harga, Digits) , 14, "Century Gothic", Lime);
    if (harga < lastprice) ObjectSetText(txt1,  DoubleToStr(harga, Digits) , 14, "Century Gothic", Red);
        lastprice = harga;

}



void QnDeleteObject()
{
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
      string oName = ObjectName(i);
      ObjectDelete(oName);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double rata_price(int tipe, string Pair)
  {
   double total_lot=0;
   double total_kali=0;
   double rata_price=0;
   for(int cnt=0; cnt<OrdersTotal(); cnt++)
     {
      int xx=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Pair && (OrderType()==tipe) && OrderMagicNumber()==MagicNumber)
        {
         total_lot  = total_lot + OrderLots();
         total_kali = total_kali + (OrderLots() * OrderOpenPrice());
        }
     }
   if(total_lot!=0)
     {
      rata_price = total_kali / total_lot;
     }
   else
     {
      rata_price = 0;
     }
   return (rata_price);
  }
  string messages="no message";


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LookupLiveAccountNumbers()
  {
   bool ff=false;

   if(AccountNumber() ==2721926)
     {
      ff=true;
     }; //reo Citro wikarsa


   return (ff);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TextPosB(string nama, string isi, int ukuran, int x, int y, color warna, int pojok)
  {
   if(ObjectFind(nama)<0)
     {
      ObjectCreate(nama,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSet(nama,OBJPROP_CORNER,pojok);
   ObjectSet(nama,OBJPROP_XDISTANCE,x);
   ObjectSet(nama,OBJPROP_YDISTANCE,y);
   ObjectSetText(nama,isi,ukuran,"Arial bold",warna);

  }

//===========
void SET(int baris, string label2, color col)
  {
   int x,y1;
   y1=12;
   for(int t=0; t<100; t++)
     {
      if(baris==t)
        {
         y1=t*y1;
         break;
        }
     }


   x=63;
   y1=y1+10;
   string bar=DoubleToStr(baris,0);
   string kk=" : ";
   TextPos("SN"+bar, label2, 8, x, y1, col,Info_Corner);

  }
void TextPos(string nama, string isi, int ukuran, int x, int y1, color warna, int pojok)
  {
   if(ObjectFind(nama)<0)
     {
      ObjectCreate(nama,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSet(nama,OBJPROP_CORNER,pojok);
   ObjectSet(nama,OBJPROP_XDISTANCE,x);
   ObjectSet(nama,OBJPROP_YDISTANCE,y1);
   ObjectSetText(nama,isi,ukuran,"Arial",warna);
  }



//===========
void SET2(int baris3, string label3, color col3)
  {
   int x3,y3;
   y3=12;
   for(int t3=0; t3<100; t3++)
     {
      if(baris3==t3)
        {
         y3=t3*y3;
         break;
        }
     }


   x3=170;
   y3=y3+10;
   string bar3=DoubleToStr(baris3,0);
   string kk3=" : ";
   TextPos3("SN3"+bar3, label3, 8, x3, y3, col3,Info_Corner);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TextPos3(string nama3, string isi3, int ukuran3, int x3, int y3, color warna3, int pojok3)
  {
   if(ObjectFind(nama3)<0)
     {
      ObjectCreate(nama3,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSet(nama3,OBJPROP_CORNER,pojok3);
   ObjectSet(nama3,OBJPROP_XDISTANCE,x3);
   ObjectSet(nama3,OBJPROP_YDISTANCE,y3);
   ObjectSetText(nama3,isi3,ukuran3,"Arial",warna3);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Bt(string nm,int ys,color cl)
  {
   ObjectCreate(0,nm,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,nm,OBJPROP_XSIZE,110);
   ObjectSetInteger(0,nm,OBJPROP_YSIZE,30);
   ObjectSetInteger(0,nm,OBJPROP_BORDER_COLOR,clrSilver);
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,ys);
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,35);
   ObjectSetString(0,nm,OBJPROP_TEXT,nm);
   ObjectSetInteger(0,nm,OBJPROP_CORNER,2);
   ObjectSetInteger(0,nm,OBJPROP_BGCOLOR,cl);
   ObjectSetString(0,nm,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,White);
   ObjectSetInteger(0,nm,OBJPROP_BACK, false);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllm(int gg=0)
  {

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      Os=OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY&& ((gg==1 && OrderProfit()>0)||gg==0))
        {
         Oc=OrderClose(i, OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);

         continue;
        }
      if(OrderType()==OP_SELL&& ((gg==1 && OrderProfit()>0)||gg==0))
        {
         Oc=OrderClose(i, OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, CLR_NONE);

        }
     }
  }

//+------------------------------------------------------------------+

// Function: check indicators signalbfr buffer value 
bool signalbfr (double value) 
{
   if (value != 0 && value != EMPTY_VALUE)
      return true;
   else
      return false;
} 


//--------------------------------------------
void tradeResponse()
{
//tggggg

   if( telegram== No ) return;
   if( sendorder == Yes )
   {

  int total=OrdersTotal();
  datetime max_time = 0; 
  
  for(int pos=0;pos<total;pos++){  // Current orders -----------------------
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderOpenTime() <= _opened_last_time ) continue;
     
     
     string message = StringFormat(
     "\n----TRADE_EXPERT\n OPEN ORDER----\r\n%s %s lots \r\n%s @ %s \r\nSL - %s\r\nTP - %s\r\n----------------------\r\n\n",
            order_type(),
            DoubleToStr(OrderLots(),2),
            OrderSymbol(),
            DoubleToStr(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),        
            DoubleToStr(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
            DoubleToStr(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS))
     );
     smartBot.SendMessageToChannel(InpChannel,message);
    if(StringLen(message) > 0) {
 
 smartBot.SendMessageToChannel(InpChannel,message); 
    } 
     max_time = MathMax(max_time,OrderOpenTime());

   }
  
   _opened_last_time = MathMax(max_time,_opened_last_time);
   
   }
   
   if( sendclose == Yes )
   {
   datetime max_time = 0;
   double day_profit = 0;
   
   bool is_closed = false;
   int total = OrdersHistoryTotal();
   for(int pos=0;pos<total;pos++) {  // History orders-----------------------
     
     if( TimeDay(TimeCurrent()) == TimeDay(OrderCloseTime()) && OrderCloseTime() > iTime(NULL,1440,0)) {
         day_profit += order_pips();
     }
     
     if(OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY)==false) continue;
     if(OrderCloseTime() <= _closed_last_time) continue;

     printf(TimeToStr(OrderCloseTime()));
     is_closed = true;
     string message = StringFormat("\n----Trade_Expert CLOSE PROFIT----\r\n%s %s lots\r\n%s @ %s\r\nCP - %s \r\nTP - %s \r\nProfit: %s PIPS \r\n--------------------------------\r\n\n",
            order_type(),
            DoubleToStr(OrderLots(),2),
            OrderSymbol(),
            DoubleToStr(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),                
            DoubleToStr(OrderClosePrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),          
            DoubleToStr(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),
            DoubleToStr(order_pips()/10,1)           
     );
    
     smartBot.SendMessageToChannel(InpChannel,message);
    if(StringLen(message) > 0) {
      if(is_closed) message += StringFormat("Total Profit of today : %s PIPS",DoubleToStr(day_profit/10,1));
      printf(message);
smartBot.SendMessageToChannel(InpChannel,message);
    }     
     
     max_time = MathMax(max_time,OrderCloseTime());

   } 
   _closed_last_time = MathMax(max_time,_closed_last_time);
  
  }
   
     
 } //tggggggggggggggggg
 
//===============tg
double order_pips() {
   if(OrderType() == OP_BUY) {
      return (OrderClosePrice()-OrderOpenPrice())/(MathMax(MarketInfo(OrderSymbol(),MODE_POINT),0.00000001));
   } else {
      return (OrderOpenPrice()-OrderClosePrice())/(MathMax(MarketInfo(OrderSymbol(),MODE_POINT),0.00000001));
   }
}
string order_type () {
   
   if(OrderType() == OP_BUY)        return "BUY";
   if(OrderType() == OP_SELL)       return "SELL";
   if(OrderType() == OP_BUYLIMIT)   return "BUYLIMIT";
   if(OrderType() == OP_SELLLIMIT)  return "SELLLIMIT";
   if(OrderType() == OP_BUYSTOP)    return "BUYSTOP";
   if(OrderType() == OP_SELLSTOP)   return "SELLSTOP";
   
   return "";
}

datetime _tms_last_time_messaged;



string ReadCBOE()
  {

   string cookie=NULL,headers;
   char post[],result[];     string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"  
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"): 
//   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//--- 
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("You must add the address ' "+google_url+"' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result)); 
      //--- save the data in the file
      int filehandle=FileOpen("realTatino-log.html",FILE_WRITE|FILE_BIN);
      //--- ïðîâåðêà îøèáêè 
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file 
         FileClose(filehandle);

         int filehandle2=FileOpen("realTatino-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
        }else{
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + offsets*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);

   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(str1,NewsArr[1][NomNews])<0)continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[3][NomNews],judulnews)>=0 && !Vtunggal)continue;
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !Vhigh)continue;
      if(StringFind(NewsArr[2][NomNews],"Medium")>=0 && !Vmedium)continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !Vlow)continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)break;
      if(sh1<0 || sh1>sh2)NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)break;
     }
  }



void datanews()
{
   if(MQLInfoInteger(MQL_TESTER) || !AvoidNews )
      return;
      
   offsets = gmtoffset();
   double CheckNews=0;
   if(AfterNewsStop>0)
     {
      if(TimeCurrent()-LastUpd>=Upd){Comment("News Loading...");Print("News Loading...");UpdateNews();LastUpd=TimeCurrent();Comment(""); messages="__________NEWS LOADING___________";smartBot.SendMessageToChannel(InpChannel,messages);}
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Name=StringSubstr(TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")if(ObjectFind(Name)==0)continue;
            if(StringFind(str1,NewsArr[1][i])<0)continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)continue;

            color clrf = clrNONE;
            if(Vtunggal && StringFind(NewsArr[3][i],judulnews)>=0)clrf=highc;
            if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)clrf=highc;
            if(Vmedium && StringFind(NewsArr[2][i],"Medium")>=0)clrf=mediumc;
            if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)clrf=lowc;

            if(clrf==clrNONE)continue;

            if(NewsArr[3][i]!="")
              {
               ObjectCreate(Name,0,OBJ_VLINE,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,Style);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int i;
      CheckNews=0;
    //tg
/*      for(i=0;i<NomNews;i++)
        {
         int power=0;
         if(Vtunggal && StringFind(NewsArr[3][i],judulnews)>=0)power=1;
         if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)power=1;
         if(Vmedium && StringFind(NewsArr[2][i],"Moderate")>=0)power=2;
         if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)power=3;
         if(power==0)continue;
         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(i) && TimeCurrent()-1*MinAfter<TimeNewsFunck(i) && StringFind(str1,NewsArr[1][i])>=0)
           { 
           CheckNews=2;
            break;
           }
         else CheckNews=0;
         }*/

//ory
      for(i=0;i<NomNews;i++)
        {
         int power=0;
         if(Vtunggal && StringFind(NewsArr[3][i],judulnews)>=0)power=1;
         if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)power=1;
         if(Vmedium && StringFind(NewsArr[2][i],"Medium")>=0)power=2;
         if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)power=3;
         if(power==0)continue;
         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(i) && TimeCurrent()-60*MinAfter<TimeNewsFunck(i) && StringFind(str1,NewsArr[1][i])>=0)
           { jamberita= " In "+string((int)(TimeNewsFunck(i)-TimeCurrent())/60)+" Minutes ["+NewsArr[1][i]+"]"; infoberita = ">> "+StringSubstr(NewsArr[3][i],0,28);
           CheckNews=1;
            break;
           }
         else CheckNews=0;
         }
      if (CheckNews==1 && i!=Now && Signal) { Alert("within  ",(int)(TimeNewsFunck(i)-TimeCurrent())/60," minutes released news Currency ",NewsArr[1][i],"_",NewsArr[3][i]);};
      if (CheckNews==1 && i!=Now && telegram == Yes && sendnews == Yes) { messages="     >> NEWS ALERT<<\nTIME :Within "+string((int)(TimeNewsFunck(i)-TimeCurrent())/60)+" minutes released news \nCurrency : "+NewsArr[1][i]+"\nImpact : "+NewsArr[2][i]+"\nTitle : "+NewsArr[3][i]+"\nForecast: \nPreviours:------more detail https://bit.ly/35NPVPi --------------";Now=i; smartBot.SendMessageToChannel(InpChannel,messages);}
     // if (1==1 && i!=Now && sendnews == yes) { tms_send(message,_token);Now=i;}

     }
     
   if(CheckNews>0 && NewsFilter) trade=false;
   if(CheckNews>0)
     {  

      /////  We are doing here if we are in the framework of the news
      if ( !StopTarget() && NewsFilter ) infoberita ="News Time >> TRADING OFF";smartBot.SendMessageToChannel(InpChannel,infoberita);smartBot.SendMessage(chats.m_id,messages);
      if ( !StopTarget()&& !NewsFilter) infoberita="Attention!! News Time";smartBot.SendMessageToChannel(InpChannel,infoberita);smartBot.SendMessage(chats.m_id,messages);

     }else{
      if (NewsFilter) trade=true; 
      // We are out of scope of the news release (No News)
      if ( !StopTarget()) jamberita= "No News"; infoberita = "Waiting......";smartBot.SendMessageToChannel(InpChannel,jamberita+"  "+infoberita); smartBot.SendMessage(chats.m_id,infoberita);

     } 
return;
}


 int ExitSignal = 0;
  //+------------------------------------------------------------------+
void OnTick()
  {
 
  EA_name();
  
 double tes=iCustom(symbol,PERIOD_CURRENT,(string)(IndicatorName5),60,1,1);
TradeSignal();
  
   timelockaction();
   string status2="Copyright © 2021, NOEL M NGUEMECHIEU";
   ObjectCreate("M5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("M5",status2,8,"Arial",LightGray);
   ObjectSet("M5", OBJPROP_CORNER, 2);
   ObjectSet("M5", OBJPROP_XDISTANCE, 0);
   ObjectSet("M5", OBJPROP_YDISTANCE, 0);

  //Alert("olT : ",_opened_last_time,"\ncLT : ",_closed_last_time);
 
   if(UseBot){
 smartBot.ProcessMessages();
  smartBot.GetUpdates();
}
  datanews();

  GUI();


 tradeResponse();
 if(showfibo){snrfibo(); };

 

 //if(StopTarget()==FALSE) ClosetradePairs(Symbol());return;

ClosetradePairs(symbol);
    //Close Long Positions, instant signal is tested first
   if(ExitTrade()=="EXITBUY" ||ExitSignal < 0)
     {   
     
      
         myOrderClose(OP_BUY, 100, "");
     
     }
   
   //Close Short Positions, instant signal is tested first
   if(ExitTrade()=="EXITSELL"||ExitSignal > 0)
     {   
      
         myOrderClose(OP_SELL, 100, "");
     
     }
     
  if(deletepo==Yes){ DeleteByDuration(PendingOrderExpirationBars * PeriodSeconds());
   DeleteByDistance(DeleteOrderAtDistance * myPoint);
   }
     if(closeTradesAtPL){CloseTradesAtPL(CloseAtPL);};
      

   if(UsePartialClose) {//PARTIAL CLOSE
      CheckPartialClose();
   }
   if(UseTrailingStop)//TRAILING STOP
     {
      TrailingStopTrail(OP_BUY, Trail_Step * myPoint, Trail_Step * myPoint, true, Trail_Above * myPoint); //Trailing Stop = trail
   TrailingStopTrail(OP_SELL, Trail_Step * myPoint, Trail_Step * myPoint, true, Trail_Above * myPoint); //Trailing Stop = trail

     }
   if(UseBreakEven)//BREAK EVEN
     {
      _funcBE();
     }

  
   TradeNow();//trade
  
   Comment("");
   datetime start_= StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " 00:00"),start2=0;
   bool TARGET=true;
   ThisDayOfYear=DayOfYear(); 
   
   


   
   P1=DYp(iTime(NULL,PERIOD_D1,0));
   Wp1=DYp(iTime(NULL,PERIOD_W1,0));
   MNp1=DYp(iTime(NULL,PERIOD_MN1,0));
 double PR=0,PB=0,PS=0,LTB=0,LTS=0;
   if(AccountBalance()>0)
     {
      Persentase1=(P1/AccountBalance())*100;

     }
     
     // Calculer les floating profits pour le magic
    for(int i=0; i<OrdersTotal(); i++)
     {
      int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
        {
         PB+=OrderProfit()+OrderCommission()+OrderSwap();
        }
      if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
        {
         PS+=OrderProfit()+OrderCommission()+OrderSwap();
        }
     }  
     
     
   // Profit floating pour toutes les paires , variable TPM
   
   // if(TPm>0&&PB+PS>=TPm)
    if(1<0)
    { messages="Profit TP closing all trades.PB,PS "+(string)(PB+PS);
     Print("Profit TP closing all trades.PB,PS "+string(PB+PS));
      //CloseAll();
     }
     
   // Si les floating profit + ce qui est déjà fermé, pour le magic,  atteint le daily profit, on vire les trades pour le magic
   // Si non on reparcourt les ordres pour gérer les martis
   DailyProfit=P1+PB+PS;

   if(ProfitValue>0 && ((P1+PB+PS)/(AccountEquity()-(P1+PB+PS)))*100 >=ProfitValue &&  TargetReachedForDay!=ThisDayOfYear )
        {
          CloseAll();
          TargetReachedForDay=ThisDayOfYear;          
          Alert( "Daily Target reached. Closed running trades");messages="Daily Target reached. Closed running trades";
          smartBot.SendMessageToChannel(InpChannel,messages);
          Comment("                                                 Daily Target reached!");
        }
    else 
        {
    for(int i=0; i<OrdersTotal(); i++)
     {
      int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(!xx)continue;
      if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
        {
         TO++;
         TB++;
         PB+=OrderProfit()+OrderCommission()+OrderSwap();
         LTB+=OrderLots();
      
        //if(closeAskedFor!= "BUY"+OrderSymbol()) 
            ClosetradePairs(OrderSymbol());
        }
      if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
        {
         TO++;
         TS++;
         PS+=OrderProfit()+OrderCommission()+OrderSwap();
         LTS+=OrderLots();
         //if(closeAskedFor!= "SELL"+OrderSymbol()) 
            ClosetradePairs(OrderSymbol());
        }

 }}
       
  }
  
double GetDistanceInPoints(const string symbols,ENUM_UNIT unit,double value,double pip_value,double volume) {
   switch(unit) {
      default: 
         PrintFormat("Unhandled unit %s, returning -1",EnumToString(unit));
         break;
      case InPips: {
         double distance = value;
         
         if (IsTesting()&&DebugUnit) PrintFormat("%s:%.2f dist: %.5f",EnumToString(unit),value,distance);
         
         return value;
      }
      case InDollars: {
         double tickSize        = SymbolInfoDouble(symbols,SYMBOL_TRADE_TICK_SIZE);
         double tickValue       = SymbolInfoDouble(symbols,SYMBOL_TRADE_TICK_VALUE);
         double dVpL            = tickValue / tickSize;            
         double distance        = (value /(volume * dVpL))/pip_value;

         if (IsTesting()&&DebugUnit) PrintFormat("%s:%s:%.2f dist: %.5f volume:%.2f dVpL:%.5f pip:%.5f",symbols,EnumToString(unit),value,distance,volume,dVpL,pip_value);
         
         return distance;      
      }
   }
   return -1;
}
 void  _funcBE()
  {

   int count=OrdersTotal();
   double ts=0;
   while(count>0)
     {
      int os=OrderSelect(count-1,MODE_TRADES);

      if (OrderMagicNumber()==MagicNumber) {
         //--- symbol variables                     
         double pip=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
         if(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)==5 || SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)==3)
            pip*=10;
         int digits = (int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);

         switch(OrderType()) {
            default:
               break;
            case ORDER_TYPE_BUY: {
               switch(BreakEvenUnit) {
                  default:
                  case InDollars: {
                     double profit_distance = OrderProfit();
                     bool is_activated = profit_distance > BreakEvenTrigger;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / BreakEvenTrigger);
                        if (steps>0) {
                           //--- check current step count is within limit
                           if (steps <= MaxNoBreakEven) {
                              //--- calculate stop loss distance                                                    
                              double stop_distance   = GetDistanceInPoints(OrderSymbol(),BreakEvenUnit,BreakEvenProfit*steps,1,OrderLots()); //--- pip value forced to 1 because BreakEvenProfit*steps already in points
                              double stop_price      = NormalizeDouble(OrderOpenPrice()+stop_distance,digits);
                              //--- move stop if needed
                              if ((OrderStopLoss()==0)||(stop_price > OrderStopLoss())) {
                                 if (DebugBreakEven) {
                                    Print("BE[Trigger:$"+DoubleToString(BreakEvenTrigger,2)
                                       +",Profit:$"+DoubleToString(BreakEvenProfit,2)
                                       +",Max:"+DoubleToString(MaxNoBreakEven,2)+"]"
                                       +" p:$"+DoubleToString(profit_distance,digits)
                                       +" s:$"+DoubleToString(steps,digits)
                                       +" sd:"+DoubleToString(stop_distance,digits)
                                       +" sp:"+DoubleToString(stop_price,digits));                              
                                 }
                                 if (!OrderModify(OrderTicket(),OrderOpenPrice(),stop_price,OrderTakeProfit(),0,clrGold)) {
                                    Print("Failed to modify break even. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                                 }
                              }                               
                           }
                        }
                     }                     
                     break;
                  }               
                  case InPips: {
                     double profit_distance = SymbolInfoDouble(OrderSymbol(),SYMBOL_BID) - OrderOpenPrice();
                     bool is_activated = profit_distance > BreakEvenTrigger*pip;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / BreakEvenTrigger*pip);
                        if (steps>0) {
                           //--- check current step count is within limit          
                           if (steps <= MaxNoBreakEven) {
                              double stop_distance = BreakEvenProfit*pip*steps;
                              double stop_price = NormalizeDouble(OrderOpenPrice()+stop_distance,digits);
                              //--- move stop if needed
                              if ((OrderStopLoss()==0)||(stop_price > OrderStopLoss())) {
                                 if (DebugBreakEven) {
                                    Print("BE[Trigger:"+DoubleToString(BreakEvenTrigger)
                                       +",Profit:"+DoubleToString(BreakEvenProfit)
                                       +",Max:"+IntegerToString(MaxNoBreakEven)+"]"
                                       +" p:"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps)
                                       +" sd:"+DoubleToString(stop_distance,digits)
                                       +" sp:"+DoubleToString(stop_price,digits));                              
                                 }
                                 if (!OrderModify(OrderTicket(),OrderOpenPrice(),stop_price,OrderTakeProfit(),0,clrGold)) {
                                    Print("Failed to modify break even. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                                 }
                              }                     
                           }
                        }
                     }
                     break;
                  }
               }
               break;
            }
            case ORDER_TYPE_SELL: {
               switch(BreakEvenUnit) {
                  default:
                  case InDollars: {
                     double profit_distance = OrderProfit();
                     bool is_activated = profit_distance > BreakEvenTrigger;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / BreakEvenTrigger);
                        if (steps>0) {
                           //--- check current step count is within limit
                           if (steps <= MaxNoBreakEven) {
                              //--- calculate stop loss distance                                                    
                              double stop_distance = GetDistanceInPoints(OrderSymbol(),BreakEvenUnit,BreakEvenProfit*steps,1,OrderLots());
                              double stop_price    = NormalizeDouble(OrderOpenPrice()-stop_distance,digits);
                              //--- move stop if needed
                              if ((OrderStopLoss()==0)||(stop_price < OrderStopLoss())) {
                                 if (DebugBreakEven) {
                                    Print("BE[Trigger:$"+DoubleToString(BreakEvenTrigger,2)
                                       +",Profit:$"+DoubleToString(BreakEvenProfit,2)
                                       +",Max:"+IntegerToString(MaxNoBreakEven)+"]"
                                       +" p:$"+DoubleToString(profit_distance,digits)
                                       +" s:$"+DoubleToString(steps,digits)
                                       +" sd:"+DoubleToString(stop_distance,digits)
                                       +" sp:"+DoubleToString(stop_price,digits));                              
                                 }                        
                                 if (!OrderModify(OrderTicket(),OrderOpenPrice(),stop_price,OrderTakeProfit(),0,clrGold)) {
                                    Print("Failed to modify break even. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                                 }
                              }                              
                           }
                        }
                     }
                     break;
                  }
                  case InPips: {
                     double profit_distance = OrderOpenPrice() - SymbolInfoDouble(OrderSymbol(),SYMBOL_ASK);
                     bool is_activated = profit_distance > BreakEvenTrigger*pip;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / BreakEvenTrigger*pip);
                        if (steps>0) {
                           //--- check current step count is within limit          
                           if (steps <= MaxNoBreakEven) {
                              double stop_distance = BreakEvenProfit*pip*steps;
                              double stop_price    = NormalizeDouble(OrderOpenPrice()-stop_distance,digits);
                              //--- move stop if needed
                              if ((OrderStopLoss()==0)||(stop_price < OrderStopLoss())) {
                                 if (DebugBreakEven) {
                                    Print("BE[Trigger:"+DoubleToString(BreakEvenTrigger)
                                       +",Profit:"+DoubleToString(BreakEvenProfit)
                                       +",Max:"+IntegerToString(MaxNoBreakEven)+"]"
                                       +" p:"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps)
                                       +" sd:"+DoubleToString(stop_distance,digits)
                                       +" sp:"+DoubleToString(stop_price,digits));                              
                                 }                        
                                 if (!OrderModify(OrderTicket(),OrderOpenPrice(),stop_price,OrderTakeProfit(),0,clrGold)) {
                                    Print("Failed to modify break even. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                                 }
                              }                     
                           }
                        }
                     }
                     break;
                  }
               }            
               break;
            }
         }

      }
      count--;
     }
  }
  
void CheckPartialClose() {
   int count=OrdersTotal();
   double ts=0;
   while(count>0)
     {
      int os=OrderSelect(count-1,MODE_TRADES);

      if (OrderMagicNumber()==MagicNumber) {
         //--- symbol variables                     
         double pip=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
         if(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)==5 || SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)==3)
            pip*=10;
         int digits = (int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);

         switch(OrderType()) {
            default:
               break;
            case ORDER_TYPE_BUY: {
               switch(PartialCloseUnit) {
                  default:
                  case InDollars: {
                     double profit_distance = OrderProfit();
                     bool is_activated = profit_distance > PartialCloseTrigger;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / PartialCloseTrigger);
                        if (steps>0) {
                           //--- check current step count is within limit
                           if (steps <= MaxNoPartialClose) {
                              //--- calculate new lot size
                              int lot_digits = (int)(MathLog(SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_STEP))/MathLog(0.1));
                              double lots = NormalizeDouble(OrderLots() * PartialClosePercent,lot_digits);
                              if (lots < SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_MIN)) { //--- close all
                                 lots = OrderLots();
                              }
                              if (OrderClose(OrderTicket(),lots,SymbolInfoDouble(OrderSymbol(),SYMBOL_BID),5,clrYellow)) {
                                 if (DebugPartialClose) {
                                    Print("PC[Trigger:$"+DoubleToString(PartialCloseTrigger,2)
                                       +",Percent:"+DoubleToString(PartialClosePercent,2)
                                       +",Max:"+IntegerToString(MaxNoPartialClose)+"]"
                                       +" p:$"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps,digits)
                                       +" l:"+DoubleToString(lots,lot_digits));                              
                                 }
                              } else {
                                 Print("Failed to partial close. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                              }                               
                           }
                        }
                     }                     
                     break;
                  }               
                  case InPips: {
                     double profit_distance = SymbolInfoDouble(OrderSymbol(),SYMBOL_BID) - OrderOpenPrice();
                     bool is_activated = profit_distance > PartialCloseTrigger*pip;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / PartialCloseTrigger*pip);
                        if (steps>0) {
                           //--- check current step count is within limit          
                           if (steps <= MaxNoPartialClose) {
                              //--- calculate new lot size
                              int lot_digits = (int)(MathLog(SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_STEP))/MathLog(0.1));
                              double lots = NormalizeDouble(OrderLots() * PartialClosePercent,lot_digits);
                              if (lots < SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_MIN)) { //--- close all
                                 lots = OrderLots();
                              }
                              if (OrderClose(OrderTicket(),lots,SymbolInfoDouble(OrderSymbol(),SYMBOL_BID),5,clrYellow)) {
                                 if (DebugPartialClose) {
                                    Print("PC[Trigger:"+DoubleToString(PartialCloseTrigger,2)
                                       +",Percent:"+DoubleToString(PartialClosePercent,2)
                                       +",Max:"+IntegerToString(MaxNoPartialClose)+"]"
                                       +" p:"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps,digits)
                                       +" l:"+DoubleToString(lots,lot_digits));                              
                                 }
                              } else {
                                 Print("Failed to partial close. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                              }                     
                           }
                        }
                     }
                     break;
                  }
               }
               break;
            }
            case ORDER_TYPE_SELL: {
               switch(PartialCloseUnit) {
                  default:
                  case InDollars: {
                     double profit_distance = OrderProfit();
                     bool is_activated = profit_distance > PartialCloseTrigger;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / PartialCloseTrigger);
                        if (steps>0) {
                           //--- check current step count is within limit
                           if (steps <= MaxNoPartialClose) {
                              //--- calculate new lot size
                              int lot_digits = (int)(MathLog(SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_STEP))/MathLog(0.1));
                              double lots = NormalizeDouble(OrderLots() * PartialClosePercent,lot_digits);
                              if (lots < SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_MIN)) { //--- close all
                                 lots = OrderLots();
                              }
                              if (OrderClose(OrderTicket(),lots,SymbolInfoDouble(OrderSymbol(),SYMBOL_ASK),5,clrYellow)) {
                                 if (DebugPartialClose) {
                                    Print("PC[Trigger:$"+DoubleToString(PartialCloseTrigger,2)
                                       +",Percent:"+DoubleToString(PartialClosePercent,2)
                                       +",Max:"+IntegerToString(MaxNoPartialClose)+"]"
                                       +" p:$"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps,digits)
                                       +" l:"+DoubleToString(lots,lot_digits));                              
                                 }
                              } else {
                                 Print("Failed to partial close. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                              }                            
                           }
                        }
                     }
                     break;
                  }
                  case InPips: {
                     double profit_distance = OrderOpenPrice() - SymbolInfoDouble(OrderSymbol(),SYMBOL_ASK);
                     bool is_activated = profit_distance > PartialCloseTrigger*pip;
                     if (is_activated) {
                        double steps = MathFloor(profit_distance / PartialCloseTrigger*pip);
                        if (steps>0) {
                           //--- check current step count is within limit          
                           if (steps <= MaxNoPartialClose) {
                              //--- calculate new lot size
                              int lot_digits = (int)(MathLog(SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_STEP))/MathLog(0.1));
                              double lots = NormalizeDouble(OrderLots() * PartialClosePercent,lot_digits);
                              if (lots < SymbolInfoDouble(OrderSymbol(),SYMBOL_VOLUME_MIN)) { //--- close all
                                 lots = OrderLots();
                              }
                              if (OrderClose(OrderTicket(),lots,SymbolInfoDouble(OrderSymbol(),SYMBOL_ASK),5,clrYellow)) {
                                 if (DebugPartialClose) {
                                    Print("PC[Trigger:"+DoubleToString(PartialCloseTrigger,2)
                                       +",Percent:"+DoubleToString(PartialClosePercent,2)
                                       +",Max:"+IntegerToString(MaxNoPartialClose)+"]"
                                       +" p:"+DoubleToString(profit_distance,digits)
                                       +" s:"+DoubleToString(steps,digits)
                                       +" l:"+DoubleToString(lots,lot_digits));                              
                                 }
                              } else {
                                 Print("Failed to partial close. Order " + IntegerToString(OrderTicket()) + ", error: " + IntegerToString(GetLastError()));
                              }                    
                           }
                        }
                     }
                     break;
                  }
               }            
               break;
            }
         }

      }
      count--;
     }
} 
  //+------------------------------------------------------------------+
void CloseAll()
  {
   int totalOP  = OrdersTotal(),tiket=0;
   for(int cnt = totalOP-1 ; cnt >= 0 ; cnt--)
     {
      Os=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderMagicNumber() == MagicNumber)
        {
         Oc=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);
         Sleep(300);
         continue;
        }
      if(OrderType()==OP_SELL && OrderMagicNumber() == MagicNumber)
        {
         Oc=OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, CLR_NONE);
         Sleep(300);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DYp(datetime start_)
  {

   double total = 0;
   for(int i = OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderMagicNumber() == MagicNumber  &&OrderCloseTime()>=start_)
           {
            total+=(OrderProfit()+OrderSwap()+OrderCommission());
           }
        }
     }
   return(total);
  }
  
bool IsNewM1Candle(){

   //If the time of the candle when the function last run
   //is the same as the time of the time this candle started
   //return false, because it is not a new candle
   if(NewCandleTime==iTime(symbol,PERIOD_CURRENT,0)) return false;
   
   //otherwise it is a new candle and return true
   else{
      //if it is a new candle then we store the new value
      NewCandleTime=iTime(symbol,PERIOD_CURRENT,0);
      return true;
   }
}
  void timelockaction(void)
{
  if(TradeDays())
   return;
   
 double stoplevel=0,proffit=0,newsl=0,price=0;
 
 string sy=NULL;
 int sy_digits=0;
 double sy_points=0;
 bool ans=false; 
 bool next=false;
 int otype=-1;
 int kk=0;
 
  for(int i=OrdersTotal()-1;i>=0;i--)
   {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
    if(OrderMagicNumber()!=MagicNumber)continue;
     next=false;
     ans=false;
     sy=OrderSymbol();
     ask=SymbolInfoDouble(sy,SYMBOL_ASK);
     bid=SymbolInfoDouble(sy,SYMBOL_BID);
     sy_digits=(int)SymbolInfoInteger(sy,SYMBOL_DIGITS);
     sy_points=SymbolInfoDouble(sy,SYMBOL_POINT);
     stoplevel=MarketInfo(sy, MODE_STOPLEVEL)*sy_points;
     otype=OrderType();
     kk=0;
     proffit=OrderProfit()+OrderSwap()+OrderCommission();
     newsl=OrderOpenPrice();
     
     switch(EA_TIME_LOCK_ACTION)
      {
        case closeall:
         if(otype>1)
          { 
            while(kk<5 && !OrderDelete(OrderTicket())){
                 kk++;}
          }
         else
          {
            price=(otype==OP_BUY)?bid:ask;
            while(kk<5 && !OrderClose(OrderTicket(),OrderLots(),price,10)){
               kk++;
               price=(otype==OP_BUY)?SymbolInfoDouble(sy,SYMBOL_BID):SymbolInfoDouble(sy,SYMBOL_ASK);
              } 
          }         
         break;      
        case closeprofit:
         if(proffit<=0)
           break;
         else
           {
            price=(otype==OP_BUY)?bid:ask;
            while(otype<2 && kk<5 && !OrderClose(OrderTicket(),OrderLots(),price,10)){
               kk++;
               price=(otype==OP_BUY)?SymbolInfoDouble(sy,SYMBOL_BID):SymbolInfoDouble(sy,SYMBOL_ASK);
              } 
           }
         break;        
       case breakevenprofit:
          if(proffit<=0)
            break;
          else
            {
             price=(otype==OP_BUY)?bid:ask;
             while(otype<2 && kk<5 && MathAbs(price-newsl)>=stoplevel && !OrderModify(OrderTicket(),newsl,newsl,OrderTakeProfit(),OrderExpiration())){
                   kk++;
                   price=(otype==OP_BUY)?SymbolInfoDouble(sy,SYMBOL_BID):SymbolInfoDouble(sy,SYMBOL_ASK);
                  }
            }
          break;           
            
      }
     continue; 
  }
  
}

  
int SymbolNumOfSymbol(string symbols)
{
   for ( int i = 0; i < NumOfSymbols; i++)
   {
      if (symbols==mysymbolList[i]+postfix) return(i);
   }
   return(-1);
}
  void ClosetradePairs(string Pair)
{
   if (closetype != opposite) return;
   int SymbolNum = SymbolNumOfSymbol(Pair);
   if (SymbolNum < 0) return;    
 
   if(ExitSignal > 0)
   {//Print("Opposite Close Sell ",Pair);
      closeOP(OP_SELL,Pair);
   }
   else if(ExitSignal < 0)
   {//Print("Opposite Close Buy ",Pair);
      closeOP(OP_BUY,Pair);
   }

}

int closeOP(int kode,string pair)
  {
  
   //Print( "in closeOP with closeAskedFor" + closeAskedFor);
   int totalOP  = OrdersTotal(),tiket=0;
   for(int cnt = totalOP-1 ; cnt >= 0 ; cnt--)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderMagicNumber()==MagicNumber)
        {
         if(OrderSymbol()==pair&& OrderType()==OP_BUY && kode==OP_BUY)
           {tiket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,clrNONE);}
         if(OrderSymbol()==pair&& OrderType()==OP_SELL&& kode==OP_SELL)
           {tiket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,clrNONE);}
         if(OrderSymbol()==pair&& OrderType()==OP_BUYSTOP && kode==OP_BUYSTOP)
           {tiket = OrderDelete(OrderTicket());Print("delete PObuy");}
         if(OrderSymbol()==pair&& OrderType()==OP_SELLSTOP&& kode==OP_SELLSTOP)
           {tiket = OrderDelete(OrderTicket());Print("delete POsell");}
         if(kode == -1)
           {
            if(OrderSymbol()==pair && OrderType()==OP_SELL)
              {tiket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,clrNONE);}
            if(OrderSymbol()==pair && OrderType()==OP_BUY)
              {tiket = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,clrNONE);}
            if(OrderSymbol()==pair && OrderType()>1)
              {
               tiket = OrderDelete(OrderTicket(),clrNONE);
              }
           }
        }
     }
     
   // RESET LEVEL_SL FLAG FOR OPERAION AND PAIR  
   if (kode== OP_BUY && closeAskedFor== "BUY"+pair)  
      closeAskedFor ="";
   if (kode== OP_SELL && closeAskedFor== "SELL"+pair)
     closeAskedFor =""; 
   
   
   return(tiket);
  }

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
     

int warna(string Ad_0) {
   color Li_ret_8=_Neutral;
   if (Ad_0 =="SELL") Li_ret_8 = _SellSignal;
   if (Ad_0 =="BUY") Li_ret_8 = _BuySignal;
   return (Li_ret_8);
}

   
void TradeNow()
{


  u_sep=StringGetCharacter(sep,0); 
    int k=StringSplit(mysymbol,u_sep,mysymbolList); 
   NumOfSymbols = ArraySize(mysymbolList);

 for (int jj=0;jj<NumOfSymbols;jj++){

  if(UseAllsymbol==true){//TRADE ALL SYMBOLS
   symbol=mysymbolList[jj];
      
  }else{symbol=Symbol(); }//TRADE CURRENT CHART SYMBOL
  
  

      double SetPoint=0;
      
      long VL =11;
      if(vdigits == 3 || vdigits == 5)
        {
         SetPoint =10*vpoint;
         VL=20;
        }
      if( vdigits == 4)
        {
         SetPoint = vpoint;
        }
      if(vdigits == 2 )
        {
         SetPoint = 10*vpoint;
        }

 double sl=0,tpx=0,tpx2=0,xlimit=0,xstop=0,slimit=0,slstop=0,tplimit=0,tpstop=0;

            if(TS>0 &&InpMoneyManagement==LOT_OPTIMIZE){TradingLots=SubLots;}
            
          //sell 
           if((TradeSignal()=="SELL")&&IsNewM1Candle()&&(Trade_Styles == SHORT || Trade_Styles==BOTH))
           { sendOnce = iTime(symbol,mtfz,0);
       
                 //Open Sell Order
 
   
        double price = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),vdigits);
         int ticket;
     double  SL = 200 * myPoint; //Stop Loss = value in points (relative to price)
      if(SL > MaxSL) SL = MaxSL;
      if(SL < MinSL) SL = MinSL;
      double TP = 200 * myPoint; //Take Profit = value in points (relative to price)
      if(TP > MaxTP) TP = MaxTP;
      if(TP < MinTP) TP = MinTP;
         if(TradeDays()==false) return; //open trades only on specific days of the week   

        
        switch( Order_Type){
        
         case MARKET_ORDERS:Os= ticket = myOrderSend(OP_SELL, price, TradeSize(InpMoneyManagement), "");break;
         case LIMIT_ORDERS: Os=ticket = myOrderSend(OP_SELLLIMIT, price,TradeSize(InpMoneyManagement) ,"");break;
         case STOP_ORDERS : Os=ticket = myOrderSend(OP_SELLSTOP, price, TradeSize(InpMoneyManagement), "");break;
          default :Os=ticket = myOrderSend(OP_SELLLIMIT, price,TradeSize(InpMoneyManagement), "");break;
        }
            if(ticket <= 0) {return;}else{ //not autotrading => only send alert
         myAlert("order", "");
         
      myOrderModifyRel(OrderTicket(), 0, TP);
      myOrderModifyRel(OrderTicket(), SL, 0);}
             
             }
  
            
            
            
            
            
            
            
            
            
            
            
  
//buy    
         if( (TradeSignal()=="BUY")&& (Trade_Styles == LONG || Trade_Styles==BOTH)&& IsNewM1Candle())
           { sendOnce = iTime(symbol,PERIOD_CURRENT,0);
    
         double  price = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),vdigits);
   
   int ticket;
      double SL = 200 * myPoint; //Stop Loss = value in points (relative to price)
      if(SL > MaxSL) SL = MaxSL;
      if(SL < MinSL) SL = MinSL;
     double  TP = 200 * myPoint; //Take Profit = value in points (relative to price)
      if(TP > MaxTP) TP = MaxTP;
      if(TP < MinTP) TP = MinTP;
    
    
        switch( Order_Type){
        
         case MARKET_ORDERS: Os=ticket = myOrderSend(OP_BUY, price, TradeSize(InpMoneyManagement), "");break;
         case LIMIT_ORDERS: Os=ticket = myOrderSend(OP_BUYLIMIT, price, TradeSize(InpMoneyManagement), "");break;
         case STOP_ORDERS :Os= ticket = myOrderSend(OP_BUYSTOP, price, TradeSize(InpMoneyManagement), "");break;
          default :Os= ticket = myOrderSend(OP_BUYLIMIT, price, TradeSize(InpMoneyManagement), "");break;
     }
         
           if(ticket <= 0){}else {//not autotrading => only send alert
         myAlert("order", "");
           myOrderModifyRel(OrderTicket(), 0, TP);
      myOrderModifyRel(OrderTicket(), SL, 0);
      }
  }   
 
   if( TargetReachedForDay != ThisDayOfYear && MaxSpread>0&&MarketInfo(symbol,MODE_SPREAD)<=MaxSpread && TradeDays() && trade && !StopTarget() && TradeMode == Automatic&& AccountBalance() > minbalance)
{
  
      double Free=AccountFreeMargin();
      double One_Lot=MarketInfo(symbol,MODE_MARGINREQUIRED);

      if(One_Lot!=0)
        {
         if(TradingLots>floor(Free/One_Lot*100)/100)
           {
            Print("NO ENOUGHT MONEY!");
            return;
           }
         if(TradingLots==0)
            return;
        }
      else{ return;}
              //=================================================
      double prs=0,prb=0;int TBa=0,TSa=0;
      int ttlbuy=0,ttlsell=0;
      for(int pos=0; pos<=OrdersTotal(); pos++)
        {
         if(!OrderSelect(pos,SELECT_BY_POS))
           {
            continue;
           }
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==symbol )//&& OrderType()==OP_BUY)
           {
            TBa++;
           }
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==symbol )//&& OrderType()==OP_SELL)
           {
            TSa++;
           }
         if(OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY)
           {
            ttlbuy ++;
           }
         if(OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL)
           {
            ttlsell ++;
           }
        }// Alert("t buy : ",ttlbuy," ttl sell : ",ttlsell);
      double point=MarketInfo(symbol,MODE_POINT);
      double digits=MarketInfo(symbol,MODE_DIGITS);
     bid =NormalizeDouble(MarketInfo(symbol,MODE_BID),(int)digits);
     ask =NormalizeDouble(MarketInfo(symbol,MODE_ASK),(int)digits);

             int cnt = 720;
             double cur_day = 0;
             double prev_day = 0;
             double rates_d1[2][6];
             //---- exit if period is greater than daily charts
             //---- Get new daily prices & calculate pivots
   	       cur_day = TimeDay(Time[0] - (GMTshift*3600));
   		    yesterday_close = iClose(symbol,snrperiod,1);
   		    today_open = iOpen(symbol,snrperiod,0);
   		    yesterday_high = iHigh(symbol,snrperiod,1);//day_high;
   		    yesterday_low = iLow(symbol,snrperiod,1);//day_low;
   		    day_high = iHigh(symbol,snrperiod,1);
   		    day_low  = iLow(symbol,snrperiod,1);
   		    prev_day = cur_day;
   		    
            	yesterday_high = MathMax(yesterday_high,day_high);	    
            	yesterday_low = MathMin(yesterday_low,day_low);	    

           
                //------ Pivot Points ------
                Rx = (yesterday_high - yesterday_low);
                Px = (yesterday_high + yesterday_low + yesterday_close)/3; //Pivot
                R1x = Px + (Rx * 0.38);
                R2x = Px + (Rx * 0.62);
                R3x = Px + (Rx * 0.99);
                S1x = Px - (Rx * 0.38);
                S2x = Px - (Rx * 0.62);
                S3x = Px - (Rx * 0.99);
//++++++++++++++++++++++++++++++++++++++++
               if (bid > R3x ) {R3x = 0; S3x = R2x;}
               if (bid > R2x && bid < R3x) {R3x = 0; S3x = R1x;}
               if (bid > R1x && bid < R2x) {R3x = R3x; S3x = Px;}
               if (bid > Px && bid < R1x) {R3x = R2x; S3x = S1x;}
               if (bid > S1x && bid < Px) {R3x = R1x; S3x = S2x;}
               if (bid > S2x && bid < S1x) {R3x = Px; S3x = S3x;}
               if (bid > S3x && bid < S2x) {R3x = S1x; S3x = 0;}
               if (bid < S3x) {R3x = S2x; S3x = 0;}

     


}}Sleep(100);
}
      
      
      
      
      
int myOrderSend(int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   int retries = 0;
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed"); 
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
   || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
   )
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
    
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = SymbolInfoDouble(symbol,SYMBOL_ASK);
   else if(type == OP_SELL)
      price = SymbolInfoDouble(symbol,SYMBOL_BID);
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   if(MaxSpread > 0 && SymbolInfoDouble(symbol,SYMBOL_ASK)- SymbolInfoDouble(symbol,SYMBOL_BID) > MaxSpread * myPoint)
     {
      myAlert("order", "Order"+ordername_+" not sent, maximum spread "+DoubleToStr(MaxSpread * myPoint, vdigits)+" exceeded");
      return(-1);
     }
   //adjust price for pending order if it is too close to the market price
   double MinDistance = PriceTooClose * myPoint;
   if(type == OP_BUYLIMIT && SymbolInfoDouble(symbol,SYMBOL_ASK) - price < MinDistance)
      price = SymbolInfoDouble(symbol,SYMBOL_ASK) - MinDistance;
   else if(type == OP_BUYSTOP && price - SymbolInfoDouble(symbol,SYMBOL_ASK) < MinDistance)
      price = SymbolInfoDouble(symbol,SYMBOL_ASK) + MinDistance;
   else if(type == OP_SELLLIMIT && price - SymbolInfoDouble(symbol,SYMBOL_BID) < MinDistance)
      price = SymbolInfoDouble(symbol,SYMBOL_BID) + MinDistance;
   else if(type == OP_SELLSTOP && SymbolInfoDouble(symbol,SYMBOL_BID) - price < MinDistance)
      price = SymbolInfoDouble(symbol,SYMBOL_BID) - MinDistance;
   while(ticket < 0 && retries < OrderRetry+1)
     {
     

     
     
     
     
     
     
     
      ticket = OrderSend(symbol, type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price,  vdigits), MaxSlippage,0, 0, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+symbol+" Magic #"+IntegerToString(MagicNumber));
   return(ticket);
  }

      
      
int myOrderModify(int ticket, double SL, double TP) //modify SL and TP (absolute price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, vdigits);
   TP = NormalizeDouble(TP, vdigits);
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   //adjust targets for market order if too close to the market price
   double MinDistance = PriceTooClose * myPoint;
   if(OrderType() == OP_BUY)
     {
      if(NormalizeDouble(SL, vdigits) != 0 && ask - SL < MinDistance)
         SL = ask - MinDistance;
      if(NormalizeDouble(TP, vdigits) != 0 && TP - ask < MinDistance)
         TP = ask + MinDistance;
     }
   else if(OrderType() == OP_SELL)
     {
      if(NormalizeDouble(SL, vdigits) != 0 && SL - bid < MinDistance)
         SL = bid + MinDistance;
      if(NormalizeDouble(TP, vdigits) != 0 && bid - TP < MinDistance)
         TP = bid - MinDistance;
     }
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(OrderTicket(), NormalizeDouble(OrderOpenPrice(), vdigits), NormalizeDouble(SL, vdigits), NormalizeDouble(TP, vdigits), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
   return(0);
  }

int myOrderModifyRel(int ticket, double SL, double TP) //modify SL and TP (relative to open price), zero targets do not modify
  {if(OrderSymbol()==symbol){
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err = 0;
   SL = NormalizeDouble(SL, vdigits);
   TP = NormalizeDouble(TP, vdigits);
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   //convert relative to absolute
   if(OrderType() % 2 == 0) //buy
     {
      if(NormalizeDouble(SL, vdigits) != 0)
         SL = OrderOpenPrice() - SL;
      if(NormalizeDouble(TP, vdigits) != 0)
         TP = OrderOpenPrice() + TP;
     }
   else //sell
     {
      if(NormalizeDouble(SL, vdigits) != 0)
         SL = OrderOpenPrice() + SL;
      if(NormalizeDouble(TP, vdigits) != 0)
         TP = OrderOpenPrice() - TP;
     }
   //adjust targets for market order if too close to the market price
   double MinDistance = PriceTooClose * myPoint;
   if(OrderType() == OP_BUY)
     {
      if(NormalizeDouble(SL, vdigits) != 0 && ask - SL < MinDistance)
         SL = ask - MinDistance;
      if(NormalizeDouble(TP, vdigits) != 0 && TP - ask < MinDistance)
         TP = ask + MinDistance;
     }
   else if(OrderType() == OP_SELL)
     {
      if(NormalizeDouble(SL, vdigits) != 0 && SL - bid < MinDistance)
         SL = bid + MinDistance;
      if(NormalizeDouble(TP, vdigits) != 0 && bid - TP < MinDistance)
         TP = bid - MinDistance;
     }
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(OrderTicket(), NormalizeDouble(OrderOpenPrice(), vdigits), NormalizeDouble(SL, vdigits), NormalizeDouble(TP, vdigits), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+IntegerToString(ticket);
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+DoubleToString(SL);
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+DoubleToString(TP);
   myAlert("modify", alertstr);
  } return(0);
  }

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
   
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
    
  