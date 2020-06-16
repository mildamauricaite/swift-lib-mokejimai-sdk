import XCTest
import JWTDecode
import PayseraCommonSDK
import PromiseKit

@testable import PayseraMokejimaiSDK

class PayseraMokejimaiSDKTests: XCTestCase {
    private let jwtToken = "insert_me"
    private let language = "en"

    func testSendLog() {
        let userId = "insert_me"
        let appVersion = "insert_me"
        
        let action = "app_unlocked"
        let context = ["app_version": appVersion]
        let expectation = XCTestExpectation(description: "")
            
        createMokejimaiApiClient()
            .sendLog(userId: userId, action: action, context: context)
            .done { response in
                print(response)
            }.catch { error in
                print((error as? PSApiError)?.toJSON() ?? "")
            }.finally { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetManualTransferConfiguration() {
        var transferConfigurations: [PSManualTransferConfiguration]?
        let expectation = XCTestExpectation(description: "Manual Transfer Configuration should be not nil")
        
        let mokejimaiApiClient = createMokejimaiApiClient()
        
        let filter = PSBaseFilter()
        filter.limit = 200
        
        mokejimaiApiClient
            .getManualTransferConfiguration(filter: filter)
            .done { response in
                transferConfigurations = response.items
            }.catch { error in
                print((error as? PSApiError)?.toJSON() ?? "")
            }.finally {
                expectation.fulfill()
            }
    
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(transferConfigurations)
    }
    
    func testCreatingLithuanianCompanyAccount() {
        var companyAccount: PSCompanyAccount?
        var apiError: PSApiError?
        let userId: Int = 0 // change me
        let expectation = XCTestExpectation(description: "createCompanyAccount should return some response")
        let companyIdentifier = PSCompanyIdentifier(countryCode: "LT", companyCode: "300060819")
        
        createMokejimaiApiClient()
            .createCompanyAccount(userId: userId, using: .identifier(companyIdentifier))
            .done { response in
                companyAccount = response
            }
            .catch { error in
                apiError = error as? PSApiError
                print(apiError?.toJSON() ?? "")
            }
            .finally {
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.error, "manager_name_mismatch")
    }
    
    func testCreatinngBulgarianCompanyAccount() {
            var companyAccount: PSCompanyAccount?
            var apiError: PSApiError?
            var solutionError: PSCompanyTaskSolutionError?
            let userId: Int = 0 // change me
            let expectation = XCTestExpectation(description: "createCompanyAccount should return some response")
            let companyIdentifier = PSCompanyIdentifier(countryCode: "BG", companyCode: "204037635")
            
            createMokejimaiApiClient()
                .createCompanyAccount(userId: userId, using: .identifier(companyIdentifier))
                .done { response in
                    companyAccount = response
                }
                .catch { error in
                    apiError = error as? PSApiError
                    if let json = apiError?.data as? [String: Any] {
                        solutionError = PSCompanyTaskSolutionError(JSON: json)
                    }
                    print(apiError?.toJSON() ?? "")
                }
                .finally {
                    expectation.fulfill()
                }

            wait(for: [expectation], timeout: 10.0)
            
            XCTAssertNotNil(apiError)
            XCTAssertNotNil(solutionError)
            XCTAssertEqual(apiError?.error, "task_solution_required")
    }
    
    func testSolvingTask() {
        var companyAccount: PSCompanyAccount?
        var apiError: PSApiError?
        let userId: Int = 0 // change me
        let expectation = XCTestExpectation(description: "createCompanyAccount should return some response")
        let companyTask = PSCompanyTask(id: "5XMVigNsGD", countryCode: "BG", solution: "RYGG5")
        
        print(companyTask)
        
        createMokejimaiApiClient()
            .createCompanyAccount(userId: userId, using: .task(companyTask))
            .done { response in
                companyAccount = response
            }
            .catch { error in
                apiError = error as? PSApiError
                print(apiError?.toJSON() ?? "")
            }
            .finally {
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(apiError)
        XCTAssertEqual(apiError?.error, "manager_name_mismatch")
    }
    
    func testGetCurrentUserAddresses() {
        var actualCountry: String?
        let expectation = XCTestExpectation(description: "User address must at least have living address")
        let expectedCountry = "insert_me"
        
        createMokejimaiApiClient()
            .getCurrentUserAddresses()
            .done { response in
                actualCountry = response.items
                    .first { $0.type == "living_address" }?
                    .countryCode
            }.catch { error in
                print("Error: \((error as? PSApiError)?.toJSON() ?? [:])")
            }.finally {
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(actualCountry, expectedCountry)
    }
    
    func testGetUserAddresses() {
        var actualCountry: String?
        let expectation = XCTestExpectation(description: "User address must at least have living address")
        let expectedCountry = "insert_me"
        let userIdentifier = "insert_me"
        
        createMokejimaiApiClient()
            .getUserAddresses(userIdentifier: userIdentifier)
            .done { response in
                actualCountry = response.items
                    .first { $0.type == "living_address" }?
                    .countryCode
            }.catch { error in
                print("Error: \((error as? PSApiError)?.toJSON() ?? [:])")
            }.finally {
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(actualCountry, expectedCountry)
    }
    
    func testUpdateCurrentUserLivingAddress() {
        //Given
        let expected = PSAddress()
        expected.type = "insert_me"
        expected.houseNumber = "insert_me"
        expected.apartmentNumber = "insert_me"
        expected.streetName = "insert_me"
        expected.cityName = "insert_me"
        expected.countryCode = "insert_me"
        expected.postalCode = "insert_me"
        expected.countyName = "insert_me"

        var actual: PSAddress?
        let expectation = XCTestExpectation(description: "User address must be the same as the address set")

        createMokejimaiApiClient()
            .updateCurrentUserAddress(expected)
            .done { response in
                actual = response
            }.catch { error in
                print("Error: \((error as? PSApiError)?.toJSON() ?? [:])")
            }.finally {
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(expected.type, actual?.type)
        XCTAssertEqual(expected.houseNumber, actual?.houseNumber)
        XCTAssertEqual(expected.apartmentNumber, actual?.apartmentNumber)
        XCTAssertEqual(expected.streetName, actual?.streetName)
        XCTAssertEqual(expected.cityName, actual?.cityName)
        XCTAssertEqual(expected.countryCode, actual?.countryCode)
        XCTAssertEqual(expected.postalCode, actual?.postalCode)
        XCTAssertEqual(expected.countyName, actual?.countyName)
    }
    
    func testUpdateUserLivingAddress() {
        //Given
        let userIdentifier = "insert_me"
        let expected = PSAddress()
        expected.type = "insert_me"
        expected.houseNumber = "insert_me"
        expected.apartmentNumber = "insert_me"
        expected.streetName = "insert_me"
        expected.cityName = "insert_me"
        expected.countryCode = "insert_me"
        expected.postalCode = "insert_me"
        expected.countyName = "insert_me"

        var actual: PSAddress?
        let expectation = XCTestExpectation(description: "User address must be the same as the address set")

        createMokejimaiApiClient()
            .updateUserAddress(userIdentifier: userIdentifier, address: expected)
            .done { response in
                actual = response
            }.catch { error in
                print("Error: \((error as? PSApiError)?.toJSON() ?? [:])")
            }.finally {
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(expected.type, actual?.type)
        XCTAssertEqual(expected.houseNumber, actual?.houseNumber)
        XCTAssertEqual(expected.apartmentNumber, actual?.apartmentNumber)
        XCTAssertEqual(expected.streetName, actual?.streetName)
        XCTAssertEqual(expected.cityName, actual?.cityName)
        XCTAssertEqual(expected.countryCode, actual?.countryCode)
        XCTAssertEqual(expected.postalCode, actual?.postalCode)
        XCTAssertEqual(expected.countyName, actual?.countyName)
    }
    
    func createMokejimaiApiClient() -> MokejimaiApiClient {
        let mokejimaiToken = try? decode(jwt: jwtToken)
        let credentials = PSApiJWTCredentials(token: mokejimaiToken)
        
        return MokejimaiApiClientFactory.createTransferApiClient(
            headers: PSRequestHeaders(headers: [.acceptLanguage(language)]),
            credentials: credentials
        )
    }
    
    func testGetUserAccountsData() {
        var object: [PSUserAccountData]?
        let expectation = XCTestExpectation(description: "")
        createMokejimaiApiClient()
            .getUserAccountsData(id: 0000).done { result in
                object = result.items
            }.catch { error in
                print(error)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(object)
    }
    
    func testGetAvailableIdentityDocuments() {
        var object: [PSIdentityDocument]?
        let expectation = XCTestExpectation(description: "")
        let filter = PSAvailableIdentityDocumentsFilter()
        filter.country = "lt"
        createMokejimaiApiClient()
            .getAvailableIdentityDocuments(filter: filter).done { result in
                object = result.items
            }.catch { error in
                print(error)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(object)
    }
}
