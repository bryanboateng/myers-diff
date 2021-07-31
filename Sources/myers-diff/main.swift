import ArgumentParser

struct MyersDiff: ParsableCommand {
    @Argument(help: "A string to compare.")
    var s1: String
    
    @Argument(help: "Another string to compare.")
    var s2: String
    
    func run() throws {
        let diff = diff
        print(diff)
        print("Average similarity: \(diff.averageSimilarity)")
        print("Maximum similarity: \(diff.maximumSimilarity)")
    }
    
    private var diff: Diff {
        let s1Lines: [Line] = {
            var lines =  [Line]()
            for enumeratedCharacter in s1.enumerated() {
                lines.append(Line(number: enumeratedCharacter.offset + 1, character: enumeratedCharacter.element))
            }
            return lines
        }()
        
        let s2Lines: [Line] = {
            var lines =  [Line]()
            for enumeratedCharacter in s2.enumerated() {
                lines.append(Line(number: enumeratedCharacter.offset + 1, character: enumeratedCharacter.element))
            }
            return lines
        }()
        
        let backtrack = backtrack (
            between: s1Lines.map { line in line.character },
            and: s2Lines.map { line in line.character }
        )
        
        var edits = [Edit]()
        
        for backtrackStep in backtrack {
            let s1Line = backtrackStep.prevX != s1.count ? s1Lines[backtrackStep.prevX] : nil
            let s2Line = backtrackStep.prevY != s2.count ? s2Lines[backtrackStep.prevY] : nil
            
            if backtrackStep.x == backtrackStep.prevX {
                edits.insert(.insertion(line: s2Line!.number, character: s2Line!.character), at: 0)
            } else if backtrackStep.y == backtrackStep.prevY {
                edits.insert(.deletion(line: s1Line!.number, character: s1Line!.character), at: 0)
            } else {
                edits.insert(.equal(oldLine: s1Line!.number, newLine: s2Line!.number, character: s1Line!.character), at: 0)
            }
        }
        
        return Diff(edits: edits)
    }
    
    private func backtrack(between s1: [Character], and s2: [Character]) -> [BacktrackStep] {
        let shortestEdit = shortestEdit(between: s1, and: s2)
        
        var x = s1.count
        var y = s2.count
        
        var backtrack = [BacktrackStep]()
        
        for enumeratedEditStep in shortestEdit.enumerated().reversed() {
            let k = x - y
            let d = enumeratedEditStep.offset
            let v = enumeratedEditStep.element
            
            var prevK: Int
            if k == -d || (k != d && v[k - 1]! < v[k + 1]!) {
                prevK = k + 1
            } else {
                prevK = k - 1
            }
            
            let prevX = v[prevK]!
            let prevY = prevX - prevK
            
            while x > prevX && y > prevY {
                backtrack.append(BacktrackStep(prevX: x - 1, prevY: y - 1, x: x, y: y))
                
                x = x - 1
                y = y - 1
            }
            if d > 0 {
                backtrack.append(BacktrackStep(prevX: prevX, prevY: prevY, x: x, y: y))
                
                x = prevX
                y = prevY
            }
        }
        return backtrack
    }
    
    private func shortestEdit(between s1: [Character], and s2: [Character]) -> [[Int: Int]] {
        let n = s1.count
        let m = s2.count
        let max = n + m
        
        var v = [Int: Int]()
        v[1] = 0
        var trace = [[Int: Int]]()
        trace.append(v)
        
        var x = 0
        var y = 0
        while x < n && y < m && s1[x] == s2[y] {
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
                
                while x < n && y < m && s1[x] == s2[y] {
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
}

MyersDiff.main()
