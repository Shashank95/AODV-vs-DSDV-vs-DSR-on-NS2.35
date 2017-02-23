load win.tr;
x = win(:,1);
y = win(:,2);
plot(x,y);
title('CWND size vs time graph for AODV');
xlabel('TIME (sec)');
ylabel('CWND size (packets)');