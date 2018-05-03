

input int Stop_Loss   = 200; // Stop Loss [point]
input int Take_Profit = 500; // Take Profit [point]
input double ATR_NUM = 100;
input int BB_NORM = 20;
input int BB_SUPP = 20;
double VOLUME = .1;
float MULTIPLIER = .00001;
int CURRENT_STATUS = 0;
#include <trade/trade.mqh>
datetime lastbar = 0;

void OnTick()
{
   double BB_Lower[], BB_High[], BB_Mid[];
   double BB_Extra_Low[], BB_Extra_High[];
   double ATR[];
   double MA_F[], MA_S[];
   double MA_F_W[], MA_S_W[];
   
   int _ATR = iMomentum(_Symbol, PERIOD_D1, 20, PRICE_CLOSE);
   int BB_Def = iBands(_Symbol, PERIOD_D1, BB_NORM, 0, 2, PRICE_CLOSE);
   int BB_Def_X = iBands(_Symbol, PERIOD_D1, BB_SUPP, 0, 3, PRICE_CLOSE);
   int Def_MA_F = iMA(_Symbol, PERIOD_W1, 14,0, MODE_SMA, PRICE_CLOSE);
   int Def_MA_S = iMA(_Symbol, PERIOD_W1, 30, 0, MODE_SMA, PRICE_CLOSE);
   int Def_MA_F_W = iMA(_Symbol, PERIOD_MN1, 14, 0, MODE_SMA, PRICE_CLOSE);
   int Def_MA_S_W = iMA(_Symbol, PERIOD_MN1, 30, 0, MODE_SMA, PRICE_CLOSE);
   
   ArraySetAsSeries(BB_Lower, true);
   ArraySetAsSeries(BB_High, true);
   ArraySetAsSeries(BB_Mid, true);
   ArraySetAsSeries(BB_Extra_High, true);
   ArraySetAsSeries(BB_Extra_Low, true);
   ArraySetAsSeries(ATR, true);
   ArraySetAsSeries(MA_F, true);
   ArraySetAsSeries(MA_S, true);
   ArraySetAsSeries(MA_F_W, true);
   ArraySetAsSeries(MA_S_W, true);
   
   CopyBuffer(_ATR, 0, 0, 3, ATR);
   CopyBuffer(BB_Def, 2, 0, 3, BB_Lower);
   CopyBuffer(BB_Def, 1, 0, 3, BB_Mid);
   CopyBuffer(BB_Def, 0, 0, 3, BB_High);
   CopyBuffer(BB_Def_X, 2, 0, 3, BB_Extra_Low);
   CopyBuffer(BB_Def_X, 0, 0, 3, BB_Extra_High);
   CopyBuffer(Def_MA_F, 0, 0, 3, MA_F);
   CopyBuffer(Def_MA_S, 0, 0, 3, MA_S);
   CopyBuffer(Def_MA_F_W, 0, 0, 3, MA_F_W);
   CopyBuffer(Def_MA_S_W, 0, 0, 3, MA_S_W);
      
   MqlTick Latest_Price;
   SymbolInfoTick(Symbol() ,Latest_Price);
   
   if(Latest_Price.ask < BB_Lower[0] &&
   MA_F[0] > MA_S[0] &&
   MA_F_W[0] > MA_S_W[0] &&
   CURRENT_STATUS == 0 &&
   IsNewBar())
   {
      OpenBuyOrder();
   }
   if(CURRENT_STATUS == 1 &&
   IsNewBar() &&
   (Latest_Price.ask < BB_Extra_Low[0] ||
    Latest_Price.ask > BB_Mid[0] ||
    MA_F[0] < MA_S[0] ||
    MA_F_W[0] < MA_S_W[0]))
   {
      CloseBuyOrder();
   }
   
   if(Latest_Price.ask > BB_High[0] &&
   CURRENT_STATUS == 0 &&
   MA_S[0] > MA_F[0] &&
   MA_S_W[0] > MA_F_W[0] &&
   IsNewBar())
   {
      OpenSellOrder();
   }
   if(CURRENT_STATUS == 2 &&
   IsNewBar() &&
   (Latest_Price.ask > BB_Extra_High[0] ||
    Latest_Price.ask < BB_Mid[0] ||
    MA_S[0] < MA_F[0] ||
    MA_S_W[0] < MA_F_W[0]))
   {
      CloseSellOrder();
   }
   
 }
 void OpenBuyOrder()//double tp, double sl)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_BUY;
   myRequest.symbol = _Symbol;
   myRequest.volume = VOLUME;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //myRequest.tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Take_Profit * MULTIPLIER);
   //myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LasdtBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   
   //LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   CURRENT_STATUS = 1;
}
void CloseBuyOrder()//double tp, double sl)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_SELL;
   myRequest.symbol = _Symbol;
   myRequest.volume = VOLUME;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //myRequest.tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Take_Profit * MULTIPLIER);
   //myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LastEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   //LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);     
   CURRENT_STATUS =  0;
}
void OpenSellOrder()//double tp, double sl)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_SELL;
   myRequest.symbol = _Symbol;
   myRequest.volume = VOLUME;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //myRequest.tp = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Take_Profit * MULTIPLIER);
   //myRequest.sl = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LastEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   //LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);     
   CURRENT_STATUS =  2;
}
 void CloseSellOrder()//double tp, double sl)
{
   MqlTradeRequest myRequest;
   MqlTradeResult myResult;
   ZeroMemory(myRequest);
   
   double v = AccountInfoDouble(ACCOUNT_BALANCE) * .0001;
   //float volumeCalc = (ACCOUNT_BALANCE * .015)/Stop_Loss;
   
   myRequest.action = TRADE_ACTION_DEAL;
   myRequest.type = ORDER_TYPE_BUY;
   myRequest.symbol = _Symbol;
   myRequest.volume = VOLUME;//NormalizeDouble(v, 2);
   myRequest.type_filling = ORDER_FILLING_FOK;
   myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //myRequest.tp = tp;//SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (Take_Profit * MULTIPLIER);
   //myRequest.sl = sl;//SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (Stop_Loss * MULTIPLIER);
   myRequest.deviation = 50;
   OrderSend(myRequest, myResult);
   double LasdtBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   
   //LastOrderPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   CURRENT_STATUS = 0;
}
bool IsNewBar()
{
   
  datetime lastbar_time = SeriesInfoInteger(Symbol(), PERIOD_H1, SERIES_LASTBAR_DATE);
  
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
