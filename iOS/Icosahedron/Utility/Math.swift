import Foundation

infix operator ** { associativity left precedence 160 }
func ** (radix: Int, power: Int) -> Double { return pow(Double(radix), Double(power)) }
