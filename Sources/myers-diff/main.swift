import Foundation

let a = "ABCABBA"
let b = "CBABAC"

let diff = MyersDiffAlgorithm.diff(between: a, and: b)
print(diff)
print("Average similarity: \(diff.averageSimilarity)")
print("Maximum similarity: \(diff.maximumSimilarity)")
