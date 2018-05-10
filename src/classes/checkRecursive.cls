public Class checkRecursive{
	@TestVisible private static boolean run = true;
	private static boolean runForCalPercent = true;
	
	private static boolean runDeposit = true;
    public static boolean runDepositOnce(){	
    if(runDeposit){
     runDeposit=false;
     return true;
    }else{
        return runDeposit;
    }
    }
    public static boolean runDepositAlready(){
    	return runDeposit;
    }
 	public static boolean runOnce(){
		Integer i=0;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
	i++;
 		if(run){
			run=false;
			return true;
 		}else{
			return run;
 		}
 	}
 	public static boolean runAlready(){
 		run=true;
		return false;
 	}
 	public static boolean makeRunTrue(){
 		run=true;
		return true;
 	}
 	
}