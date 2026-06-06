const http = require('http');
const server = http.createServer((req, res) => {
  let body = '';
  req.on('data', c => body += c);
  req.on('end', () => {
    let data;
    try { data = JSON.parse(body); } catch(e) { data = {}; }
    const resp = JSON.stringify({
      success: true, stamp: data.stamp||'', head: '9999',
      data: {
        flag: 1, token: 'x', currentTime: Date.now(), dianka: 999999,
        armyModel: [
          {id:1,code:'general_9_18',genius:'tf_20',level:220,feature:1,evolution:10,kezhi:'6:10|1:10|8:10'},
          {id:2,code:'general_9_20',genius:'tf_20',level:220,feature:1,evolution:10,kezhi:'6:10|1:10|8:10'},
          {id:3,code:'general_7_19',genius:'tf_20',level:220,feature:1,evolution:10,kezhi:'5:10|4:10|7:10'},
          {id:4,code:'general_1_15',genius:'tf_20',level:220,feature:1,evolution:10,kezhi:'5:10|7:10|9:10'},
          {id:5,code:'general_3_13',genius:'tf_20',level:220,feature:1,evolution:10,kezhi:'2:10|1:10|6:10'},
        ],
        bagModel: [], process: {history:'',finished:''},
        roleModel: {roleID:1,agent:'4399',userID:'gm_admin',userName:'',roleName:'GM',imageID:1,level:220,exp:0,money:99999999,dianka:999999,exploit:99999999,reverence:99999999,rongyu:99999,winCount:0,lostCount:0,ranking:0,score:0,choose:'',finished:'',history:'',loginServer:0}
      }
    });
    res.writeHead(200, {
      'Content-Type': 'application/json; charset=utf-8',
      'Content-Length': Buffer.byteLength(resp),
      'Connection': 'close'
    });
    res.end(resp);
    console.log(`Sent ${resp.length} bytes`);
  });
});
server.listen(3000, () => console.log('Raw HTTP on 3000'));
