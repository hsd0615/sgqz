cat /opt/server.log
echo "===DATA==="
ls -la /opt/data.json
echo "===PLAYERS==="
grep -o '"role_name":"[^"]*"' /opt/data.json | head -20
echo "===FIGHT==="
grep -c "fight" /opt/server.log
echo "===DONE==="
