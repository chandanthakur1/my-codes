require 'json'
require 'csv'

fileName = "BankGuarantee"


def recursive(data, fileName)
    unless ["Array", "Document"].include?(data["name"])
        path = data["path"]
        name = data["name"]

        if path.include?(name)

            begin
                path = path[0, path.length - name.length - 1] + " "
            rescue => exception
                path = path[0, path.length - name.length] + " "
            end
        end
        CSV.open("API_All/#{fileName}/#{fileName}.csv", "a") do |csv|
            csv << [name, path]
        end
    end

    begin
        types = data["types"]
        # i = 1
        for type in types

            if ["Array", "Document"].include?(type["name"])
                recursive(type, fileName)
            end
            # puts "Type " + i.to_s + ": " + type["name"] + " => " + type["path"]
            # i = i + 1
        end
    rescue => exception
        fields =  data["fields"]

        for field in fields         
            recursive(field, fileName)
            # if ["Array", "Document"].include?(field["name"])
            #     recursive(field)
            # end
        end
    end
end


list = [
    "BankGuarantees",
    "CashCredit",
    "ConstructionFinance",
    "Discount",
    "ExportPackingCredit",
    "Factoring",
    "GreenFieldFinance",
    "InventoryFunding",
    "LeaseRentalDiscounting",
    "LetterOfCredit",
    "LoanAgainstProperty",
    "Overdraft",
    "PackCreditForeignCurrency",
    "ReceivableAssignment",
    "ShortTermLoan",
    "TermLoan",
    "WorkingCapitalDemandLoan"
]


for fileName in list

    file = File.read("API_All/#{fileName}/#{fileName}.json")
    data = JSON.parse(file)
    allData =  data["fields"]
    
    fil = File.new("API_All/#{fileName}/#{fileName}.csv", "w")
    fil.close
    
    for data in allData 
        recursive(data, fileName)
    end
end


puts "Done"
