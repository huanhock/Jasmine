import UIKit

/// Main view controller for Tetris

class TetrisViewController: UIViewController {

    @IBOutlet private var gridCollectionView: UICollectionView!
    @IBOutlet private var upcomingCollectionView: UICollectionView!

    // initialize in viewDidLoad
    fileprivate var gridView: TetrisGridView!
    private var engine: TetrisEngineProtocol!
    fileprivate var cellSize: CGFloat!

    fileprivate var movingTileView: TetrisView?

    override func viewDidLoad() {
        super.viewDidLoad()

        gridCollectionView.dataSource = self
        gridCollectionView.delegate = self
        gridView = TetrisGridView(gridCollectionView)

        setupTapGesture()
    }

    // Engine is initialized here as updates to UICollectionViewCell is only possible after this
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        engine = TetrisEngine(viewDelegate: self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func tapHandler(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: gridCollectionView)
        if let indexPath = gridCollectionView.indexPathForItem(at: location) {
            engine.moveTile(towards: indexPath)
        }
    }

}

/// MARK: - TetrisViewDelegate
extension TetrisViewController: TetrisViewDelegate {

    func updateMovingTile(_ movingTile: TetrisTile) {
        let currentMovingTileView = movingTileView ?? TetrisView(movingTile.word, size: cellSize)
        currentMovingTileView.removeFromSuperview()
        currentMovingTileView.text = String(movingTile.word)
        gridView.addToCell(currentMovingTileView, at: movingTile.indexPath)
        movingTileView = currentMovingTileView
    }

    /// Settle the moving tile on the grid after it has collided.
    /// Since it's already set to the correct position by updateMovingTile, 
    /// we simply remove the reference to it here so that a new moving tile view will be created
    func placeMovingTile() {
        movingTileView = nil
    }

    func destroyTile(at indexPath: IndexPath) {
        gridView.clearCell(at: indexPath)
    }

    func shiftTileDown(at indexPath: IndexPath) {
        gridView.shiftViewDown(at: indexPath)
    }

}

/// MARK: - UICollectionViewDataSource
extension TetrisViewController: UICollectionViewDataSource {

    // every section comprises a row of tiles,
    // while the column index of the tile is given by IndexPath.row
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Constants.Tetris.columns
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.Tetris.rows
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.Tetris.cellIdentifier, for: indexPath)

        // todo: remove these temp code (for visualization only)
        cell.layer.borderWidth = 1.0
        let label = UILabel()
        label.frame.size = CGSize(width: cell.frame.width, height: cell.frame.height / 3)
        label.text = "r:" + String(indexPath.row) + " s:" + String(indexPath.section)
        label.font = label.font.withSize(12)
        cell.contentView.addSubview(label)

        return cell
    }

}

/// MARK: - UICollectionViewDelegateFlowLayout
extension TetrisViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize = collectionView.frame.width / CGFloat(Constants.Tetris.columns)
        return CGSize(width: cellSize, height: cellSize)
    }

}
