import Foundation

struct Test {
    static func test() {
        let _ = LocalizedStringResource.expenseActualExchangeRate(
            expenseCurrencyCode: "USD",
            actualRateExpenseToBase: "0.92",
            baseCurrencyCode: "EUR"
        )
    }
}
