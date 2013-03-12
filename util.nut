function inflate(money)
	{
	return money*GetInflationRate()/100;
	}

function deinflate(money)
	{
	return money*100/GetInflationRate();
	}

function GetInflationRate() //from simpleai
	{
	return (100 * AICompany.GetMaxLoanAmount() / AIGameSettings.GetValue("difficulty.max_loan"));
	}

enum StationDirection
{
x_is_constant__horizontal,
y_is_constant__vertical
}

class Station
{
location = null;
direction = null;
is_city = null;
}

function ProvideMoney()
{
if(AICompany.GetBankBalance(AICompany.COMPANY_SELF)>10*AICompany.GetMaxLoanAmount()) AICompany.SetLoanAmount(0);
else AICompany.SetLoanAmount(AICompany.GetMaxLoanAmount());
}

function RepayLoan()
{
while(AICompany.SetLoanAmount(AICompany.GetLoanAmount()-AICompany.GetLoanInterval()));
}

function GetAvailableMoney()
{
local me = AICompany.ResolveCompanyID(AICompany.COMPANY_SELF);
return AICompany.GetBankBalance(me) + AICompany.GetMaxLoanAmount() - AICompany.GetLoanAmount() - inflate(10000);
}

function SetNameOfVehicle(vehicle_id, string)
{
if(!AIVehicle.IsValidVehicle(vehicle_id)) abort("Invalid vehicle");
local i = 1;
for(;!AIVehicle.SetName(vehicle_id, string + " #" + i); i++)
	{
	//Error("SetNameOfVehicle: " + AIError.GetLastErrorString() + ": " + string);
	if(AIError.GetLastError() == AIError.ERR_PRECONDITION_STRING_TOO_LONG) SetNameOfVehicle(vehicle_id, "PRECONDITION_FAILED");
	}
}

function TotalLastYearProfit()
{
local list = AIVehicleList();
local suma =0;
for (local q = list.Begin(); list.HasNext(); q = list.Next()) //from Chopper 
   {
   suma += AIVehicle.GetProfitLastYear(q);
   }
return suma;
}

function IsItNeededToImproveThatStation(station, cargo)
{
return AIStation.GetCargoWaiting(station, cargo)>50 || (AIStation.GetCargoRating(station, cargo)<40&&AIStation.GetCargoWaiting(station, cargo)>0) ;
}

function IsItNeededToImproveThatNoRawStation(station, cargo)
{
return AIStation.GetCargoWaiting(station, cargo)>150 || (AIStation.GetCargoRating(station, cargo)<40&&AIStation.GetCargoWaiting(station, cargo)>0) ;
}

function NewLine()
	{
	AILog.Info(" ");
	} 

function Debug(string){Info(string);} //redirect
function Info(string)
{
local date=AIDate.GetCurrentDate ();
AILog.Info(AIDate.GetYear(date)  + "." + AIDate.GetMonth(date)  + "." + AIDate.GetDayOfMonth(date)  + " " + string);
}


function Important(string){Info(string);} //redirect
function Warning(string)
{
local date=AIDate.GetCurrentDate ();
AILog.Warning(AIDate.GetYear(date)  + "." + AIDate.GetMonth(date)  + "." + AIDate.GetDayOfMonth(date)  + " " + string);
}

function Error(string)
{
local date=AIDate.GetCurrentDate ();
AILog.Error(AIDate.GetYear(date)  + "." + AIDate.GetMonth(date)  + "." + AIDate.GetDayOfMonth(date)  + " " + string);
}

/////////////////////////////////////////////////
/// Age of the youngest vehicle (in days)
/////////////////////////////////////////////////
function AgeOfTheYoungestVehicle(station)
{
local list = AIVehicleList_Station(station);
local minimum = 10000;
for (local q = list.Begin(); list.HasNext(); q = list.Next()) //from Chopper 
   {
   local age=AIVehicle.GetAge(q);
   if(minimum>age)minimum=age;
   }

return minimum;
}

function GetAverageCapacity(station, cargo)
{
local list = AIVehicleList_Station(station);
local total = 0;
local ile = 0;
for (local q = list.Begin(); list.HasNext(); q = list.Next()) //from Chopper 
   {
   local plus=AIVehicle.GetCapacity (q, cargo);
   if(plus>0)
      {
	  total+=plus;
	  ile++;
	  }
   }
if(ile==0)return 0;
else return total/ile;
}

function abort(message)
{
Error(message + ", last error is " + AIError.GetLastErrorString());
Warning("Please, post savegame");
local zero=0/0;
}

function GetDepotLocation(vehicle)
{
if (!AIVehicle.IsValidVehicle(vehicle)) abort("invalid vehicle: " + vehicle);
local new_style = LoadDataFromStationNameFoundByStationId(AIStation.GetStationID(GetLoadStationLocation(vehicle)), "[]");
if(AIMap.IsValidTile(new_style)) return new_style;
//for(local i=0; i<AIOrder.GetOrderCount(vehicle); i++) if(AIOrder.IsGotoDepotOrder(vehicle, i))return AIOrder.GetOrderDestination(vehicle, i);
abort("Explosion caused by vehicle " + AIVehicle.GetName(vehicle)+ "psudotile from station name is "+new_style);
}

function GetLoadStationLocation(vehicle)
{
if (!AIVehicle.IsValidVehicle(vehicle)) abort("invalid vehicle: " + vehicle);
for(local i=0; i<AIOrder.GetOrderCount(vehicle); i++) if(AIOrder.IsGotoStationOrder(vehicle, i))return AIOrder.GetOrderDestination(vehicle, i);
abort("Explosion caused by vehicle " + AIVehicle.GetName(vehicle));
}

function GetUnloadStationLocation(vehicle)
{
if (!AIVehicle.IsValidVehicle(vehicle)) abort("invalid vehicle: " + vehicle);

local onoff = false;
for(local i=0; i<AIOrder.GetOrderCount(vehicle); i++) {
   if(AIOrder.IsGotoStationOrder(vehicle, i)) {
	  if(onoff==true)return AIOrder.GetOrderDestination(vehicle, i);
	  onoff=true
	  }
   }
abort("Explosion caused by vehicle " + AIVehicle.GetName(vehicle));
}

function GetVehicleType(vehicle_id)
{
	return AIEngine.GetVehicleType(AIVehicle.GetEngineType(vehicle_id));
}

function IsAllowedPAXPlane()
{
	if(0 == AIAI.GetSetting("PAX_plane"))return false;
	return IsAllowedPlane();
}

function IsAllowedCargoPlane()
{
	if(0 == AIAI.GetSetting("cargo_plane"))return false;
	return IsAllowedPlane();
}

function IsAllowedPlane()
{
	if(AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_AIR))return false;

	local ile;
	local veh_list = AIVehicleList();
	veh_list.Valuate(GetVehicleType);
	veh_list.KeepValue(AIVehicle.VT_AIR);
	ile = veh_list.Count();
	local allowed = AIGameSettings.GetValue("vehicle.max_aircraft");
	if(allowed==0)return false;
	if(ile==0)return true;
	if((allowed - ile)<4) return false;
	if(((ile*100)/(allowed))>90) return false;
	return true;
}

function IsAllowedTruck()
{
	if(0 == AIAI.GetSetting("use_trucks"))return false;
	return IsAllowedRV();
}

function IsAllowedSmartCargoTrain()
{
	if(0 == AIAI.GetSetting("use_smart_freight_trains"))return false;
	return IsAllowedTrain();
}

function IsAllowedStupidCargoTrain()
{
	if(0 == AIAI.GetSetting("use_stupid_freight_trains"))return false;
	return IsAllowedTrain();
}

function IsAllowedBus()
{
	if(0 == AIAI.GetSetting("use_busses"))return false;
	return IsAllowedRV();
}

function IsAllowedRV()
{
	if(AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_ROAD))return false;

	local ile;
	local veh_list = AIVehicleList();
	veh_list.Valuate(GetVehicleType);
	veh_list.KeepValue(AIVehicle.VT_ROAD);
	ile = veh_list.Count();
	local allowed = AIGameSettings.GetValue("vehicle.max_roadveh");
	if(allowed==0)return false;
	if(ile==0)return true;
	if(((ile*100)/(allowed))>90) return false;
	if((allowed - ile)<5) return false;
	return true;
}

function IsAllowedTrain()
{
	if(AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_RAIL))return false;

	local ile;
	local veh_list = AIVehicleList();
	veh_list.Valuate(GetVehicleType);
	veh_list.KeepValue(AIVehicle.VT_RAIL);
	ile = veh_list.Count();
	local allowed = AIGameSettings.GetValue("vehicle.max_trains");
	if(allowed==0)return false;
	if(ile==0)return true;
	if(((ile*100)/(allowed))>90) return false;
	if((allowed - ile)<5) return false;
	return true;
}

function BurnMoney()
{
//clear water
//tree planting
local tile;
do
  {
  tile = RandomTile();
  }

while(!AITile.IsWaterTile(tile))
while(true)
   {
    AITile.DemolishTile(tile);
	if(AIError.GetLastError() == AIError.ERR_NOT_ENOUGH_CASH)break;
   }

while(true)
  {
  tile = RandomTile();
  AITile.PlantTree(tile);
  if(AIError.GetLastError() == AIError.ERR_NOT_ENOUGH_CASH)return;
  }
}

function Name()
	{
	if((AICompany.GetName(AICompany.COMPANY_SELF)!="AIAI")&&(AIVehicleList().Count()>0)){
		while(true){
			Sleep(1000);
			Info("Company created by other ai. As such it is not possible for AIAI to menage that company.");
			Info("Zzzzz...")
			}
		}
	AICompany.SetPresidentName("http://tinyurl.com/ottdaiai");
	AICompany.SetName("AIAI");
	if (AICompany.GetName(AICompany.COMPANY_SELF)!="AIAI"){
			if(!AICompany.SetName("Suicide AIAI")){
			local i = 2;
			while (!AICompany.SetName("Suicide AIAI #" + i))i++;
			}
		BurnMoney();
		while(true) Sleep(1000);
		}
	}

function Sqrt(i) { //from Rondje
	if (i == 0)
		return 0;   // Avoid divide by zero
	local n = (i / 2) + 1;       // Initial estimate, never low
	local n1 = (n + (i / n)) / 2;
	while (n1 < n) {
		n = n1;
		n1 = (n + (i / n)) / 2;
	}
	return n;
}

function SafeAddRectangle(list, tile, radius) { //from Rondje
	local x1 = max(1, AIMap.GetTileX(tile) - radius);
	local y1 = max(1, AIMap.GetTileY(tile) - radius);
	
	local x2 = min(AIMap.GetMapSizeX() - 2, AIMap.GetTileX(tile) + radius);
	local y2 = min(AIMap.GetMapSizeY() - 2, AIMap.GetTileY(tile) + radius);
	
	//Error("(" + x1 + ", " + y1 + ")" + "(" + x2 + ", " + y2 + ")")
	
	list.AddRectangle(AIMap.GetTileIndex(x1, y1),AIMap.GetTileIndex(x2, y2)); 
}

function mini(a, b)
{
if(a<b)return a;
return b;
}

function maxi(a, b)
{
if(a>b)return a;
return b;
}

function abs(a)
{
if(a<0)return -a;
return a;
}

function RandomTile() { //from ChooChoo
	return abs(AIBase.Rand()) % AIMap.GetMapSize();
}

function StringToInteger(string)
{
Info(string+"<-len")
local result = 0;
local i=0;
while(i<string.len()){
	result=result*10+string[i]-48;
	i++;
	}
return result;
}
