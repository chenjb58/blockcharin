
pragma solidity ^0.4.21;

contract BigHW{
    
    mapping(address=>uint) money;
    mapping(address=>string) company_names;
    mapping(string=>address) company_addrs;
    
    address private bank;   //address of bank
    Receipt[] receipt_list;
    
    
    struct Receipt{
        address from_addr;
        address to_addr;
        uint amount;
        uint begin_time;
        uint last_time;
    }
    
    
    constructor() public {
        bank = msg.sender;
        money[msg.sender] = 99999999;
        company_names[msg.sender] = "bank";
        company_addrs["bank"] = msg.sender;
    }
    
    function registerCompany(string company_name) public returns(bool){
        if(bytes(company_names[msg.sender]).length > 0 ) return false;
        if(company_addrs[company_name]!=address(0)) return false;
        company_names[msg.sender] = company_name;
        company_addrs[company_name] = msg.sender;
        return true;
    }
    
    function inc_bank_money(uint money_amount) public returns(bool){
        if(msg.sender != bank) return false;
        else money[bank] += money_amount;
        return true;
    }
    
    function makeDeal(string company_name, uint amount, uint last_time) public returns(bool){
        if(company_addrs[company_name] == address(0)) return false;
        if(msg.sender == bank && amount > money[bank]) { //bank makes deal right now
            money[company_addrs[company_name]] += amount;
            money[bank] -= amount;
        }
        else if(money[msg.sender] > amount) {
            uint current_amount = amount;
            Receipt memory add_receipt;
            for(uint i=0; i<receipt_list.length && current_amount>0;i++){
                if(receipt_list[i].to_addr == msg.sender){
                    if(receipt_list[i].amount > current_amount){
                        add_receipt = Receipt(receipt_list[i].from_addr,company_addrs[company_name],current_amount,now,last_time);
                        receipt_list.push(add_receipt);
                        receipt_list[i].amount -= current_amount;
                        current_amount = 0;
                        break;
                    }
                    else {
                        add_receipt = Receipt(receipt_list[i].from_addr,company_addrs[company_name],current_amount,now,last_time);
                        current_amount -= receipt_list[i].amount;
                        delete receipt_list[i];
                        receipt_list[i] = add_receipt;
                    }
                }
            }
            if(current_amount>0){
                add_receipt = Receipt(msg.sender, company_addrs[company_name], current_amount, now, last_time);
                receipt_list.push(add_receipt);
            }
        }
        else return false;
        return true;
    }
    
    function payTo(string company_name) public returns(uint unpay_receipt_num){
        unpay_receipt_num = 0;
        for(uint i=0; i<receipt_list.length; i++){
            if(receipt_list[i].from_addr == msg.sender && receipt_list[i].to_addr == company_addrs[company_name]){
                if(money[msg.sender] > receipt_list[i].amount){
                    money[msg.sender] -= receipt_list[i].amount;
                    money[company_addrs[company_name]] += receipt_list[i].amount;
                    delete receipt_list[i];
                    receipt_list[i] = receipt_list[receipt_list.length-1];
                    delete receipt_list[receipt_list.length-1];
                    receipt_list.length -= 1;
                    i -= 1;
                }
                else unpay_receipt_num += 1;
            }
        }
    }
    
    function payAll() public returns(uint unpay_receipt_num){
        unpay_receipt_num = 0;
        for(uint i=0; i<receipt_list.length; i++){
            if(receipt_list[i].from_addr == msg.sender && money[msg.sender] > receipt_list[i].amount){
                money[msg.sender] -= receipt_list[i].amount;
                money[receipt_list[i].to_addr] += receipt_list[i].amount;
                delete receipt_list[i];
                receipt_list[i] = receipt_list[receipt_list.length-1];
                delete receipt_list[receipt_list.length-1];
                receipt_list.length -= 1;
                i -= 1;
            }
            else unpay_receipt_num += 1;
        }
    }
    
    function get_receipt_money(address addr) private returns(uint max_amount){
        max_amount = 0;
        for(uint i=0; i<receipt_list.length; i++){
            if(receipt_list[i].to_addr == addr)
            max_amount += receipt_list[i].amount;
        }
    }
    
    
    function borrow_money_from_bank(uint amount, uint last_time) public returns(bool){
        uint max_borrow_money = get_receipt_money(msg.sender);
        if(amount > max_borrow_money) return false;
        else {
            Receipt memory tmp = Receipt(msg.sender, bank, amount, now, last_time);
            receipt_list.push(tmp);
        }
        return true;
    }
    
    function ask_for_money()public {
         for(uint i=0; i<receipt_list.length; i++){
            if(receipt_list[i].to_addr == msg.sender && receipt_list[i].begin_time+receipt_list[i].last_time<=now && money[receipt_list[i].from_addr] > receipt_list[i].amount){
                money[msg.sender] += receipt_list[i].amount;
                money[receipt_list[i].from_addr] -= receipt_list[i].amount;
                delete receipt_list[i];
                receipt_list[i] = receipt_list[receipt_list.length-1];
                delete receipt_list[receipt_list.length-1];
                receipt_list.length -= 1;
                i -= 1;
            }
        }
    }
    
    function get_money()public returns(uint){
        return money[msg.sender];
    }
    
    function inc_company_money(string company_name, uint amount)public returns(bool){
        if(msg.sender!=bank) return false;
        if(company_addrs[company_name]==address(0)) return false;
        money[company_addrs[company_name]] += amount;
        return true;
    }
}
