####################################################################
#         AWK Script to calculate Normalized Routing Load          #
#              Works with AODV, DSDV, DSR and OLSR		   #
####################################################################

BEGIN{
recvd = 0;#################### to calculate total number of data packets received
rt_pkts = 0;################## to calculate total number of routing packets received
}

{
##### Check if it is a data packet
if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" )) recvd++;

##### Check if it is a routing packet
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ($7 =="AODV" || $7 =="message" || $7 =="DSR" || $7 =="OLSR")) rt_pkts++;
}

END{
printf("##################################################################################\n");
printf("\n");
printf("                       Normalized Routing Load = %.3f\n", rt_pkts/recvd);
printf("\n");
printf("##################################################################################\n");
}
