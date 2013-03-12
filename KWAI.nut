//this.anie nowych po��cze�
//lepsze wybieranie przy a8
//industry - valuate before building
//nie pierwsze lepsze tylko najlepsze, nie masowac budowy (wiek reszty)
//kasowanie nadmiaru
//sprzedawa� samoloty z minusem w obu latach (je�li starsze ni� 2 lata)

class KWAI
{
desperacja=0;
rodzic=null;
_koszt=0;
}

function KWAI::GetMinimalDistance()
{
if(200-this.desperacja*10<70)return 70;
return 200-this.desperacja*10;
}

function KWAI::ValuatorDlaCzyJuzZlinkowane(station_id, i)
{
return AITile.GetDistanceManhattanToTile( AIStation.GetLocation(station_id), AIIndustry.GetLocation(i) );
}

function KWAI::CzyJuzZlinkowane(i, cargo) //DUPNA HEUREZA TODO - replace it by feeder system
{
local list = AIStationList(AIStation.STATION_AIRPORT);
//dystans od i wi�kszy od 20
list.Valuate(this.ValuatorDlaCzyJuzZlinkowane, i);
list.KeepBelowValue(20);

for (local stacja = list.Begin(); list.HasNext(); cargo = list.Next())
    {
    local pojazdy = AIVehicleList_Station(stacja);
	for (local plane = pojazdy.Begin(); pojazdy.HasNext(); plane = pojazdy.Next())
	  {
	  if(AIVehicle.GetCapacity(plane, cargo)!=0)return true;
	  }
	}
return false;
}

function KWAI::BuildAirportRouteBetweenCities()
{
	AILog.Info("Trying to build an airport route (city version)");

	local airport_type = (AIAirport.IsValidAirportType(AIAirport.AT_LARGE) ? AIAirport.AT_LARGE : AIAirport.AT_SMALL);
	local engine=this.FindAircraft(airport_type, this.GetPassengerCargoId(), 3, AICompany.GetBankBalance(AICompany.COMPANY_SELF));
	
	if(AIEngine.IsValidEngine(engine) == false) 
	    {
		AILog.Info("Unfortunatelly no suitable aircraft found");
		for(local i=1; i<400; i++)
		   {
		   if(AIEngine.IsValidEngine(this.FindAircraft(airport_type, this.GetPassengerCargoId(), 3, 30000*i)))
		       {
			   _koszt=i*30000;
			   return false;
			   }
		   }
		return false;
		}
	
	AILog.Info("Engine found");

	local tile_1 = this.FindSuitableAirportSpotInTown(airport_type, 0);
	if (tile_1 < 0) 
	   {
	   _koszt=0;
	   return false;
	   }
	local tile_2 = this.FindSuitableAirportSpotInTown(airport_type, tile_1);
	if (tile_2 < 0) {
	   {
	   _koszt=0;
	   return false;
	   }
	}
	
	/* Build the airports for real */
	if (!AIAirport.BuildAirport(tile_1, airport_type, AIStation.STATION_NEW)) {
		AILog.Error("Although the testing told us we could build 2 airports, it still failed on the first airport at tile " + tile_1 + ".");
	   _koszt=0;
	   return false;
	}
	if (!AIAirport.BuildAirport(tile_2, airport_type, AIStation.STATION_NEW)) {
		AILog.Error("Although the testing told us we could build 2 airports, it still failed on the second airport at tile " + tile_2 + ".");
		if(AIAI.GetSetting("other_debug_signs"))AISign.BuildSign(tile_2, "HERE"+AIError.GetLastErrorString());
		AIAirport.RemoveAirport(tile_1);
	   _koszt=0;
		return false;
	}
	
	local dystans = AITile.GetDistanceManhattanToTile(tile_1, tile_2);
	local speed = AIEngine.GetMaxSpeed(engine);
	local licznik = this.IleSamolotow(dystans, speed);
	for(local i=0; i<licznik; i++) 
	   {
	   for(local i=0; !this.BuildPassengerAircraftWithRand(tile_1, tile_2, engine, this.GetPassengerCargoId()); i++)
          {
		  rodzic.Konserwuj();
		  AIController.Sleep(100);
		  if(AIEngine.IsBuildable(engine)==false) return true;
		  }
  	   }

	AILog.Info("Done building a route");
	return true;
}

function KWAI::FindAircraft(airport_type, cargo, ile, balance)
{
//AILog.Error(balance+"");
local engine_list = AIEngineList(AIVehicle.VT_AIR);

//AILog.Error("engine_list.Count() I " + engine_list.Count());

if(airport_type==AIAirport.AT_SMALL)
	{
	engine_list.Valuate(AIEngine.GetPlaneType);
	engine_list.RemoveValue(AIAirport.PT_BIG_PLANE);
	}

//AILog.Error("engine_list.Count() II " + engine_list.Count());
	
balance-=2000;
if(ile!=0)balance-=2*AIAirport.GetPrice(airport_type);
if(balance<0)return -1;
engine_list.Valuate(AIEngine.GetPrice);

if(ile==0) engine_list.KeepBelowValue(balance);
else engine_list.KeepBelowValue(balance/ile);

//AILog.Error("engine_list.Count() III " + engine_list.Count());

engine_list.Valuate(AIEngine.CanRefitCargo, cargo);
engine_list.KeepValue(1);

//AILog.Error("engine_list.Count() IV " + engine_list.Count());

engine_list.Valuate(AIEngine.GetMaxSpeed);
engine_list.KeepAboveValue(100);

//AILog.Error("engine_list.Count() V " + engine_list.Count());

engine_list.Valuate(AIEngine.GetCapacity);
engine_list.KeepAboveValue(40); //HARDCODED OPTION
engine_list.KeepTop(1);

//AILog.Error("engine_list.Count() VI " + engine_list.Count());

if(engine_list.Count()==0)return -1;
return engine_list.Begin();
}

function KWAI::BuildCargoAircraft(tile_1, tile_2, engine, cargo, nazwa)
{
local vehicle = this.BuildAircraft(tile_1, tile_2, engine, cargo);
if(vehicle==-1)return false;

AIOrder.AppendOrder(vehicle, tile_1, AIOrder.AIOF_FULL_LOAD_ANY);
AIOrder.AppendOrder(vehicle, tile_2, 0);
AIVehicle.StartStopVehicle(vehicle);
/*
for(local i=1; AIVehicle.SetName(vehicle, nazwa)==false; i++)
   {
   //maksimum 30 znak�w
   //potrzeba obcinacza stringa
   AIVehicle.SetName(vehicle, nazwa+" # "+i);
   }
*/	
return true;
}

function KWAI::BuildPassengerAircraftWithRand(tile_1, tile_2, engine, cargo)
{
if(AIBase.RandRange(2)==1)
   {
   local swap=tile_2;
   tile_2=tile_1;
   tile_1=swap;
   }
return this.BuildPassengerAircraft(tile_1, tile_2, engine, cargo);
}

function KWAI::BuildPassengerAircraft(tile_1, tile_2, engine, cargo)
{
local vehicle = this.BuildAircraft(tile_1, tile_2, engine, cargo);

if(vehicle==-1)return false;

AIOrder.AppendOrder(vehicle, tile_1, AIOrder.AIOF_FULL_LOAD_ANY);
AIOrder.AppendOrder(vehicle, tile_2, AIOrder.AIOF_FULL_LOAD_ANY);
AIVehicle.StartStopVehicle(vehicle);
	
return true;
}

function KWAI::BuildAircraft(tile_1, tile_2, engine, cargo)
{
	/* Build an aircraft */
	local hangar = AIAirport.GetHangarOfAirport(tile_1);

	if (!AIEngine.IsValidEngine(engine)) {
		return -1;
	}
	
local vehicle = AIVehicle.BuildVehicle(hangar, engine);

	if (!AIVehicle.IsValidVehicle(vehicle)) {
		AILog.Error("Couldn't build the aircraft " + AIError.GetLastErrorString());
		return -1;
	}

if(!AIVehicle.RefitVehicle(vehicle, cargo)) 
   {
   AILog.Error("Couldn't refit the aircraft " + AIError.GetLastErrorString());
   AIVehicle.SellVehicle(vehicle);
   return -1;
   }
return vehicle;
}

class AirCargoRoute
{
id_lotniska_startowego = null;
typ_nowego_lotniska = null;
tile_nowego_lotniska = null;
engine = null;
cargo = null;
nazwa=null;
}

function KWAI::FindRouteBetweenCityAndIndustry()
{
local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;
for (local aktualna = list.Begin(); list.HasNext(); aktualna = list.Next())
   {
   local pozycja=AIStation.GetLocation(aktualna);
   local airport_type = AIAirport.GetAirportType(pozycja);

   local airport_x, airport_y, airport_rad;
   airport_x = AIAirport.GetAirportWidth(airport_type);
   airport_y = AIAirport.GetAirportHeight(airport_type);
   airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);

   local cargo_list = AICargoList();
   for (local cargo = cargo_list.Begin(); cargo_list.HasNext(); cargo = cargo_list.Next())
      {
	  //AILog.Info(AICargo.GetCargoLabel(cargo) +" "+AITile.GetCargoAcceptance(pozycja, cargo, airport_x, airport_y, airport_rad));
	  if(AITile.GetCargoAcceptance(pozycja, cargo, airport_x, airport_y, airport_rad)>10)
	     {

		 //to szukamy czegos to transportu tego
		 local engine = this.FindAircraft(airport_type, cargo, 3, AICompany.GetBankBalance(AICompany.COMPANY_SELF));
		 if(engine==-1) continue;
		 
		 //to szukamy producenta tego syfu
		 local industry_list = AIIndustryList_CargoProducing(cargo);
		 if(industry_list.Count()==0) continue;

		 //dobrych producent�w
		 industry_list.Valuate(AIIndustry.GetLastMonthProduction, cargo);
		 industry_list.KeepAboveValue(100); //HARDCODED OPTION
		 if(industry_list.Count()==0) continue;

		 //dalekich producent�w
		 industry_list.Valuate(AIIndustry.GetDistanceManhattanToTile, pozycja);
		 industry_list.KeepAboveValue(this.GetMinimalDistance());
		 if(industry_list.Count()==0) continue;
		 
		 //szukamy miejsca na lotnisko
		 for (local producent = industry_list.Begin(); industry_list.HasNext(); producent = industry_list.Next())
		     {
			local dystans = AIIndustry.GetDistanceManhattanToTile(producent, pozycja);
			local speed = AIEngine.GetMaxSpeed(engine);
			local ile = this.IleSamolotow(dystans, speed);
			if(this.IsItPossibleToAddBurden(aktualna, AIIndustry.GetLocation(producent), engine, ile)==false)continue;
			
			 if(this.CzyJuzZlinkowane(producent, cargo))continue;
			 local zwrot = FindSuitableAirportSpotNearIndustry(airport_type, producent);
			//AILog.Info(AICargo.GetCargoLabel(cargo) + zwrot);
			if(zwrot!=null)
			    {
 				zwrot.id_lotniska_startowego = aktualna;
 				zwrot.typ_nowego_lotniska = airport_type;
 				zwrot.engine = engine;
 				zwrot.cargo = cargo;
 				zwrot.nazwa = AIIndustry.GetName(producent)+" to "+AIStation.GetName(aktualna);
				return zwrot;
				}
			 }
		 }
	  }   
   }
return null;
}

function KWAI::IleSamolotow(dystans, speed)
{
if(((3*dystans)/(2*speed))<3)return 3;
return (3*dystans)/(2*speed);
}

function KWAI::FindSuitableAirportSpotNearIndustry(airport_type, industry_id)
{
local airport_x, airport_y, airport_rad;
local good_tile = 0;
airport_x = AIAirport.GetAirportWidth(airport_type);
airport_y = AIAirport.GetAirportHeight(airport_type);
airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);

local tile_list=AITileList_IndustryProducing (industry_id, airport_rad)
tile_list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
tile_list.KeepValue(1);
/* Walk all the tiles and see if we can build the airport at all */
	{
	local test = AITestMode();
    for (local tile = tile_list.Begin(); tile_list.HasNext(); tile = tile_list.Next()) 
		{
		if (!AIAirport.BuildAirport(tile, airport_type, AIStation.STATION_NEW)) continue;
		good_tile = tile;
		break;
		}
	}

/* Did we found a place to build the airport on? */
if (good_tile != 0) 
   {
   local zwrot = AirCargoRoute();
   zwrot.tile_nowego_lotniska = good_tile;
   return zwrot;
   }
else 
   {
   return null;
   }
}

function KWAI::CargoConnectionBuilder()
{
AIAI.Info("Trying to build an airport route from industry");

local propozycja = this.FindRouteBetweenCityAndIndustry();

AIAI.Info("Trying to build an airport route from industry - scanning completed");

if(propozycja == null) 
   {
   AIAI.Info("Airport cargo route failed");
   return false;
   }
else
   {
   AIAI.Info("Airport cargo route found");
   }

if (!AIAirport.BuildAirport(propozycja.tile_nowego_lotniska, propozycja.typ_nowego_lotniska, AIStation.STATION_NEW)) 
	{
	AILog.Error("Although the testing told us we could build airport we failed at tile " + propozycja.tile_nowego_lotniska + ".");
	return false;
	}
else
   {
   AIAI.Info("Airport constructed");
   }
	
	local tile_2=AIStation.GetLocation(propozycja.id_lotniska_startowego);
	local dystans = AITile.GetDistanceManhattanToTile(propozycja.tile_nowego_lotniska, tile_2);
	local speed = AIEngine.GetMaxSpeed(propozycja.engine);
	local licznik = this.IleSamolotow(dystans, speed);

   AIAI.Info("We want " + licznik + " aircrafts.");

	for(local i=0; i<licznik; i++) 
	   {
       AIAI.Info("We have " + i + " from " + licznik + " aircrafts.");
	   while(!this.BuildCargoAircraft(propozycja.tile_nowego_lotniska, tile_2, propozycja.engine, propozycja.cargo, propozycja.nazwa))
          {
		  AIAI.Info("Next try");
 		  rodzic.Konserwuj();
		  if(AIEngine.IsBuildable(propozycja.engine)==false) 
		     {
			 AILog.Error("WTF - engine expired");
			 return true;
			 }
		  AIController.Sleep(100);
		  }
  	   }

	return true;
}

function KWAI::Skip(plane, stacja)
{
for(local i=0; i<AIOrder.GetOrderCount(plane); i++)
   {
   if(AIOrder.GetOrderFlags(plane, i)==AIOrder.AIOF_FULL_LOAD_ANY)
      {
	   AIOrder.SetOrderFlags(plane, i, AIOrder.AIOF_NO_LOAD);
	   AIController.Sleep(10);
	   AIOrder.SetOrderFlags(plane, i, AIOrder.AIOF_FULL_LOAD_ANY);	  	
	  }
   }
}

function KWAI::Konserwuj()
{
this.Skipper();
this.Uzupelnij();
this.DeadlockPrevention();
}

function KWAI::Burden(tile_1, tile_2, engine)
{
return AIEngine.GetMaxSpeed(engine)*200/(AITile.GetDistanceManhattanToTile(tile_1, tile_2)+50);
}

function KWAI::GetBurden(stacja)
{
local total;
local total = 0;
local airlist=AIVehicleList_Station(stacja);
for (local plane = airlist.Begin(); airlist.HasNext(); plane = airlist.Next())
   {
   total += this.Burden(AIOrder.GetOrderDestination (plane, 0), AIOrder.GetOrderDestination (plane, 1), AIVehicle.GetEngineType(plane));
   }
   
if(AIAI.GetSetting("debug_signs_for_airports_load")) AISign.BuildSign(AIStation.GetLocation(stacja), total+"");
return total;
}

function KWAI::IsItPossibleToAddBurden(stacja, tile, engine, ile=1)
{
local maksimum;
local total = this.GetBurden(stacja);
local airport_type = AIAirport.GetAirportType(AIStation.GetLocation(stacja));
if(airport_type==AIAirport.AT_LARGE) maksimum = 1500; //1 l�dowanie miesi�cznie - 250 //6 na du�ym
if(airport_type==AIAirport.AT_SMALL) maksimum = 500; //1 l�dowanie miesi�cznie - 250 //4 na ma�ym

total+=ile*this.Burden(AIStation.GetLocation(stacja), tile, engine);

return total < maksimum;
}

function KWAI::Uzupelnij()
{
local airport_type;

local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;

for (local aktualna = list.Begin(); list.HasNext(); aktualna = list.Next())
   {
   local cargo_list = AICargoList();
   for (local cargo = cargo_list.Begin(); cargo_list.HasNext(); cargo = cargo_list.Next())
	   if(AIStation.GetCargoWaiting(aktualna, cargo)>1)
       {
	   if(GetAverageCapacity(aktualna, cargo)*3 < AIStation.GetCargoWaiting(aktualna, cargo) || AIStation.GetCargoRating(aktualna, cargo)<30 ) //HARDCODED OPTION
		  {
		  //teraz trzeba znale�� lotnisko docelowe
		  local odbiorca = AIStationList(AIStation.STATION_AIRPORT);
		  for (local goal = odbiorca.Begin(); odbiorca.HasNext(); goal = odbiorca.Next())
			 {
 			 local tile_1 = AIStation.GetLocation(aktualna);
			 local tile_2 = AIStation.GetLocation(goal);
			 local airport_type_1 = AIAirport.GetAirportType(tile_1);
			 local airport_type_2 = AIAirport.GetAirportType(tile_2);
			 if(airport_type_1==AIAirport.AT_SMALL || airport_type_2==AIAirport.AT_SMALL) 
			    {
				airport_type=AIAirport.AT_SMALL;
				}
			 else
			    {
				airport_type=AIAirport.AT_LARGE;
				}
			
			 /*useless*/
 			 local airport_x_to = AIAirport.GetAirportWidth(airport_type_2);
			 /*useless*/
			 local airport_y_to = AIAirport.GetAirportHeight(airport_type_2);
			 /*useless*/
			 local airport_rad_to = AIAirport.GetAirportCoverageRadius(airport_type_2);

			 local engine=this.FindAircraft(airport_type, cargo, 1, AICompany.GetBankBalance(AICompany.COMPANY_SELF));
		     if(engine==-1) continue;
			 if(AITile.GetDistanceManhattanToTile(tile_1, tile_2)>100)
			 if(NajmlodszyPojazd(goal)>40)
			 {
				 if(this.IsItPossibleToAddBurden(aktualna, tile_2, engine))
				 if(this.IsItPossibleToAddBurden(goal, tile_1, engine))
				     {
					 if(AITile.GetCargoAcceptance(tile_2, cargo, airport_x_to, airport_y_to, airport_rad_to)>10)
					    {
						if( (this.GetPassengerCargoId()==cargo) || (this.GetMailCargoId()==cargo) )
						   {
						   if(AITile.GetCargoProduction(tile_2, cargo, airport_x_to, airport_y_to, airport_rad_to)>10)
						   this.BuildPassengerAircraft(tile_1, tile_2, engine, cargo);
						   }
						else
						   {
						   this.BuildCargoAircraft(tile_1, tile_2, engine, cargo, "uzupelniacz");
						   }
						}
				     }
				}
			 }
		   }
	   }   
   }
}

function KWAI::DeadlockPrevention()
{
local list = AIVehicleList();

//samolot
list.Valuate(AIVehicle.GetVehicleType);
list.KeepValue(AIVehicle.VT_AIR);

//�aduje
list.Valuate(AIVehicle.GetState);
list.KeepValue(AIVehicle.VS_AT_STATION);


for (local veh = list.Begin(); list.HasNext(); veh = list.Next())
   {
   //nie pasa�er�w
   if(AIVehicle.GetCapacity(veh, this.GetPassengerCargoId())!=0)continue;
   
   local cargo_list = AICargoList();
   for (local cargo = cargo_list.Begin(); cargo_list.HasNext(); cargo = cargo_list.Next())
       {
	   if(AIVehicle.GetCapacity(veh, cargo)!=0)
	      {
		  AIVehicle.SendVehicleToDepot(veh);
		  AIController.Sleep(10);
		  AIVehicle.SendVehicleToDepot(veh);
		  continue;
		  }
       }
   }
}

function KWAI::Skipper()
{
local list = AIStationList(AIStation.STATION_AIRPORT);
if(list.Count()==0)return;

for (local aktualna = list.Begin(); list.HasNext(); aktualna = list.Next())
   {
   local pozycja=AIStation.GetLocation(aktualna)
   local airlist=AIVehicleList_Station(aktualna);
   if(airlist.Count()==0)continue;
   local counter=0;
   
   local lista = AIList();
   local minimum = 101;
   local pustak;
   for (local plane = airlist.Begin(); airlist.HasNext(); plane = airlist.Next())
      {
	  if(AIVehicle.GetState(plane)==AIVehicle.VS_AT_STATION)
	     if(AITile.GetDistanceManhattanToTile(AIVehicle.GetLocation(plane), pozycja)<30)
		    if(AIVehicle.GetCapacity(plane, this.GetPassengerCargoId())>0)
			{
			local percent = ( 100 * AIVehicle.GetCargoLoad(plane, this.GetPassengerCargoId()))/(AIVehicle.GetCapacity(plane, this.GetPassengerCargoId()));
			if(percent < minimum)
			   {
			   minimum=percent;
			   pustak=plane;
			   }
  		    lista.AddItem(plane, plane);
			counter++;
			}
	  }
 
   for (local skipping = lista .Begin(); lista .HasNext(); skipping = lista.Next())
      {
	  if(skipping!=pustak) this.Skip(skipping, aktualna);
	  }
   }
}

function KWAI::FindSuitableAirportSpotInTown(airport_type, center_tile)
{
	local airport_x, airport_y, airport_rad;

	airport_x = AIAirport.GetAirportWidth(airport_type);
	airport_y = AIAirport.GetAirportHeight(airport_type);
	airport_rad = AIAirport.GetAirportCoverageRadius(airport_type);
	local town_list = AITownList();

	town_list.Valuate(AITown.GetLocation);
	
	/* Remove all the towns we already used */
	/* Only for small towns */

	local station_list=AIStationList(AIStation.STATION_AIRPORT);
	for(local i=station_list.Begin(); station_list.HasNext(); i=station_list.Next())
	    {
		local location;
		local town;
	
		location = AIStation.GetLocation(i);
	    town = AITile.GetClosestTown(location);
		if(AITown.GetPopulation(town)<1000) town_list.RemoveValue(AITown.GetLocation(town));
	
		location = AIStation.GetLocation(i)+AIMap.GetTileIndex(0, 8);
	    town = AITile.GetClosestTown(location);
		if(AITown.GetPopulation(town)<1000) town_list.RemoveValue(AITown.GetLocation(town));
		
		location = AIStation.GetLocation(i)+AIMap.GetTileIndex(0, -8);
	    town = AITile.GetClosestTown(location);
		if(AITown.GetPopulation(town)<1000) town_list.RemoveValue(AITown.GetLocation(town));

		location = AIStation.GetLocation(i)+AIMap.GetTileIndex(-8, 0);
	    town = AITile.GetClosestTown(location);
		if(AITown.GetPopulation(town)<1000) town_list.RemoveValue(AITown.GetLocation(town));

		location = AIStation.GetLocation(i)+AIMap.GetTileIndex(8, 0);
	    town = AITile.GetClosestTown(location);
		if(AITown.GetPopulation(town)<1000) town_list.RemoveValue(AITown.GetLocation(town));
		}


	town_list.Valuate(AITown.GetPopulation);
	town_list.KeepAboveValue(500);

	if(town_list.Count()>10)
	   {
	   local new_town_list = town_list;
	   new_town_list.KeepAboveValue(500);
	   if(town_list.Count()>=10)
	      {
		  town_list = new_town_list;
		  }
	   town_list.Valuate(AIBase.RandItem);
	   }
	   
	/* Keep the best 10, if we can't find 2 stations in there, just leave it anyway */
	town_list.KeepTop(10);

	/* Now find 2 suitable towns */
	for (local town = town_list.Begin(); town_list.HasNext(); town = town_list.Next()) {

    	local tile = AITown.GetLocation(town);
		/* Create a 30x30 grid around the core of the town and see if we can find a spot for a small airport */
		local list = AITileList();
		/* XXX -- We assume we are more than 15 tiles away from the border! */
		list.AddRectangle(tile - AIMap.GetTileIndex(15, 15), tile + AIMap.GetTileIndex(15, 15));
		list.Valuate(AITile.IsBuildableRectangle, airport_x, airport_y);
		list.KeepValue(1);
		if (center_tile != 0) {
			/* If we have a tile defined, we don't want to be within x tiles of this tile */
			list.Valuate(AITile.GetDistanceManhattanToTile, center_tile);
			list.KeepAboveValue(this.GetMinimalDistance());
		}
		/* Sort on acceptance, remove places that don't have acceptance */
		list.Valuate(AITile.GetCargoAcceptance, this.GetPassengerCargoId(), airport_x, airport_y, airport_rad);
		list.RemoveBelowValue(50);

		list.Valuate(AITile.GetCargoAcceptance, this.GetMailCargoId(), airport_x, airport_y, airport_rad);
		list.RemoveBelowValue(10);

		/* Couldn't find a suitable place for this town, skip to the next */
		if (list.Count() == 0) continue;
		/* Walk all the tiles and see if we can build the airport at all */
		{
			local test = AITestMode();
			local good_tile = 0;

			for (tile = list.Begin(); list.HasNext(); tile = list.Next()) {
				if (!AIAirport.BuildAirport(tile, airport_type, AIStation.STATION_NEW)) continue;
				good_tile = tile;
				break;
			}

			/* Did we found a place to build the airport on? */
			if (good_tile == 0) continue;
		}

		AILog.Info("Found a good spot for an airport in town " + town + " at tile " + tile);

		return tile;
	}

	AILog.Info("Couldn't find a suitable town to build an airport in");
	return -1;
}

function KWAI::GetPassengerCargoId()
{
local cargo_list = AICargoList();
cargo_list.Valuate(AICargo.HasCargoClass, AICargo.CC_PASSENGERS);
cargo_list.KeepValue(1);
cargo_list.Valuate(AICargo.GetTownEffect);
cargo_list.KeepValue(AICargo.TE_PASSENGERS);
cargo_list.Valuate(AICargo.GetTownEffect);
cargo_list.KeepValue(AICargo.TE_PASSENGERS);

if(!AICargo.IsValidCargo(cargo_list.Begin()))
{
	AILog.Error("PAX Cargo do not exist");
}

cargo_list.Valuate(AICargo.GetCargoIncome, 1, 1); //Elimination ECS tourists
cargo_list.KeepBottom(1);

return cargo_list.Begin();
}

function KWAI::GetMailCargoId()
{
local list = AICargoList();
for (local i = list.Begin(); list.HasNext(); i = list.Next()) 
	{
	if(AICargo.GetTownEffect(i)==AICargo.TE_MAIL)
		{
		return i;
		}
	}
return null;
}

