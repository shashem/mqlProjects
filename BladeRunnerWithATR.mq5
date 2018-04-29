//+------------------------------------------------------------------+
//|                                              EpicBladeRunner.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <trade/trade.mqh>
input int Stop_Loss   = 2000; // Stop Loss [point]
input int Take_Profit = 2000; // Take Profit [point]
float MULTIPLIER = .00001;
input int Fast_Move = 14;
input int Slow_Move = 30;
input int MOMEN = 14;
input double MOMEN_NUM = 99.99;
input double MOMEN_NUM_LOW = 99.5;
input double MOMEN_SELL = 14;
input double MOMEN_SELL_NUM = 99.99;
input double MOMEN_SELL_NUM_LOW = 99.5;
int CURRENT_STATUS = 0;
int HOLDER = 0;
double VOLUME = .1;
datetime lastbar = 0;
double LastOrderPrice = 0;
double maxDefFromBuy = 0;
double maxDefFromSell = 0;
int ResetClock = 0;
void OnTick()
  {
      double A_MA_15M_14[], A_MA_15M_30[], A_MA_30M_14[], A_MA_30M_30[], A_MA_H1_14[], A_MA_H1_30[], A_MA_H4_14[], A_MA_H4_30[], A_MA_D1_14[], A_MA_D1_30[], ATR1_PERIOD[], ATR2_PERIOD[];
      MqlTick Latest_Price; // Structure to get the latest prices      
      SymbolInfoTick(Symbol() ,Latest_Price);
      
      
      int MA_15M_14 = iMA(_Symbol, PERIOD_M15, Fast_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_15M_30 = iMA(_Symbol, PERIOD_M15, Slow_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_30M_14 = iMA(_Symbol, PERIOD_M30, Fast_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_30M_30 = iMA(_Symbol, PERIOD_M30, Slow_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_H1_14 = iMA(_Symbol, PERIOD_H1, Fast_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_H1_30 = iMA(_Symbol, PERIOD_H1, Slow_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_H4_14 = iMA(_Symbol, PERIOD_H4, Fast_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_H4_30 = iMA(_Symbol, PERIOD_H4, Slow_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_D1_14 = iMA(_Symbol, PERIOD_D1, Fast_Move, 0, MODE_SMA, PRICE_CLOSE);
      int MA_D1_30 = iMA(_Symbol, PERIOD_D1, Slow_Move, 0, MODE_SMA, PRICE_CLOSE);
      int ATR1 = iMomentum(_Symbol, PERIOD_H4, MOMEN, PRICE_CLOSE);
      int ATR2 = iMomentum(_Symbol, PERIOD_H4, MOMEN_SELL, PRICE_CLOSE);
    
      ArraySetAsSeries(A_MA_15M_14, true);
      ArraySetAsSeries(A_MA_15M_30, true);
      ArraySetAsSeries(A_MA_30M_14, true);
      ArraySetAsSeries(A_MA_30M_30, true);
      ArraySetAsSeries(A_MA_H1_14, true);
      ArraySetAsSeries(A_MA_H1_30, true);                  
      ArraySetAsSeries(A_MA_H4_14, true);
      ArraySetAsSeries(A_MA_H4_30, true);
      ArraySetAsSeries(A_MA_D1_14, true);
      ArraySetAsSeries(A_MA_D1_30, true);
      ArraySetAsSeries(ATR1_PERIOD, true);
      ArraySetAsSeries(ATR2_PERIOD, true);
     
      CopyBuffer(MA_15M_14, 0, 0, 3, A_MA_15M_14);
      CopyBuffer(MA_15M_30, 0, 0, 3, A_MA_15M_30);
      CopyBuffer(MA_30M_14, 0, 0, 3, A_MA_30M_14);
      CopyBuffer(MA_30M_30, 0, 0, 3, A_MA_30M_30);
      CopyBuffer(MA_H1_14, 0, 0, 3, A_MA_H1_14);
      CopyBuffer(MA_H1_30, 0, 0, 3, A_MA_H1_30);
      CopyBuffer(MA_H4_14, 0, 0, 3, A_MA_H4_14);
      CopyBuffer(MA_H4_30, 0, 0, 3, A_MA_H4_30);
      CopyBuffer(MA_D1_14, 0, 0, 3, A_MA_D1_14);
      CopyBuffer(MA_D1_30, 0, 0, 3, A_MA_D1_30);
      CopyBuffer(ATR1, 0, 0, 3, ATR1_PERIOD);
      CopyBuffer(ATR2, 0, 0, 3, ATR2_PERIOD);
      
     if(A_MA_H4_14[0] > A_MA_H4_30[0] && CURRENT_STATUS == 0 && ATR1_PERIOD[0] >= MOMEN_NUM && HOLDER == 0 && IsNewBar())
      {
         //A_MA_D1_14[0] > A_MA_D1_30[0]if(A_MA_H4_14[0] > A_MA_H4_30[0] )
         //{
           // if(A_MA_H1_14[0] > A_MA_H1_30[0])
            //{
              // if(A_MA_30M_14[0] > A_MA_30M_30[0])
               //{
                 // if(A_MA_15M_14[0] > A_MA_15M_30[0])
                  //{
                     OpenBuyOrder(VOLUME);//Orig
                     //OpenSellOrder(VOLUME);
                     SendNotification("Possible Buy Opportunity for " + _Symbol);
                     CURRENT_STATUS = 1;
                  //}
               //}
            //}
         //}
      }
      
      if((//A_MA_D1_14[0] < A_MA_D1_30[0] ||
            A_MA_H4_14[0] < A_MA_H4_30[0] ||
            //A_MA_H1_14[0] < A_MA_H1_30[0] ||
            //A_MA_30M_14[0] < A_MA_30M_30[0] ||
            //A_MA_15M_14[0] < A_MA_15M_30[0] || 
            ATR1_PERIOD[0] < MOMEN_NUM_LOW
            ) && CURRENT_STATUS == 1 && IsNewBar() )
      {
         OpenSellOrder(VOLUME);//Orig
         //OpenBuyOrder(VOLUME);
         SendNotification("If in get out " + _Symbol);
         CURRENT_STATUS = 0;
         
      }
      
      if(A_MA_H4_14[0] < A_MA_H4_30[0] && CURRENT_STATUS == 0 && ATR2_PERIOD[0] >= MOMEN_SELL_NUM && HOLDER == 0 && IsNewBar())
      {
        //A_MA_D1_14[0] < A_MA_D1_30[0] if(A_MA_H4_14[0] < A_MA_H4_30[0])
         //{
            //if(A_MA_H1_14[0] < A_MA_H1_30[0])
            //{
             //  if(A_MA_30M_14[0] < A_MA_30M_30[0])
               //{
                 // if(A_MA_15M_14[0] < A_MA_15M_30[0])
                  //{
                     OpenSellOrder(VOLUME);//Orig
                     //OpenBuyOrder(VOLUME);
                     SendNotification("Possible Sell Opportunity for " + _Symbol);
                     CURRENT_STATUS = 2;
                  //}
               //}
            //}
         //}
      }
      
      if((//A_MA_D1_14[0] > A_MA_D1_30[0] ||
            A_MA_H4_14[0] > A_MA_H4_30[0] ||
            //A_MA_H1_14[0] > A_MA_H1_30[0] ||
            //A_MA_30M_14[0] > A_MA_30M_30[0] ||
            //A_MA_15M_14[0] > A_MA_15M_30[0] || 
            ATR2_PERIOD[0] < MOMEN_SELL_NUM_LOW
            ) 
            && CURRENT_STATUS == 2 && IsNewBar())
      {
         OpenBuyOrder(VOLUME); //Orig
         //OpenSellOrder(VOLUME);
         SendNotification("If in get out " + _Symbol);
         CURRENT_STATUS = 0;
         
      }
      if(CURRENT_STATUS == 0)
      {
         Comment("All Good");
      }
      else if(CURRENT_STATUS == 1)
      {
         Comment("Buy Status");
      }
      else if(CURRENT_STATUS == 2)
      {
         Comment("Sell Status");
      }
      //Comment(OrdersTotal());
        if(PositionsTotal() == 0 && CURRENT_STATUS == 1)
        {
            HOLDER = 10;
        }
        else if(PositionsTotal() == 0 && CURRENT_STATUS == 2)
        {
            HOLDER = 20;
        }
        if(A_MA_15M_14[0] > A_MA_15M_30[0] && HOLDER == 10)
        {
            //CURRENT_STATUS = 0;
            HOLDER = 0;
        }
        else if(A_MA_15M_14[0] < A_MA_15M_30[0] && HOLDER == 20)
        {
            //CURRENT_STATUS = 0;
            HOLDER = 0;
        }
        
  }
  
  void OpenBuyOrder(double volume)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_BUY;
   myRequest.symbol = _Symbol;
   myRequest.volume = volume;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   myRequest.tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Take_Profit * MULTIPLIER);
   myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LastBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   
   LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   CURRENT_STATUS = 1;
}
void OpenSellOrderClose(double volume)
{
   CTrade trade;
   /*for(int i = PositionsTotal()-1; i>=0; i--)
   {
      trade.PositionClose(PositionGetSymbol(i));
      
   }*/
   trade.PositionClose(_Symbol);
   CURRENT_STATUS = 0;
   /*MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_SELL;
   myRequest.symbol = _Symbol;
   myRequest.volume = volume;
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //myRequest.tp = Ask + (ProfitPunkte * _Point);
   //myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + standardStopLoss;
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LastEquity=AccountInfoDouble(ACCOUNT_EQUITY);*/
}
void OpenSellOrder(double volume)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_SELL;
   myRequest.symbol = _Symbol;
   myRequest.volume = volume;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   myRequest.tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Take_Profit * MULTIPLIER);
   myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LastEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   CURRENT_STATUS = 2;
}
//+------------------------------------------------------------------+
bool IsNewBar()
{
   
  datetime lastbar_time = SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
  
  if(lastbar ==0)
  {
      lastbar = lastbar_time;
      return false;
  }
  if(lastbar!=lastbar_time)
  {
      lastbar = lastbar_time;
      return true;
  }
  return false;
}

