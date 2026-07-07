collect_service_logs() {

    SERVICE_NAME=$1

    # step 1
    # does service exist?

    STATUS_OUTPUT=$(systemctl status "$SERVICE_NAME" 2>&1)
    if [[ "$STATUS_OUTPUT" == *"could not be found"* ]]
    then
	    echo "SERVICE_NOT_INSTALLED"
	    return
    fi

    #step2
    #read logs

    LOGS=$(journalctl -u "$SERVICE_NAME" -n 30 --no-pager 2>&1)

    #step 3 
    ##no logs?
    
    if [[ "$LOGS" == *" No entries"* ]]
    then
	    echo "NO_LOGS_FOUND"
	    return
    fi

    #step 4
    #permission denied?
    

   if [[ "$LOGS" == *"Permission denied"* ]]
   then
	   echo "ACCESS_DENIED"
	   return
   fi

   #step 5
   #seccuss

   echo "$LOGS"


}
