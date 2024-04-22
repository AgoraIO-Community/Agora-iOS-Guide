//
//  AgoraTokenService.swift
//  Awesome Video Call
//

import Foundation

struct AgoraGetTokenRequestBody: Codable {
    
    let tokenType: String
    let channel: String
    let role: String
    let uid: String
    let expire: Int
    
    init(
        tokenType: String = "rtc",
        channel: String,
        role: String = "publisher",
        uid: Int = 0,
        expire: Int = 3600
    ) {
        self.tokenType = tokenType
        self.channel = channel
        self.role = role
        self.uid = "\(uid)"
        self.expire = expire
    }
}

struct AgoraGetTokenResponse: Codable {
    let token: String
}

final class AgoraTokenService {
    
    func getToken(for channelName: String) async throws -> String {
        
        let requestBody = AgoraGetTokenRequestBody(channel: channelName)
        let requestBodyData = try JSONEncoder().encode(requestBody)
        
        // TODO: Change `localhost` to local IP address if testing on physical devices.
        var urlRequest = URLRequest(url: URL(string: "http://localhost:8080/getToken")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = requestBodyData
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(AgoraGetTokenResponse.self, from: data).token
    }
}
