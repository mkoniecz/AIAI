class BusRoadBuilder extends RoadBuilder
{
}

function BusRoadBuilder::Possible()
{
if(!IsAllowedBus())return false;
Info("estimated cost of a bus connection: " + this.cost + " /  available funds: " + GetAvailableMoney());
return this.cost<GetAvailableMoney();
}

function BusRoadBuilder::FindBusPair()
{
trasa.start = GetRatherBigRandomTown();
trasa.end = GetNiceRandomTown(AITown.GetLocation(trasa.start))
trasa.cargo = rodzic.GetPassengerCargoId();

if(trasa.end == null) return false;
Info("From " + AITown.GetName(trasa.start) + "  to " +  AITown.GetName(trasa.end) );
trasa.cargo = rodzic.GetPassengerCargoId();

trasa = BusStationAllocator(trasa);

if(!((trasa.first_station.location==null)||(trasa.second_station.location==null)))
	{
	trasa.start_tile = AITown.GetLocation(trasa.start);
	trasa.end_tile = AITown.GetLocation(trasa.end);
	trasa.production = min(AITile.GetCargoAcceptance(trasa.first_station.location, trasa.cargo, 1, 1, 3), AITile.GetCargoAcceptance(trasa.second_station.location, trasa.cargo, 1, 1, 3));
	trasa.type = 2;
	
	trasa = WybierzRVForFindPair(trasa);
	if(trasa.engine == null) return false;
	return true;
	}
return false;
}

function BusRoadBuilder::Go()
{
AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
trasa = Route();

for(local i=0; i<retry_limit; i++)
   {
   Important("Scanning for bus route");
   if(!this.FindBusPair())
      {
	  Info("Nothing found!");
	  cost = 0;
	  return false;
      }
   Important("Scanning for bus route completed [ " + desperation + " ] ");
   if(this.PrepareRoute())
      {
	  Info("   Contruction started on correct route.");
	  if(this.ConstructionOfBusRoute())
	  return true;
	  else trasa.forbidden.AddItem(trasa.start, 0);
	  }
   else
      {
	  if(trasa.start==null)return false;
	  else trasa.forbidden.AddItem(trasa.start, 0);
	  }
   }
return false;
}

function BusRoadBuilder::ConstructionOfBusRoute()
{
if(!this.ZbudujStacjeAutobusow())
   {
   if(trasa.start!=null) trasa.forbidden.AddItem(trasa.start, 0);
   return false;	  
   }
return this.ConstructionOfRVRoute();
}

function BusRoadBuilder::ZbudujStacjeAutobusow()
{
if(!AIRoad.BuildDriveThroughRoadStation(trasa.first_station.location, trasa.start_otoczka[0], AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW)) 
   {
   Info("   Producer station placement impossible due to " + AIError.GetLastErrorString());
   if(rodzic.GetSetting("other_debug_signs")) AISign.BuildSign(trasa.first_station.location, AIError.GetLastErrorString());
   return false;
   }
if(!AIRoad.BuildDriveThroughRoadStation(trasa.second_station.location, trasa.koniec_otoczka[0], AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW)) 
   {
   Info("   Consumer station placement impossible due to " + AIError.GetLastErrorString());
   AIRoad.RemoveRoadStation(trasa.first_station.location);
   if(rodzic.GetSetting("other_debug_signs")) AISign.BuildSign(trasa.second_station.location, AIError.GetLastErrorString());
   return false;
   }
return RoadToStation();
}
