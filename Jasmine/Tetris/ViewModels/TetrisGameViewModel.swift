import Foundation

/// The main view model for Tetris game
class TetrisGameViewModel {

    weak var delegate: TetrisGameViewControllerDelegate?

    fileprivate var tetrisGrid = TetrisGrid()

    var upcomingTiles: [String] = []
    fileprivate var fallingTileText: String?

    var currentScore: Int = 0

    let countDownTimer = CountDownTimer(totalTimeAllowed: Constants.Tetris.totalTime)

    /// Populate upcomingTiles
    init() {
        for _ in 0..<Constants.Tetris.upcomingTilesCount {
            upcomingTiles.append(getRandomWord())
        }
    }

    /// Checks for and returns coordinates of matching phrase, searching by row-wise and return if found
    /// otherwise continue with searching by column-wise
    fileprivate func checkForMatchingPhrase() -> Set<Coordinate>? {
        if let matchedCoordinates = checkForMatchingPhrase(searchByRow: true) {
            return matchedCoordinates
        } else {
            return checkForMatchingPhrase(searchByRow: false)
        }
    }

    /// Checks for and returns coordinates of matching phrase, search row/col-wise as specify by searchbyRow
    /// Concatenate the words row by row or col by col to check if a phrase is contained in them
    private func checkForMatchingPhrase(searchByRow: Bool) -> Set<Coordinate>? {
        var matchedCoordinates: Set<Coordinate> = []
        let maxIndex = searchByRow ? Constants.Tetris.rows : Constants.Tetris.columns
        for index in 0..<maxIndex {
            var line = ""
            if searchByRow {
                for col in 0..<Constants.Tetris.columns {
                    line += getTileText(row: index, col: col)
                }
            } else {
                for row in 0..<Constants.Tetris.rows {
                    line += getTileText(row: row, col: index)
                }
            }

            guard let validPhraseRange = getValidPhraseRange(line) else {
                continue
            }

            for i in validPhraseRange {
                let coordinate = searchByRow ? Coordinate(row: index, col: i) : Coordinate(row: i, col: index)
                matchedCoordinates.insert(coordinate)
            }
            return matchedCoordinates
        }
        return nil
    }

    /// Gets the tile text at coordinate specified by `row` and `col`
    /// returns " " if no tile is present so that phrases separated by gaps don't get matched
    private func getTileText(row: Int, col: Int) -> String {
        return tetrisGrid.get(at: Coordinate(row: row, col: col)) ?? " "
    }

    /// Shifts all the tiles above `coordinates` 1 row down.
    /// Starts from the row right above the coordinates so that it can break once an empty tile is encountered
    fileprivate func shiftDownTiles(_ coordinates: Set<Coordinate>) {
        var coordinatesToShift: [(from: Coordinate, to: Coordinate)] = []
        for coordinate in coordinates {
            for row in (0..<coordinate.row).reversed() {
                let currentCoordinate = Coordinate(row: row, col: coordinate.col)
                guard let text = tetrisGrid.remove(at: currentCoordinate) else {
                    break
                }
                let newCoordinate = currentCoordinate.getNextRow()
                tetrisGrid.add(at: newCoordinate, tileText: text)
                coordinatesToShift.append((from: currentCoordinate, to: newCoordinate))
            }
        }
        delegate?.animate(shiftTiles: coordinatesToShift)
    }

    // TODO: fetch from database to match valid phrase
    private func getValidPhraseRange(_ line: String) -> CountableRange<Int>? {
        let phrases = ["先发制人"]
        for phrase in phrases {
            let phraseLen = phrase.characters.count
            for i in 0...line.characters.count - phraseLen {
                let startIndex = line.index(line.startIndex, offsetBy: i)
                if line[startIndex..<line.index(startIndex, offsetBy: phraseLen)] == phrase {
                    return i..<i + phraseLen
                }
            }
        }
        return nil
    }

    // TODO: generate from database, base on existing grid
    fileprivate func getRandomWord() -> String {
        let words = "先发制人"
        return String(words[words.index(words.startIndex,
                                        offsetBy: Random.integer(toInclusive: UInt(words.characters.count)))])
    }
}

extension TetrisGameViewModel: TetrisGameViewModelProtocol {

    func shiftFallingTile(to coordinate: Coordinate) -> Bool {
        return !tetrisGrid.hasTile(at: coordinate)
    }

    func dropNextTile() -> (location: Coordinate, tileText: String) {
        upcomingTiles.append(getRandomWord())
        let tileText = upcomingTiles.removeFirst()
        delegate?.redisplayUpcomingTiles()
        fallingTileText = tileText
        let randCol = Random.integer(toInclusive: UInt(Constants.Tetris.columns))
        return (location: Coordinate(row: Coordinate.origin.row, col: randCol),
                tileText: tileText)
    }

    func landFallingTile(at coordinate: Coordinate) {
        guard let fallingTileText = fallingTileText else {
            assertionFailure("No falling tile")
            return
        }
        tetrisGrid.add(at: coordinate, tileText: fallingTileText)

        guard let destroyedCoordinates = checkForMatchingPhrase() else {
            return
        }
        tetrisGrid.remove(at: destroyedCoordinates)
        delegate?.animate(destroyTilesAt: destroyedCoordinates)

        currentScore += destroyedCoordinates.count
        delegate?.redisplay(newScore: currentScore)

        shiftDownTiles(destroyedCoordinates)
    }

    func swapCurrentTileWithUpcomingTile(at index: Int) {
        guard let currentFallingTileText = fallingTileText else {
            assertionFailure("No falling tile")
            return
        }
        fallingTileText = upcomingTiles[index]
        upcomingTiles[index] = currentFallingTileText
    }

    func startGame() {
        countDownTimer.startTimer(timerInterval: Constants.Tetris.timeInterval, viewControllerDelegate: delegate)
    }
}
