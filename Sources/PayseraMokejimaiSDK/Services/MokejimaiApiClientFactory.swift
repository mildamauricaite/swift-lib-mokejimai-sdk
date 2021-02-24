import Foundation
import Alamofire
import PayseraCommonSDK

public class MokejimaiApiClientFactory {
    public static func createTransferApiClient(
        headers: PSRequestHeaders,
        credentials: PSApiJWTCredentials,
        tokenRefresher: PSTokenRefresherProtocol? = nil,
        logger: PSLoggerProtocol? = nil
    ) -> MokejimaiApiClient {
        let interceptor = PSRequestAdapter(credentials: credentials, headers: headers)
        let session = Session(
            interceptor: interceptor,
            cachedResponseHandler: ResponseCacher(behavior: .doNotCache)
        )
        
        return MokejimaiApiClient(
            session: session,
            credentials: credentials,
            tokenRefresher: tokenRefresher,
            logger: logger
        )
    }
}
