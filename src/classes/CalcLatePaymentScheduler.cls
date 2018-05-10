global class CalcLatePaymentScheduler implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CalcLatePaymentController cp = new CalcLatePaymentController();
        cp.CalcLatePayment();
    }
}