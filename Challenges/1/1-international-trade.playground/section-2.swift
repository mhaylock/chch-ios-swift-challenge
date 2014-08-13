import Cocoa

class Transaction {
    let store: String
    let sku: String
    let amount: NSDecimalNumber
    let currency: String
    init(store: String, sku: String, amount: NSDecimalNumber, currency: String) {
        self.store = store
        self.sku = sku
        self.amount = amount
        self.currency = currency
    }
}

let bundle = NSBundle.mainBundle()

let transPath = bundle.pathForResource("SAMPLE_TRANS", ofType: "csv")
let csvString = String.stringWithContentsOfFile(transPath, encoding: NSUTF8StringEncoding, error: nil)!

let csvLines = csvString.componentsSeparatedByString("\n")
let cvsRows = csvLines[1..<csvLines.count-1]

var transactions = Array<Transaction>()
for line in cvsRows {
    let values = line.componentsSeparatedByString(",")
    let currencyAmount = values[2].componentsSeparatedByString(" ")
    let transaction = Transaction(store: values[0], sku: values[1], amount: NSDecimalNumber(string: currencyAmount[0]), currency: currencyAmount[1])
    transactions.append(transaction)
}

struct Rate {
    var from: String = "",
        to: String = "",
        conversionRate: NSDecimalNumber = NSDecimalNumber()
}

class Rates : NSXMLParser, NSXMLParserDelegate {
    var rates: [Rate]

    var currentElement: String?,
        currentRate: Rate?

    init(fileName: String) {
        rates = Array()

        var error: NSError?;
        var data = NSData(contentsOfFile: fileName,
                                 options: .DataReadingMappedIfSafe,
                                   error: &error)

        super.init(data: data)

        self.delegate = self;
        self.parse()
    }

    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName: String!, attributes: [NSObject : AnyObject]!) {
        currentElement = elementName

        if elementName == "rate" {
            currentRate = Rate()
        }
    }

    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        if let element = currentElement {
            switch element {
                case "from":
                    currentRate!.from = string
                case "to":
                    currentRate!.to = string
                case "conversion":
                    currentRate!.conversionRate = NSDecimalNumber(string: string)
                default:
                    break
            }
        }
    }

    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName: String!) {
        currentElement = nil
        if elementName == "rate" {
            rates.append(currentRate!)
        }
    }
}

let ratesPath = bundle.pathForResource("SAMPLE_RATES", ofType: "xml")
let rates = Rates(fileName: ratesPath)
rates.rates

