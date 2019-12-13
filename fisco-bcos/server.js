var http = require("http")
var url=require('url');
var qs=require('querystring');//解析参数的库

const webapi = require("./nodejs-sdk/packages/api/web3j").Web3jService;
const Configuration = require("./nodejs-sdk/packages/api/common/configuration").Configuration;
Configuration.setConfig("./nodejs-sdk/packages/cli/conf/config.json");
const utils = require("./nodejs-sdk/packages/api/common/web3lib/utils");

http.createServer(function(req,res){
    res.writeHead(200,
        {"Content-Type":'text/plain','charset':'utf-8',
        'Access-Control-Allow-Origin':'*',
        'Access-Control-Allow-Methods':'PUT,POST,GET,DELETE,OPTIONS'});

    var url_info = require('url').parse(req.url,true)
    var get_data = url_info.query;
    var api = new webapi();

    if (url_info.pathname == '/api'){       //注册下游公司
        if (get_data.type == 1){
            var para = get_data.company_name + "";
            var sendarr = new Array(para);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","registerCompany(string)",sendarr).then(value=>{
                var returnarr = new Array("uint256");
                var temp = utils.decodeParams(returnarr,value.output);
                var json = JSON.stringify({
                    result1:temp[0],
                });
                res.write(json);
                // console.log(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (get_data.type == 2){        //获取公司名称
            var para = get_data.cpnId + "";
            var sendarr = new Array(para);
            console.log("sendarr:"+sendarr); api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","getCompanyName(uint256)",sendarr).then(value=>{
                var returnarr = new Array("string");
		console.log("returnarr:"+returnarr);
                var temp = utils.decodeParams(returnarr,value.output);
                var json;
                if (temp[0] == "") {
                    json = JSON.stringify({
                        result: "this ID doesn't not register"
                    });
                }
                else{
                    json = JSON.stringify({
                        result: temp[0]
                    });
                }
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (get_data.type == 3){        //核心企业签发应收账款
            var data1 = get_data.toId + "";
            var data2 = get_data.amount + "";
            var data3 = get_data.max_time + "";
            var sendarr = new Array(data1,data2,data3);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","signReciept(uint256,uint256,uint256)",sendarr).then(value=>{
                var json = JSON.stringify({
                        result: "success!"
                    });
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        
        if (get_data.type == 4){    //申请融资
            var data1 = get_data.cpnId + "";
            var data2 = get_data.amount + "";

            var sendarr = new Array(data1,data2);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","askFinance(uint256,uint256)",sendarr).then(value=>{
                var returnarr = new Array("uint256");
                var temp = utils.decodeParams(returnarr,value.output);
                var json;
                if (parseInt(temp[0]) == 0) {
                    json = JSON.stringify({
                        result1:"failed"
                    });
                }
                else {
                    json = JSON.stringify({
                        result1:"success!"
                    });
                }
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (get_data.type == 5){    //债券转让
            var data1 = get_data.fromId + "";
            var data2 = get_data.toId + "";
            var data3 = get_data.amount + "";
            var sendarr = new Array(data1,data2,data3);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","transferOwned(uint256,uint256,uint256)",sendarr).then(value=>{
                var returnarr = new Array("uint256");
                var temp = utils.decodeParams(returnarr,value.output);
                var json;
                if (parseInt(temp[0]) == 0) {
                    json = JSON.stringify({
                        result1:"succeess!"
                    });
                }
                else{
                    json = JSON.stringify({
                        result1:"failed!"
                    });
                }
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (get_data.type == 6){    //确认核心企业还款
            var data1 = get_data.fromId + "";
            var sendarr = new Array(data1);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","ackCorePaid(uint256)",sendarr).then(value=>{
                var json = JSON.stringify({
                        result: "success!"
                    });
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }

        if (get_data.type == 7){
            var data1 = get_data.cpnId + "";
            var data2 = get_data.amount + "";
            var sendarr = new Array(data1,data2);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","payFinance(uint256,uint256)",sendarr).then(value=>{
                var returnarr = new Array("uint256");
                var temp = utils.decodeParams(returnarr,value.output);
                var json;
                if(temp[0] == 0){
                    json = JSON.stringify({
                        result1:"failed!"
                    });
                }
                else{
                    json = JSON.stringify({
                        result1:"success!"
                    });
                }
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
    }
}).listen(3000);
