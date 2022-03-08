//
//  Closures.swift
//  Narrative Nurse
//
//  Created by Slavik Voloshyn
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation

public typealias Identifier = String

public typealias VoidClosure = () -> Void
public typealias OptionalVoidClosure = VoidClosure?
public typealias IntClosure = ((Int) -> Void)
public typealias IdentifierClosure = ((Identifier) -> Void)
public typealias IdentifiersClosure = (([Identifier]) -> Void)
public typealias BoolClosure = (Bool) -> Void
public typealias StringClosure = (String) -> Void
public typealias OptionalStringClosure = (String?) -> Void
public typealias URLClosure = (URL) -> Void
public typealias FileTypeClosure = (SequenceFileType) -> Void
public typealias OptionalURLClosure = (URL?) -> Void
public typealias OptionsClosure = (([Option]) -> Void)
public typealias Closure<Result> = ((Result) -> Void)
