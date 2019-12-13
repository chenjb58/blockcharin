var http = require("http")
var url=require('url');
var qs=require('querystring');

const webapi = require("./nodejs-sdk/packages/api/web3j").Web3jService;
const Configuration = require("./nodejs-sdk/packages/api/common/configuration").Configuration;
Configuration.setConfig("./nodejs-sdk/packages/cli/conf/config.json");
const utils = require("./nodejs-sdk/packages/api/common/web3lib/utils");

http.createServer(function(req,res){
    res.writeHead(200,
        {"Content-Type":'text/plain','charset':'utf-8',
        'Access-Control-Allow-Origin':'*',
        'Access-Control-Allow-Methods':'PUT,POST,GET,DELETE,OPTIONS'});

    var url_data = require('url').parse(req.url,true)
    var url_query = url_data.query;
    var api = new webapi();

    if (url_data.pathname == '/api'){       //注册下游公司
        if (url_query.type == 1){
            var para = url_query.company_name + "";
            var para_array = new Array(para);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","registerCompany(string)",para_array).then(value=>{
                var return_array = new Array("uint256");
                var tmp = utils.decodeParams(return_array,value.output);
                var json = JSON.stringify({
                    result1:tmp[0],
                });
                res.write(json);
                // console.log(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (url_query.type == 2){        //获取公司名称
            var para = url_query.cpnId + "";
            var para_array = new Array(para);
            console.log("para_array:"+para_array); api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","getCompanyName(uint256)",para_array).then(value=>{
                var return_array = new Array("string");
		console.log("return_array:"+return_array);
                var tmp = utils.decodeParams(return_array,value.output);
                var json;
                if (tmp[0] == "") {
                    json = JSON.stringify({
                        result: "this ID doesn't not register"
                    });
                }
                else{
                    json = JSON.stringify({
                        result: tmp[0]
                    });
                }
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        if (url_query.type == 3){        //核心企业签发应收账款
            var para1 = url_query.toId + "";
            var para2 = url_query.amount + "";
            var para3 = url_query.max_time + "";
            var para_array = new Array(para1,para2,para3);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","signReciept(uint256,uint256,uint256)",para_array).then(value=>{
                var json = JSON.stringify({
                        result: "success!"
                    });
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }
        
        if (url_query.type == 4){    //申请融资
            var para1 = url_query.cpnId + "";
            var para2 = url_query.amount + "";

            var para_array = new Array(para1,para2);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","askFinance(uint256,uint256)",para_array).then(value=>{
                var return_array = new Array("uint256");
                var tmp = utils.decodeParams(return_array,value.output);
                var json;
                if (parseInt(tmp[0]) == 0) {
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
        if (url_query.type == 5){    //债券转让
            var para1 = url_query.fromId + "";
            var para2 = url_query.toId + "";
            var para3 = url_query.amount + "";
            var para_array = new Array(para1,para2,para3);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","transferOwned(uint256,uint256,uint256)",para_array).then(value=>{
                var return_array = new Array("uint256");
                var tmp = utils.decodeParams(return_array,value.output);
                var json;
                if (parseInt(tmp[0]) == 0) {
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
        if (url_query.type == 6){    //确认核心企业还款
            var para1 = url_query.fromId + "";
            var para_array = new Array(para1);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","ackCorePaid(uint256)",para_array).then(value=>{
                var json = JSON.stringify({
                        result: "success!"
                    });
                res.write(json);
                res.end();
            }).catch(err=>{
                console.log(err);
            });
        }

        if (url_query.type == 7){
            var para1 = url_query.cpnId + "";
            var para2 = url_query.amount + "";
            var para_array = new Array(para1,para2);
            api.sendRawTransaction("0x91634c395d8d7e9c1a81a6d16f9de57104a03cf2","payFinance(uint256,uint256)",para_array).then(value=>{
                var return_array = new Array("uint256");
                var tmp = utils.decodeParams(return_array,value.output);
                var json;
                if(tmp[0] == 0){
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
