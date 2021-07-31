struct Diff {
    let edits: [Edit]
    
    var averageSimilarity: Double {
        (similarity1 + similarity2) / 2
    }
    
    var maximumSimilarity: Double {
        max(similarity1, similarity2)
    }
    
    private var s1: String {
        var string = ""
        for edit in edits {
            switch edit {
            case .insertion(_, _): break
            case .deletion(_, let character):
                string.append(character)
            case .equal(_, _, let character):
                string.append(character)
            }
        }
        return string
    }
    
    private var s2: String {
        var string = ""
        for edit in edits {
            switch edit {
            case .insertion(_, let character):
                string.append(character)
            case .deletion(_, _): break
            case .equal(_, _, let character):
                string.append(character)
            }
        }
        return string
    }
    
    private var equalCount: Int {
        return edits.reduce(0) { partialResult, edit in
            switch edit {
            case .equal:
                return partialResult + 1
            default:
                return partialResult + 0
            }
        }
    }
    
    private var similarity1: Double {
        return Double(equalCount) / Double(s1.count)
    }
    
    private var similarity2: Double {
        return Double(equalCount) / Double(s2.count)
    }
}

extension Diff: CustomStringConvertible {
    var description: String {
        var description = ""
        for edit in edits {
            switch edit {
            case .insertion(let line, let character):
                description += "+   \(line) \(character)"
            case .deletion(let line, let character):
                description += "- \(line)   \(character)"
            case .equal(let oldLine, let newLine, let character):
                description += "  \(oldLine) \(newLine) \(character)"
            }
            description += "\n"
        }
        return String(description.dropLast())
    }
}
