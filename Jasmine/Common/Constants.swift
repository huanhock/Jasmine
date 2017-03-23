import ChameleonFramework
import Foundation

enum Constants {
    enum Grid {
        static let rows = 4
        static let columns = 4
        static let time: TimeInterval = 60
    }

    enum Tetris {
        /// Number of rows on the grid
        static let rows = 12
        /// Number of cols on the grid
        static let columns = 8

        /// Total time allowed
        static let totalTime: TimeInterval = 120
        /// Interval to update the time
        static let timeInterval: TimeInterval = 1

        static let upcomingTilesCount = 3

        /// Reuse identifier for the cell
        /// can be shifted to custom UICollectionViewCell class when created
        static let cellIdentifier = "tetrisCell"
    }

    enum Theme {
        static let mainColor = FlatMint()
        static let mainColorDark = FlatMintDark()

        static let mainWhiteColor = FlatWhite()
        static let mainFontColor = FlatBlack()

        static let tilesFont = UIFont(name: "HelveticaNeue-Light", size: 30.0)
    }

    enum Language: String {
        case english = "eng"
        case chinese = "cmn"
    }

    enum UserDefaultsKeys: String {
        case launchedBefore
    }

}
