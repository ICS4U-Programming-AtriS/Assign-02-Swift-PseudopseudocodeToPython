//
//  Compiler.swift
//
//  Created by Atri Sarker
//  Created on 2025-11-04
//  Version 1.0
//  Copyright (c) 2025 Atri Sarker. All rights reserved.
//
// Program that converts a .txt file with a pseudocode-like programming language
// into python code. The python code is written into a .py file.
// The language is called Pseudopseudocode.

import Foundation

// Helper function to get everything in a line after a keyword.
func getLineAfterKeyword(_ line: String, _ keyword: String) -> String {
    // .dropFirst(n) removes the first n characters from a string.
    return String(line.dropFirst(keyword.count))
}

// Pseudopseudocode to Python converter.
// Converts an array [list] of strings representing lines of Pseudopseudocode
// into a single string representing the equivalent python code.
// Added some flags to allow my linter to pass.
// swiftlint:disable:next cyclomatic_complexity function_body_length
func convertToPython(_ arr: [String]) -> String {
    // Indentation defined as 4 spaces
    let indent: String = "    "
    // Represents the current level of indentation
    var indentLevel: Int = 0
    // Represents the current line number
    var lineNum: Int = 0
    // String to store the generated code
    var code: String = ""
    // Loop through every line in the input array
    for line in arr {
        // Increment line number
        lineNum += 1
        // Remove leading whitespace. [This is really cool.]
        let trimmedLine = String(line.drop(while: { $0.isWhitespace }))
        // String to store the code of the current line
        var pythonLine = ""
        // Add indentation for the line
        code += String(repeating: indent, count: indentLevel)
        // MAP pseudopseudocode to python
        if trimmedLine.hasPrefix("FUNC ") {
            // FUNCTION DEFINITION
            let functionDefinition = getLineAfterKeyword(trimmedLine, "FUNC ")
            // FUNC funcName(params)  -->  def funcName(params):
            pythonLine = "def \(functionDefinition):"
            // Increment indentation level
            indentLevel += 1
        } else if trimmedLine == "ENDFUNC" {
            // FUNCTION CLOSE
            // Decrement indentation level
            indentLevel -= 1
        } else if trimmedLine.hasPrefix("RETURN") {
            // RETURN STATEMENT
            let returnValue = getLineAfterKeyword(trimmedLine, "RETURN")
            // RETURN value  -->  return value
            // RETURN --> return
            pythonLine = "return \(returnValue)"
        } else if trimmedLine.hasPrefix("IF ") {
            // IF STATEMENT
            let ifCondition = getLineAfterKeyword(trimmedLine, "IF ")
            // IF condition  -->  if (condition):
            pythonLine = "if (\(ifCondition)):"
            indentLevel += 1
        } else if trimmedLine == "ENDIF" {
            // IF STATEMENT CLOSE
            // Decrement indentation level
            indentLevel -= 1
        } else if trimmedLine.hasPrefix("WHILE ") {
            // WHILE LOOP STATEMENT
            let whileCondition = getLineAfterKeyword(trimmedLine, "WHILE ")
            // WHILE condition  -->  while (condition):
            pythonLine = "while (\(whileCondition)):"
            indentLevel += 1
        } else if trimmedLine == "ENDWHILE" {
            // WHILE LOOP CLOSE
            // Decrement indentation level
            indentLevel -= 1
        } else if trimmedLine.hasPrefix("SET ") {
            // ASSIGNMENT STATEMENT
            let assignment = getLineAfterKeyword(trimmedLine, "SET ")
            // SET var = value  -->  var = value
            pythonLine = assignment
        } else if trimmedLine.hasPrefix("PRINT ") {
            // PRINT STATEMENT
            let printArgument = getLineAfterKeyword(trimmedLine, "PRINT ")
            // PRINT value  -->  print(value, end="")
            pythonLine = "print(" + printArgument + ", end=\"\")"
        } else if trimmedLine.hasPrefix("GETSTRING ") {
            // STRING INPUT STATEMENT
            let varName = getLineAfterKeyword(trimmedLine, "GETSTRING ")
            // GETSTRING varName  -->  varName = input()
            pythonLine = "\(varName) = input()"
        } else if trimmedLine.hasPrefix("CASTASNUM ") {
            // TYPE CASTING TO NUMBER STATEMENT
            let varName = getLineAfterKeyword(trimmedLine, "CASTASNUM ")
            // CASTASNUM varName  -->  varName = float(varName)
            pythonLine = "\(varName) = float(\(varName))"
        } else if trimmedLine.hasPrefix("#") {
            // COMMENT
            // Comment lines are the same in both languages
            pythonLine = trimmedLine
        } else if trimmedLine.isEmpty {
            // EMPTY LINE
            pythonLine = trimmedLine
        } else {
            // UNRECOGNIZED LINE
            code = "ERROR: FAILED TO PROCESS LINE \(lineNum)"
        }
        // CHECK IF INDENTATION LEVEL IS VALID
        if indentLevel < 0 {
            break
        }
        // Add the converted line to the code string
        code += pythonLine
        // Add newline
        code += "\n"
    }
    // CHECK IF INDENTATION LEVEL IS BALANCED
    if indentLevel != 0 {
        // ERROR MESSAGE
        code = "ERROR: INDENTATION MISMATCH"
    }
    // Return the code
    return code
}

// Get all arguments
let arguments: [String] = CommandLine.arguments
// First argument is the path to the input file.
let inputFilePath: String = arguments[1]
// Second argument is the path to the output file
let outputFilePath: String = arguments[2]
// Print arguments
print("Input file: " + inputFilePath)
print("Output file: " + outputFilePath)
// Open input file
guard let inputFile = FileHandle(forReadingAtPath: inputFilePath) else {
    print("CANNOT OPEN "  + inputFilePath)
    exit(1)
}
// Open output file
guard let outputFile = FileHandle(forWritingAtPath: outputFilePath) else {
    print("CANNOT OPEN " + outputFilePath)
    exit(1)
}
// Read data from the input file and save it into an array [list]
let inputData = inputFile.readDataToEndOfFile()
guard let inputString = String(data: inputData, encoding: .utf8) else {
    print("CANNOT CONVERT " + inputFilePath + " DATA TO A STRING")
    exit(1)
}
// Split the input string into lines
let inputLines: [String] = inputString.components(separatedBy: .newlines)

// Convert to python code
let pythonCode: String = convertToPython(inputLines)
// Clear output file before writing
outputFile.truncateFile(atOffset: 0)
// Reset file pointer to the beginning
outputFile.seek(toFileOffset: 0)
// Write python code to output file
if let data = pythonCode.data(using: .utf8) {
    outputFile.write(data)
} else {
    print("Error: WRITING FAILED")
}
// Completion message
print("DONE!")
