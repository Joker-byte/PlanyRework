import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        observeThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        updateUIForTheme()
    }
    
    deinit {
        removeThemeObserver()
    }
}
