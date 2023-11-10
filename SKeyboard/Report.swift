import Foundation

/// 
/// - Parameter reportString: 01 02 03 04 05 06 07 08
/// - Returns: Data from report string where each component is UInt8 value
func reportStringToData(_ reportString: String) -> Data {
    let reportStringComponents = reportString.components(separatedBy: " ")
    let reportData = Data(reportStringComponents.compactMap { UInt8($0, radix: 16) })
    return reportData
}

