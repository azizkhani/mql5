//+------------------------------------------------------------------+
//|                                                    azizkhani.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input double lot=0.5;

void OnTick(){

  if(MacdCciSignalCL()=="Close buy")
      close(1111);
  
  if(MacdCciSignalCL()=="Close Sell")
      close(2222);
  
  
  if(iVolumes(NULL,0,0)<=1 &&Orders()==0){
    if(MacdCciSignalOP()=="Buy" && iMACD(NULL,0,12,26,9,PRICE_CLOSE)<0)
      buyOrSell(111,ORDER_TYPE_BUY_LIMIT);
      
    if(MacdCciSignalOP()=="Sell" && iMACD(NULL,0,12,26,9,PRICE_CLOSE)>0) 
      buyOrSell(222,ORDER_TYPE_BUY_LIMIT);
  }
  
   Alert("iMACD"+iMACD(NULL,0,12,26,9,PRICE_CLOSE));
   Alert("iMA"+iMA(Symbol(), PERIOD_CURRENT, 30, 0, MODE_SMA, PRICE_CLOSE));
  // test buy
   //buyOrSell(222,ORDER_TYPE_BUY_LIMIT);
   // PlaceMarketOrder(100,1000);
  
}

//+-------------------------------تابع چک کردن اندکاتورها-----------------------------------+
string  MacdCciSignalOP(){
      
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE)> iMACD(NULL,0,12,26,9,PRICE_CLOSE) && 
         iCCI(Symbol(),0,14,PRICE_TYPICAL)>100){
      return("Buy");
   }
   else if(iMACD(NULL,0,12,26,9,PRICE_CLOSE)< iMACD(NULL,0,12,26,9,PRICE_CLOSE) && 
            iCCI(NULL,0,14,PRICE_TYPICAL)<-100){
      return("Sell");
   }
   else
      return("NO SIGNAL");
 }
   
   
//+-------------------------------تایع شمارش پوزیشنها-----------------------------------+   
int Orders(){
   int num=0;
   for(int i=OrdersTotal()-1;i>=0;i--){
       if(OrderSelect(i)){
         if(OrderGetInteger(ORDER_MAGIC)==1111 || OrderGetInteger(ORDER_MAGIC)==2222)
            num++;
       }
   }
   return(num);
}
  /*int  iMACD(
   string              symbol,              // symbol name
   ENUM_TIMEFRAMES     period,              // period
   int                 fast_ema_period,     // period for Fast average calculation
   int                 slow_ema_period,     // period for Slow average calculation
   int                 signal_period,       // period for their difference averaging
   ENUM_APPLIED_PRICE  applied_price        // type of price or handle
   );
   iMACD(NULL,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,2)
  */
  
  /*
  double  iMACD(
   string       symbol,           // symbol
   int          timeframe,        // timeframe
   int          fast_ema_period,  // Fast EMA period
   int          slow_ema_period,  // Slow EMA period
   int          signal_period,    // Signal line period
   int          applied_price,    // applied price
   int          mode,             // line index
   int          shift             // shift
   );
   
   iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)
  */
  
//+-------------------------------تابع چک کردن اندکاتورها-----------------------------------+
string  MacdMovingAVG(){
      
   if(iMACD(NULL,0,12,26,9,PRICE_CLOSE)> iMACD(NULL,0,12,26,9,PRICE_CLOSE) && 
          iMA(Symbol(), PERIOD_H1, 0, 0, MODE_SMA, PRICE_CLOSE)>100){
      return("Buy");
   }
   else if(iMACD(NULL,0,12,26,9,PRICE_CLOSE)< iMACD(NULL,0,12,26,9,PRICE_CLOSE) && 
             iMA(Symbol(), PERIOD_H1, 0, 0, MODE_SMA, PRICE_CLOSE)<-100){
      return("Sell");
   }
   else
      return("NO SIGNAL");
}
  
 //+-------------------------------تابع چک کردن مکدی برای بستن پوزشنها-----------------------------------+      
string  MacdCciSignalCL(){
   if(iMACD(NULL,PERIOD_CURRENT,12,26,9,PRICE_CLOSE)> iMACD(NULL,0,12,26,9,PRICE_CLOSE)  &&
                  iMACD(NULL,0,12,26,9,PRICE_CLOSE)< iMACD(NULL,0,12,26,9,PRICE_CLOSE))
      return("Close buy");
   else if(iMACD(NULL,0,12,26,9,PRICE_CLOSE)< iMACD(NULL,0,12,26,9,PRICE_CLOSE)  && 
               iMACD(NULL,0,12,26,9,PRICE_CLOSE)> iMACD(NULL,0,12,26,9,PRICE_CLOSE))
      return("Close Sell");
   else
      return("NO SIGNAL");
}
   
   
//+-------------------------------تاربع بستن پوزیشنها-----------------------------------+    
void close(int Magic){
 for(int i=OrdersTotal()-1;i>=0;i--){
    if(OrderSelect(i)){
      // if(OrderGetInteger(ORDER_MAGIC)==Magic)
       // bool yccb =OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,clrGreen);
    }   
  }
}

void buyOrSell(int EXPERT_MAGIC,ENUM_ORDER_TYPE orderType){

   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   //--- parameters to place a pending order
   request.action   =TRADE_ACTION_PENDING;                             // type of trade operation
   request.symbol   =Symbol();                                         // symbol
   request.volume   =0.1;                                              // volume of 0.1 lot
   request.deviation=5;                                                // allowed deviation from the price
   request.magic    =EXPERT_MAGIC;                                     // MagicNumber of the order
   int offset = 50;                                                    // offset from the current price to place the order, in points
   double price;                                                       // order triggering price
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);                // value of point
   int digits=SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);                // number of decimal places (precision)
   //--- checking the type of operation
   if(orderType==ORDER_TYPE_BUY_LIMIT){
      request.type     =ORDER_TYPE_BUY_LIMIT;                          // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;        // price for opening 
      request.price    =NormalizeDouble(price,digits);                 // normalized opening price 
   }
   else if(orderType==ORDER_TYPE_SELL_LIMIT){
      request.type     =ORDER_TYPE_SELL_LIMIT;                          // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point;         // price for opening 
      request.price    =NormalizeDouble(price,digits);                  // normalized opening price 
   }
   else if(orderType==ORDER_TYPE_BUY_STOP){
      request.type =ORDER_TYPE_BUY_STOP;                                // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point;         // price for opening 
      request.price=NormalizeDouble(price,digits);                      // normalized opening price 
   }
   else if(orderType==ORDER_TYPE_SELL_STOP){
      request.type     =ORDER_TYPE_SELL_STOP;                           // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID)-offset*point;         // price for opening 
      request.price    =NormalizeDouble(price,digits);                  // normalized opening price 
   }
   else Alert("This example is only for placing pending orders");   // if not pending order is selected
   //--- send the request
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());   // if unable to send the request, output the error code
   //--- information about the operation
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
}

bool PlaceMarketOrder(double val,int EXPERT_MAGIC){
      MqlTradeRequest Request;
      MqlTradeResult Result;
 
        Request.volume = NormalizeDouble(MathAbs(val),2);
     if (val<0){
         Request.type = ORDER_TYPE_SELL; 
         Request.comment = "Sell "+ DoubleToString(Request.volume)+" "+ _Symbol;
     } else{
         Request.type = ORDER_TYPE_BUY; 
         Request.comment = "Buy "+ DoubleToString(Request.volume)+" "+ _Symbol;
     }
     Request.action = TRADE_ACTION_DEAL;
     //Request.type_filling = ORDER_FILLING_AON;
     Request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
     Request.symbol = _Symbol;
     Request.deviation = 5;
     Request.magic = EXPERT_MAGIC;
     Request.sl=0;
     Request.tp=0;
     bool result = OrderSend(Request, Result); 
     if (result == false)    Print("OrderSend failure.");
    
     Alert("PlaceMarketOrder() return code: " + IntegerToString(Result.retcode));

   return result;
}