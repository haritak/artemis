echo Waking up teachers ltsp server:
echo all other clients will be woken up later by teachers ltsp server
#old teachersltspserver was smokepc2 : wakeonlan 50:e5:49:2a:84:76
#new teachersltspserver desktop hp:
wakeonlan 3C:D9:2B:67:72:2E
sleep 1

#echo apostolakis pc:
#wakeonlan 00:26:18:CA:5B:D7
#sleep 1

#echo apostalakis second pc:
#wakeonlan 00:1D:60:9A:EE:C0
#sleep 1

#echo wait for ubuntu server to come up
#sleep 10

#echo teachersltspserver_client_smokepc2:
#echo "smokepc2 (old teachersltspserver):"
#wakeonlan 50:e5:49:2a:84:76

#echo teachersltspserver_client_sep:

#echo teachersltspserver_client_nosmokepc1:

#echo nosmokepc mesa deksia gwnia. 
#wakeonlan 00:1d:60:9a:ee:c0

echo done
