# Initialization settings
BEGIN {

        sendLine = 0;
        recvLine = 0;
        fowardLine = 0;
        if(mseq==0)
  mseq=10000;
 for(i=0;i<mseq;i++){
  rseq[i]=-1;
  sseq[i]=-1;
 }
}
# Applications received packet
$0 ~/^s.* AGT/ {
# if(sseq[$6]==-1){
         sendLine ++ ;
#        sseq[$6]=$6;
# }
}

# Applications to send packets
$0 ~/^r.* AGT/{
# if(rreq[$6]==-1){
         recvLine ++ ;
#         sseq[$6]=$6;
#        }

}


# Routing procedures to forward the packet
$0 ~/^f.* RTR/ {

        fowardLine ++ ;

}

# Final output
END {
        printf "cbr s:%d r:%d, r/s Ratio:%.4f, f:%d \n", sendLine, recvLine, (recvLine/sendLine),fowardLine;

}
