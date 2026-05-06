/*
Copyright (c) 2026 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import MdocDataModel18013
import MdocDataTransfer18013
import struct WalletStorage.Document

/// [Doc Types to [Namespace to Items]] dictionary
public typealias RequestItems = MdocDataTransfer18013.RequestItems

/// Presentation service abstract protocol

public protocol PresentationService: Sendable {
	/// Status of the data transfer
	//var status: TransferStatus { get }
	/// instance of a presentation ``FlowType``
	var flow: FlowType { get }
	/// Generate a QR code to be shown to verifier (optional)
	func startQrEngagement(secureAreaName: String?, crv: CoseEcCurve) async throws -> String
	/// Receive request.
	func receiveRequest() async throws -> UserRequestInfo

	var transactionLog: TransactionLog { get }
	
	var  zkpDocumentIds: [Document.ID]? { get }

	/// Send response to verifier (without extra KB-JWT claims).
	func sendResponse(userAccepted: Bool, itemsToSend: RequestItems, onSuccess: (@Sendable (URL?) -> Void)?) async throws
	/// Send response to verifier with optional extra KB-JWT claims for PaSO SCA conformance.
	func sendResponse(userAccepted: Bool, itemsToSend: RequestItems, additionalKBJWTClaims: [String: Any]?, onSuccess: (@Sendable (URL?) -> Void)?) async throws

	/// wait for disconnect
	func waitForDisconnect() async throws
}

public extension PresentationService {
	/// Default for services without KB-JWT injection (BLE, fault): ignores extra claims.
	func sendResponse(userAccepted: Bool, itemsToSend: RequestItems, additionalKBJWTClaims: [String: Any]?, onSuccess: (@Sendable (URL?) -> Void)?) async throws {
		try await sendResponse(userAccepted: userAccepted, itemsToSend: itemsToSend, onSuccess: onSuccess)
	}
	/// Default for services that only implement the claims-bearing overload: forwards with nil.
	func sendResponse(userAccepted: Bool, itemsToSend: RequestItems, onSuccess: (@Sendable (URL?) -> Void)?) async throws {
		try await sendResponse(userAccepted: userAccepted, itemsToSend: itemsToSend, additionalKBJWTClaims: nil, onSuccess: onSuccess)
	}
}

public protocol NetworkingProtocol: Sendable {
	func data(from url: URL) async throws -> (Data, URLResponse)
	func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkingProtocol {}
