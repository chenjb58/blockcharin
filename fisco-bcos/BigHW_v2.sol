pragma solidity ^0.4.24;

contract BigHW_v2 {
	// 定义核心企业向下游企业签发的应收账款 单据
	struct reciept {
		uint to;      // 欠谁
		uint amount;	 // 这张单据代表欠多少
		uint endTime;    // 还款到期时间
		bool used;       // 判断这个元素是否被占用
		bool payed;      // 标记该账单是否已经被偿还
	}
	
    //下游企业
    struct downCompany{
        string name;    //公司名
        address addr;   //地址
        uint[] owned;   //持有债券，是reciepts的下标数组
        uint financed;  //银行融资总额度
    }
    
    reciept[] reciepts;     //账单
    uint public coreDebt;   //欠款
    
    address bank;       //银行
    address coreCompany; //中心企业
    
    mapping(uint=>downCompany) downCompanies;   //用uint映射一个下游企业
    uint dcpnNum;      //下游企业企业总数
   // mapping(string=>string) psw;  
    
    constructor() public {
        bank = msg.sender;
        coreDebt = 0;
        dcpnNum = 0;
        setCoreCompany(msg.sender);
    }	
    
    //注册一个公司，参数为公司名
    function registerCompany(string company_name)returns(uint){
	    dcpnNum ++;
	    downCompanies[dcpnNum].addr = msg.sender;
	    downCompanies[dcpnNum].name = company_name;
	    return dcpnNum;
	}
	
    //通过下标获取公司名
	function getCompanyName(uint id)public returns(string){
	    return downCompanies[id].name;
	}
	
    //设置核心企业
	function setCoreCompany(address addr)public returns(bool){
	   // require(msg.sender == bank);
	    coreCompany = addr;
	}
	
    //制作收据，返回收据在reciepts里的下标
	function makeReciept(uint toId, uint amount, uint endTime)private returns(uint rid){
	    rid=0;
	    while(rid<reciepts.length && reciepts[rid].used){rid++;}
	    if(rid == reciepts.length) reciepts.push(reciept(toId,amount,endTime,true,false));
	    else {
	        reciepts[rid].to = toId;
	        reciepts[rid].amount = amount;
	        reciepts[rid].endTime = endTime;
	        reciepts[rid].used = true;
	        reciepts[rid].payed = false;
	    }
	    coreDebt += amount;
	}
	
    //下游公司添加债券
	function addDownCompanyOwned(uint cpnId, uint rid) private{
	    downCompanies[cpnId].owned.push(rid);
	}
	
    //下游公司删除债券
	function deleteDownCompanyOwned(uint cpnId, uint rid) private{
	    uint i;
	    for(i=0; i<downCompanies[cpnId].owned.length; i++){
	        if(downCompanies[cpnId].owned[i] == rid) break;
	    }
	    for(; i<downCompanies[cpnId].owned.length-1; i++){
	        downCompanies[cpnId].owned[i]=downCompanies[cpnId].owned[i+1];
	    }
	    downCompanies[cpnId].owned.length -= 1;
	}
	
    //核心企业签发应收账款
    function signReciept(uint toId, uint amount, uint max_time) public{
     //   require(msg.sender == coreCompany);
        uint endTime = now + max_time*3600;
        uint rid = makeReciept(toId,amount,endTime);
        addDownCompanyOwned(toId,rid);
    }
    
    //下游企业获取债券总金额
    function getOwnedAmount(uint cpnId) public returns(uint){
        uint total = 0;
        for(uint i=0; i<downCompanies[cpnId].owned.length; i++){
            total += reciepts[downCompanies[cpnId].owned[i]].amount;
        }
        return total;
    }
    
    //下游企业转让债券
    function transferOwned(uint fromId, uint toId, uint amount) public returns(uint){
        //require(msg.sender==downCompanies[fromId).addr);
        uint max_amount =getOwnedAmount(fromId);
        if(max_amount < amount) return max_amount;
        for(uint i=0; i<downCompanies[fromId].owned.length; i++){
            if(amount==0) break;
            if(reciepts[downCompanies[fromId].owned[i]].payed) continue;
            if(reciepts[downCompanies[fromId].owned[i]].amount <= amount){
                reciepts[downCompanies[fromId].owned[i]].to = toId;
                addDownCompanyOwned(toId,downCompanies[fromId].owned[i]);
                deleteDownCompanyOwned(fromId,i);
                amount -= reciepts[downCompanies[fromId].owned[i]].amount;
            }
            else {
                reciepts[downCompanies[fromId].owned[i]].amount -= amount;
                uint newRid = makeReciept(toId, amount, reciepts[downCompanies[fromId].owned[i]].endTime);
                addDownCompanyOwned(toId,newRid);
                amount = 0;
                break;
            }
        }
        return 0;
    }
    
    //下游企业申请融资，只能申请债券总金额以内的金额
    function askFinance(uint cpnId, uint amount)public returns(uint){
        uint max_amount = getOwnedAmount(cpnId);
        if(amount > max_amount) return 0;
        else{
            downCompanies[cpnId].financed += amount;
        }
        return amount;
    }
    
    //下游企业偿还融资
    function payFinance(uint cpnId, uint amount)public returns(uint){
        if(amount > downCompanies[cpnId].financed) return 0;
        else{
            downCompanies[cpnId].financed -= amount;
        }
        return amount;
    }
    
    //下游企业在链外确认已经收款
    function ackCorePaid(uint cpnId)public{
        //require(msg.sender == downCompanies[cpnId].addr)
        for(uint i=0; i<downCompanies[cpnId].owned.length; i++){
            if(reciepts[downCompanies[cpnId].owned[i]].endTime > now) continue;
            reciepts[downCompanies[cpnId].owned[i]].payed = true;
            reciepts[downCompanies[cpnId].owned[i]].used = false;
            coreDebt -= reciepts[downCompanies[cpnId].owned[i]].amount;
            deleteDownCompanyOwned(cpnId,downCompanies[cpnId].owned[i]);
        }
    }
    
    bool[64] public unpaid;//未按期还款的下游公司
    //设置unpaid数组，查看哪些id的公司没有按时还款
    function checkUnpaid() public {
        for(uint i=1; i<=dcpnNum; i++){
            unpaid[i] = false;
            for(uint j=0; j<downCompanies[i].owned.length; i++){
                if(reciepts[downCompanies[i].owned[j]].endTime < now && reciepts[downCompanies[i].owned[j]].payed == false){
                    unpaid[i] = true;
                    break;
                }
            }
        }
    }
}

