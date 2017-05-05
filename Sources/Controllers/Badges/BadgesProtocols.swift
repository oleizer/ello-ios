////
///  BadgesProtocols.swift
//

protocol BadgesScreenProtocol: StreamableScreenProtocol {
    var delegate: BadgesScreenDelegate? { get set }
}

protocol BadgesScreenDelegate: class {
}
