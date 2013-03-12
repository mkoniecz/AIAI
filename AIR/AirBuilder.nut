class AirBuilder extends Builder
{
}

function AirBuilder::FindPairIndustryToTownAllocator(route)
{
route.first_station.location = null;
route.second_station.location = null;
return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_METROPOLITAN, route.start);
route.second_station.location = FindSuitableAirportSpotInTheTown(AIAirport.AT_METROPOLITAN, route.end, route.cargo);
route.station_size = AIAirport.AT_METROPOLITAN;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_LARGE, route.start);
route.second_station.location = FindSuitableAirportSpotInTheTown(AIAirport.AT_LARGE, route.end, route.cargo);
route.station_size = AIAirport.AT_LARGE;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_COMMUTER, route.start);
route.second_station.location = FindSuitableAirportSpotInTheTown(AIAirport.AT_COMMUTER, route.end, route.cargo);
route.station_size = AIAirport.AT_COMMUTER;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_SMALL, route.start);
route.second_station.location = FindSuitableAirportSpotInTheTown(AIAirport.AT_SMALL, route.end, route.cargo);
route.station_size = AIAirport.AT_SMALL;
return route;
}

function AirBuilder::FindPairDualIndustryAllocator(route)
{
route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_METROPOLITAN, route.start);
route.second_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeConsumer(AIAirport.AT_METROPOLITAN, route.end, route.cargo);
route.station_size = AIAirport.AT_METROPOLITAN;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_LARGE, route.start);
route.second_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeConsumer(AIAirport.AT_LARGE, route.end, route.cargo);
route.station_size = AIAirport.AT_LARGE;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_COMMUTER, route.start);
route.second_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeConsumer(AIAirport.AT_COMMUTER, route.end, route.cargo);
route.station_size = AIAirport.AT_COMMUTER;
if(route.first_station.location != null && route.second_station.location != null ) return route;

route.first_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(AIAirport.AT_SMALL, route.start);
route.second_station.location = FindSuitableAirportSpotNearIndustryWithAirportTypeConsumer(AIAirport.AT_SMALL, route.end, route.cargo);
route.station_size = AIAirport.AT_SMALL;
return route;
}

function AirBuilder::FindSuitableAirportSpotNearIndustryWithAirportTypeProducer(airport_type, industry_id)
{
local airport_x, airport_y, airport_rad;
local good_tile = 0;
airport_x = AIAirport.GetAirportWidth(airport_type);
airport_y = AIAirport.GetAirportHeight(airport_type);
airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);

local tile_list=AITileList_IndustryProducing (industry_id, airport_rad)

tile_list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
tile_list.KeepValue(1);
return FindSuitableAirportSpotNearIndustryWithAirportType(tile_list, airport_type);
}

function AirBuilder::FindSuitableAirportSpotNearIndustryWithAirportTypeConsumer(airport_type, consumer, cargo)
{
local airport_x, airport_y, airport_rad;
local good_tile = 0;
airport_x = AIAirport.GetAirportWidth(airport_type);
airport_y = AIAirport.GetAirportHeight(airport_type);
airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);

local list=AITileList_IndustryAccepting(consumer, 3);

list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
list.KeepValue(1);

list.Valuate(AITile.GetCargoAcceptance, cargo, 1, 1, 3);
list.RemoveValue(0);
return FindSuitableAirportSpotNearIndustryWithAirportType(list, airport_type);
}

function AirBuilder::FindSuitableAirportSpotNearIndustryWithAirportType(tile_list, airport_type)
{
	local test = AITestMode();
    for (local tile = tile_list.Begin(); tile_list.HasNext(); tile = tile_list.Next()) 
		{
		if (AIAirport.BuildAirport(tile, airport_type, AIStation.STATION_NEW)) return tile;
		}
/* Did we found a place to build the airport on? */
return null;
}

function AirBuilder::FindSuitableAirportSpotInTown(airport_type, center_tile)
	{
	local airport_x, airport_y, airport_rad;

	airport_x = AIAirport.GetAirportWidth(airport_type);
	airport_y = AIAirport.GetAirportHeight(airport_type);
	airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);
	local town_list = AITownList();

	//Info(town_list.Count());
	
	//town_list.Valuate(AITown.GetLocation);
	
	town_list.Valuate(this.PopulationWithRandValuator);
	town_list.KeepAboveValue(500-desperation);

	if (center_tile != 0) {
    town_list.Valuate(AITown.GetDistanceManhattanToTile, center_tile);
	town_list.KeepAboveValue(this.GetMinDistance());    
	town_list.KeepBelowValue(this.GetMaxDistance());    
	}
	
	town_list.Valuate(this.DistanceWithRandValuator, center_tile);
	//TODO - wed�ug dystansu optimum to 500
	   
	town_list.KeepBottom(50);

	//Info(town_list.Count());
	
	for (local town = town_list.Begin(); town_list.HasNext(); town = town_list.Next()) {

    	local tile = AITown.GetLocation(town);

		local list = AITileList();
		local range = Sqrt(AITown.GetPopulation(town)/100) + 15;
		SafeAddRectangle(list, tile, range);

		//Info("tiles " + list.Count());
	
		list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
		list.KeepValue(1);

		//Info(list.Count());
	
		list.Valuate(rodzic.IsConnectedDistrict);
		list.KeepValue(0);

		//Info(list.Count());
	
		/* Sort on acceptance, remove places that don't have acceptance */
		list.Valuate(AITile.GetCargoAcceptance, rodzic.GetPassengerCargoId(), airport_x, airport_y, airport_rad);
		list.RemoveBelowValue(50);

		//Info(list.Count());
	
		list.Valuate(AITile.GetCargoAcceptance, rodzic.GetMailCargoId(), airport_x, airport_y, airport_rad);
		list.RemoveBelowValue(10);

		//Info(list.Count());
	
		/* Couldn't find a suitable place for this town, skip to the next */
		if (list.Count() == 0) continue;
		/* Walk all the tiles and see if we can build the airport at all */
		{
			local good_tile = 0;
			for (tile = list.Begin(); list.HasNext(); tile = list.Next()) {
				if(!IsItPossibleToHaveAirport(tile, airport_type, AIStation.STATION_NEW))
				   {
				   //Error("BAD " + tile);
				   //AISign.BuildSign(tile, "X");
				   continue;
				   }
				good_tile = tile;
				break;
			}

			/* Did we found a place to build the airport on? */
			if (good_tile == 0) continue;
		}

		Info("Found a good spot for an airport in town " + town + " at tile " + tile);
		return tile;
	}

	Info("Couldn't find a suitable town to build an airport in");
	return -1;
}

function AirBuilder::FindSuitableAirportSpotInTheTown(town, cargo)
{
 	local tile = AITown.GetLocation(town);
	local list = AITileList();
	local range = Sqrt(AITown.GetPopulation(town)/100) + 15;
	SafeAddRectangle(list, tile, range);

	list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
	list.KeepValue(1);

	/* Sort on acceptance, remove places that don't have acceptance */
	list.Valuate(AITile.GetCargoAcceptance, rodzic.GetPassengerCargoId(), airport_x, airport_y, airport_rad);
	list.RemoveBelowValue(50);

	//Info(list.Count());

	list.Valuate(AITile.GetCargoAcceptance, rodzic.GetMailCargoId(), airport_x, airport_y, airport_rad);
	list.RemoveBelowValue(10);

	//Info(list.Count());
	
	/* Couldn't find a suitable place for this town, skip to the next */
	if (list.Count() == 0) return null;
	/* Walk all the tiles and see if we can build the airport at all */
		local good_tile = 0;
		for (tile = list.Begin(); list.HasNext(); tile = list.Next()) {
			if(!IsItPossibleToHaveAirport(tile, airport_type, AIStation.STATION_NEW))continue;
		    else
			  {
			  return tile;
			  }
		}

return null;
}

function AirBuilder::GetMaxDistance()
{
return 750+desperation*50;
}

function AirBuilder::GetMinDistance()
{
return maxi(200-this.desperation*10, 70);
}

function AirBuilder::GetOptimalDistance()
{
return 400;
}

function AirBuilder::ValuatorDlaCzyJuzZlinkowane(station_id, i)
{
return AITile.GetDistanceManhattanToTile( AIStation.GetLocation(station_id), AIIndustry.GetLocation(i) );
}

function AirBuilder::IsConnectedIndustry(industry, cargo)
{
if(CheckerIsReallyConnectedIndustry(industry, cargo, AIAirport.AT_LARGE))return true;
else if(CheckerIsReallyConnectedIndustry(industry, cargo, AIAirport.AT_METROPOLITAN))return true;
else if(CheckerIsReallyConnectedIndustry(industry, cargo, AIAirport.AT_COMMUTER))return true;
else return CheckerIsReallyConnectedIndustry(industry, cargo, AIAirport.AT_SMALL);
}

function AirBuilder::CheckerIsReallyConnectedIndustry(industry, cargo, airport_type)
{
local radius = AIAirport.GetAirportCoverageRadius(airport_type);

local tile_list=AITileList_IndustryProducing(industry, radius);
for (local q = tile_list.Begin(); tile_list.HasNext(); q = tile_list.Next()) //from Chopper 
   {
   local station_id = AIStation.GetStationID(q);
   if(AIAirport.IsAirportTile(q))
   if(AIAirport.GetAirportType(q)==airport_type)
      {
	  local vehicle_list=AIVehicleList_Station(station_id);
	  if(vehicle_list.Count()!=0)
	  if(AIStation.GetStationID(GetLoadStationLocation(vehicle_list.Begin()))==station_id) //czy load jest na wykrytej stacji
	  {
	  if(AIVehicle.GetCapacity(vehicle_list.Begin(), cargo)!=0)//i laduje z tej stacji
	     {
		 return true;
		 }
	  }
	  }
   }
return false;
}

function AirBuilder::CostEstimation()
{
	for(local i=1; i<400; i++)
	   {
	   local enginiatko = AirBuilder.FindAircraft(AIAirport.AT_LARGE, AIAI.GetPassengerCargoId(), 3, 30000*i);
	   if(enginiatko!=null)
	   if(AIEngine.IsBuildable(enginiatko))
	       {
		   return i*30000;
		   }
	   }
}

function AirBuilder::FindEngine(route)
{
route.engine_count = 3;
route.engine = AirBuilder.FindAircraft(route.station_size, route.cargo, route.engine_count = 3, route.budget);
route.demand = AirBuilder.CostEstimation();
return route;
}

function FindAircraftValuatorRunningOnVehicleIDs(vehicle_id)
{
return FindAircraftValuator(AIVehicle.GetEngineType(vehicle_id));
}
function FindAircraftValuator(engine_id)
{
return AIEngine.GetCapacity(engine_id) * AIEngine.GetMaxSpeed(engine_id);
}

function AirBuilder::FindAircraft(airport_type, cargo, ile, balance)
{
local typical_minimal_capacity = 40
local engine_list = AIEngineList(AIVehicle.VT_AIR);

if(airport_type==AIAirport.AT_SMALL || airport_type==AIAirport.AT_COMMUTER )
	{
	engine_list.Valuate(AIEngine.GetPlaneType);
	engine_list.RemoveValue(AIAirport.PT_BIG_PLANE);
	}

if(ile!=0)balance-=2*AIAirport.GetPrice(airport_type);
if(balance<0)return null;
engine_list.Valuate(AIEngine.GetPrice);

if(ile==0) engine_list.KeepBelowValue(balance);
else engine_list.KeepBelowValue(balance/ile);

engine_list.Valuate(AIEngine.CanRefitCargo, cargo);
engine_list.KeepValue(1);

engine_list.Valuate(FindAircraftValuator);
engine_list.KeepTop(1);
if(engine_list.Count()==0)return null;
return engine_list.Begin();
}

function AirBuilder::BuildPassengerAircraftWithRand(tile_1, tile_2, engine, cargo)
{
if(AIBase.RandRange(2)==1)
   {
   local swap=tile_2;
   tile_2=tile_1;
   tile_1=swap;
   }
return this.BuildPassengerAircraft(tile_1, tile_2, engine, cargo);
}

function AirBuilder::BuildExpressAircraft(tile_1, tile_2, engine, cargo)
{
local vehicle = this.BuildAircraft(tile_1, tile_2, engine, cargo);

if(vehicle==-1)return false;

AIOrder.AppendOrder(vehicle, tile_1, 0);
AIOrder.AppendOrder(vehicle, tile_2, 0);
AIVehicle.StartStopVehicle(vehicle);
	
return true;
}

function AirBuilder::BuildPassengerAircraft(tile_1, tile_2, engine, cargo)
{
local vehicle = this.BuildAircraft(tile_1, tile_2, engine, cargo);
if(vehicle==-1)return false;
if(!AIOrder.AppendOrder(vehicle, tile_1, AIOrder.AIOF_FULL_LOAD_ANY))abort(AIVehicle.GetName(vehicle) + " - order fail")
if(!AIOrder.AppendOrder(vehicle, tile_2, AIOrder.AIOF_FULL_LOAD_ANY))abort(AIVehicle.GetName(vehicle) + " - order fail")
if(!AIVehicle.StartStopVehicle(vehicle)) abort(AIVehicle.GetName(vehicle) + " - startstop fail")
return true;
}

function AirBuilder::BuildAircraft(tile_1, tile_2, engine, cargo)
{
	/* Build an aircraft */
	local hangar = AIAirport.GetHangarOfAirport(tile_1);

	local vehicle = AIAI.BuildVehicle(hangar, engine);

	if (!AIVehicle.IsValidVehicle(vehicle)) {
		return -1;
		}

if(!AIVehicle.RefitVehicle(vehicle, cargo)) 
   {
   Error("Couldn't refit the aircraft " + AIError.GetLastErrorString());
   AIVehicle.SellVehicle(vehicle);
   return -1;
   }
return vehicle;
}

function AirBuilder::HowManyAirplanes(distance, speed, production, engine)
{
local ile = (3*distance)/(2*speed);
Info(ile + "aircrafts needed; based on distance");

ile *= 10 * production;
//Info(ile + "&^%***********");

ile /= AIEngine.GetCapacity(engine);
Info(ile + "aircrafts needed after production (" + production + ") and capacity (" +  AIEngine.GetCapacity(engine) +") adjustment");
ile = max(ile, 3);
return ile;
}

function AirBuilder::ValuateProducer(ID, cargo)
	{
	if(AIIndustry.GetLastMonthProduction(ID, cargo)<50-4*desperation)return 0; //protection from tiny industries servised by giant trains
	local base = AIIndustry.GetLastMonthProduction(ID, cargo);
	base*=(100-AIIndustry.GetLastMonthTransportedPercentage (ID, cargo));
	if(AIIndustry.GetLastMonthTransportedPercentage (ID, cargo)==0)base*=3;
	base*=AICargo.GetCargoIncome(cargo, 10, 50);
	if(base!=0){
		if(AIIndustryType.IsRawIndustry(AIIndustry.GetIndustryType(ID))){
			//base*=3;
			//base/=2;
			base+=10000;
			base*=100;
			}
		else{
			base*=min(99, deinflate(TotalLastYearProfit()/1000))+1;
			}
		}
	//Info(AIIndustry.GetName(ID) + " is " + base + " point producer of " + AICargo.GetCargoLabel(cargo));
	return base;
	}

function AirBuilder::ValuateConsumer(ID, cargo, score)
{
if(AIIndustry.GetStockpiledCargo(ID, cargo)==0) score*=2;
return score;
}

function AirBuilder::distanceBetweenIndustriesValuator(distance)
{
if(distance>GetMaxDistance())return 0;
if(distance<GetMinDistance()) return 0;
return max(1, abs(400-distance)/20);
}

function AirBuilder::BuildCargoAircraft(tile_1, tile_2, engine, cargo, nazwa)
{
local vehicle = this.BuildAircraft(tile_1, tile_2, engine, cargo);
if(vehicle==-1)return false;

AIOrder.AppendOrder(vehicle, tile_1, AIOrder.AIOF_FULL_LOAD_ANY);
AIOrder.AppendOrder(vehicle, tile_2, AIOrder.AIOF_NO_LOAD);
AIVehicle.StartStopVehicle(vehicle);
SetNameOfVehicle(vehicle, nazwa);
return true;
}

function AirBuilder::GetNiceRandomTown(location)
{
local town_list = AITownList();
town_list.Valuate(AITown.GetDistanceManhattanToTile, location);
town_list.KeepBelowValue(GetMaxDistance());
town_list.KeepAboveValue(GetMinDistance());
town_list.Valuate(AIBase.RandItem);
town_list.KeepTop(1);
if(town_list.Count()==0)return null;
return town_list.Begin();
}

function AirBuilder::Maintenance()
{
this.Skipper();

if(AIGameSettings.IsDisabledVehicleType(AIVehicle.VT_AIR))return;
local ile;
local veh_list = AIVehicleList();
veh_list.Valuate(GetVehicleType);
veh_list.KeepValue(AIVehicle.VT_AIR);
ile = veh_list.Count();
local allowed = AIGameSettings.GetValue("vehicle.max_aircraft");
if(allowed==ile)return;

this.Uzupelnij();
this.UzupelnijCargo();
}

function AirBuilder::GetEffectiveDistanceBetweenAirports(tile_1, tile_2)
{
local x1 = AIMap.GetTileX(tile_1);
local y1 = AIMap.GetTileY(tile_1);

local x2 = AIMap.GetTileX(tile_2);
local y2 = AIMap.GetTileY(tile_2);

local x_delta = abs(x1 - x2);
local y_delta = abs(y1 - y2);

local longer = max(x_delta, y_delta);
local shorter = min(x_delta, y_delta);

return shorter*99/70 + longer - shorter;
}

function AirBuilder::Burden(tile_1, tile_2, engine)
{
return AIEngine.GetMaxSpeed(engine)*200/(this.GetEffectiveDistanceBetweenAirports(tile_1, tile_2)+50);
}

function AirBuilder::GetBurden(airport)
{
local total;
local total = 0;
local airlist=AIVehicleList_Station(airport);
for (local plane = airlist.Begin(); airlist.HasNext(); plane = airlist.Next())
   {
   total += this.Burden(AIOrder.GetOrderDestination (plane, 0), AIOrder.GetOrderDestination (plane, 1), AIVehicle.GetEngineType(plane));
   }
return total;
}

function AirBuilder::IsItPossibleToAddBurden(airport_id, tile=null, engine=null, ile=1)
{
local maksimum;
local total = this.GetBurden(airport_id);
local airport_type = AIAirport.GetAirportType(AIStation.GetLocation(airport_id));
if(airport_type==AIAirport.AT_LARGE) maksimum = 1500; //1 l�dowanie miesi�cznie - 250 //6 na du�ym
if(airport_type==AIAirport.AT_METROPOLITAN ) maksimum = 2000; //1 l�dowaie miesi�cznie - 250 //6 na du�ym
if(airport_type==AIAirport.AT_COMMUTER) maksimum = 500; //1 l�dowanie miesi�cznie - 250 //4 na ma�ym
if(airport_type==AIAirport.AT_SMALL) maksimum = 750; //1 l�dowanie miesi�cznie - 250 //4 na ma�ym
 
if(AIAI.GetSetting("debug_signs_for_airports_load")) AISign.BuildSign(AIStation.GetLocation(airport_id), total + " (" + maksimum + ")");

if(tile != null && engine != null) total+=ile*this.Burden(AIStation.GetLocation(airport_id), tile, engine);

return total <= maksimum;
}

function AirBuilder::Uzupelnij()
{
local airport_type;
local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;

for (local airport = list.Begin(); list.HasNext(); airport = list.Next())
	{
	local cargo_list = AICargoList();
	for (local cargo = cargo_list.Begin(); cargo_list.HasNext(); cargo = cargo_list.Next())
		{
		if(AIStation.GetCargoWaiting(airport, cargo)>100)
			{																						//protection from flood of mail planes
			if((GetAverageCapacity(airport, cargo)*3 < AIStation.GetCargoWaiting(airport, cargo) &&  AIStation.GetCargoWaiting(airport, cargo)>200) 
			|| AIStation.GetCargoRating(airport, cargo)<30 ) //HARDCODED OPTION
				{
				//teraz trzeba znale�� lotnisko docelowe
				local odbiorca = AIStationList(AIStation.STATION_AIRPORT);
				for (local goal_airport = odbiorca.Begin(); odbiorca.HasNext(); goal_airport = odbiorca.Next())
					{
					local tile_1 = AIStation.GetLocation(airport);
					local tile_2 = AIStation.GetLocation(goal_airport);
					local airport_type_1 = AIAirport.GetAirportType(tile_1);
					local airport_type_2 = AIAirport.GetAirportType(tile_2);
					if((airport_type_1==AIAirport.AT_SMALL || airport_type_2==AIAirport.AT_SMALL)||
					   (airport_type_1==AIAirport.AT_COMMUTER  || airport_type_2==AIAirport.AT_COMMUTER)) 
						airport_type=AIAirport.AT_SMALL;
					else
						airport_type=AIAirport.AT_LARGE;

					local engine=this.FindAircraft(airport_type, cargo, 1, GetAvailableMoney());
					if(engine==null) continue;
					local vehicle_list=AIVehicleList_Station(airport);
					vehicle_list.Valuate(FindAircraftValuatorRunningOnVehicleIDs);
					vehicle_list.RemoveAboveValue(FindAircraftValuator(engine))
					if(vehicle_list.Count()==0) continue;
					ProvideMoney();
					if(AITile.GetDistanceManhattanToTile(tile_1, tile_2)>100
					&& AgeOfTheYoungestVehicle(goal_airport)>40)
						{
						if(this.IsItPossibleToAddBurden(airport, tile_2, engine, 1)
						&& this.IsItPossibleToAddBurden(goal_airport, tile_1, engine, 1))
							{
							if( rodzic.GetPassengerCargoId()==cargo )
								this.BuildPassengerAircraft(tile_1, tile_2, engine, cargo);
							else if(rodzic.GetMailCargoId()==cargo)
								this.BuildExpressAircraft(tile_1, tile_2, engine, cargo);
							break;
							}
						}
					}
				}
			}   
		}
	}
}

function AirBuilder::UzupelnijCargo()
{
local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;

for (local airport = list.Begin(); list.HasNext(); airport = list.Next()){
	local cargo_list = AICargoList();
	for (local cargo = cargo_list.Begin(); cargo_list.HasNext(); cargo = cargo_list.Next())
		if(AIStation.GetCargoWaiting(airport, cargo)>1){
		if(cargo != AIAI.GetPassengerCargoId())
			if(cargo != AIAI.GetMailCargoId())
				if(IsItNeededToImproveThatStation(airport, cargo))
				{
				local airport_type = AIAirport.GetAirportType(AIStation.GetLocation(airport));
				if(airport_type==AIAirport.AT_SMALL || airport_type==AIAirport.AT_COMMUTER){
					airport_type=AIAirport.AT_SMALL;
					}
				local vehicle = AIVehicleList_Station(airport).Begin();
				local another_station = AIOrder.GetOrderDestination(vehicle, 0);
				if(AIStation.GetLocation(airport) == another_station) another_station = AIOrder.GetOrderDestination(vehicle, 1);
				local engine=this.FindAircraft(airport_type, cargo, 1, GetAvailableMoney());
				if(engine != null){
					ProvideMoney();
					if(IsItPossibleToAddBurden(airport, another_station, engine)) {
						this.BuildCargoAircraft(AIStation.GetLocation(airport), another_station, engine, cargo, "uzupelniacz");
						}
					}
				else {
					Error("Plane not found for " + AICargo.GetCargoLabel(cargo) + " cargo.");
					}
		  }
	   }   
   }
}

function CzyToPassengerCargoValuator(veh)
{
   if(AIVehicle.GetCapacity(veh, AIAI.GetPassengerCargoId())>0)return 1;
   return 0;
   }

function AirBuilder::Skipper()
{
local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;

local list = AIList();

for (local airport = list.Begin(); list.HasNext(); airport = list.Next())
   {
   local pozycja=AIStation.GetLocation(airport)
   local airlist=AIVehicleList_Station(airport);
   if(airlist.Count()==0)continue;

   local counter=0;
   local minimum = 101;
   local plane_left_on_airport = null;
   for (local plane = airlist.Begin(); airlist.HasNext(); plane = airlist.Next()){
	  if(AIVehicle.GetState(plane)==AIVehicle.VS_AT_STATION)
	     if(AITile.GetDistanceManhattanToTile(AIVehicle.GetLocation(plane), pozycja)<30)
		    if(AIVehicle.GetCapacity(plane, rodzic.GetPassengerCargoId())>0){
			local percent = ( 100 * AIVehicle.GetCargoLoad(plane, rodzic.GetPassengerCargoId()))/(AIVehicle.GetCapacity(plane, rodzic.GetPassengerCargoId()));
		    //Info(percent + " %");
			if(percent < minimum)
			   {
			   //Info(percent + " %%%")
			   minimum=percent;
			   plane_left_on_airport=plane;
			   }
  		    list.AddItem(plane, airport);
			counter++;
			}
	  }
   if(plane_left_on_airport!=null)list.RemoveItem(plane_left_on_airport); 
   }
local count=0;
for (local plane = list.Begin(); list.HasNext(); plane = list.Next())
   {
   if(AIOrder.SkipToOrder(plane, (AIOrder.ORDER_CURRENT+1)%AIOrder.GetOrderCount(plane)))count++;
   }
Info(count+" planes skipped to next destination!");
}

function AirBuilder::PopulationWithRandValuator(town_id)
{
return AITown.GetPopulation(town_id)-AIBase.RandRange(500);
}
	
function AirBuilder::DistanceWithRandValuator(town_id, center_tile)
{
local rand = AIBase.RandRange(150);
local distance = AITown.GetDistanceManhattanToTile(town_id, center_tile)-AirBuilder.GetOptimalDistance();
if(distance<0)distance*=-1;
return distance + rand;
}

function AirBuilder::IsItPossibleToHaveAirport(a, b, c)
{
local test = AITestMode();
if(AIAirport.BuildAirport(a, b, c)) return true;
return (AIError.GetLastError() == AIError.ERR_NOT_ENOUGH_CASH);
}
