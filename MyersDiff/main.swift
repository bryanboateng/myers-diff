import Foundation

let a = "ABCABBA"
let b = "CBABAC"

print(diff: diff(a: a, b: b))
print(similarityScore(a: a, b: b))

struct Line {
    let number: Int
    let character: Character
}

enum Edit {
    case insertion(line: Int, character: Character)
    case deletion(line: Int, character: Character)
    case equal(oldLine: Int, newLine: Int, character: Character)
}

struct BacktrackStep {
    let (prevX, prevY): (Int, Int)
    let (x, y): (Int, Int)
}

func similarityScore(a: String, b: String) -> (Double, Double, Double) {
    let diff = diff(a: a, b: b)
    
    let ne: Double = diff.reduce(0) { partialResult, edit in
        switch edit {
        case .equal:
            return partialResult + 1
        default:
            return partialResult + 0
        }
    }
    
    return (ne / Double(a.count), ne / Double(b.count), ((ne / Double(a.count)) + (ne / Double(b.count)))/2)
}

func print(diff: [Edit]) {
    for edit in diff {
        switch edit {
        case .insertion(let line, let character):
            print("+   \(line) \(character)")
        case .deletion(let line, let character):
            print("- \(line)   \(character)")
        case .equal(let oldLine, let newLine, let character):
            print("  \(oldLine) \(newLine) \(character)")
        }
    }
}

func diff(a: String, b: String) -> [Edit] {
    
    var aLines = [Line]()
    for aEnumeratedElement in a.enumerated() {
        aLines.append(Line(number: aEnumeratedElement.offset + 1, character: aEnumeratedElement.element))
    }
    
    var bLines = [Line]()
    for bEnumeratedElement in b.enumerated() {
        bLines.append(Line(number: bEnumeratedElement.offset + 1, character: bEnumeratedElement.element))
    }
    
    let backtrack = backtrack (
        a: aLines.map { line in line.character },
        b: bLines.map { line in line.character }
    )
    
    var diff = [Edit]()
    
    for backtrackStep in backtrack {
        let a_line = backtrackStep.prevX != a.count ? aLines[backtrackStep.prevX] : nil
        let b_line = backtrackStep.prevY != b.count ? bLines[backtrackStep.prevY] : nil
        
        if backtrackStep.x == backtrackStep.prevX {
            diff.insert(.insertion(line: b_line!.number, character: b_line!.character), at: 0)
        } else if backtrackStep.y == backtrackStep.prevY {
            diff.insert(.deletion(line: a_line!.number, character: a_line!.character), at: 0)
        } else {
            diff.insert(.equal(oldLine: a_line!.number, newLine: b_line!.number, character: a_line!.character), at: 0)
        }
    }
    
    return diff
}

private func backtrack(a: [Character], b: [Character]) -> [BacktrackStep] {
    let shortestEdit = shortestEdit(a: a, b: b)
    
    var x = a.count
    var y = b.count
    
    var backtrack = [BacktrackStep]()
    
    for enumeratedEditStep in shortestEdit.enumerated().reversed() {
        let k = x - y
        let d = enumeratedEditStep.offset
        let v = enumeratedEditStep.element
        
        var prev_k: Int
        if k == -d || (k != d && v[k - 1]! < v[k + 1]!) {
            prev_k = k + 1
        } else {
            prev_k = k - 1
        }
        
        let prev_x = v[prev_k]!
        let prev_y = prev_x - prev_k
        
        while x > prev_x && y > prev_y {
            backtrack.append(BacktrackStep(prevX: x - 1, prevY: y - 1, x: x, y: y))
            
            x = x - 1
            y = y - 1
        }
        if d > 0 {
            backtrack.append(BacktrackStep(prevX: prev_x, prevY: prev_y, x: x, y: y))
            
            x = prev_x
            y = prev_y
        }
    }
    return backtrack
}

private func shortestEdit(a: [Character], b: [Character]) -> [[Int: Int]] {
    let n = a.count
    let m = b.count
    let max = n + m
    
    var v = [Int: Int]()
    v[1] = 0
    var trace = [[Int: Int]]()
    trace.append(v)
    
    var x = 0
    var y = 0
    while x < n && y < m && a[x] == b[y] {
        x += 1
        y += 1
    }
    v[0] = x
    
    if x >= n && y >= m {
        return trace
    }
    
    
    for d in 1...max {
        trace.append(v)
        for k in stride(from: -d, through: d, by: 2) {
            var x: Int
            if k == -d || (k != d && v[k - 1]! < v[k + 1]!) {
                x = v[k + 1]!
            } else {
                x = v[k - 1]! + 1
            }
            var y = x - k
            
            while x < n && y < m && a[x] == b[y] {
                x += 1
                y += 1
            }
            
            v[k] = x
            
            if x >= n && y >= m {
                return trace
            }
        }
    }
    return trace
}
