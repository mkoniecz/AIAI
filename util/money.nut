function RepayOnePieceOfLoan() {
	return AICompany.SetLoanAmount(AICompany.GetLoanAmount()-AICompany.GetLoanInterval())
}

function BorrowOnePieceOfLoan() {
	return AICompany.SetLoanAmount(AICompany.GetLoanAmount()+AICompany.GetLoanInterval())
}

function GetSafeBankBalance() {
	local minimum = Money.Inflate(20000)
	minimum +=  AIInfrastructure.GetMonthlyInfrastructureCosts(AICompany.COMPANY_SELF,  AIInfrastructure.INFRASTRUCTURE_RAIL)
	minimum +=  AIInfrastructure.GetMonthlyInfrastructureCosts(AICompany.COMPANY_SELF,  AIInfrastructure.INFRASTRUCTURE_ROAD)
	minimum +=  AIInfrastructure.GetMonthlyInfrastructureCosts(AICompany.COMPANY_SELF,  AIInfrastructure.INFRASTRUCTURE_CANAL)
	minimum +=  AIInfrastructure.GetMonthlyInfrastructureCosts(AICompany.COMPANY_SELF,  AIInfrastructure.INFRASTRUCTURE_AIRPORT)
	return minimum
}

function GetAvailableMoney() {
	local money = AICompany.GetBankBalance(AICompany.COMPANY_SELF)
	if (money > money + AICompany.GetMaxLoanAmount()) {
		return 2147483647 //implied by _intsize_ = 4 on 32bit architecture
	}
	money = money + AICompany.GetMaxLoanAmount()
	money = money - AICompany.GetLoanAmount() - GetSafeBankBalance()
	return money;
}

function BankruptProtector() {
	local needed_pocket_money = GetSafeBankBalance();
	while(AICompany.GetBankBalance(AICompany.COMPANY_SELF) < needed_pocket_money) {
		while(AICompany.GetBankBalance(AICompany.COMPANY_SELF) < 0) {
			FunnyComplaintAboutMoneyTrouble(AIBase.RandRange(11));
			if (AICompany.GetLoanAmount() == AICompany.GetMaxLoanAmount()) {
				FunnyComplaintAboutMoneyTrouble(10);
				DoomsdayMachine();
				SafeMaintenance();
				Sleep(200);
				if(AICompany.GetBankBalance(AICompany.COMPANY_SELF) > 0) {
					Info("End of serious financial problems!");
				}
			}
			BorrowOnePieceOfLoan()
		}
		if (!BorrowOnePieceOfLoan()) {
			Warning("Borrowing more is impossible and we need money! ("+AICompany.GetBankBalance(AICompany.COMPANY_SELF)/1000+"k/"+needed_pocket_money/1000+"k)");
			Helper.SellAllVehiclesStoppedInDepots();
			SafeMaintenance();
			Sleep(200);
		}
	}
}

function FunnyComplaintAboutMoneyTrouble(severity){
	if(severity < 9){
		Warning("We need money!");
	} else if(severity == 10) {
		Warning("We need bailout!");
	} else {
		Error("We are too big to fail! Remember, we employ " + (AIVehicleList().Count()*7+AIStationList(AIStation.STATION_ANY).Count()*3+23) + " people!");
	}
}

function ProvideMoney(amount = null) {
	if (AICompany.GetBankBalance(AICompany.COMPANY_SELF)>10*AICompany.GetMaxLoanAmount()) {
		Money.MakeMaximumPayback();
	} else {
		Money.MaxLoan();
	}

	if(amount == null) {
		return;
	}

	while(AICompany.GetBankBalance(AICompany.COMPANY_SELF) - 3*AICompany.GetLoanInterval() > amount) {
		if(AICompany.GetLoanAmount() == 0) {
			break;
		}
		RepayOnePieceOfLoan();
		Info("Loan rebalanced to " + AICompany.GetLoanAmount());
	}
}

function PortionOfAvailableLoanInPercents(){
	local loan = AICompany.GetLoanAmount();
	local max_loan = AICompany.GetMaxLoanAmount();
	local loan_available = max_loan - loan;
	local portion_of_available_loan_in_percents = loan_available / (max_loan / 100);
	return portion_of_available_loan_in_percents;
}