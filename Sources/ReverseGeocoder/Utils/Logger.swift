//
//  Logger.swift
//  ReverseGeocoder
//
//  Created by Thibaud David on 03/10/2024.
//


public typealias Logger = (_ caller: Any?, LogLevel, String) -> Void
public enum LogLevel {
    case error, debug
}
