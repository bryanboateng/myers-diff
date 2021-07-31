enum Edit {
    case insertion(line: Int, character: Character)
    case deletion(line: Int, character: Character)
    case equal(oldLine: Int, newLine: Int, character: Character)
}
