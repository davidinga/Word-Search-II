/*
Given an m x n board of characters and a list of strings words, return all words on the board.

Each word must be constructed from letters of sequentially adjacent cells, where adjacent cells are horizontally or vertically neighboring. The same letter cell may not be used more than once in a word.

Example 1:

Input: board = [["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],["i","f","l","v"]], words = ["oath","pea","eat","rain"]
Output: ["eat","oath"]

Example 2:

Input: board = [["a","b"],["c","d"]], words = ["abcb"]
Output: []

Constraints:

m == board.length
n == board[i].length
1 <= m, n <= 12
board[i][j] is a lowercase English letter.
1 <= words.length <= 3 * 104
1 <= words[i].length <= 10
words[i] consists of lowercase English letters.
All the strings of words are unique.
*/

class TrieNode {
    let value: Character
    var children: [Character: TrieNode]
    var refs = 0
    var isLast = false

    init(_ value: Character = "*") {
        self.value = value
        self.children = [:]
    }

    func insert(_ word: String) {
        var curr = self
        for character in word {
            if curr.children[character] == nil {
                curr.children[character] = TrieNode(character)
            }
            curr = curr.children[character]!
            curr.refs += 1
        }
        curr.isLast = true
    }

    func remove(_ word: String) {
        var curr = self
        for character in word {
            curr = curr.children[character]!
            curr.refs -= 1
        }
    }
}

func findWords(_ board: [[Character]], _ words: [String]) -> [String] {
    var result: [String] = []
    var trie = TrieNode()
    var visited: Set<[Int]> = []
    var word = ""
    var wordsToFind = Set(words)

    for word in words {
        trie.insert(word)
    }

    func getNeighbors(_ root: [Int]) -> [[Int]] {
        var neighbors: [[Int]] = []
        let rowOffset = [-1, 0, 1, 0]
        let colOffset = [0, 1, 0, -1]
        for i in 0..<4 {
            let row = root[0] + rowOffset[i]
            let col = root[1] + colOffset[i]
            if row < 0 || row >= board.count || col < 0 || col >= board[0].count {
                continue
            }
            neighbors.append([row, col])
        }
        return neighbors
    }

    func dfs(_ root: [Int], _ search: TrieNode, _ word: inout String) -> Bool {
        guard wordsToFind.count > 0 else { return true }
        guard search.refs > 0 else { return false }
        guard !visited.contains(root) else { return false }
        guard board[root[0]][root[1]] == search.value else { return false }

        word.append(search.value)
        visited.insert(root)

        if search.isLast, wordsToFind.contains(word) {
            result.append(word)
            wordsToFind.remove(word)
            trie.remove(word)
        }

        for neighbor in getNeighbors(root) {
            if let trie = search.children[board[neighbor[0]][neighbor[1]]] {
                if dfs(neighbor, trie, &word) { return true }
            }
        }

        word.removeLast()
        visited.remove(root)

        return false
    }

    outerLoop: for row in board.indices {
        for col in board[0].indices {
            if let trie = trie.children[board[row][col]]{
                if dfs([row, col], trie, &word) { break outerLoop }
            }
        }
    }

    return result
}